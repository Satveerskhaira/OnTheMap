//
//  UdacityClient.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import Foundation
class UdacityClient: NSObject {
    
    // MARK : Properties
    
    // Shared Session
    
    let session = URLSession.shared
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    // Method to create URL
    
    func UdacityURLWithParameter(_ parameter : [String : AnyObject], withPathExtension : String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        print(components.url!)
        
        return components.url!
        
    }

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
