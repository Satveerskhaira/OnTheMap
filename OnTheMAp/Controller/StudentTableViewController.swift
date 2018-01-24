//
//  StudentTableViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 1/22/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    // Properties
    
    var appDelegate: UdacityClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UdacityClient.sharedInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (appDelegate.student.count)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get cell type
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let student = appDelegate.student[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "\(student.firstName ?? " ") \(student.lastName ?? " ")"
        cell.detailTextLabel?.text = student.mediaURL
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK : unwind segue
extension StudentTableViewController {
    
    @IBAction func unwindSegue (segue : UIStoryboardSegue) {
//        if let sender = segue.source as? StoreStudentLoactionViewController {
//            print(sender.newLocationcatiolati)
//            let studentLocation = StudentLocationAnnotation(title: ((appDelegate.user!.user.firstName) + " " + (appDelegate.user!.user.lastName)),
//                                                            locationName: sender.studentURL!,
//                                                            discipline: "Udacity",
//                                                            coordinate: CLLocationCoordinate2D(latitude: (sender.newLocationcatiolati)!, longitude: (sender.newlocationcatioLongi)!))
//
//            studentLocationAnnotation.append(studentLocation)
//            mapView.addAnnotations(studentLocationAnnotation)
//        }
//        //currentStudentLocation()
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
                }
                
            } catch {
                print("Could not parse the data as JSON: '\(String(data: data!, encoding: .utf8)!)'")
                return
            }
        }
        task.resume()
        
    }
}


