//
//  PlayVideoReferenceViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/8/21.
//

import AVKit
import MobileCoreServices
import UIKit

class PlayVideoViewController: UIViewController {
  @IBAction func playVideo(_ sender: AnyObject) {
    VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
  }
}

// MARK: UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard
      let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
      mediaType == (kUTTypeMovie as String),
      let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
      else { return }
    dismiss(animated: true) {
      //3
      let player = AVPlayer(url: url)
      let vcPlayer = AVPlayerViewController()
      vcPlayer.player = player
      self.present(vcPlayer, animated: true, completion: nil)
    }
  }
}

// MARK: UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
}
