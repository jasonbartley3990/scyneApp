//
//  SavedItemsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/19/21.
//

import UIKit

class SavedItemsViewController: UIViewController {
    
    private var items: [Post] = []
    
    private var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "saved items"
        view.backgroundColor = .systemBackground
        grabItems()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func grabItems() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        let group = DispatchGroup()
        
        DatabaseManager.shared.grabSavedItems(for: email, completion: {
            [weak self] items in
            
            guard let fetchedItems = items else {return}
            
            let fetchitemCount = fetchedItems.count
            
            for _ in fetchedItems {
                group.enter()
            }
            
            for item in fetchedItems {
                DatabaseManager.shared.getItem(with: item, completion: { [weak self] grabbedItem in
                    group.leave()
                    guard let strongSelf = self else {
                        return}
                    
                    if let grabbedItem = grabbedItem {
                        strongSelf.items.append(grabbedItem)
                    }
                })
            }
            
            group.notify(queue: .main, execute: {
                print("here here")
                self?.collectionView?.reloadData()
            })
           
        })
        
    }
    
    

}

extension SavedItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        let images = items[indexPath.row].photoUrls
        guard let image = images.first else {return cell}
        cell.configure(with: URL(string: image), id: items[indexPath.row].postId)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated:true)
        let item = items[indexPath.row]
        let vc = ItemDetailViewController(post: item)
        vc.completion = {
            [weak self] bool in
            if bool {
                DispatchQueue.main.async {
                    self?.items.remove(at: indexPath.row)
                    self?.collectionView?.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("didPost"), object: nil)
                }
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SavedItemsViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {
            index, _ -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33)), subitem: item, count: 3)
            
            let section = NSCollectionLayoutSection(group: group)

            
            return section
        })
        
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
}
