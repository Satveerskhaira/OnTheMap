//
//  StudentsStorage.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 1/26/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import Foundation


final class StudentsStorage {
    
    var student = [Student.Results]()
    var studentID : String?
    var session : String?
    var user : UserData? = nil
    var currentUserObjectID : String?  = nil
    
    private init() {
    }
    
    class func sharedInstance() -> StudentsStorage {
        struct Singleton {
            static var sharedInstance = StudentsStorage()
        }
        return Singleton.sharedInstance
    }
}
