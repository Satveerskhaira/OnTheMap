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
    var studentLocation :String?
    var studentURL : String?
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var newLocationcatiolati : Double?
    var newlocationcatioLongi : Double?
    var newLocationcationTitle : String?
    var newLocationcationDetail : StudentLocation?
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                        
                        //Store value to
                        self.newLocationcationTitle = item.placemark.title!
                        self.newLocationcatiolati = item.placemark.coordinate.latitude
                        self.newlocationcatioLongi = item.placemark.coordinate.longitude

                        self.newLocationcationDetail?.title = item.placemark.title!
                        self.newLocationcationDetail?.latitude = item.placemark.coordinate.latitude
                        self.newLocationcationDetail?.longitude = item.placemark.coordinate.longitude
                        
                        self.matchingItems.append(item as MKMapItem)
                        
                        //Create one function for all Annotations
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.mapView.addAnnotation(annotation)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finish(_ sender: Any) {
       
        let url = "https://parse.udacity.com/parse/classes/StudentLocation"
        if appDelegate.currentUserObjectID == nil {
            postPut(url, method: "POST")
        } else  {
            postPut(url + "/\(appDelegate.currentUserObjectID!)", method: "PUT")
        }
    }
    
    func postPut (_ url: String, method : String) {
        let lastName = appDelegate.user!.user.lastName
        let firstName = appDelegate.user!.user.firstName
        let title = newLocationcationTitle!
        let lati = newLocationcatiolati!
        let longi = newlocationcatioLongi!
        let id = appDelegate.studentID!
        let stuURL = studentURL!
        
        // Calling method PUT or POST
        
       // var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        var request = URLRequest(url: URL(string: url)!)
        //request.httpMethod = "POST"
        request.httpMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(id)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(title)\", \"mediaURL\": \"\(stuURL)\",\"latitude\": \(lati), \"longitude\": \(longi)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            //print(String(data: data!, encoding: .utf8)!)
            
            performUIUpdatesOnMain {
                //code for unwind and reload
                self.performSegue(withIdentifier: "unwind", sender: self)
            }
        }
        task.resume()
    }
}
