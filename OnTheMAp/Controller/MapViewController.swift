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
    
    var appDelegate: AppDelegate!
    var studentLocationAnnotation : [StudentLocationAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Appdelegate
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Set MapView delegate
        mapView.delegate = self

        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        for student in (appDelegate.student?.results)! {
            let studentLocation = StudentLocationAnnotation(title: ((student.firstName) + " " + (student.lastName)),
                                                    locationName: student.mediaURL,
                                                    discipline: "Udacity",
                                                    coordinate: CLLocationCoordinate2D(latitude: (student.latitude), longitude: (student.longitude)))

            studentLocationAnnotation.append(studentLocation)
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
        dismiss(animated: true, completion: nil)
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
