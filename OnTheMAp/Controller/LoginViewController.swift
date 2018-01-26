//
//  LoginViewController.swift
//  OnTheMAp
//
//  Created by Satveer Singh on 12/3/17.
//  Copyright © 2017 Satveer Singh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK : Properties

    var myActivityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable UI
        setUIEnabled(true)
        
        userName.delegate = self
        password.delegate = self
       
        //Create Activity Indicator
        activityIndicator(myActivityIndicator)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //configureBackground()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        let app = UIApplication.shared
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            app.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func logIN(_ sender: Any) {
        
        let name = userName.text!
        let pwd = password.text!
        
        if name.isEmpty || pwd.isEmpty {
            showAlert("User Name or Password not entered", alertTitle: "Login Fail", action: false) {(success) in
                //Do nothing
            }
        } else {
            performUIUpdatesOnMain({
                self.setUIEnabled(false)
                self.activity(self.myActivityIndicator, false)
            })
            
            UdacityClient.sharedInstance().authenticateWithViewController(name, pwd, self) { (success, error) in
                if success {
                    self.completeLogin()
                } else {
                    performUIUpdatesOnMain({
                        self.setUIEnabled(true)
                        self.activity(self.myActivityIndicator, true)
                        self.showAlert(error!, alertTitle: "Login Failed", action: false) {(success) in
                            //Do nothing
                        }
                    })
                    
                }
            }
        }
    }
  
    //Call segue once login complete
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            self.activity(self.myActivityIndicator, true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        userName.isEnabled = enabled
        password.isEnabled = enabled
        loginButton.isEnabled = enabled
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }


    func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}

// MARK: - ViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
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
        updateViewframe(frameOrigin: CGFloat(-120))
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Update frame
    func updateViewframe( frameOrigin : CGFloat) {
        view.frame.origin.y = frameOrigin + 120
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(userName)
        resignIfFirstResponder(password)
    }
    
}


extension UIViewController {
    
    func showAlert(_ textField : String, alertTitle : String, action : Bool, addLocationSegue : @escaping (_ continue : Bool) -> Void) {
        // create the alert
        let alert = UIAlertController(title: alertTitle, message: textField, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        if action {
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default){UIAlertAction in
                addLocationSegue(true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){UIAlertAction in
                addLocationSegue(false)
            })
        } else {
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel){UIAlertAction in
                addLocationSegue(false)
            })
        }
        
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Shoe Activity Indictor
    func activityIndicator(_ myActivityIndicator : UIActivityIndicatorView) {
        //Create Activity Indicator
        myActivityIndicator.activityIndicatorViewStyle = .gray
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = true
        
        // Add to supreview
        view.addSubview(myActivityIndicator)
    }
    
    func activity(_ myActivityIndicator : UIActivityIndicatorView, _ start : Bool){
        myActivityIndicator.hidesWhenStopped = start
        if start {
            
            myActivityIndicator.stopAnimating()
        } else {
            myActivityIndicator.startAnimating()
        }
    }
}
