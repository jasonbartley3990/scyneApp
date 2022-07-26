//
//  FullLengthTitleViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/20/21.
//

import UIKit

class FullLengthTitleViewController: UIViewController, UITextFieldDelegate {
    
    private let image: UIImage
    
    private let videoUrl: URL
    
    private let titleTextField: ScyneTextField = {
        let textfield = ScyneTextField()
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .continue
        textfield.placeholder = "enter title"
        return textfield
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "name of video?"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    init(image: UIImage, url: URL) {
        self.image = image
        self.videoUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(titleTextField)
        view.addSubview(label)
        titleTextField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: (view.safeAreaInsets.top + 15), width: (view.width - 40), height: 40)
        titleTextField.frame = CGRect(x: (view.width - 235)/2, y: label.bottom + 20, width: 235, height: 50)
    }
    
    
    @objc func didTapNext() {
        titleTextField.resignFirstResponder()
        
        guard let videoTitle = titleTextField.text, !videoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "nothing entered", message: "please enter a title for your video", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self.present(ac, animated: true)
            }
            return
        }
        
        let vc = fullLengthEditPostViewController(image: image, url: videoUrl, title: videoTitle)
        navigationController?.pushViewController(vc, animated: true)
    }

    
    

}
