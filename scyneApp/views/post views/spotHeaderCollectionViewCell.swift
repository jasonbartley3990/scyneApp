//
//  spotHeaderCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import SDWebImage

protocol SpotHeaderCollectionViewDelegate: AnyObject {
    func SpotHeaderCollectionViewDelegateDidTapMore(_ cell: SpotHeaderCollectionViewCell, post: Post)
}

class SpotHeaderCollectionViewCell: UICollectionViewCell {
    static let identifier = "SpotHeaderCollectionViewCell"
    
    public weak var delegate: SpotHeaderCollectionViewDelegate?
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "scyneEarth")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let scyneTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private var isSaved = false
    
    private var post: Post?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(scyneTitle)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        scyneTitle.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
      
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding*2)
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = (imageSize/2)
        
        scyneTitle.sizeToFit()
        scyneTitle.frame = CGRect(x: imageView.right+10, y:0, width: scyneTitle.width, height: contentView.height)
        moreButton.frame = CGRect(x: contentView.width-60, y: (contentView.height-50)/2, width: 50, height: 50)
    }
      
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: SpotHeaderCollectionViewCellModel) {
        scyneTitle.text = viewModel.title
        
        self.isSaved = viewModel.isSaved
        self.post = viewModel.post
        
    }
    
    @objc func didTapMore() {
        guard let post = self.post else {
            print("returned")
            return}
        delegate?.SpotHeaderCollectionViewDelegateDidTapMore(self, post: post)
    }
    
    
    
        
    
    
}

