//
//  adVideoViewerViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/12/21.
//

import UIKit
import AVKit
import AVFoundation

class adVideoViewerViewController: UIViewController {
    
    private let companyName: String
    
    private let companyLogo: UIImage
    
    private let companyLink: String
    
    private let url: URL
    
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
        label.textColor = .white
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
    
    init(company: String, logo: UIImage, link: String, url: URL) {
        self.companyLogo = logo
        self.companyName = company
        self.companyLink = link
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
    
    @objc func didTapNext() {
        let vc = adVideoProductLinkViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink, url: self.url)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @objc func didTapButton() {
        let vc = adVideoSelectorViewController(company: self.companyName, logo: self.companyLogo, link: self.companyLink)
        navigationController?.pushViewController(vc, animated: true)
    }

   

}
