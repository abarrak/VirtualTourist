//
//  PhotosAlbumVC.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class PhotosAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate,  NSFetchedResultsControllerDelegate {
    
    // Mark: - Properties
    
    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!

    private var blockOperations: [BlockOperation] = []
    
    var pin: Pin?
    
    let imageEncodingQ = DispatchQueue(label: "ImageEncoding", attributes: .concurrent)
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            albumCollectionView?.reloadData()
        }
    }
    
    // MARK: Deinit
    
    deinit {
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    // Mark: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
        loadPhotos()
    }
    
    // Mark: - Methods
    
    private func setupUI() {
        navigationController?.isNavigationBarHidden = false
        setFlowLayout()
        navigateToPin()
    }
    
    private func setFlowLayout() {
        let interSpace: CGFloat = 6.0
        let lineSpace: CGFloat = 7.0
        let dimension = (view.frame.size.width - (2 * interSpace)) / 3.0
        
        flowLayout.minimumInteritemSpacing = interSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func navigateToPin() {
        if let lat = pin?.latitude, let long = pin?.longitude {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
            let region = MKCoordinateRegionMake(location, span)
            
            topMapView.setRegion(region, animated: true)
        }
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    private func loadPhotos() {
        let retrieved = fetchedResultsController?.fetchedObjects
        
        // if they are no photos in the store, get them from flicker.
        if retrieved == nil || (retrieved?.count)! < 1 {
            fetchNewPhotos()
        }
    }
    
    private func fetchNewPhotos() {
        self.enableUI(false)

        let lat = (pin?.latitude)!
        let lon = (pin?.longitude)!
        
        FlickerClient.shared.searchForPhotos(latitude: lat, longitude: lon) {
            (success, photoDictionary, errorString) in
            
            if !success {
                performAsync { self.alertMessage("Failed", message: errorString!) }
            } else {
                
                photoDictionary?.forEach() { (i) in
                    
                    let title = i["title"]
                    let url   = i["image_url"]!
                    let photoData = try? Data(contentsOf: URL(string: url)!)
                    
                    performAsync {
                        self.createPhoto(title: title!, image: photoData! as NSData)
                    }
                }
                performAsync {
                    super.saveInStore()
                    self.enableUI(true)
                }
            }
        }
    }
    
    // Add a photo to the store with association
    private func createPhoto(title: String, image: NSData) {
        let photo = Photo(title: title, image: image, context: context)
        photo.pin = pin
        pin?.addToPhotos(photo)
    }
    
    // Remove a photo from the store
    private func deletePhoto(_ indexPath: IndexPath) {
        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
            pin?.removeFromPhotos(photo)
            context.delete(photo)
            super.saveInStore()
        }
    }
    
    // Mark: - Actions & Protocols
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumViewCell",
                                                      for: indexPath) as! AlbumCollectionViewCell
        
        cell.setImage(photo.imgObject as! Data)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(indexPath)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.insertItems(at: [newIndexPath]) }
            blockOperations.append(op)
            
        case .update:
            guard let newIndexPath = newIndexPath else { return }
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.reloadItems(at: [newIndexPath]) }
            blockOperations.append(op)
            
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.moveItem(at: indexPath, to: newIndexPath) }
            blockOperations.append(op)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.deleteItems(at: [indexPath]) }
            blockOperations.append(op)
        }
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            
        case .insert:
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        case .update:
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        case .delete:
            let op = BlockOperation { [weak self] in
                self?.albumCollectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        default:
            break
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumCollectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }

    @IBAction func refreshPhotos(_ sender: UIBarButtonItem) {
        enableUI(false)
        
        // Delete all model photos ..
        albumCollectionView.performBatchUpdates({
            let photos = self.pin?.photos
            for p in photos! {
                self.context.delete(p as! Photo)
            }
        }, completion: nil)

        super.saveInStore()
        
        // get new collection ..
        fetchNewPhotos()
    }
    
    // Mark: - Helpers
    
    private func enableUI(_ enabled: Bool) {
        newCollectionButton.isEnabled = enabled
    }
    
    private func serializePhoto(_ photo: UIImage) -> Data? {
        guard let seralized = UIImageJPEGRepresentation(photo, 1) else {
            alertMessage("Error", message: "Photo is not saved !")
            return nil
        }
        return seralized
    }
}
