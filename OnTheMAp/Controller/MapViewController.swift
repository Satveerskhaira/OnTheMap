//
//  FirstViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    //properties for student array
    
    var appDelegate: UdacityClient!
    var studentLocationAnnotation : [StudentLocationAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Appdelegate
        
        // get the app delegate
        appDelegate = UdacityClient.sharedInstance()
        
        //Set MapView delegate
        mapView.delegate = self

        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        for student in (appDelegate.student) {
            if student.firstName == nil || student.lastName == nil || student.latitude == nil  || student.longitude == nil {
                print("Data with error \(student)")
            } else {
            
            let studentLocation = StudentLocationAnnotation(title: ((student.firstName)! + " " + (student.lastName)!),
                                                            locationName: student.mediaURL!,
                                                    discipline: "Udacity",
                                                    coordinate: CLLocationCoordinate2D(latitude: (student.latitude)!, longitude: (student.longitude)!))

            studentLocationAnnotation.append(studentLocation)
            }
        }
        
        mapView.addAnnotations(studentLocationAnnotation)
        
    }

    
    let regionRadius: CLLocationDistance = 1000000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    @objc func logout() {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            self.dismiss(animated: true, completion: nil)
        }
        task.resume()
        
    }
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? StudentLocationAnnotation else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK : unwind segue
extension MapViewController {
    
    @IBAction func unwindSegue (segue : UIStoryboardSegue) {
        if let sender = segue.source as? StoreStudentLoactionViewController {
            print(sender.newLocationcatiolati)
            let studentLocation = StudentLocationAnnotation(title: ((appDelegate.user!.user.firstName) + " " + (appDelegate.user!.user.lastName)),
                                                            locationName: sender.studentURL!,
                                                            discipline: "Udacity",
                                                            coordinate: CLLocationCoordinate2D(latitude: (sender.newLocationcatiolati)!, longitude: (sender.newlocationcatioLongi)!))
            
            studentLocationAnnotation.append(studentLocation)
            mapView.addAnnotations(studentLocationAnnotation)
        }
        //currentStudentLocation()
    }
    
    //MARK: Get Current student location information if present
    
    func currentStudentLocation() {
        // Student data
        //let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(self.appDelegate.studentID)%22%7D"
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%224343538699%22%7D"
        
        print(urlString)
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(Student.self, from: data!)
                if parseResult.results.count != 0 {
                    self.appDelegate!.student.append(contentsOf: parseResult.results)
                }
                
            } catch {
                print("Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
                return
            }
        }
        task.resume()
        
    }
}

