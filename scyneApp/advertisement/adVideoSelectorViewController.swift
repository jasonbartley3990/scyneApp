//
//  adVideoSelectorViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices


class adVideoSelectorViewController: UIViewController, UINavigationControllerDelegate {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("select video", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    init(company: String, logo: UIImage, link: String) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(button)
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(x: (view.width - 200)/2, y: (view.height - 40)/2, width: 200, height: 40)
        
        }
    

}

extension adVideoSelectorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) { 
      // 1
      guard
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
        mediaType == (kUTTypeMovie as String),
        let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        else { return }

      // 2
      dismiss(animated: true) {
        //3
        let vc = adVideoViewerViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, url: url)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }}
}
