//
//  fullLengthEditViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import UIKit

class fullLengthChooseThumbViewController: UIViewController {
    
    private var videoUrl: URL
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let VideoSelectedlabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.text = "video selected"
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "select a thumbnail that will represent your video in the gallery scroll"
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.numberOfLines = 2
        return label
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("select thumbnail", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(url: URL) {
        self.videoUrl = url
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(VideoSelectedlabel)
        view.addSubview(imageView)
        view.addSubview(infoLabel)
        view.addSubview(selectButton)
        selectButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = (view.width)/4
        let labelSize = (view.width - 40)
        let buttonSize: CGFloat = 150
        imageView.frame = CGRect(x: (view.width - size)/2, y: view.safeAreaInsets.top + 5, width: size, height: size)
        VideoSelectedlabel.frame = CGRect(x: (view.width - labelSize)/2 , y: imageView.bottom , width: labelSize, height: 50)
        infoLabel.frame = CGRect(x: (view.width - labelSize)/2, y: VideoSelectedlabel.bottom + 20, width: labelSize, height: 50)
        selectButton.frame = CGRect(x: (view.width - buttonSize)/2, y: infoLabel.bottom + 5, width: buttonSize, height: 40)
    }
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    private func showEditPhoto(image: UIImage) {
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else { return }

        let vc = FullLengthTitleViewController(image: resizedImage, url: videoUrl)
        navigationController?.pushViewController(vc, animated: false)

    }
}

extension fullLengthChooseThumbViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            print("uh oh")
            return
            
        }
        showEditPhoto(image: image)
    }
    }
