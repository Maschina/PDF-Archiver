//
//  Archive.swift
//  PDFArchiveViewer
//
//  Created by Julian Kahnert on 22.08.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import Foundation

struct Archive {

    private var allDocuments = [Document]()
    var availableTags = Set<Tag>()
    var sections = [TableSection<String, Document>]()

    lazy var years: [String] = {
        var years = Set<String>()
        for document in allDocuments {
            years.insert(document.folder)
        }
        return Array(years.sorted().reversed().prefix(3))
    }()

    init() {
        sections = TableSection.group(rowItems: allDocuments) { (document) in
            let calender = Calendar.current
            return String(calender.component(.year, from: document.date))
        }.reversed()
    }

    mutating func setAllDocuments(_ documents: [Document]) {
        allDocuments = documents
    }

    mutating func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        // filter documents
        let filteredDocuments = allDocuments.filter {( document: Document) -> Bool in
            let doesCategoryMatch = (scope == "All") || (document.folder == scope)

            if searchText.isEmpty {
                return doesCategoryMatch
            } else {
                // TODO: maybe also search in tags/date
                return doesCategoryMatch && document.specification.lowercased().contains(searchText.lowercased())
            }
        }

        // create table sections
        sections = TableSection.group(rowItems: filteredDocuments) { (document) in
            let calender = Calendar.current
            return String(calender.component(.year, from: document.date))
        }.reversed()
    }
}

struct YearSection: Comparable {
    static func < (lhs: YearSection, rhs: YearSection) -> Bool {
        return lhs.year < rhs.year
    }

    var year: Date
    var headlines: [Document]

}