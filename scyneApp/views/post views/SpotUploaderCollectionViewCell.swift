//
//  SpotUploaderCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol SpotUploaderCollectionViewCellDelegate: AnyObject {
    func SpotUploaderCollectionViewCellDelegateDidTapPoster(_ cell: SpotUploaderCollectionViewCell, username: String, email: String, region: String)
    
}

class SpotUploaderCollectionViewCell: UICollectionViewCell {
    static let identifier = "SpotUploaderCollectionViewCell"
    
    public weak var delegate: SpotUploaderCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .thin)
        label.numberOfLines = 1
        label.textColor = .label
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var uploader: String?
    
    private var email: String?
    
    private var region: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPoster))
        label.addGestureRecognizer(tap)
        
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
    
    func configure(with viewModel: SpotUploaderCollectionViewCellViewModel) {
        label.text = "uploaded by: \(viewModel.uploader)"
        self.uploader = viewModel.uploader
        self.email = viewModel.email
        self.region = viewModel.region
    }
    
    @objc func didTapPoster() {
        guard let poster = self.uploader else {return}
        guard let email = self.email else {return}
        guard let reg = self.region else {return}
        delegate?.SpotUploaderCollectionViewCellDelegateDidTapPoster(self, username: poster, email: email, region: reg)
    }
    
}




