//
//  StoreStudentLoactionViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/17/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit
import MapKit
class StoreStudentLoactionViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // Properties
    var studentLocation :String?
    var studentURL : String?
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var newLocationcationDetail : StudentLocation!
    let regionRadius: CLLocationDistance = 1000000
    var myActivityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var finished: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create Activity Indicator
        activityIndicator(myActivityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.updateUI(false, 0.5)
        // Do any additional setup after loading the view.
        let searchLocation = MKLocalSearchRequest()
        searchLocation.naturalLanguageQuery = studentLocation
        
        // Set the region to an associated map view's region
        searchLocation.region = mapView.region
        
        let search = MKLocalSearch(request: searchLocation)
        
        search.start { (respone, error) in
            
            
            if error == nil {
                guard let res = respone else {
                    self.showAlert("Network issue while finding Location, Search again", alertTitle: "Location", action: false, addLocationSegue: { (success) in
                        self.updateUI(true, 1.0)
                    })
                    return
                }
                if res.mapItems.count == 0 {
                    self.showAlert("Location not found, Search again", alertTitle: "Location", action: false, addLocationSegue: { (success) in
                        self.updateUI(true, 1.0)
                    })
                } else {
                    for item in res.mapItems {
                    
                        self.newLocationcationDetail = StudentLocation(title: item.placemark.title!, latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                        self.matchingItems.append(item as MKMapItem)
                        
                        //Create one function for all Annotations
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.mapView.addAnnotation(annotation)
                        self.centerMapOnLocation(location: CLLocation.init(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
                        self.updateUI(true, 1.0)
                        break
                    }
                }
            }
            else {
                self.showAlert("Could not Geocode the string, Search again", alertTitle: "Location not found", action: false, addLocationSegue: { (success) in
                    self.updateUI(true, 1.0)
                })
                return
            }
        }
    }
    

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : Add new location
    @IBAction func finish(_ sender: Any) {
       
        if matchingItems.count == 0 {
            self.showAlert("Location not found, Search again", alertTitle: "New Location", action: false) {(success) in
                //Do nothing
            }
        } else {
            
            guard let newLocation = newLocationcationDetail else {
                self.showAlert("Location not found, Search again", alertTitle: "New Location", action: false) {(success) in
                    //Do nothing
                }
                return
            }
            UdacityClient.sharedInstance().postPut(newLocation, studentURL!, handlerForUpdate: { (success, error) in
                if success {
                    performUIUpdatesOnMain {
                        //code for unwind and reload
                        self.performSegue(withIdentifier: "unwind", sender: self)
                    }
                } else  {
                    self.showAlert(error!, alertTitle: "New location Posting failed", action: false) {(success) in
                        //Do nothing
                    }
                    return
                }
            })
        }
    }

    // MARK : Activity controller
    
    func updateUI(_ intractionEnabled : Bool, _ alpha : CGFloat ) {
        performUIUpdatesOnMain {
            self.finished.isEnabled = intractionEnabled
            self.mapView.isUserInteractionEnabled = intractionEnabled
            self.mapView.alpha = alpha
            self.activity(self.myActivityIndicator, intractionEnabled)
        }
    }

}

