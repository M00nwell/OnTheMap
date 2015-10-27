//
//  ViewController.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/24.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    let client = UdacityClient.sharedInstance()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        warningLabel.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTouch(sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        warningLabel.text = ""
        if email == ""{
            warningLabel.text = "Please Enter Email"
            return
        }
        if password == ""{
            warningLabel.text = "Please Enter Password"
            return
        }
        client.creatSession(email, password: password) { (success, errorString) in
            if success{
                self.warningLabel.text = self.client.userID!
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                self.warningLabel.text = errorString
                })
            }
        }


    }

    @IBAction func signupButtonTouch(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!)
    }
    
}

