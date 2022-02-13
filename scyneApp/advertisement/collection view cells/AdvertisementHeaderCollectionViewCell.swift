//
//  AdvertisementHeaderCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/10/21.
//

import UIKit

protocol AdvertisementHeaderDelegate: AnyObject {
    func advertisementheaderDidTapMore(_ cell: AdvertisementHeaderCollectionViewCell, link: String)
}

class AdvertisementHeaderCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "advertismentheaderCollectionViewCell"
    
    public weak var delegate: AdvertisementHeaderDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var link: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(companyLabel)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        companyLabel.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height-(imagePadding * 2)
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        companyLabel.sizeToFit()
        companyLabel.frame = CGRect(x: imageView.right+10, y: 0, width: companyLabel.width, height: contentView.height)
        
        moreButton.frame = CGRect(x: contentView.width-60, y: (contentView.height-50)/2, width: 50, height: 50)
        
    }
    
    public func configure(with viewModel: advertisementHeaderViewModel) {
        companyLabel.text = viewModel.company
        self.link = viewModel.link
        let url = URL(string: viewModel.photoUrl)
        imageView.sd_setImage(with: url, completed: nil)
        
    }
    
    @objc func didTapMore() {
        guard let link = self.link else {return}
        delegate?.advertisementheaderDidTapMore(self, link: link)
    }
}
