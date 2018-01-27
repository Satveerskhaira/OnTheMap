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
    
    let studentDelegate = StudentsStorage.self
    
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
                        self.currentStudentData({ (success, error) in
                           //Get currect student location if present even if error occured other student data is loaded will be shown. So only True is passed in this block.
                            self.currentStudentLocation(handlerForCurrentStuLocation: { (success, error) in
                                handlerForAuth(true, error)
                            })
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
        studentDelegate.sharedInstance().student.removeAll()
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
        
        if !(name.isEmpty)  && !(pwd.isEmpty) {
            
            //Create URL
            //parameters
           
            var request = URLRequest(url: URL(string: Constants.Session)!)
            request.httpMethod = Methods.post
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"udacity\": {\"username\": \"\(name)\", \"password\": \"\(pwd)\"}}".data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    handlerForSession(false, error?.localizedDescription)
                    return
                }
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                do {
                    let parseResult = try decoder.decode(Udacity.self, from: newData!)
                    if parseResult.session.id != " " {
                        self.studentDelegate.sharedInstance().session = parseResult.session.id
                        self.studentDelegate.sharedInstance().studentID = parseResult.account.key
                        // Call back login handler:
                        handlerForSession(true, nil)
                    }
                } catch {
                    do {
                        let parseError = try decoder.decode(UdacityError.self, from: newData!)
                        handlerForSession(false, parseError.error)
                    } catch {
                        handlerForSession(false, "Could not connect with Udacity server")
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func studentData(handlerForstudentData :@escaping (_ success : Bool, _ error : String?) -> Void) {
        
        // Set parameter
        
        var parameter = [String:String]()
        parameter["order"] = "-updatedAt"
        parameter["limit"] = "100"
        // Create URL
        let url = udacityURLWithParameter(parameter as [String : AnyObject], withPathExtension : Constants.StudentLocation)
        
        // Create Request
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                handlerForstudentData(false, error?.localizedDescription)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(Student.self, from: data!)
                
                self.studentDelegate.sharedInstance().student.append(contentsOf: parseResult.results)
                
                handlerForstudentData(true, nil)
            } catch {
                handlerForstudentData(false, "Could not load data from Udacity network: '\(String(data: data!, encoding: .utf8)!)'")
            }
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
    
    //MARK: Get Current student location information if present
    
    //Step 1
    
    func currentStudentLocation(handlerForCurrentStuLocation : @escaping (_ success : Bool, _ error : String?) -> Void) {
        // Student data
        let stuID = studentDelegate.sharedInstance().studentID!
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(stuID)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                handlerForCurrentStuLocation(false, error?.localizedDescription)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(Student.self, from: data!)
                if parseResult.results.count != 0 {
                    self.studentDelegate.sharedInstance().student.append(contentsOf: parseResult.results)
                    for stu in parseResult.results {
                        self.studentDelegate.sharedInstance().currentUserObjectID = stu.objectId
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
        let studentID1 = studentDelegate.sharedInstance().studentID!
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(studentID1)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                handlerForCurrentStuData(false, error?.localizedDescription)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(UserData.self, from: newData!)
                // Call function for current student location
                self.studentDelegate.sharedInstance().user = parseResult
               handlerForCurrentStuData(true, nil)
            } catch {
                handlerForCurrentStuData(false, "User not found in udacity account")
            }
        }
        task.resume()
    }
    
    // MARK : Udpate or add student location
    
    func postPut (_ newLocation : StudentLocation!, _ webAddress : String,  handlerForUpdate : @escaping (_ success :Bool, _ error : String?) -> Void ) {
        
        var url = Constants.postPut
        var method = ""
        if studentDelegate.sharedInstance().currentUserObjectID == nil {
            method = "POST"
        } else  {
            method = "PUT"
            url = url + "/\(studentDelegate.sharedInstance().currentUserObjectID!)"
        }
        
        let lastName = studentDelegate.sharedInstance().user!.user.lastName
        let firstName = studentDelegate.sharedInstance().user!.user.firstName
        let id = studentDelegate.sharedInstance().studentID!
        
        
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
                return
            }
            handlerForUpdate(true, nil)
        }
        task.resume()
    }
    
    // MARK : Logout
    
    func logout(_ handlerForLogout : @escaping (_ success : Bool, _ error : String?) -> Void) {
        var request = URLRequest(url: URL(string: Constants.logout)!)
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
                return
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

    

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
