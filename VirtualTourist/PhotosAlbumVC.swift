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

class PhotosAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
    // Mark: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).stack.context

    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin?
    var albumPhotos: [Photo]?
    
    let imageEncodingQ = DispatchQueue(label: "ImageEncoding", attributes: .concurrent)
    
    // Mark: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    func setupUI() {
        navigationController?.isNavigationBarHidden = false
        setFlowLayout()
        albumCollectionView?.reloadData()
        navigateToPin()
    }
    
    func setFlowLayout() {
        let interSpace: CGFloat = 3.0
        let lineSpace: CGFloat = 8.0
        let dimension = (view.frame.size.width - (2 * interSpace)) / 3.0
        
        flowLayout.minimumInteritemSpacing = interSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    // Mark: - Methods
    
    private func navigateToPin() {
        if let lat = pin?.latitude, let long = pin?.longitude {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
            let region = MKCoordinateRegionMake(location, span)
            
            topMapView.setRegion(region, animated: true)
        }
    }
    
    private func loadPhotos() {
        // if they are in the store, get them, then stop.
        let retrieved = pin?.photos
        if retrieved != nil && (retrieved?.count)! > 0 {
            albumCollectionView.reloadData()
        }
        // otherwise, get to flicker please.
    }
    
    
    // Mark: - Actions & Protocol

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell",
                                                      for: indexPath) as! AlbumCollectionViewCell
        let data = (pin?.photos?.allObjects as! [Data])[indexPath.row]
        
        cell.setImage(image: deserializePhoto(data)!)
        
        return cell
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
