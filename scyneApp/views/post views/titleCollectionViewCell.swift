//
//  titleCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol titleCollectionViewCellDelegate: AnyObject {
    func titleCollectionViewCellDelegateDidTapTitle(_ cell: titleCollectionViewCell)
}

class titleCollectionViewCell: UICollectionViewCell {
    static let identifier = "titleCollectionViewCell"
    
    weak var delegate: titleCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
        label.addGestureRecognizer(tap)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: (contentView.width - label.width)/2, y: 2, width: label.width , height: contentView.height)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
    }
    
    
    @objc func didTapTitle() {
        print("was tapped um")
        delegate?.titleCollectionViewCellDelegateDidTapTitle(self)
    }
    
    override func prepareForReuse() {
        label.text = nil
    }
    
    func configure(with viewModel: TitleCollectionViewCellViewModel) {
        label.text = viewModel.title
    }
}
