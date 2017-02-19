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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).stack.context

    @IBOutlet weak var mapView: MKMapView!
    
    var pinAnnotations = [MKPointAnnotation]()
    var allPins: [Pin]?
    var currentLocation: Pin?
    var pinToOpen: Pin?
    
    // Mark: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerGestures()
        retrieveHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        print(allPins?.count ?? "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            try context.save()
        } catch {
            alertMessage("Failed", message: "Error while saving data.")
        }
    }
    
    // Mark: - Methods
    
    private func retrieveHistory() {
        retrieveStoredPins()
        retrievePreviousLocation()
    }
    
    private func retrieveStoredPins() {
        // If pins are on the map, exit.
        if allPins != nil {
            return
        }
        let all = Pin.all(context: context)
        
        if all != nil && (all?.count)! > 0 {
            allPins = all
            buildAnnotationsList()
        } else {
            alertMessage("Notice", message: "No Pin data are retrieved.")
        }
    }
    
    private func retrievePreviousLocation() {
        if currentLocation != nil {
            navigateTo(currentLocation)
        }
    }
    
    // Listen for long presses on the map view, and invoke long gesture callback in response.
    private func registerGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.allowableMovement = 15
        longPressGesture.delegate = self
        
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
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
    
    private func buildAnnotationsList() {
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
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let lat = pin.latitude, long = pin.longtitude
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat),
                                                longitude: CLLocationDegrees(long))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = pin.title
        
        return annotation
    }
    
    private func cleanMap() {
        if pinAnnotations.count > 0 {
            mapView.removeAnnotations(pinAnnotations)
        }
    }
    
    // Mark: - Actions & Protocol
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .blue
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        addPin(annotation)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            pinToOpen = pinFromAnnotation(annotation)
            performSegue(withIdentifier: "presentAlbumVC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentAlbumVC" {
            let albumVC = segue.destination as! PhotosAlbumVC
            albumVC.pin = pinToOpen
        }
    }

    // Mark: - Helpers
    
    private func pinFromAnnotation(_ annotation: MKAnnotation) -> Pin? {
        let c = annotation.coordinate
        return Pin.findBy(latitude: c.latitude, longtitude: c.longitude, context: context)
    }
    
    private func addPin(_ annotation: MKAnnotation) {
        let t = annotation.title!!
        let c = annotation.coordinate
        
        if let _ = allPins?.contains(where: { $0.latitude == c.latitude && $0.longtitude == c.longitude }){
            print("Found ..")
            return
        }
        
        print("will create new to be persisted")
        
        let _ = Pin(title: t, latitude: c.latitude, longtitude: c.longitude, context: context)
    }
}
