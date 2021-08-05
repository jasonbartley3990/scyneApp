//
//  SpotAddressCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

class SpotAddressCollectionViewCell: UICollectionViewCell {
    static let identifier = "SpotAddressCollectionViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .label
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: contentView.width-20, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: SpotAddressCollectionViewCellViewModel) {
        label.text = "\(viewModel.address)\n\n"
    }
    
}
