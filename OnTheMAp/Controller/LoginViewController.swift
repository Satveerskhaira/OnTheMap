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
    
    @IBOutlet weak var loginButton: UIButton!
    // Properties

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIN(_ sender: Any) {
        
        let name = "satveersingh@outlook.com"
        let password = "kherasatveer"
        UdacityClient.sharedInstance().authenticateWithViewController(name, password, self) { (success, error) in
            if success {
                self.completeLogin()
            } else {
                print(error!)
            }
            
        }
    }
  
    //Call segue once login complete
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            
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
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }

/*
    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }
*/
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
