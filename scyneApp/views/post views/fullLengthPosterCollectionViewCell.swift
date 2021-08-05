//
//  fullLengthPosterCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 6/5/21.
//

import UIKit

protocol fullLengthPosterCollectionViewCellDelegate: AnyObject {
    func fullLengthPosterCollectionViewCellDidTapLabel(_ cell: fullLengthPosterCollectionViewCell, username: String, email: String, region: String)
    
}

class fullLengthPosterCollectionViewCell: UICollectionViewCell {
    static let identifier = "fullLengthPosterCollectionViewCell"
    
    weak var delegate: fullLengthPosterCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private var posterEmail: String?
    
    private var posterUsername: String?
    
    private var region: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 2, width: label.width , height: contentView.height)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        
    }
    
    
    @objc func didTapLabel() {
        print("was tapped um")
        guard let email = self.posterEmail else {return}
        guard let username = self.posterUsername else {return}
        guard let reg = self.region else {return}
        
        delegate?.fullLengthPosterCollectionViewCellDidTapLabel(self, username: username, email: email, region: reg)
    }
    
    override func prepareForReuse() {
        label.text = nil
    }
    
    func configure(with viewModel: fullLengthPosterCollectionViewCellViewModel) {
        label.text = " posted by:  \(viewModel.poster)"
        self.posterEmail = viewModel.posterEmail
        self.posterUsername = viewModel.poster
        self.region = viewModel.region
    }
}

