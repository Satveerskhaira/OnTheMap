//
//  StudentLocation.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/13/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import Foundation
import MapKit

// MARK : StudentLocationAnnotation class to create MKAnnotation on mapview
class StudentLocationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

// MARK : StudentLocation class will store information of currect student geocoded location details. 
class StudentLocation  {
    var title : String
    var latitude : Double
    var longitude : Double
    init(title : String, latitude: Double, longitude : Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}
