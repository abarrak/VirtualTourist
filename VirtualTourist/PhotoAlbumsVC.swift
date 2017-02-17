//
//  PhotoAlbumsVC.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PhotoAlbumsVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    // Mark: - Properties
    
    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var albumPhotos = [Photo]()

    // Mark: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        setFlowLayout()
        albumCollectionView?.reloadData()
    }


    // Mark: - Actions & Protocol

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath)
        
        return cell
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


    // Mark: - Helpers
}
