//
//  AdvertisementWebLinkCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/11/21.
//

import UIKit

protocol AdvertisementWebLinkCollectionViewCellDelegate: AnyObject {
    func AdvertisementDidTapLink(_ cell: AdvertisementWebLinkCollectionViewCell, link: String)
}

class AdvertisementWebLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "AdvertisementWebLink"
    
    public weak var delegate: AdvertisementWebLinkCollectionViewCellDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private var link = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapLink), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let buttonWidth: CGFloat = 250
        button.frame = CGRect(x: (contentView.width - buttonWidth)/2, y: 0, width: buttonWidth, height: 25)
    }
    
    public func configure(with viewModel: AdvertisementWebLinkViewModel) {
        button.setTitle(viewModel.linkTitle, for: .normal)
        self.link = viewModel.link
    }
    
    @objc func didTapLink() {
        delegate?.AdvertisementDidTapLink(self, link: self.link)
    }
    
    
}
