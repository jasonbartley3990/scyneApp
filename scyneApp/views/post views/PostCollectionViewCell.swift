//
//  PostCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import SDWebImage
import UIKit

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, post: FullLength, index: Int)
}

final class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    
    }()
    
    weak var delegate: PostCollectionViewCellDelegate?
    
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()
    
    public var index = 0
    
    private var post: FullLength?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(x: (contentView.width-size)/2, y: (contentView.height-size)/2, width: size, height: size)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with viewModel: PostCollectionViewCellViewModel) {
        imageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        self.post = viewModel.fullLength
    }
    
    @objc func didDoubleTapToLike() {
        
        guard let post = self.post else {return}
        
//        heartImageView.isHidden = false
//        UIView.animate(withDuration: 0.4) {
//            self.heartImageView.alpha = 1
//        } completion: {[weak self] done in
//            if done {
//                UIView.animate(withDuration: 0.4) {
//                    self?.heartImageView.alpha = 0
//                } completion: { done in
//                    if done {
//                        self?.heartImageView.isHidden = true
//                }
//                }
//        }
//        }
        delegate?.postCollectionViewCellDidLike(self, post: post, index: self.index)
        
        
    }
    
}

