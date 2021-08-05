//
//  SettingsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import StoreKit
import JGProgressHUD
import SafariServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var sections: [settingsSection] = []
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        createTableFooter()

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: creating options on settings
    
    public func configureModels() {
        sections.append(settingsSection(title: "app", options: [settingOption(title: "rate app", image: UIImage(systemName: "star"), color: .systemOrange) { [weak self] in
            guard let scene = self?.view.window?.windowScene else {return}
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                let ac = UIAlertController(title: "unable to bring up app review", message: "current ios version does not sopprt this", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self?.present(ac, animated: true)
            }
           
        },
        settingOption(title: "saved spots", image: UIImage(systemName: "square.and.arrow.down"), color: .label) { [weak self] in
            let vc = SavedSpotsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "saved items", image: UIImage(systemName: "square.and.arrow.down"), color: .label) { [weak self] in
            let vc = SavedItemsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "blocked users", image: UIImage(systemName: "xmark.octagon"), color: .label) { [weak self] in
            let vc = BlockedUsesViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "change local region", image: UIImage(systemName: "house"), color: .label) { [weak self] in
            //available on next update
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "this function will be available next update", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            }
//            let vc = ChooseRegionWithCompletionViewController()
//            vc.completion = { reg in
//
//
//            }
//            self?.navigationController?.pushViewController(vc, animated: true)
            
        }]))
        sections.append(settingsSection(title: "information", options: [ settingOption(title: "post advertisements", image: UIImage(systemName:"eye"), color: .label, handler: { [weak self] in
            let vc = AdvertismentMenuViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }),
        settingOption(title: "privacy policy", image: UIImage(systemName: "raised.hand"), color: .systemOrange) { [weak self] in
            let website = "https://www.privacypolicies.com/live/c487ac90-8f69-41b3-9327-d9e9ed7aa18c"
            let result = urlOpener.shared.verifyUrl(urlString: website)
            if result == true {
                if let url = URL(string: website ) {
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true)
                }
            } else {
                print("cant open url")
                let ac = UIAlertController(title: "invalid url", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            }
        },
        settingOption(title: "terms and conditions", image: UIImage(systemName: "raised.hand"), color: .systemOrange){ [weak self] in
            let vc = TermsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "report an issue", image: UIImage(systemName: "message"), color: .systemBlue){ [weak self] in
            let vc = ReportAnIssueViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }]))
        
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("sign out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        tableView.tableFooterView = footer
    }
    
    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(title: "sign out", message: "are you sure you want to sign out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "sign out", style: .destructive, handler: {
            [weak self] _ in
            AuthManager.shared.signOut {
                success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVc = UINavigationController(rootViewController: vc)
                        navVc.modalPresentationStyle = .fullScreen
                        self?.present(navVc, animated: true)
                    }
                } else {
                    print("failed to sign out")
                }
            }
        }))
        present(actionSheet, animated: true)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    
    
    

    

}


