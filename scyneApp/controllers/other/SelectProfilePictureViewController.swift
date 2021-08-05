//
//  SelectProfilePictureViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/4/21.
//

import UIKit

class SelectProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let region: String
    
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "select a profile photo"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    init(region: String) {
        self.region = region
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(profilePictureImageView)
        view.addSubview(label)
        addImageGesture()
        addLabelGesture()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 120
        profilePictureImageView.frame = CGRect(x: (view.width-imageSize)/2, y: view.safeAreaInsets.top + 15, width: imageSize, height: imageSize)
        label.frame = CGRect(x: 10, y: profilePictureImageView.bottom + 20, width: (view.width - 20), height: 40)
    }
    
    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }
    
    private func addLabelGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
    }
    
    @objc func didTapNext() {
        guard let image = profilePictureImageView.image else {return}
        let vc = SignUpViewController(region: self.region, image: image)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapImage() {
        let sheet = UIAlertController(title: "profile picture", message:"how would you like to select a profile picture", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "take photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            }
        }))
        
        sheet.addAction(UIAlertAction(title: "choose photo", style: .default, handler: {
            [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            }
            
        }))
        present(sheet, animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        DispatchQueue.main.async {
            self.profilePictureImageView.image = image
        }
        
    }
       
}
