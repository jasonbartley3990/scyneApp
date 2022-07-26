//
//  SelectRegionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/24/21.
//

import UIKit

class SelectRegionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "scyneEarth")
        imageView.backgroundColor = .black
        return imageView
    }()
   
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "select nearest skate scene"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let textField: ScyneTextField = {
        let textField = ScyneTextField()
        return textField
    }()
    
    let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.isHidden = true
        return picker
    }()
    
    private let scenes: [String] = ["San Fransisco CA", "Los Angeles CA", "Sacramento CA", "San Diego CA", "Orange CA", "San Luis Obispo CA", "Fresno CA", "Monterey CA", "North California", "Bakersfield CA", "Santa Ana CA", "San Jose CA", "San Bernardino CA", "Stockton CA","Santa Rosa CA", "Ventura CA", "Santa Barbara CA", "Mexicali CA", "Las Vegas NV", "NYC","Long Island NY", "East New York", "Albany NY", "Syracuse NY", "Pheonix AZ", "Tuscon AZ", "New Mexico", "Dallas/FW TX", "Austin TX", "San Antonio TX", "Houston TX", "Western Texas","Kansas City MO", "Saint Louis MO", "New Orleans LA", "Ohklahoma City", "Denver CO", "Salt Lake City UT", "OREGON", "WASHINGTON","Miama FL", "Tampa Fl","Orlando FL", "Jacksonville FL", "Minneapolis MN", "Atlanta GA", "Chicago IL", "Columbus OH", "Cleveland OH", "Cincinnatti OH", "Pittsburgh PA", "Philadelphia PA", "Washington DC", "Baltimore MD", "New Jersey", "Boston MA", "Milwaukee WI", "Detroit MI", "Indianapolis IL", "NEW ENGLAND", "NORTH CAROLINA", "SOUTH CAROLINA", "Nashville TN", "Little Rock AR", "VIRGINIA", "MISSISIPPI", "ALABAMA", "IDAHO" ,"KENTUCKY", "Vancouver Canada", "Montreal Canada", "Toronto Canada", "Ontario Canada" ]
    
    
    init(name: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(pickerView)
        view.addSubview(textField)
        view.addSubview(imageView)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.delegate = self
        textField.placeholder = "select region"
        textField.inputView = pickerView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = view.width/4
        imageView.frame = CGRect(x: (view.width - imageSize)/2, y: view.safeAreaInsets.top + 5, width: imageSize, height: imageSize)
        label.frame = CGRect(x: 20, y: imageView.bottom, width: (view.width - 40), height: 40)
        textField.frame = CGRect(x: 25, y: label.bottom + 20, width: (view.width - 50), height: 40)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.isHidden = false
    }
    
    

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scenes.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scenes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = scenes[row]
        textField.resignFirstResponder()
    }
    
    @objc func didTapNext() {
        
        guard let bool = textField.text?.isEmpty else {return}
        
        if bool {
            let ac = UIAlertController(title: "Nothing entered", message: "Please select the nearest region", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
        
        guard let text = textField.text else {return}
        
        let vc = SelectProfilePictureViewController(region: text)
        navigationController?.pushViewController(vc, animated: true)
    }
}
