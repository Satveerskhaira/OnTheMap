//
//  UdacityClient.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    // MARK : Properties
    
    // Shared Session
    
    let networkSession = URLSession.shared
    
    // authentication state
    
    var student = [Student.Results]()
    var studentID : String?
    var session : String?
    var user : UserData? = nil
    var currentUserObjectID : String?  = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    // Method to create URL
    
    
    // Get session and load data
    
    func authenticateWithViewController(_ name: String, _ pwd : String, _ viewController: UIViewController, handlerForAuth: @escaping (_ success : Bool, _ errorString : String?) -> Void) {
        // Create Session
        self.getSession(name, pwd) { (success, error) in
            if success {
                // If session success get data current student data
                // current student location.
                self.studentData(handlerForstudentData: { (success, error) in
                    if success {
                        self.currentStudentLocation(handlerForCurrentStuLocation: { (success, error) in
                            if success {
                                //No action
                               // handlerForAuth(true, nil)
                            }
                            if error != nil {
                                print(error!)
                            }
                        })
                        self.currentStudentData({ (success, error) in
                            if success {
                                handlerForAuth(true, nil)
                            } else {
                                handlerForAuth(false, error)
                            }
                        })
                    } else {
                        handlerForAuth(false, error)
                    }
                })
            } else {
                handlerForAuth(false, error)
            }
        }
    }
    
    // MARK : Refresh
    
    func refreshData(_ handlerReloadData : @escaping (_ success : Bool, _ error : String?) -> Void ) {
        // Remove old data
        student.removeAll()
        // reload data
        
        self.studentData { (success, error) in
            if success {
                self.currentStudentLocation(handlerForCurrentStuLocation: { (success, error) in
                    if success {
                        handlerReloadData(true, error)
                    } else {
                        handlerReloadData(success, error)
                    }
                })
            } else {
                handlerReloadData(success, error)
            }
        }
    }
    
    // Post Method
    
    func getSession(_ name : String, _ pwd : String, _ handlerForSession : @escaping (_ success : Bool, _ errorString : String?) -> Void) {
        
        //User name
       // let name = "satveersingh@outlook.com"
       // let pwd = "kherasatveer"
        
        if !(name.isEmpty)  && !(pwd.isEmpty) {
            
            //Create URL
            //parameters
           
            var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session?")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"udacity\": {\"username\": \"\(name)\", \"password\": \"\(pwd)\"}}".data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                do {
                    let parseResult = try decoder.decode(Udacity.self, from: newData!)
                    if parseResult.session.id != " " {
                        self.session = parseResult.session.id
                        self.studentID = parseResult.account.key
                        // Call back login handler:
                        handlerForSession(true, nil)
                    }
                } catch {
                    do {
                        let parseError = try decoder.decode(UdacityError.self, from: newData!)
                        handlerForSession(false, parseError.error)
                    } catch {
                        handlerForSession(false, "Could not connect with Udacity")
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func studentData(handlerForstudentData :@escaping (_ success : Bool, _ error : String?) -> Void) {
        
        // Student data
        //let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt"
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
                
                self.student.append(contentsOf: parseResult.results)
                handlerForstudentData(true, nil)
            } catch {
                handlerForstudentData(true, "Could not load data from Udacity network")
            }
        }
        task.resume()
    }
    
    //MARK: Get Current student location information if present
    
    //Step 1
    
    func currentStudentLocation(handlerForCurrentStuLocation : @escaping (_ success : Bool, _ error : String?) -> Void) {
        // Student data
        //let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(self.appDelegate.studentID)%22%7D"
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%224343538699%22%7D"
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
                    self.student.append(contentsOf: parseResult.results)
                    for stu in parseResult.results {
                        self.currentUserObjectID = stu.objectId
                        break
                    }
                }
                handlerForCurrentStuLocation(true, nil)

                
            } catch {
                handlerForCurrentStuLocation(true, "Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
            }
        }
        task.resume()
    }
    
    // MARK : Current user information
    //Step 1
    func currentStudentData(_ handlerForCurrentStuData : @escaping (_ success : Bool, _ error : String?) -> Void ) {
        
        // Student data
        let studentID1 = studentID!
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(studentID1)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(UserData.self, from: newData!)
                // Call function for current student location
                self.user = parseResult
               handlerForCurrentStuData(true, nil)
            } catch {
                handlerForCurrentStuData(false, "User not found in udacity account")
            }
        }
        task.resume()
    }
    
    // MARK : Udpate or add student location
    
    func postPut (_ newLocation : StudentLocation!, _ webAddress : String, _ url: String, method : String, handlerForUpdate : @escaping (_ success :Bool, _ error : String?) -> Void ) {
        
        let lastName = user!.user.lastName
        let firstName = user!.user.firstName
        let id = studentID!
        
        
        // Calling method PUT or POST
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(id)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(newLocation.title)\", \"mediaURL\": \"\(webAddress)\",\"latitude\": \(newLocation.latitude), \"longitude\": \(newLocation.longitude)}".data(using: .utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                handlerForUpdate(false, error?.localizedDescription)
            }
            handlerForUpdate(true, nil)
        }
        task.resume()
    }
    
    // MARK : Logout
    
    func logout(_ handlerForLogout : @escaping (_ success : Bool, _ error : String?) -> Void) {
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
                handlerForLogout(false, error?.localizedDescription)
            }
            let range = Range(5..<data!.count)
            guard let newData = data?.subdata(in: range) /* subset response data! */ else {
                handlerForLogout(true, error?.localizedDescription)
                return
            }
            handlerForLogout(true, nil)
        }
        task.resume()
    }
    

    // MARK : create a URL from parameters
    func udacityURLWithParameter(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
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
