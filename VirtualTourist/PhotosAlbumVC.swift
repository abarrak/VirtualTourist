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

class PhotosAlbumVC: CoreDataCollectionViewController, MKMapViewDelegate {
    
    // Mark: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).stack.context

    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin?
    var albumPhotos = [UIImage]()
    
    let imageEncodingQ = DispatchQueue(label: "ImageEncoding", attributes: .concurrent)
    
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
                    let d = try? Data(contentsOf: URL(string: i["image_url"]!)!)
                    
                    performUIUpdatesOnMain {
                        self.albumPhotos.append(self.deserializePhoto(d!)!)
                        self.albumCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    // Mark: - Actions & Protocol

//    override func collectionView(_ collectionView: UICollectionView,
//                                 numberOfItemsInSection section: Int) -> Int {
//        return albumPhotos.count
//    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCellView",
                                                      for: indexPath) as! AlbumCollectionViewCell
        
        cell.setImage(image: deserializePhoto(photo.imgObject as! Data)!)
        return cell
    }
   
//    override func collectionView(_ collectionView: UICollectionView,
//                                 commit editingStyle: UICollectionCellEditingStyle,
//                                 forRowAt indexPath: IndexPath) {
//        
//        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo, editingStyle == .delete {
//            context.delete(photo)
//        }
//    }
    
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
