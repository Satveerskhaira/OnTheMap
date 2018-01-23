//
//  ParseData.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import Foundation

struct Student : Decodable {
    let results : [Results]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
    
    struct Results : Decodable {
        let objectId : String
        let uniqueKey : String?
        let firstName : String?
        let lastName: String?
        let mapString : String?
        let mediaURL : String?
        let latitude : Double?
        let longitude : Double?
    }
}

//
struct Udacity :Decodable {

 let account : Account
 let session : Session
 
    private enum CodingKeys: String, CodingKey {
        case account, session
    }
    struct Account : Decodable {
        let registered : Bool
        let key : String
    }
    
    struct Session : Decodable {
        let id : String
        //let expiratio : String
    }
}

struct UdacityError : Decodable {
    let status : Int
    let error : String
}

//Current user name
struct UserData : Decodable {
    
    let user : User
    
    private enum CodingKeys : String, CodingKey {
       case user
    }
    struct User : Decodable {
        let lastName : String
        let firstName : String
        
        private enum CodingKeys : String, CodingKey {
            case lastName = "last_name"
            case firstName = "first_name"
        }
    }
}



