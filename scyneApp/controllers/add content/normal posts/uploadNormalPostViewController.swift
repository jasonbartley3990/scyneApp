//
//  uploadNormalPostViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/3/21.
//

import UIKit

class uploadNormalPostViewController: UIViewController {
    
    private var images: [UIImage]
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("select picture", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    init(images: [UIImage]) {
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
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
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
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
        
    }

}

extension uploadNormalPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
    self.images.append(image)
    if self.images.count == 8 {
        let vc = uploadNormalPostCaptionViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }else {
        let vc = UploadNormalPostAskForMorePhotosViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
   
}
}
