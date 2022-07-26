//
//  NoResultsTableViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/28/22.
//

import UIKit

class NoResultsTableViewCell: UITableViewCell {

    static let identifier = "NoResultsTableViewCell"
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "NO RESULTS"
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(noResultsLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        noResultsLabel.frame = CGRect(x: 5, y: (contentView.height - 25)/2, width: contentView.width - 10, height: 25)
    }
}
