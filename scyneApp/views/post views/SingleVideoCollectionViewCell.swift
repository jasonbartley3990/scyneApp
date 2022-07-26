//
//  SingleVideoCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/30/21.
//

import UIKit
import AVFoundation
import AVKit

protocol SingleVideoCollectionViewCellDelegate: AnyObject {
    func SingleVideoCollectionViewCellDidDoubleTap(_ cell: SingleVideoCollectionViewCell, index: Int, post: Post, viewers: Int, type: String)
}

class SingleVideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "singleVideoCollectionViewCell"
    
    public weak var delegate: SingleVideoCollectionViewCellDelegate?
    
    private let player = AVPlayer(playerItem: nil)
    
    public var index = 0
    
    private var post: Post?
    
    public var hasBeenViewed = false
    
    private var viewers = 0
    
    private var type = "clip"
    
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()
    
    var timer: Timer = Timer()
    var count: Int = 0 {
        didSet {
            if count == 2 {
                hasBeenViewed = true
                
                guard let post = self.post else {return}
            
                DatabaseManager.shared.incrementVideoCount(post: post)
                stopTimer()
                timer.invalidate()
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(x: (contentView.width-size)/2, y: (contentView.height-size)/2, width: size + 10, height: size)    }
    
    @objc func didDoubleTapToLike() {
        heartImageView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.heartImageView.alpha = 1
        } completion: {[weak self] done in
            if done {
                UIView.animate(withDuration: 0.4) {
                    self?.heartImageView.alpha = 0
                } completion: { [weak self] done in
                    if done {
                        self?.heartImageView.isHidden = true
                }
                }
        }
        }
        guard let post = self.post else {return}
        
        delegate?.SingleVideoCollectionViewCellDidDoubleTap(self, index: self.index, post: post, viewers: self.viewers, type: self.type)
        
    }
    
    public func configure(with viewModel: SingleVideoCollectionViewCellViewModel) {
        self.post = viewModel.post
        self.viewers = viewModel.viewers
        self.type = viewModel.type
        
        player.replaceCurrentItem(with: AVPlayerItem(url: viewModel.url))
        
        let layer = AVPlayerLayer(player: player)
        let viewWidth: CGFloat = contentView.width
        layer.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth)
        self.layer.addSublayer(layer)
        do {
              try AVAudioSession.sharedInstance().setCategory(.playback)
           } catch(let error) {
               print(error.localizedDescription)
           }
    
        player.volume = 0.9
    }
    
    public func pauseVideo() {
        player.pause()
    }
    
    public func playVideo() {
        player.seek(to: CMTime.zero)
        player.play()
        player.volume = 0.9
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player.replaceCurrentItem(with: nil)
    }
    
    public func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
    }
    
    @objc func timerCounter() {
        count = count + 1
    }
    
    public func stopTimer() {
        timer.invalidate()
    }
    
}
