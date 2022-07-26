//
//  AskingPriceViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import UIKit

class AskingPriceViewController: UIViewController, UITextFieldDelegate {
    
    private let image: [UIImage]
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "dollarsign.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "asking price?"
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let priceTextField: ScyneTextField = {
        let textfield = ScyneTextField()
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .continue
        textfield.placeholder = "example: 30"
        return textfield
    }()
    
    init(image: [UIImage]) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(priceTextField)
        priceTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        //we dont want users to have more than 8 photos so dont allow nthem to go back
        if image.count == 8 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = view.width/3
        let labelSize: CGFloat = 200
        imageView.frame = CGRect(x:(view.width - imageSize)/2 , y: view.safeAreaInsets.top + 10, width: imageSize, height: imageSize)
        label.frame = CGRect(x: (view.width - labelSize)/2 , y: imageView.bottom + 10, width: labelSize, height: 40)
        priceTextField.frame = CGRect(x:(view.width - 200)/2 , y: label.bottom + 5, width: 200, height: 50)
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc func didTapNext() {
        priceTextField.resignFirstResponder()
        
        guard let askingPrice = priceTextField.text, !askingPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let ac = UIAlertController(title: "nothing entered", message: "please enter a value to continue", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
            present(ac, animated: true)
            return
            
        }
        
        let vc = ItemTypeViewController(images: image, price: askingPrice)
        navigationController?.pushViewController(vc, animated: true)

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == priceTextField {
            priceTextField.resignFirstResponder()
        }
        return true
    }
}
