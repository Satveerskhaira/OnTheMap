//
//  AddLocationViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/17/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var newLocation: UITextField!
    @IBOutlet weak var studentURL: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.title = "Add Location"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Cancel
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
   
    }
    @IBAction func serachStudentLocation(_ sender: Any) {
        let storeStudentLocation = storyboard?.instantiateViewController(withIdentifier: "StoreStudentLocation") as! StoreStudentLoactionViewController
        storeStudentLocation.studentLocation = newLocation.text
        storeStudentLocation.studentURL = studentURL.text
        self.present(storeStudentLocation, animated: true, completion: nil)
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
