//
//  SpotHeaderCollectionReusableView.swift
//  scyneApp
//
//  Created by Jason bartley on 5/10/21.
//

import UIKit

import SDWebImage

protocol SpotHeaderCollectionReusableViewDelegate: AnyObject {
    func SpotheaderCollectionReusableViewdidTapSave(_ header: SpotHeaderCollectionReusableView)
    func SpotHeaderCollectionReusableViewDidTapComment(_ header: SpotHeaderCollectionReusableView, post: Post)
    func spotHeaderCollectionReusableViewDidTapPin(_ header: SpotHeaderCollectionReusableView, post: Post)
    func spotHeaderCollectionReusableViewDidTapPoster(_ header:SpotHeaderCollectionReusableView, username: String, email: String, region: String)
    
}

class SpotHeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "SpotHeaderCollectionReusableView"
    
    weak var delegate: SpotHeaderCollectionReusableViewDelegate?
    
    private var isSaved = false
    
    private var post: Post?
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.isUserInteractionEnabled = true
        return scroll
    }()
    
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.text = "780 collins street"
        label.textAlignment = .center
        return label
    }()
    
    private let uploaderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .label
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
   
    public let pageTurner: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        page.numberOfPages = 1
        page.currentPageIndicatorTintColor = .systemGray
        page.pageIndicatorTintColor = .systemGray2
        return page
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "video", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    public let saveLabel: UILabel = {
        let label = UILabel()
        label.text = "save"
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var pinButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "mappin.and.ellipse", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(addressLabel)
        addSubview(scrollView)
        addSubview(saveLabel)
        addSubview(commentButton)
        addSubview(pinButton)
        addSubview(pageTurner)
        addSubview(uploaderLabel)
        pinButton.addTarget(self, action: #selector(didTapPin), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(didTapSaveSpot))
        saveLabel.addGestureRecognizer(saveTap)
        let posterTap = UITapGestureRecognizer(target: self, action: #selector(didTapPoster))
        uploaderLabel.addGestureRecognizer(posterTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonSize = width/11
        let saveLabelWidth: CGFloat = 70
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        commentButton.frame = CGRect(x: 5, y: scrollView.bottom + 2, width: buttonSize, height: buttonSize)
        pinButton.frame = CGRect(x: commentButton.right + 5, y: commentButton.top, width: buttonSize, height: buttonSize)
        pageTurner.frame = CGRect(x: (width - 160)/2, y: scrollView.bottom + 2, width: 160, height: 20)
        saveLabel.frame = CGRect(x: (width - saveLabelWidth - 5), y: commentButton.top , width: saveLabelWidth, height: 35)
        
        addressLabel.frame = CGRect(x: 10, y: commentButton.bottom + 4, width: (width - 20), height: 40)
        uploaderLabel.frame = CGRect(x: 20, y: addressLabel.bottom + 5, width: (width - 40), height: 30)
        scrollView.delegate = self
    }
    
    public func configure(with viewModel: SpotHeaderViewModel) {
        addressLabel.text = viewModel.address
        uploaderLabel.text = viewModel.spotUploader
        isSaved = viewModel.isSaved
        if viewModel.isSaved {
            saveLabel.text = "saved"
            saveLabel.textColor = .systemGreen
        } else {
            saveLabel.text = "save"
            saveLabel.textColor = .label
        }
        
        self.post = viewModel.post
        pageTurner.numberOfPages = viewModel.numberOfPics
        
        let urls = viewModel.spotPictureUrl
        print(urls)
        let num = urls.count
        
        let numFloat = CGFloat(num)
        
        scrollView.contentSize = CGSize(width: width*numFloat, height: width)
        
        for x in 0..<num {
            if x == 0 {
                let view1 = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                view1.backgroundColor = .secondarySystemBackground
                
                let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView1.contentMode = .scaleAspectFit
                
                view1.addSubview(imageView1)
                scrollView.addSubview(view1)
                
                let url = URL(string: urls[x])
                imageView1.sd_setImage(with: url, completed: nil)
            }
            
            if x == 1 {
                let view2 = UIView(frame: CGRect(x: width, y: 0, width: width, height: width))
                view2.backgroundColor = .secondarySystemBackground
                
                let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView2.contentMode = .scaleAspectFit
                imageView2.clipsToBounds = true
                
                view2.addSubview(imageView2)
                scrollView.addSubview(view2)
                
                let url = URL(string: urls[x])
                imageView2.sd_setImage(with: url, completed: nil)
            }
            
            if x == 2 {
                let view3 = UIView(frame: CGRect(x: width*2, y: 0, width: width, height: width))
                view3.backgroundColor = .secondarySystemBackground
                
                let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView3.contentMode = .scaleAspectFit
                imageView3.clipsToBounds = true
                
                view3.addSubview(imageView3)
                scrollView.addSubview(view3)
                
                let url = URL(string: urls[x])
                imageView3.sd_setImage(with: url, completed: nil)
            }
            
            if x == 3 {
                let view4 = UIView(frame: CGRect(x: width*3, y: 0, width: width, height: width))
                view4.backgroundColor = .secondarySystemBackground
                
                let imageView4 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView4.contentMode = .scaleAspectFit
                imageView4.clipsToBounds = true
                
                view4.addSubview(imageView4)
                scrollView.addSubview(view4)
                
                let url = URL(string: urls[x])
                imageView4.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 4 {
                let view5 = UIView(frame: CGRect(x: width*4, y: 0, width: width, height: width))
                view5.backgroundColor = .secondarySystemBackground
                
                let imageView5 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView5.contentMode = .scaleAspectFit
                imageView5.clipsToBounds = true
                
                view5.addSubview(imageView5)
                scrollView.addSubview(view5)
                
                let url = URL(string: urls[x])
                imageView5.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 5 {
                let view6 = UIView(frame: CGRect(x: width*5, y: 0, width: width, height: width))
                view6.backgroundColor = .secondarySystemBackground
                
                let imageView6 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView6.contentMode = .scaleAspectFit
                imageView6.clipsToBounds = true
                
                view6.addSubview(imageView6)
                scrollView.addSubview(view6)
                
                let url = URL(string: urls[x])
                imageView6.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 6 {
                let view7 = UIView(frame: CGRect(x: width*6, y: 0, width: width, height: width))
                view7.backgroundColor = .secondarySystemBackground
                
                let imageView7 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView7.contentMode = .scaleAspectFit
                imageView7.clipsToBounds = true
                
                view7.addSubview(imageView7)
                scrollView.addSubview(view7)
                
                let url = URL(string: urls[x])
                imageView7.sd_setImage(with: url, completed: nil)
                
            }
            
            if x == 7 {
               
                let view8 = UIView(frame: CGRect(x: width*7, y: 0, width: width, height: width))
                view8.backgroundColor = .secondarySystemBackground
                
                let imageView8 = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                imageView8.contentMode = .scaleAspectFit
                imageView8.clipsToBounds = true
                
                view8.addSubview(imageView8)
                scrollView.addSubview(view8)
                
                let url = URL(string: urls[x])
                imageView8.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    
    @objc func didTapSaveSpot() {
        if self.isSaved {
            saveLabel.textColor = .label
            saveLabel.text = "save"
        } else {
            saveLabel.textColor = .systemGreen
            saveLabel.text = "saved"
        }
        
        delegate?.SpotheaderCollectionReusableViewdidTapSave(self)
        self.isSaved = !isSaved
        
    }
    
    private func changeSave() {
        if self.isSaved {
           
        } else {
           
    }
    }
    
    @objc func didTapComment() {
        guard let post = self.post else {return}
        delegate?.SpotHeaderCollectionReusableViewDidTapComment(self, post: post)
    }
    
    @objc func didTapPin() {
        guard let post = self.post else {return}
        delegate?.spotHeaderCollectionReusableViewDidTapPin(self, post: post)
    }
    
    @objc func didTapPoster() {
        print("aye")
        guard let post = self.post else {
            print("returned")
            return}
        delegate?.spotHeaderCollectionReusableViewDidTapPoster(self, username: post.posterUsername, email: post.posterEmail, region: post.region)
    }
    
}

extension SpotHeaderCollectionReusableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
        pageTurner.currentPage = page
        
    }
}
