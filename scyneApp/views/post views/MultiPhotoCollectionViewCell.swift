//
//  MultiPhotoCollectionViewCell.swift
//  scyneApp
//
//  Created by Jason bartley on 5/22/21.
//

import UIKit
import SDWebImage

protocol MultiImageViewDelegate: AnyObject {
    func MultiImageViewDelegateDidScroll(_ cell: MultiPhotoCollectionViewCell, page: Int, index: Int, type: String)
    func MultiImageViewDelegateDidDoubleTap(_ cell: MultiPhotoCollectionViewCell, post: Post, index: Int, type: String)
}

class MultiPhotoCollectionViewCell: UICollectionViewCell {
    static let identifier = "MultiPhotoCollectionViewCell"
    
    public weak var delegate: MultiImageViewDelegate?
    
    public var index = 0
    
    private var post: Post?
    
    public var type = "post"
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()

    
    private var id: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(x: (contentView.width-size)/2, y: (contentView.height-size)/2, width: size, height: size)
        scrollView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.contentOffset.x = 0
    }
    
    @objc func didDoubleTapToLike() {
        guard let post = self.post else {return}
        
        let type = post.postType
        
        if type == "normal" {
        
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
            
            delegate?.MultiImageViewDelegateDidDoubleTap(self, post: post, index: self.index, type: self.type)
        }
    }
    
    
    func configure(with viewModel: MultiPhotoCollectionViewCelViewModel, id: String?) {
        self.post = viewModel.post
        
        let urls = viewModel.urls
        let num = urls.count
        self.type = viewModel.type
        
        let numFloat = CGFloat(num)
        
        scrollView.contentSize = CGSize(width: contentView.width*numFloat, height: contentView.height)
        
        for x in 0..<num {
            if x == 0 {
                let url = URL(string: urls[x])
                
                
                let view1 = UIView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                view1.backgroundColor = .secondarySystemBackground
                
                let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView1.contentMode = .scaleAspectFit
                
                view1.addSubview(imageView1)
                scrollView.addSubview(view1)
                
                
                imageView1.sd_setImage(with: url, completed: nil)
            }
            
            if x == 1 {
                let view2 = UIView(frame: CGRect(x: contentView.width, y: 0, width: contentView.width, height: contentView.height))
                view2.backgroundColor = .secondarySystemBackground
                
                let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView2.contentMode = .scaleAspectFit
                imageView2.clipsToBounds = true
                
                view2.addSubview(imageView2)
                scrollView.addSubview(view2)
                
                let url = URL(string: urls[x])
                imageView2.sd_setImage(with: url, completed: nil)
            }
            
            if x == 2 {
                let view3 = UIView(frame: CGRect(x: contentView.width*2, y: 0, width: contentView.width, height: contentView.height))
                view3.backgroundColor = .secondarySystemBackground
                
                let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView3.contentMode = .scaleAspectFit
                imageView3.clipsToBounds = true
                
                view3.addSubview(imageView3)
                scrollView.addSubview(view3)
                
                let url = URL(string: urls[x])
                imageView3.sd_setImage(with: url, completed: nil)
            }
            
            if x == 3 {
                let view4 = UIView(frame: CGRect(x: contentView.width*3, y: 0, width: contentView.width, height: contentView.height))
                view4.backgroundColor = .secondarySystemBackground
                
                let imageView4 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView4.contentMode = .scaleAspectFit
                imageView4.clipsToBounds = true
                
                view4.addSubview(imageView4)
                scrollView.addSubview(view4)
                
                let url = URL(string: urls[x])
                imageView4.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 4 {
                let view5 = UIView(frame: CGRect(x: contentView.width*4, y: 0, width: contentView.width, height: contentView.height))
                view5.backgroundColor = .secondarySystemBackground
                
                let imageView5 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView5.contentMode = .scaleAspectFit
                imageView5.clipsToBounds = true
                
                view5.addSubview(imageView5)
                scrollView.addSubview(view5)
                
                let url = URL(string: urls[x])
                imageView5.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 5 {
                let view6 = UIView(frame: CGRect(x: contentView.width*5, y: 0, width: contentView.width, height: contentView.height))
                view6.backgroundColor = .secondarySystemBackground
                
                let imageView6 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView6.contentMode = .scaleAspectFit
                imageView6.clipsToBounds = true
                
                view6.addSubview(imageView6)
                scrollView.addSubview(view6)
                
                let url = URL(string: urls[x])
                imageView6.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 6 {
                let view7 = UIView(frame: CGRect(x: contentView.width*6, y: 0, width: contentView.width, height: contentView.height))
                view7.backgroundColor = .secondarySystemBackground
                
                let imageView7 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView7.contentMode = .scaleAspectFit
                imageView7.clipsToBounds = true
                
                view7.addSubview(imageView7)
                scrollView.addSubview(view7)
                
                let url = URL(string: urls[x])
                imageView7.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 7 {
               
                let view8 = UIView(frame: CGRect(x: contentView.width*7, y: 0, width: contentView.width, height: contentView.height))
                view8.backgroundColor = .secondarySystemBackground
                
                let imageView8 = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height))
                imageView8.contentMode = .scaleAspectFit
                imageView8.clipsToBounds = true
                
                view8.addSubview(imageView8)
                scrollView.addSubview(view8)
                
                let url = URL(string: urls[x])
                imageView8.sd_setImage(with: url, completed: nil)
            }
        }
    
}

}

extension MultiPhotoCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
        let type = self.type
        delegate?.MultiImageViewDelegateDidScroll(self, page: page, index: self.index,type: type)
        
    }
}
