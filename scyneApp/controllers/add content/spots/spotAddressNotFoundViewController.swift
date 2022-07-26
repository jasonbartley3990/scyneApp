//
//  spotAddressNotFoundViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/7/21.
//

import UIKit

class spotAddressNotFoundViewController: UIViewController, UITextFieldDelegate {
    
    private var images = [UIImage]()
    
    private var latitude: Double
    
    private var longitude: Double
    
    private var address = ""
    
    init(images: [UIImage], latitude: Double, longitude: Double, address: String) {
        self.images = images
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "spot address could not be determined by gps, please manually enter the address"
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let addressTextField: ScyneTextField = {
        let field = ScyneTextField()
        field.placeholder = ""
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(addressTextField)
        view.addSubview(label)
        addressTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        if images.count == 8 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 15, width: (view.width - 20), height: 60)
        addressTextField.frame = CGRect(x: 20, y: label.bottom + 15, width: view.width-40, height: 40)
    }
    
    @objc func didTapNext() {
        addressTextField.resignFirstResponder()
        
        guard let address = addressTextField.text, !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let ac = UIAlertController(title: "nothing entered", message: "please enter a address", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        let vc = SpotTypeViewController(images: self.images, longitude: self.longitude, latitude: self.latitude, address: address)
        navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
        
    }

}
