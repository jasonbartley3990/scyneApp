//
//  ChooseRegionWithCompletionViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 6/17/21.
//

import UIKit

class ChooseRegionWithCompletionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    public var completion: ((String) -> Void)?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "select skate scene region"
        label.textAlignment = .center
        label.textColor = .black
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(pickerView)
        view.addSubview(textField)
        
       
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.delegate = self
        textField.placeholder = "select region"
        textField.inputView = pickerView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(didTapDone))
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 10, width: (view.width - 40), height: 40)
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
    
    
    @objc func didTapDone() {
        guard let region = textField.text else {return}
        print(region)
        self.completion?(region)
        self.navigationController?.popToRootViewController(animated: true)
    }
    

   

}
