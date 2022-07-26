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
        sections.append(settingsSection(title: "App", options: [settingOption(title: "Rate App", image: UIImage(systemName: "star"), color: .systemOrange) { [weak self] in
            guard let scene = self?.view.window?.windowScene else {return}
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                let ac = UIAlertController(title: "Unable to bring up app review", message: "current iOS version does not sopport this", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel))
                self?.present(ac, animated: true)
            }
           
        },
        settingOption(title: "Saved Spots", image: UIImage(systemName: "square.and.arrow.down"), color: .label) { [weak self] in
            let vc = SavedSpotsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "Saved Items", image: UIImage(systemName: "square.and.arrow.down"), color: .label) { [weak self] in
            let vc = SavedItemsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "Blocked Users", image: UIImage(systemName: "xmark.octagon"), color: .label) { [weak self] in
            let vc = BlockedUsesViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "Change Local Region", image: UIImage(systemName: "house"), color: .label) { [weak self] in
            //available on next update
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "This function will be available next update", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            }
        }]))
        sections.append(settingsSection(title: "Information", options: [ settingOption(title: "Post Advertisements", image: UIImage(systemName:"eye"), color: .label, handler: { [weak self] in
            let vc = AdvertismentMenuViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }),
        settingOption(title: "Privacy Policy", image: UIImage(systemName: "raised.hand"), color: .systemOrange) { [weak self] in
            let website = "https://www.privacypolicies.com/live/c487ac90-8f69-41b3-9327-d9e9ed7aa18c"
            let result = urlOpener.shared.verifyUrl(urlString: website)
            if result == true {
                if let url = URL(string: website ) {
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true)
                }
            } else {
                let ac = UIAlertController(title: "Invalid url", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self?.present(ac, animated: true)
            }
        },
        settingOption(title: "Terms and Conditions", image: UIImage(systemName: "raised.hand"), color: .systemOrange){ [weak self] in
            let vc = TermsViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "Report An Issue", image: UIImage(systemName: "message"), color: .systemBlue){ [weak self] in
            let vc = ReportAnIssueViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        },
        settingOption(title: "Delete Account", image: UIImage(systemName: "trash"), color: .systemRed){ [weak self] in
            let ac = UIAlertController(title: "Are you sure you want to delete account?", message: "This action cannot be undone", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { _ in
                guard let email = UserDefaults.standard.string(forKey: "email") else {
                    self?.showDeletionError()
                    return
                }
                DatabaseManager.shared.deleteAccount(email: email, completion: {
                    [weak self] success in
                    if success {
                        AuthManager.shared.deleteAUser(completion: {
                            success in
                            if success {
                                DispatchQueue.main.async {
                                    let vc = SignInViewController()
                                    let navVc = UINavigationController(rootViewController: vc)
                                    navVc.modalPresentationStyle = .fullScreen
                                    self?.present(navVc, animated: true)
                                }
                            } else {
                                self?.showDeletionError()
                            }
                        })
                    } else {
                        self?.showDeletionError()
                    }
                })
                
            }))
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self?.present(ac, animated: true, completion: nil)
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
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        tableView.tableFooterView = footer
    }
    
    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
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
    
    func showDeletionError() {
        let ac = UIAlertController(title: "Unable to delete account at this moment", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        self.present(ac, animated: true)
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


