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
    
    var apiClient = StudentsStorage.self
    var studentLocationAnnotation : [StudentLocationAnnotation] = []
    var myActivityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Appdelegate
        
        //Set MapView delegate
        mapView.delegate = self

        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
       //Create Activity Indicator
        activityIndicator(myActivityIndicator)
        
        // Add annotations
        addAnnotation()
       
    }
    
    @objc func logout() {
        updateUI(false, 0.5, false)
        UdacityClient.sharedInstance().logout { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.showAlert(error!, alertTitle: "Logout Failed", action: false, addLocationSegue: { (success) in
                    self.updateUI(true, 1.0, false)
                })
            }
        }
    }
    @IBAction func addNewLocation(_ sender: Any) {
        if (apiClient.sharedInstance().currentUserObjectID != nil) {
            showAlert("Student Location Already present. Do you want to override location", alertTitle: "Add Location", action: true, addLocationSegue: { (success) in
                if success {
                    self.performSegue(withIdentifier: "Add", sender: self)
                }
            })
        } else {
            self.performSegue(withIdentifier: "Add", sender: self)
        }
    }
    
    // MARK : Refresh data
    @IBAction func refresh(_ sender: Any) {
        refreshData()
    }
    
    // MARK: Add annotation on map
    
    func addAnnotation() {
        
        for student in (apiClient.sharedInstance().student) {
            if student.firstName == nil || student.lastName == nil || student.latitude == nil  || student.longitude == nil {
                // Do nothing
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
}


// MARK : MapView Delegate
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

// MARK : Navigation
extension MapViewController {
    
    // UnWind
    @IBAction func unwindSegue (segue : UIStoryboardSegue) {
        
        refreshData()
    }
    
    //MARK: Get Current student location information if present
    
    func refreshData() {
        updateUI(false, 0.5, false)
        mapView.isUserInteractionEnabled = false
        activity(myActivityIndicator, false)
        UdacityClient.sharedInstance().refreshData { (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.mapView.removeAnnotations(self.studentLocationAnnotation)
                    self.studentLocationAnnotation.removeAll()
                }
                self.updateUI(true, 1.0, true)
            } else {
                performUIUpdatesOnMain({
                    self.showAlert(error!, alertTitle: "Error Load Data from Network", action: false, addLocationSegue: { (success) in
                        // Do Nothing
                    })
                })
            }
        }
    }
    
    func updateUI(_ intractionEnabled : Bool, _ alpha : CGFloat, _ annotationAdd : Bool ) {
        performUIUpdatesOnMain {
            if annotationAdd {
               self.addAnnotation()
            }
            self.mapView.isUserInteractionEnabled = intractionEnabled
            self.mapView.alpha = alpha
            self.activity(self.myActivityIndicator, intractionEnabled)
        }
    }
}




