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
     var myActivityIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UdacityClient.sharedInstance()
        
        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        //Create Activity Indicator
        activityIndicator(myActivityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addNewLocation(_ sender: Any) {
        if (appDelegate.user != nil) {
            showAlert("Student Location Already present. Do you want to override location", alertTitle: "Add Location", action: true, addLocationSegue: { (success) in
                if success {
                    self.performSegue(withIdentifier: "Add", sender: self)
                }
            })
        }
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
        updateUI(false, 0.5, false)
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
        updateUI(false, 0.5, false)
        
        UdacityClient.sharedInstance().refreshData { (success, error) in
            if success {
                self.updateUI(true, 1.0, true)
            } else {
                print(error!)
            }
        }
    }
    
    func updateUI(_ intractionEnabled : Bool, _ alpha : CGFloat, _ tableReload : Bool ) {
        performUIUpdatesOnMain {
            if tableReload {
                self.studentTableView.reloadData()
            }
            self.studentTableView.isUserInteractionEnabled = intractionEnabled
            self.studentTableView.alpha = alpha
            self.activity(self.myActivityIndicator, intractionEnabled)
        }
    }
}



