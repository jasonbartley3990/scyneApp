//
//  GearActionsCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

protocol GearActionsCollectionViewCellDelegate: AnyObject {
    func GearActionsCollectionViewCellDidTapMessageButton(_ cell: GearActionsCollectionViewCell, post: Post)
    func GearActionsCollectionViewCellDidTapSaveButton(_ cell: GearActionsCollectionViewCell, isSaved: Bool, post: Post)
}

class GearActionsCollectionViewCell: UICollectionViewCell {
    static let identifier = "GearActionsCollectionViewCell"
    
    weak var delegate : GearActionsCollectionViewCellDelegate?
    
    public var isSaved: Bool? = false
    
    private var post: Post?
    
    public var index: Int?
    
    private let messageButton: UIButton = {
        let button = UIButton()
        button.setTitle("message", for: .normal)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    public let saveLabel: UILabel = {
        let label = UILabel()
        label.text = "save"
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    public let pageTurner: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        page.numberOfPages = 1
        page.currentPageIndicatorTintColor = .systemGray
        page.pageIndicatorTintColor = .systemGray2
        return page
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(messageButton)
        contentView.addSubview(saveLabel)
        contentView.addSubview(pageTurner)
        let tapSave = UITapGestureRecognizer(target: self, action: #selector(didTapSave))
        saveLabel.addGestureRecognizer(tapSave)
        messageButton.addTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
       
      
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height/1.15
        let saveLabelWidth: CGFloat = 70
        messageButton.frame = CGRect(x: 5, y: (contentView.height - size)/2 + 2, width: 110, height: size)
        pageTurner.frame = CGRect(x: (contentView.width - 160)/2, y: 0, width: 160, height: 20)
        saveLabel.frame = CGRect(x: contentView.width - saveLabelWidth - 10, y: 2, width: saveLabelWidth, height: size)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pageTurner.currentPage = 0
    }
    
    func configure(with viewModel: gearActionsCollectionViewCellViewModel) {
        self.isSaved = viewModel.isSaved
        if viewModel.isSaved {
            saveLabel.text = "saved"
            saveLabel.textColor = .green
        }
        
        self.post = viewModel.post
        pageTurner.numberOfPages = viewModel.photoCount
    }
    
    @objc func didTapMessageButton() {
        guard let post = self.post else {return}
        delegate?.GearActionsCollectionViewCellDidTapMessageButton(self, post: post)
    }
    
    @objc func didTapSave() {
        guard let saved = self.isSaved else {
            print("saved messed up")
            return}
        if saved {
            print("true")
            saveLabel.text = "save"
            saveLabel.textColor = .label
        } else {
            print("false")
            saveLabel.text = "saved"
            saveLabel.textColor = .green
        }
        
        guard let itemPost = self.post else {
            print("opps")
            return}
        
        delegate?.GearActionsCollectionViewCellDidTapSaveButton(self, isSaved: !saved, post: itemPost)
        self.isSaved = !saved
       
    }
    
    public func updateSaveLabel(with email: String) {
        guard let boolean = self.isSaved else {return}
        
        if boolean {
            self.post?.savers.append(email)
        } else {
            self.post?.savers.removeAll { $0 == email }
        }
        
        
    }
}
