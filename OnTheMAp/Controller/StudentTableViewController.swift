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
    @IBOutlet var studentTableView: UITableView!
    
    
    var appDelegate: UdacityClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UdacityClient.sharedInstance()
        
        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))

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
    

    // MARK : Logout
    
    @objc func logout() {
        UdacityClient.sharedInstance().logout { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error!)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Open linked web site
        let app = UIApplication.shared
        let student = appDelegate.student[(indexPath as NSIndexPath).row]
        if let toOpen = student.mediaURL {
            app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: Refesh data
    
    @IBAction func refresh(_ sender: Any) {
        refreshData()
    }
}



// MARK : unwind segue and reload data
extension StudentTableViewController {
    
    @IBAction func unwindSegue (segue : UIStoryboardSegue) {
        refreshData()
    }
    
    func refreshData() {
        UdacityClient.sharedInstance().refreshData { (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.studentTableView.reloadData()
                }
            } else {
                print(error!)
            }
        }
    }
}


