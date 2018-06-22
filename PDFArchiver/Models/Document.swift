//
//  Document.swift
//  PDF Archiver
//
//  Created by Julian Kahnert on 25.01.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import Foundation
import os.log

class Document: NSObject {
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Document")
    weak var delegate: TagsDelegate?
    // structure for PDF documents on disk
    var path: URL
    @objc var name: String?
    @objc var documentDone: String = ""
    var documentDate = Date()
    var documentDescription: String? {
        didSet {
            if let raw = self.documentDescription {
                self.documentDescription = raw.lowercased()
            }
        }
    }
    var documentTags: [Tag]?

    init(path: URL, delegate: TagsDelegate?) {
        self.path = path
        self.delegate = delegate

        // create a filename and rename the document
        self.name = String(path.lastPathComponent)

        // try to parse the current filename
        let parser = DateParser()
        if let date = parser.parse(self.name!) {
            self.documentDate = date
        }

        // parse the description or use the filename
        if var raw = regex_matches(for: "--[\\w\\d-]+__", in: self.name!) {
            self.documentDescription = getSubstring(raw[0], startIdx: 2, endIdx: -2)
        } else {
            let newDescription = String(path.lastPathComponent.dropLast(4))
            self.documentDescription = newDescription.components(separatedBy: "__")[0]
        }

        // parse the tags
        if var raw = regex_matches(for: "__[\\w\\d_]+.[pdfPDF]{3}$", in: self.name!) {
            // parse the tags of a document
            let documentTagNames = getSubstring(raw[0], startIdx: 2, endIdx: -4).components(separatedBy: "_")
            // get the available tags of the archive
            var availableTags = self.delegate?.getTagList() ?? []

            self.documentTags = [Tag]()
            for documentTagName in documentTagNames {
                if availableTags.contains(where: { $0.name == documentTagName }) {
                    os_log("Tag already found in archive tags.", log: self.log, type: .debug)
                    for availableTag in availableTags where availableTag.name == documentTagName {
                        availableTag.count += 1
                        self.documentTags!.append(availableTag)
                        break
                    }
                } else {
                    os_log("Tag not found in archive tags.", log: self.log, type: .debug)
                    let newTag = Tag(name: documentTagName, count: 1)
                    availableTags.insert(newTag)
                    self.documentTags!.append(newTag)
                }
            }

            // update the tag list
            self.delegate?.setTagList(tagList: availableTags)
        }
    }

    func rename(archivePath: URL) -> Bool {
        let newBasePath: URL
        let filename: String
        do {
            (newBasePath, filename) = try getRenamingPath(archivePath: archivePath)
        } catch {
            return false
        }

        // check, if this path already exists ... create it
        let newFilepath = newBasePath.appendingPathComponent(filename)
        let fileManager = FileManager.default
        do {
            if !(newBasePath.hasDirectoryPath) {
                try fileManager.createDirectory(at: newBasePath,
                                                withIntermediateDirectories: false, attributes: nil)
            }

            // test if the document name already exists in archive, otherwise move it
            if fileManager.fileExists(atPath: newFilepath.path),
               self.path != newFilepath {
                os_log("File already exists!", log: self.log, type: .error)
                dialogOK(messageKey: "renaming_failed", infoKey: "file_already_exists", style: .warning)
                return false
            } else {
                try fileManager.moveItem(at: self.path, to: newFilepath)
            }
        } catch let error as NSError {
            os_log("Error while moving file: %@", log: self.log, type: .error, error.description)
            dialogOK(messageKey: "renaming_failed", infoKey: error.localizedDescription, style: .warning)
            return false
        }
        self.name = String(newFilepath.lastPathComponent)
        self.path = newFilepath
        self.documentDone = "✔️"

        do {
            var tags = [String]()
            for tag in self.documentTags ?? [] {
                tags += [tag.name]
            }

            // set file tags [https://stackoverflow.com/a/47340666]
            try (newFilepath as NSURL).setResourceValue(tags, forKey: URLResourceKey.tagNamesKey)
        } catch let error as NSError {
            os_log("Could not set file: %@", log: self.log, type: .error, error.description)
        }
        return true
    }

    fileprivate func getRenamingPath(archivePath: URL) throws -> (new_basepath: URL, filename: String) {
        // create a filename and rename the document
        guard let tags = self.documentTags,
              tags.count > 0 else {
            dialogOK(messageKey: "renaming_failed", infoKey: "check_document_tags", style: .warning)
            throw DocumentError.tags
        }
        guard let description = self.documentDescription,
              description != "" else {
            dialogOK(messageKey: "renaming_failed", infoKey: "check_document_description", style: .warning)
            throw DocumentError.description
        }

        // get formatted date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: self.documentDate)

        // get tags
        var tagStr = ""
        for tag in tags.sorted(by: { $0.name < $1.name }) {
            tagStr += "\(tag.name)_"
        }
        tagStr = String(tagStr.dropLast(1))

        // create new filepath
        let filename = "\(dateStr)--\(description)__\(tagStr).pdf"
        let newBasepath = archivePath.appendingPathComponent(String(dateStr.prefix(4)))

        return (newBasepath, filename)
    }

    // MARK: - Other Stuff
    override var description: String {
        return "<Document \(self.self.name ?? "")>"
    }
}

enum DocumentError: Error {
    case description
    case tags
}
