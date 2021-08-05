//
//  ResaleViewController.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class ResaleViewController: UIViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       
    }
    
    //MARK: resale properties
    
    private var items: [Post] = []
    
    private var allLocalItems: [Post] = []
    
    private var allShoeItems: [Post] = []
    
    private var allPantsItems: [Post] = []
    
    private var allShirtItems: [Post] = []
    
    private var allDeckItems: [Post] = []
    
    private var allWheelItems: [Post] = []
    
    private var allTruckItems: [Post] = []
    
    private var allHeadgearItems: [Post] = []
    
    private var hasShoeBeenCalled = false
    
    private var hasHeadgearBeenCalled = false
    
    private var hasShirtBeenCalled = false
    
    private var hasPantsBeenCalled = false
    
    private var hasWheelBeenCalled = false
    
    private var hasDeckBeenCalled = false
    
    private var hasTruckBeenCalled = false
    
    private var isCurrentlyLocalFeed = true
    
    private var isCurrentlyShoeFeed = false
    
    private var isCurrentlyPantsFeed = false
    
    private var isCurrentlyShirtFeed = false
    
    private var isCurrentlyDeckFeed = false
    
    private var isCurrentlyWheelFeed = false
    
    private var isCurrentlyTruckFeed = false
    
    private var isCurrentlyHeadwearFeed = false
    
    private var collectionView: UICollectionView?
    
    private var lastDocumentLocal: DocumentSnapshot?
    
    private var lastDocumentShoe: DocumentSnapshot?
    
    private var lastDocumentShirt: DocumentSnapshot?
    
    private var lastDocumentPants: DocumentSnapshot?
    
    private var lastDocumentDeck: DocumentSnapshot?
    
    private var lastDocumentWheel: DocumentSnapshot?
    
    private var lastDocumentTruck: DocumentSnapshot?
    
    private var lastDocumentHeadwear: DocumentSnapshot?
    
    private var blockUsers: [String] = []
    
    
    

    //MARK: authorization properties
    
    private var cameraAuthorizationStatus = RequestCameraAuthorizationController.getCameraAuthorizationStatus()
    
    private var MicrophoneAuthorizationStatus = RequestMicrophoneAuthorizationController.getMicrophoneAuthorizationStatus()
    
    
    private var PhotoLibraryAuthorizationStatus = RequestPhotoLiobraryAuthorizationController.getPhotoLibraryAuthorizationStatus()
    
    private var locationAuthorizationStatus =  CLLocationManager.authorizationStatus()

    
    //private var observer: NSObjectProtocol

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LOCAL RESALE"
        view.backgroundColor = .systemBackground
        let filter = UIBarButtonItem(title: "filter", style: .done, target: self, action: #selector(didTapFilter))
        let add = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapAdd))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        navigationItem.rightBarButtonItems = [add, spacer]
        navigationItem.leftBarButtonItems = [filter, spacer]
        
        fetchLocalItems()
        configureCollectionView()
        
        self.blockUsers = infoManager.shared.blockUsers
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "LOCAL RESALE"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = "RESALE"
    }
    
    //MARK: adding content

    @objc func didTapAdd() {
        let ac = UIAlertController(title: "select an upload option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "upload a clip", style: .default) { [weak self] _ in

            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = ClipCheckPermisssionsViewController(spot: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = ClipAskForSpotViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a spot", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
                let vc = CheckSpotPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            
            let vc = SpotCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload an item for local resale", style: .default) { [weak self] _ in
            guard self?.cameraAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            guard self?.MicrophoneAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
                
            }
            
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = GearPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            let vc = GearCameraViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "upload a normal post", style: .default, handler: {
            [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckNormalPhotoLibraryAccessViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = uploadNormalPostViewController(images: [])
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
            
            
        ac.addAction(UIAlertAction(title: "upload a full length", style: .default) { [weak self] _ in
            guard self?.PhotoLibraryAuthorizationStatus == .granted else {
                let vc = CheckPhotoLibraryPermissionsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let vc = FulllengthUploadViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    
    
    //MARK: filtering posts
    
    
    @objc func didTapFilter() {
        
        //when the user chooses to filter, first the functions will check if they had already filtered for this type of item before, if they didnt, then it will do the initial fetch for these items, if they did then the collection view will be loaded with the data they had already grabbed
        //when grabbing post it will also check if the post has been uploaded by a blocked user
        
        
        guard let region = UserDefaults.standard.string(forKey: "region") else {
            print("returned")
            return}
        
        let ac = UIAlertController(title: "filter by", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "shoes", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = true
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            guard let boolean = self?.hasShoeBeenCalled else {
                print("has been returned")
                return}
            if boolean {
                guard let allItems = self?.allShoeItems else {
                    return}
                self?.items = allItems
                self?.collectionView?.reloadData()
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "shoe", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    guard let last = lastDoc else {
                        guard let allItemsShoes = self?.allShoeItems else {return}
                        self?.items = allItemsShoes
                        self?.collectionView?.reloadData()
                        return}
                    self?.lastDocumentShoe = last
                    self?.allShoeItems = allItems
                    self?.items = allItems
                    self?.hasShoeBeenCalled = true
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                    
                })
            }
            
        }))
        ac.addAction(UIAlertAction(title: "shirts", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = true
            self?.isCurrentlyHeadwearFeed = false
            
            guard let boolean = self?.hasShirtBeenCalled else {return}
            if boolean {
                
                    guard let allItems = self?.allShirtItems else {return}
                    self?.items = allItems
                    self?.collectionView?.reloadData()
                
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "shirt", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    guard let last = lastDoc else {
                        guard let AllItemsShirt = self?.allShirtItems else {return}
                        self?.items = AllItemsShirt
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return
                    }
                    self?.lastDocumentShirt = last
                    self?.allShirtItems = allItems
                    self?.items = allItems
                    self?.hasShirtBeenCalled = true
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
        }))
        ac.addAction(UIAlertAction(title: "pants", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = true
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            guard let boolean = self?.hasPantsBeenCalled else {return}
            if boolean {
                DispatchQueue.main.async {
                    guard let allItems = self?.allPantsItems else {return}
                    self?.items = allItems
                    self?.collectionView?.reloadData()
                }
                
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "pants", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {
                        guard let allItemsPants = self?.allPantsItems else {return}
                        self?.items = allItemsPants
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return}
                    self?.lastDocumentPants = last
                    self?.allPantsItems = allItems
                    self?.items = allItems
                    self?.hasPantsBeenCalled = true
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
        }))
        ac.addAction(UIAlertAction(title: "decks", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = true
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            guard let boolean = self?.hasDeckBeenCalled else {return}
            if boolean {
                DispatchQueue.main.async {
                    guard let allItems = self?.allDeckItems else {return}
                    self?.items = allItems
                    self?.collectionView?.reloadData()
                }
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "deck", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {
                        guard let allItemsDeck = self?.allDeckItems else {return}
                        self?.items = allItemsDeck
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return}
                    self?.lastDocumentDeck = last
                    DispatchQueue.main.async {
                        self?.allDeckItems = allItems
                        self?.items = allItems
                        self?.hasDeckBeenCalled = true
                        self?.collectionView?.reloadData()
                        
                    }
                })
            }
            
            
            
        }))
        ac.addAction(UIAlertAction(title: "trucks", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = true
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            guard let boolean = self?.hasTruckBeenCalled else {return}
            if boolean {
                DispatchQueue.main.async {
                    guard let allItems = self?.allTruckItems else {return}
                    self?.items = allItems
                    self?.collectionView?.reloadData()
                }
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "truck", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {
                        guard let allItemsTruck = self?.allTruckItems else {return}
                        self?.items = allItemsTruck
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return}
                    self?.lastDocumentTruck = last
                    DispatchQueue.main.async {
                        self?.allTruckItems = allItems
                        self?.items = allItems
                        self?.hasTruckBeenCalled = true
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
        }))
        ac.addAction(UIAlertAction(title: "wheels", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = true
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            guard let boolean = self?.hasWheelBeenCalled else {return}
            if boolean {
                DispatchQueue.main.async {
                    guard let allItems = self?.allWheelItems else {return}
                    self?.items = allItems
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "wheel", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    guard let last = lastDoc else {
                        guard let allItemsWheel = self?.allWheelItems else {return}
                        self?.items = allItemsWheel
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return}
                    self?.lastDocumentWheel = last
                    DispatchQueue.main.async {
                        self?.allWheelItems = allItems
                        self?.items = allItems
                        self?.hasWheelBeenCalled = true
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
            
        }))
        ac.addAction(UIAlertAction(title: "headgear", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = false
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = true
            guard let boolean = self?.hasHeadgearBeenCalled else {return}
            if boolean {
                DispatchQueue.main.async {
                    guard let allItems = self?.allHeadgearItems else {return}
                    self?.items = allItems
                    self?.collectionView?.reloadData()
                }
            } else {
                var allItems: [Post] = []
                DatabaseManager.shared.filterItemsForRegion(region: region, type: "headgear", completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    guard let last = lastDoc else {
                        guard let allItemsHeadgear = self?.allHeadgearItems else {return}
                        self?.items = allItemsHeadgear
                        DispatchQueue.main.async {
                            self?.collectionView?.reloadData()
                        }
                        return}
                    self?.lastDocumentHeadwear = last
                    self?.allHeadgearItems = allItems
                    self?.items = allItems
                    self?.hasHeadgearBeenCalled = true
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                    
                })
            }
            
        }))
        ac.addAction(UIAlertAction(title: "all for local region", style: .default, handler: {
            [weak self] _ in
            self?.isCurrentlyShoeFeed = false
            self?.isCurrentlyLocalFeed = true
            self?.isCurrentlyDeckFeed = false
            self?.isCurrentlyPantsFeed = false
            self?.isCurrentlyWheelFeed = false
            self?.isCurrentlyTruckFeed = false
            self?.isCurrentlyShirtFeed = false
            self?.isCurrentlyHeadwearFeed = false
            DispatchQueue.main.async {
                guard let allItems = self?.allLocalItems else {return}
                self?.items = allItems
                self?.collectionView?.reloadData()
            }
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
        
        
    }
    
    //MARK: blocking users
    
    private func blockAUser(email: String, currentEmail: String) {
        let ac = UIAlertController(title: "are you sure?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "block", style: .destructive, handler: {
            [weak self] _ in
            DatabaseManager.shared.blockUser(email: email, currentEmail: currentEmail, completion: {
                [weak self] success in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("userDidChangeBlock"), object: nil)
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    //MARK: when they first go to this tab it will grab local all local items

    
    private func fetchLocalItems() {
        var allItems: [Post] = []
        
        guard let region = UserDefaults.standard.string(forKey: "region") else { return }
        
        print("region \(region)")
        
        DatabaseManager.shared.getAllItemsForRegion(region: region, completion: { [weak self] items, lastDoc in
            var filteredItems = items
            for (index, post) in items.enumerated() {
                guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                if isBlocked {
                    filteredItems.remove(at: index)
                }
            }
            allItems = filteredItems
            guard let last = lastDoc else {return}
            self?.items = allItems
            DispatchQueue.main.async {
                self?.lastDocumentLocal = last
                self?.allLocalItems = allItems
                self?.collectionView?.reloadData()
                
            }
        })
    
    }
    
}

//MARK: collection view functions

extension ResaleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        guard let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        collectionView.deselectItem(at: indexPath, animated:true)
        var item = items[indexPath.row]
        let vc = ItemDetailViewController(post: item)
        vc.completion = {
            [weak self] bool in
            if bool {
                NotificationCenter.default.post(name: Notification.Name("didChangePost"), object: nil)
                
                if item.savers.contains(email) {
                    item.savers.removeAll { $0 == email }
                } else {
                    item.savers.append(email)
                }
                self?.items[indexPath.row] = item
                
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //when the user scrolls to the bottom it will paginate for the next posts according to their current feed and the last document grabbed for that feed
        
        let position = scrollView.contentOffset.y
        guard let collectionHeight = collectionView?.contentSize.height else { return }
        if position > collectionHeight - 100 - scrollView.frame.size.height {
        
            guard !DatabaseManager.shared.isPaginating else  {
                return
            }
            
            if isCurrentlyLocalFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentLocal else {return}
                DatabaseManager.shared.continueGetAllItemsForRegion(region: region, lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentLocal = last
                    guard let alreadyFetchedItems = self?.allLocalItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allLocalItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
                
            }
            
            if isCurrentlyShoeFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentShoe else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "shoe", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentShoe = last
                    guard let alreadyFetchedItems = self?.allShoeItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allShoeItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                    
                })
                
            }
            
            if isCurrentlyShirtFeed{
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentShirt else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "shirt", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentShirt = last
                    guard let alreadyFetchedItems = self?.allShirtItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allShirtItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
                
            }
            
            if isCurrentlyHeadwearFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentHeadwear else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "headgear", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentHeadwear = last
                    guard let alreadyFetchedItems = self?.allHeadgearItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allHeadgearItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
            if isCurrentlyTruckFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentTruck else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "truck", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    guard let last = lastDoc else {return}
                    self?.lastDocumentTruck = last
                    guard let alreadyFetchedItems = self?.allTruckItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allTruckItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
            if isCurrentlyPantsFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentPants else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "pants", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentPants = last
                    guard let alreadyFetchedItems = self?.allPantsItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allPantsItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
            
            if isCurrentlyDeckFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentDeck else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "deck", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentDeck = last
                    guard let alreadyFetchedItems = self?.allDeckItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allDeckItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
                
            }
            if isCurrentlyWheelFeed {
                var allItems: [Post] = []
                guard let region = UserDefaults.standard.string(forKey: "region") else {return}
                guard let lastDoc = self.lastDocumentWheel else {return}
                DatabaseManager.shared.continueFilteritemsForRegion(region: region, type: "wheel", lastDoc: lastDoc, completion: {
                    [weak self] items, lastDoc in
                    var filteredItems = items
                    for (index, post) in items.enumerated() {
                        guard let isBlocked = self?.blockUsers.contains(post.posterEmail) else {return}
                        if isBlocked {
                            filteredItems.remove(at: index)
                        }
                    }
                    allItems = filteredItems
                    
                    guard let last = lastDoc else {return}
                    self?.lastDocumentWheel = last
                    guard let alreadyFetchedItems = self?.allWheelItems else {return}
                    let newGroup = alreadyFetchedItems + allItems
                    self?.items = newGroup
                    self?.allWheelItems = newGroup
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                })
            }
        }
    }
}

//MARK: configuring collectionview

extension ResaleViewController {
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

//MARK: search results delegate

extension ResaleViewController: searchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: searchresultsViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

