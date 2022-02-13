//
//  SelectLogoViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class SelectLogoViewController: UIViewController {
    
    
    private let companyName: String
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = "select the company logo you wish to be displayed at the top of your post next to your company name. when done press next"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton()
        button.setTitle("select photo", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()
    
    init(company: String) {
        self.companyName = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(selectButton)
        view.addSubview(label)
        view.addSubview(imageView)
        selectButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageWidth: CGFloat = view.width / 3
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 15, width: view.width - 40, height: 60)
        selectButton.frame = CGRect(x: 25, y: label.bottom + 15, width: view.width - 50, height: 40)
        imageView.frame = CGRect(x:(view.width - imageWidth)/2 , y: selectButton.bottom + 15, width: imageWidth, height: imageWidth)
        imageView.layer.cornerRadius = (imageWidth/2)
    }
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    func setUpImage(image: UIImage) {
        imageView.image = image
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        
    }
    
    @objc func didTapNext() {
        guard let image = imageView.image else {return}
        let vc = SelectCompanyLinkViewController(company: self.companyName, logo: image)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

   

}

extension SelectLogoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            print("uh oh")
            return
            
        }
       setUpImage(image: image)
    }
    }
