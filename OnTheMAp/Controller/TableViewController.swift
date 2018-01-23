//
//  SecondViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    var appDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup appdelegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Setup up logout button in navigation control
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Logout
    
    @objc func logout() {
        dismiss(animated: true, completion: nil)
    }
}

/*
extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of row should be equal to students
        //return (appDelegate.student?.results.count)!
        return (appDelegate.student.count)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Push the movie detail view */
       // let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        //controller.movie = movies[(indexPath as NSIndexPath).row]
        //navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell type
        let cellReuseIdentifier = "FavoriteTableViewCell"
       
        //let student = appDelegate.student?.results[(indexPath as NSIndexPath).row]
        let student = appDelegate.student[(indexPath as NSIndexPath).row]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set cell defaults
//        cell?.textLabel!.text = "\(student?.firstName ?? " ") \(student?.lastName ?? " ")"
//        cell?.detailTextLabel?.text = student?.mediaURL
        cell?.textLabel!.text = "\(student.firstName ?? " ") \(student.lastName ?? " ")"
        cell?.detailTextLabel?.text = student.mediaURL
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        return cell!
    }
}
 */
