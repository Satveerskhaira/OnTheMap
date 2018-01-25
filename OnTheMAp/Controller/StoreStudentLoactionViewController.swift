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
    var appDelegate: UdacityClient!
     let regionRadius: CLLocationDistance = 1000000
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the app delegate
        appDelegate = UdacityClient.sharedInstance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        let searchLocation = MKLocalSearchRequest()
        searchLocation.naturalLanguageQuery = studentLocation
        
        // Set the region to an associated map view's region
        searchLocation.region = mapView.region
        
        let search = MKLocalSearch(request: searchLocation)
        
        search.start { (respone, error) in
            if error == nil {
                guard let res = respone else {
                    print("Response not recieved")
                    return
                }
                if res.mapItems.count == 0 {
                    print("No matches found")
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
                        break
                    }
                }
            }
            else {
                print("error occured while searching \(String(describing: error?.localizedDescription))")
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
       
        var url = "https://parse.udacity.com/parse/classes/StudentLocation"
        var method = ""
        if appDelegate.currentUserObjectID == nil {
            method = "POST"
        } else  {
            method = "PUT"
            url = url + "/\(appDelegate.currentUserObjectID!)"
        }
        guard let newLocation = newLocationcationDetail else {
            print("Location not found")
            return
        }
           UdacityClient.sharedInstance().postPut(newLocation, studentURL!, url, method: method, handlerForUpdate: { (success, error) in
                if success {
                    performUIUpdatesOnMain {
                        //code for unwind and reload
                        self.performSegue(withIdentifier: "unwind", sender: self)
                    }
                } else  {
                    print(error!)
                    return
                }
            })
    }
}
