//
//  DocumentTableViewCell.swift
//  PDFArchiveViewer
//
//  Created by Julian Kahnert on 12.09.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    @IBOutlet weak var tileLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var document: Document?

    override func layoutSubviews() {
        super.layoutSubviews()
        if let document = document {
            tileLabel.text = document.specification.replacingOccurrences(of: "-", with: " ")
            dateLabel.text = DateFormatter.localizedString(from: document.date, dateStyle: .medium, timeStyle: .none)
            tagLabel.text = document.tags.map { String($0.name) }.joined(separator: " ")

            switch document.downloadStatus {
            case .local:
                downloadImageView.isHidden = true
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
            case .iCloudDrive:
                downloadImageView.isHidden = false
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
            case .downloading:
                downloadImageView.isHidden = true
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        downloadImageView.isHidden = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.activityIndicatorViewStyle = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}