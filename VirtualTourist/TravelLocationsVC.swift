//
//  TravelLocationsVC.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TravelLocationsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    // Mark: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pinAnnotations = [MKPointAnnotation]()
    
    var allPins: [Pin]?
    var currentLocation: Pin?
    
    
    // Mark: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        registerGestures()
        retrieveHistory()
    }
    
    
    // Mark: - Actions & Protocol
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    // Mark: - Methods
    
    
    private func retrieveHistory() {
        retrieveStoredPins()
        retrievePreviousLocation()
    }

    private func retrieveStoredPins() {
        
    }

    private func retrievePreviousLocation() {
        if currentLocation != nil {
            navigateTo(currentLocation)
        }
    }
    
    // Listen for long presses on the map view and invoke long gesture callback in repsonse.
    private func registerGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.allowableMovement = 15
        longPressGesture.delegate = self
        
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title = ""
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if error != nil {
                    print(error ?? "")
                    
                } else {
                    if let placemark = placemarks?[0] {
                        if let country = placemark.country {
                            title = country
                        }
                        
                        if let city = placemark.locality {
                            title += ", \(city)"
                        }
                        
                        if let thoroughfare = placemark.thoroughfare {
                            title += ", \(thoroughfare)"
                        }
                    }
                }
                
                if title == "" {
                    title = "Added in \(NSDate())"
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.mapView.addAnnotation(annotation)
            })
        }
        
    }
    
    private func navigateTo(_ location: Pin?) {
        if let location = location {
            let lat = location.latitude, long = location.longtitude
            let span = MKCoordinateSpanMake(0.5, 0.5)
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
            
            let region = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func buildPinsAnnotations() {
        cleanMap()
        
        if let all = allPins {
            for pin in all {
                let annotation = buildAnnotation(pin: pin)
                
                if let annotation = annotation {
                    pinAnnotations.append(annotation)
                }
            }
            
            mapView.addAnnotations(pinAnnotations)
        }
    }
    
    private func buildAnnotation(pin: Pin) -> MKPointAnnotation? {
        let lat = pin.latitude, long = pin.longtitude
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let latDegree = CLLocationDegrees(lat)
        let longDegree = CLLocationDegrees(long)
        let coordinate = CLLocationCoordinate2D(latitude: latDegree, longitude: longDegree)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = ""

        return annotation
    }
    

    private func cleanMap() {
        if pinAnnotations.count > 0 {
            mapView.removeAnnotations(pinAnnotations)
        }
    }
    
    // Mark: - Helpers
    
    private func persistPin() {
    }
}
