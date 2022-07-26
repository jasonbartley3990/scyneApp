//
//  ClipAskForMoreVideosViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/26/21.
//

import UIKit
import AVKit
import AVFoundation

class ClipAskForMoreVideosViewController: UIViewController {
    
    let url: URL
    
    let spotId: String?
    
    var urls: [URL]
    
    let image: UIImage
    
    let videoView: UIView = {
        let videoView = UIView()
        videoView.backgroundColor = .black
        videoView.alpha = 0
        return videoView
    }()
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "do you wish to reselect the video?\notherwise press next"
        return label
    }()
    
    let retakeButton: UIButton = {
        let button = UIButton()
        button.setTitle("reselect", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
   
    
    init(url: URL, urls: [URL], spot: String?, thumbnail: UIImage) {
        self.url = url
        self.urls = urls
        self.spotId = spot
        self.image = thumbnail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(retakeButton)
        view.addSubview(label)
        view.addSubview(videoView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        retakeButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        
        let player: AVPlayer = {
            let player = AVPlayer(url: url)
            return player
        }()
        
        let layer: AVPlayerLayer = {
            let viewWidth: CGFloat = view.width/2.3
            let layer = AVPlayerLayer(player: player)
            layer.frame = CGRect(x: (view.width - viewWidth)/2, y: view.safeAreaInsets.top + 70, width: viewWidth, height: viewWidth)
            return layer
        }()
        
        videoView.layer.addSublayer(layer)
        self.view.layer.addSublayer(layer)
        player.play()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        let viewWidth: CGFloat = view.width/2.3
        videoView.frame = CGRect(x: (view.width - viewWidth)/2, y: view.safeAreaInsets.top + 10, width: viewWidth, height: viewWidth)
        label.frame = CGRect(x: 30, y: videoView.bottom + 30, width: view.width-60, height: 80)
        retakeButton.frame = CGRect(x: (view.width - 100)/2, y: label.bottom + 10, width: 100, height: 40)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
    }
    
    @objc func didTapButton() {
        let vc = ClipUploaderViewController(urls: [], spot: self.spotId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapNext() {
        self.urls.append(self.url)
       
        let vc = ClipCaptionViewController(urls: self.urls, spotId: self.spotId, thumbnail: self.image)
        navigationController?.pushViewController(vc, animated: true)
        
    }


}
