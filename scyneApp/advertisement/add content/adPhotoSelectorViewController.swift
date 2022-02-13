//
//  adPhotoSelectorViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit

class adPhotoSelectorViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private var images: [UIImage]
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("select photo", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    init(company: String, logo: UIImage, link: String, images: [UIImage]) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(button)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(x: (view.width - 200)/2, y: (view.height - 40)/2, width: 200, height: 40)
        
        }

}

extension adPhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
    self.images.append(image)
    if self.images.count == 8 {
        let vc = adPhotoProductLinkViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }else {
        let vc = adPhotoAskForMoreViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
   
}
}
