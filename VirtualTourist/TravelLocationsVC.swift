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
import CoreData

class TravelLocationsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // Mark: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pinAnnotations = [MKPointAnnotation]()
    var allPins: [Pin]?
    var pinToOpen: Pin?
    
    // Mark: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerGestures()
        retrieveHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveInStore()
        persistCurrentLocation()
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
            alertMessage("Notice", message: "There are no pins yet.")
        }
    }
    
    // Get previous MapView visible location that user left the app on.
    private func retrievePreviousLocation() {
        let location = UserDefaults.standard.dictionary(forKey: "last-location-on-map")

        if location != nil {
            let x = location?["x"] as! Double
            let y = location?["y"] as! Double
            let h = location?["h"] as! Double
            let w = location?["w"] as! Double

            let mapRect = MKMapRect(origin: MKMapPoint(x: x, y: y), size: MKMapSize(width: w, height: h))
            mapView.setVisibleMapRect(mapRect, animated: true)
        }
    }
    
    // Preserve current visible location on the map for the app next session.
    private func persistCurrentLocation() {
        let current = mapView.visibleMapRect
        let x = current.origin.x
        let y = current.origin.y
        let h = current.size.height
        let w = current.size.width
        
        let mapRectHashie = ["x": x, "y": y, "h": h, "w": w]
        
        UserDefaults.standard.set(mapRectHashie, forKey: "last-location-on-map")
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
        let lat = pin.latitude, long = pin.longitude
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
    
    private func pinFromAnnotation(_ annotation: MKAnnotation) -> Pin? {
        let c = annotation.coordinate
        return Pin.findBy(latitude: c.latitude, longitude: c.longitude, context: context)
    }
    
    private func addPin(_ annotation: MKAnnotation) {
        let t = annotation.title!!
        let c = annotation.coordinate
        let any = allPins?.contains(where: { $0.latitude == c.latitude && $0.longitude == c.longitude })
        if let _ = any {
            return
        }
        
        let pin = Pin(title: t, latitude: c.latitude, longitude: c.longitude, context: context)
        allPins?.append(pin)
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

            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true),
                                  NSSortDescriptor(key: "title", ascending: false)]
            
            let pred = NSPredicate(format: "pin = %@", argumentArray: [pinToOpen!])
            
            fr.predicate = pred
            
            // Create FetchedResultsController
            let fc = NSFetchedResultsController(fetchRequest: fr,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
            // Inject it into the albumVC
            albumVC.fetchedResultsController = fc
            
            // Inject the pin too!
            albumVC.pin = pinToOpen
        }
    }
}
