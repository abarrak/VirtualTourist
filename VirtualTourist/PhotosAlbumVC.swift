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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).stack.context
    
    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin?
    
    let imageEncodingQ = DispatchQueue(label: "ImageEncoding", attributes: .concurrent)
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and reload the table
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
    
    func setupUI() {
        navigationController?.isNavigationBarHidden = false
        setFlowLayout()
        navigateToPin()
    }
    
    func setFlowLayout() {
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
    
    private func loadPhotos() {
        let retrieved = fetchedResultsController?.fetchedObjects

        // if they are no photos in the store, get them from flicker.
        if retrieved == nil || (retrieved?.count)! < 1 {
            FlickerClient.shared.searchForPhotos(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!) {
                (success, photoDictionary, errorString) in
                
                if !success {
                    performUIUpdatesOnMain { self.alertMessage("Failed", message: errorString!) }
                    return
                }
                photoDictionary?.forEach() { (i) in
                    let t = i["title"]!
                    let d = try? Data(contentsOf: URL(string: i["image_url"]!)!)

                    performUIUpdatesOnMain {
                        let photo = Photo(title: t, image: d! as NSData, context: self.context)
                        photo.pin = self.pin
                        self.pin?.addToPhotos(photo)
                        do {
                         try self.context.save()
                        } catch {
                            
                        }
                    }
                }
                // performUIUpdatesOnMain { self.albumCollectionView.reloadData() }
            }
        } else {
            print("Already there !")
        }
    }
    
    private func deletePhoto(indexPath: IndexPath) {
        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
            context.delete(photo)
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
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
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
    
    // Mark: - Helpers

    private func enableUI(_ enabled: Bool) {
        newCollectionButton.isEnabled = enabled
    }
    
    private func serializePhoto(_ photo: UIImage) -> Data? {
        guard let seralized = UIImageJPEGRepresentation(photo, 1) else {
            alertMessage("Error", message: "Photo not saved !")
            return nil
        }
        return seralized
    }
    
    private func deserializePhoto(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
