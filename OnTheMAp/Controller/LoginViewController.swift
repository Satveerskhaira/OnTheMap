//
//  LoginViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // Properties
    
    var student =  [Student.Results] ()
    //App delegete property to store student information
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIN(_ sender: Any) {
        //User name
        userName.text = "satveersingh@outlook.com"
        password.text = "kherasatveer"
        
        if !(userName.text?.isEmpty)!  && !(password.text?.isEmpty)! {
        
            //Create URL
          
            var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"udacity\": {\"username\": \"\(userName.text!)\", \"password\": \"\(password.text!)\"}}".data(using: String.Encoding.utf8)
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
                    print(parseResult.account.key)
                    
                    if parseResult.session.id != " " {
                        self.appDelegate.session = parseResult.session.id
                        self.appDelegate.studentID = parseResult.account.key
                        self.studentData()
                    }
                } catch {
                    do {
                        let parseError = try decoder.decode(UdacityError.self, from: newData!)
                        print(parseError)
                    } catch {
                        print("Could not parse the data as JSON: '\(data!)'")
                        return
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: StudentData
    func studentData() {
        
        // Student data
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            //print(String(data: data!, encoding: .utf8)!)
            do {
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .deferredToData
                let parseResult = try decoder.decode(Student.self, from: data!)
                
                self.appDelegate!.student.append(contentsOf: parseResult.results)
                self.currentStudentLocation()
            } catch {
                print("Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
                return
            }
        }
        task.resume()
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
                    for stu in parseResult.results {
                        self.appDelegate.currentUserObjectID = stu.objectId
                        break
                    }
                }
                self.currentStudentData()
               
            } catch {
                print("Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
                return
            }
        }
        task.resume()
        
    }
    
    // MARK : Current user information
    func currentStudentData() {
        
        // Student data
        let studentID = appDelegate.studentID!
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(studentID)")!)
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
                self.appDelegate!.user = parseResult
                self.completeLogin()
            } catch {
                print("Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
                return
            }
        }
        task.resume()
    }
    
    
    // MARK : Current stutent location
    
    
    //Call segue once login complete
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
