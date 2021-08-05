//
//  IconTextButtonButton.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit

struct IconTextButtonViewModel {
    let text: String?
    let backgroundColor: UIColor?
    let image: UIImage?
    let textColor: UIColor?
}

final class IconTextButton: UIButton {
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(iconImageView)
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: IconTextButtonViewModel) {
        label.text = viewModel.text
        backgroundColor = viewModel.backgroundColor
        iconImageView.image = viewModel.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        let iconSize: CGFloat = 18
        let iconX: CGFloat = (frame.width - label.width - iconSize - 5)/2
        iconImageView.frame = CGRect(x: iconX, y: (frame.height - iconSize)/2, width: iconSize, height: iconSize)
        label.frame = CGRect(x: iconX + iconSize + 5, y: 0 , width: label.width, height: frame.height)
    }

}
