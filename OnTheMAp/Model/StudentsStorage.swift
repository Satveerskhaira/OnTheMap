//
//  StudentsStorage.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 1/26/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import Foundation


final class StudentsStorage {
    
    var students = [Student.Results]() // Students detail array
    var studentID : String? // Current student ID
    var session : String? // Session id
    var user : UserData? = nil // Current User
    var currentUserObjectID : String?  = nil // Current User Object ID to change or add new location
    
    private init() {
    }
    
    class func sharedInstance() -> StudentsStorage {
        struct Singleton {
            static var sharedInstance = StudentsStorage()
        }
        return Singleton.sharedInstance
    }
}
