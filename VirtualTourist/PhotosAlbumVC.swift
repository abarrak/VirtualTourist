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

class PhotosAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
                     MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Mark: - Properties
    
    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin?
    
    let imageEncodingQ = DispatchQueue(label: "ImageEncoding", attributes: .concurrent)
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            albumCollectionView?.reloadData()
        }
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
        } else {
            print("already there")
        }
    }
    
    private func fetchNewPhotos() {
        let lat = (pin?.latitude)!
        let lon = (pin?.longitude)!
        
        FlickerClient.shared.searchForPhotos(latitude: lat, longitude: lon) {
            (success, photoDictionary, errorString) in
            
            if !success {
                performUIUpdatesOnMain { self.alertMessage("Failed", message: errorString!) }
                return
            }
            photoDictionary?.forEach() { (i) in
                let title = i["title"]
                let url   = i["image_url"]!
                let photoData = try? Data(contentsOf: URL(string: url)!)
                
                performUIUpdatesOnMain { self.createPhoto(title: title!, image: photoData! as NSData) }
            }
        }
    }
    
    // Add a photo to the store with association
    private func createPhoto(title: String, image: NSData) {
        let photo = Photo(title: title, image: image, context: context)
        photo.pin = pin
        pin?.addToPhotos(photo)
        
        super.saveInStore()
    }
    
    // Remove a photo from the store
    private func deletePhoto(_ indexPath: IndexPath) {
        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
            pin?.removeFromPhotos(photo)
            context.delete(photo)
            super.saveInStore()
        }
    }
    
    // Mark: - Actions & Protocol

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumViewCell",
                                                      for: indexPath) as! AlbumCollectionViewCell
        
        cell.setImage(image: deserializePhoto(photo.imgObject as! Data)!)
        return cell
    }

    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(indexPath)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            albumCollectionView?.insertSections(set)
        case .delete:
            albumCollectionView?.deleteSections(set)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            albumCollectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            albumCollectionView?.deleteItems(at: [indexPath!])
        case .update:
            albumCollectionView?.reloadItems(at: [indexPath!])
        case .move:
            albumCollectionView?.deleteItems(at: [indexPath!])
            albumCollectionView?.insertItems(at: [newIndexPath!])
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumCollectionView?.reloadData()
    }
    
    @IBAction func refreshPhotos(_ sender: UIBarButtonItem) {
//        if let _ = pin?.deleteAllPhotos(context: context) {
//            fetchNewPhotos()
//        } else {
//            alertMessage("Error", message: "Refresh falied. Try again.")
//        }
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
    
    private func deserializePhoto(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
