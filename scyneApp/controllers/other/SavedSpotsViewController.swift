//
//  SavedSpotsViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/19/21.
//

import UIKit

class SavedSpotsViewController: UIViewController {
    
    private var spots: [Post] = []
    
    private var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "saved spots"
        view.backgroundColor = .systemBackground
        
        grabSpots()
        configureCollectionView()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func grabSpots() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        let group = DispatchGroup()
        
        DatabaseManager.shared.grabSavedSpots(for: email, completion: {
            [weak self] spots in
            
            guard let fetchedSpots = spots else {return}
            
            for spot in fetchedSpots {
                print("hey this one")
                print(spot)
                group.enter()
            }
            
            for spot in fetchedSpots {
                DatabaseManager.shared.getPost(with: spot, completion: { [weak self] grabbedSpot in
                    group.leave()
                    guard let strongSelf = self else {return}
                    
                    if let grabbedSpot = grabbedSpot {
                        strongSelf.spots.append(grabbedSpot)
                    }
                    
                })
            }
            
            group.notify(queue: .main, execute: {
                self?.collectionView?.reloadData()
            })
           
        })
        
    }
    
   
}

extension SavedSpotsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        let Images = spots[indexPath.row].photoUrls
        guard let firstImage = Images.first else {return cell}
        guard let spotIdent = spots[indexPath.row].spotId else {return cell}
        cell.configure(with: URL(string: firstImage), id: spotIdent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated:true)
        let spot = spots[indexPath.row]
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") else {return}
        let saveStatus = spot.savers.contains(currentEmail)
        
        guard let addy = spot.address else {return }
        guard let type = spot.spotType else {return}
        guard let ident = spot.spotId else {return}
        guard let nickname = spot.nickname else {return}
        guard let lat = spot.latitude else {return}
        guard let long = spot.longitude else {return}
        guard let info = spot.caption else {return}
        
        
        let vc = SpotDetailViewController(spot: SpotModel(location: addy, spotPhotoUrl: spot.photoUrls, spotType: type, nickName: nickname, postedBy: spot.posterEmail, latitude: lat, longitude: long, spotId: ident, savers: spot.savers, spotInfo: info, isSaved: saveStatus), post: spot)
        vc.completion = { [weak self] bool in
            if bool {
                DispatchQueue.main.async {
                    self?.spots.remove(at: indexPath.row)
                    self?.collectionView?.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("didPost"), object: nil)
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SavedSpotsViewController {
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
