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
    var apiClient = StudentsStorage.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newLocation.delegate = self
        studentURL.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Show alert if current student location already prsent already
        if ((newLocation.text?.isEmpty)! && (studentURL.text?.isEmpty)!) {
                self.showAlert("Location Search String and Web address not entered", alertTitle: "Missing", action: false) {(success) in
                //Do nothing
                }
            } else if (newLocation.text?.isEmpty)! {
                self.showAlert("Location Search String not entered", alertTitle: "Missing", action: false) {(success) in
                    //Do nothing
                    }
                } else {
                    if isValid(urlString: studentURL.text!) {
                        // Pass the location and web address to the new view controller.
                        self.resignFirstResponder()
                        let storeStudentLocation = segue.destination as! StoreStudentLoactionViewController
                        storeStudentLocation.studentLocation = newLocation.text
                        storeStudentLocation.studentURL = studentURL.text
                        
                    } else {
                        // Invalid web address
                        
                        self.showAlert("Blank or Invalid Web Address", alertTitle: "Invalid", action: false) {(success) in
                            //Do nothing
                            }
                        }
                    }
    }
    
}

// MARK : Show alert
extension AddLocationViewController {
    
    func isValid(urlString: String) -> Bool
    {
        if let urlComponents = URLComponents.init(string: urlString), urlComponents.host != nil, urlComponents.url != nil, urlComponents.host != ""
        {
            return true
        }
        return false
    }
}

// MARK: - ViewController: UITextFieldDelegate

extension AddLocationViewController: UITextFieldDelegate {
    
    // MARK : subscribe and unsubscribe from keyboard notification
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK : shift View to enter text in bottom field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if UIDevice.current.orientation.isLandscape {
            subscribeToKeyboardNotifications()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
            unsubscribeFromKeyboardNotifications()
    }
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification :Notification) {
        updateViewframe(frameOrigin: -getKeyboardHeight(notification))
    }
    
    @objc func keyboardWillHide(_ notification : Notification) {
        updateViewframe(frameOrigin: CGFloat(-130))
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Update frame
    func updateViewframe( frameOrigin : CGFloat) {
        view.frame.origin.y = frameOrigin + 130
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(newLocation)
        resignIfFirstResponder(studentURL)
    }
}
