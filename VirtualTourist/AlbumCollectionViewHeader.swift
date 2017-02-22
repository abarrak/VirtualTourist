//
//  AlbumCollectionViewHeader.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/22/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit
import MapKit

class AlbumCollectionViewHeader: UICollectionReusableView {
    
    // Mark: - Properties
    
    @IBOutlet var topMapView: MKMapView!
    
    // Mark: - Methods
    
    func navigateToPin(pin: Pin?) {
        if let lat = pin?.latitude, let long = pin?.longitude {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
            let region = MKCoordinateRegionMake(location, span)
            
            topMapView.setRegion(region, animated: true)
        }
    }
}
