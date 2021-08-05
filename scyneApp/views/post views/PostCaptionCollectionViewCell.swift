//
//  PostCaptionCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDelegateDidTapMore(_ cell: PostCaptionCollectionViewCell, caption: String)
}

class PostCaptionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCaptionCollectionViewCell"
    
    public weak var delegate: PostCaptionCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.textAlignment = .center
        label.textAlignment = .center
        return label
    }()
    
    private let moreButton: UILabel = {
        let label = UILabel()
        label.text = "read more"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.isUserInteractionEnabled = true
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        contentView.addSubview(moreButton)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCaption))
        moreButton.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonSize = contentView.height/6
        let labelHeight = contentView.height - (contentView.height/4.8)
        label.frame = CGRect(x: 12, y: 5, width: contentView.width - 24, height: labelHeight)
        moreButton.frame = CGRect(x: (contentView.width - 120)/2, y: label.bottom - 5, width: 120, height: buttonSize)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellModel) {
        if let caption = viewModel.caption {
            if caption.count < 40 {
                moreButton.isHidden = true
                label.text = "\(caption)\n"
            } else if caption.count < 60 {
                moreButton.isHidden = true
                label.text = "\(caption)"
            } else {
                label.text = caption
                moreButton.isHidden = false
            }
        } else {
            label.text = ""
            moreButton.isHidden = true
        }
        
        
        
       
    }
    
    @objc func didTapCaption() {
        guard let cap = label.text else {return}
        delegate?.postCaptionCollectionViewCellDelegateDidTapMore(self, caption: cap)
    }
    
}
