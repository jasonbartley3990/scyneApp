//
//  UploadNormalPostAskForMorePhotosViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/3/21.
//

import UIKit

class UploadNormalPostAskForMorePhotosViewController: UIViewController {
    
    private let images: [UIImage]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    
    private let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.numberOfPages = 2
        page.pageIndicatorTintColor = .gray
        page.currentPageIndicatorTintColor = .white
        page.tintColor = .white
        return page
    }()
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "do you wish to add more photos to your post? (up to 8)\notherwise press next"
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("add", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    init(images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(moreButton)
        view.addSubview(label)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(didTapCancel))
        
        configure()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.width - 120
        scrollView.frame = CGRect(x: 60, y: view.safeAreaInsets.top + 10, width: size, height: size)
        pageControl.frame = CGRect(x: (view.width - 140)/2, y: scrollView.bottom + 10, width: 140, height: 20)
        label.frame = CGRect(x: 15, y: pageControl.bottom + 10, width: (view.width - 30), height: 65)
        moreButton.frame = CGRect(x: (view.width - 100)/2, y: label.bottom + 15, width: 100, height: 40)
        scrollView.delegate = self
        
    }
    
    @objc func didTapMore() {
        let vc = uploadNormalPostViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapNext() {
        let vc = uploadNormalPostCaptionViewController(images: self.images)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapCancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
    
    func configure() {
        let num = images.count
        
        let numFloat = CGFloat(num)
        
        self.pageControl.numberOfPages = num
        
        let size = view.width - 120
        
        scrollView.contentSize = CGSize(width: size*numFloat, height: size)
        
        
        for x in 0..<num {
            if x == 0 {
                let view1 = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                view1.backgroundColor = .secondarySystemBackground
                
                let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView1.contentMode = .scaleAspectFit
                imageView1.image = images[x]
                
                
                view1.addSubview(imageView1)
                scrollView.addSubview(view1)
                
                
            }
            
            if x == 1 {
                let view2 = UIView(frame: CGRect(x: size, y: 0, width: size, height: size))
                view2.backgroundColor = .secondarySystemBackground
                
                let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView2.contentMode = .scaleAspectFit
                imageView2.clipsToBounds = true
                imageView2.image = images[x]
                
                view2.addSubview(imageView2)
                scrollView.addSubview(view2)
                
                
            }
            
            if x == 2 {
                let view3 = UIView(frame: CGRect(x: size*2, y: 0, width: size, height: size))
                view3.backgroundColor = .secondarySystemBackground
                
                let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView3.contentMode = .scaleAspectFit
                imageView3.clipsToBounds = true
                
                view3.addSubview(imageView3)
                scrollView.addSubview(view3)
               
                imageView3.image = images[x]
                
                
                
            }
            
            if x == 3 {
                let view4 = UIView(frame: CGRect(x: size*3, y: 0, width: size, height: size))
                view4.backgroundColor = .secondarySystemBackground
                
                let imageView4 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView4.contentMode = .scaleAspectFit
                imageView4.clipsToBounds = true
                
                view4.addSubview(imageView4)
                scrollView.addSubview(view4)
                
                imageView4.image = images[x]
                
                
            }
            
            if x == 4 {
                let view5 = UIView(frame: CGRect(x: size*4, y: 0, width: size, height: size))
                view5.backgroundColor = .secondarySystemBackground
                
                let imageView5 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView5.contentMode = .scaleAspectFit
                imageView5.clipsToBounds = true
                
                view5.addSubview(imageView5)
                scrollView.addSubview(view5)
                
               
                imageView5.image = images[x]
                
                
                
            }
            
            if x == 5 {
                let view6 = UIView(frame: CGRect(x: size*5, y: 0, width: size, height: size))
                view6.backgroundColor = .secondarySystemBackground
                
                let imageView6 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView6.contentMode = .scaleAspectFit
                imageView6.clipsToBounds = true
                
                view6.addSubview(imageView6)
                scrollView.addSubview(view6)
                
                imageView6.image = images[x]
                
               
            }
            
            if x == 6 {
                let view7 = UIView(frame: CGRect(x: size*6, y: 0, width: size, height: size))
                view7.backgroundColor = .secondarySystemBackground
                
                let imageView7 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView7.contentMode = .scaleAspectFit
                imageView7.clipsToBounds = true
                
                view7.addSubview(imageView7)
                scrollView.addSubview(view7)
                
                imageView7.image = images[x]
                
                
                
            }
            
            if x == 7 {
               
                let view8 = UIView(frame: CGRect(x: size*7, y: 0, width: size, height: size))
                view8.backgroundColor = .secondarySystemBackground
                
                let imageView8 = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                imageView8.contentMode = .scaleAspectFit
                imageView8.clipsToBounds = true
                
                view8.addSubview(imageView8)
                scrollView.addSubview(view8)
                
                imageView8.image = images[x]
                
                
            }
        }
    
}



}

extension UploadNormalPostAskForMorePhotosViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
        pageControl.currentPage = page
        
    }
    
}
