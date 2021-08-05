//
//  FullLengthSearchResultsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/20/21.
//

import UIKit

protocol FullLengthSearchResultsViewControllerDelegate: AnyObject {
    func FullLengthSearchResultsViewController(_ vc: FullLengthSearchResultsViewController, didSelectVideoWith video: FullLength)
}

class FullLengthSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var videos = [FullLength]()
    
    public weak var delegate: FullLengthSearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: VideoTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [FullLength]) {
        self.videos = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = self.videos.isEmpty
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier, for: indexPath) as! VideoTableViewCell
        //cell.textLabel?.text = users[indexPath.row].username
        cell.configure(with: videos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.FullLengthSearchResultsViewController(self, didSelectVideoWith: videos[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}




