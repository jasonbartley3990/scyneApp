//
//  ClipUploaderViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/26/21.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices
import CoreMedia

class ClipUploaderViewController: UIViewController {
    
    var urls = [URL]()
    
    let spotId: String?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("select video", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    init(urls: [URL], spot: String?) {
        self.urls = urls
        self.spotId = spot
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
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
    
    override func viewDidLayoutSubviews() {
        button.frame = CGRect(x: (view.width - 200)/2, y: (view.height - 40)/2, width: 200, height: 40)
        
    }
    
    @objc func didTapButton() {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }

}

extension ClipUploaderViewController: UIImagePickerControllerDelegate {
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
        
       
        let asset = AVAsset(url: url)

        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        print(durationTime)
        
        guard durationTime < 45 else {
            dismiss(animated: true, completion: {
                [weak self] in
                let ac = UIAlertController(title: "clips must be less than a 45 seconds", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            })
            return
        }
    

      // 2
      dismiss(animated: true) {
        //3
        guard let thumbnail = self.generateThumbnail(url: url) else {return}
        
        let vc = ClipAskForMoreVideosViewController(url: url, urls: self.urls, spot: self.spotId, thumbnail: thumbnail)
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }}

extension ClipUploaderViewController: UINavigationControllerDelegate {
    
}

extension ClipUploaderViewController {
    func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)

            return nil
        }
    }}
