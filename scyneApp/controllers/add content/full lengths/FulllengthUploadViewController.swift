//
//  FulllengthUploadViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class FulllengthUploadViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "The full length gallery is meant to be a collection of the hardwork and talents of the skateboarders out here in the streets all around the world. Videos are only accepted into the gallery if we feel time, effort and hardwork was put into the video. If your video was not accepted it is because we dont want the gallery to get over crowded, but instead focus a spotlight on cinematography we consider pieces of art. Skateshop videos and homie videos are most welcomed"
        label.font = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("select video", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        let labelY: CGFloat = view.height/6
        let buttonSize: CGFloat = 150
        label.frame = CGRect(x: 20, y: labelY, width: (view.width - 40), height: 250)
        button.frame = CGRect(x: (view.width - buttonSize)/2, y: label.bottom + 15, width: buttonSize, height: 40)
    }
    
    @objc func didTapButton() {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }


}

extension FulllengthUploadViewController: UIImagePickerControllerDelegate {
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
        let vc = fullLengthChooseThumbViewController(url: url)
        self.navigationController?.pushViewController(vc, animated: true)
//        let player = AVPlayer(url: url)
//        let vcPlayer = AVPlayerViewController()
//        vcPlayer.player = player
//        self.present(vcPlayer, animated: true, completion: nil)
      }
    }}

extension FulllengthUploadViewController: UINavigationControllerDelegate {
    
}


