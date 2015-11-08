//
//  ViewController.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/24.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet var fbLoginButton : FBSDKLoginButton!
    
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        warningLabel.text = ""
        passwordTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.center.x = self.view.center.x
        loginView.center.y = CGFloat(500)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        self.view.addSubview(loginView)
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
            shakeWarning(emailTextField)
            warningLabel.text = "Please Enter Email"
            return
        }
        if password == ""{
            shakeWarning(passwordTextField)
            warningLabel.text = "Please Enter Password"
            return
        }
        
        ActivityIndicatorView.shared.showProgressView(view)
        
        udacityClient.creatSession(email, password: password) { (success, errorString) in
            if success{
                self.getUserInfo()
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.shakeWarning(self.emailTextField)
                    self.shakeWarning(self.passwordTextField)
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
                return
            }
        }
    }
    
    func getUserInfo(){
        udacityClient.getUserData(){ (success, errorString) in
            if success{
                self.getStudentLocation()
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
                return
            }
        }
    }
    
    func getStudentLocation(){
        parseClient.getStudentLocations(){ (success, errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(), {
                    ActivityIndicatorView.shared.hideProgressView()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
                return
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
                return
            }
        }
    }

    @IBAction func signupButtonTouch(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!)
    }
    
    func shakeWarning(txtField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(txtField.center.x - 10, txtField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(txtField.center.x + 10, txtField.center.y))
        txtField.layer.addAnimation(animation, forKey: "position")
    }
}

extension LogInViewController: FBSDKLoginButtonDelegate{
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            warningLabel.text = "Login with Facebook failed"
        }
        else if result.isCancelled {
        }
        else {
            if result.grantedPermissions.contains("email")
            {
                ActivityIndicatorView.shared.showProgressView(view)
                udacityClient.creatSessionWithFB(FBSDKAccessToken.currentAccessToken().tokenString) { (success, errorString) in
                    if success{
                        self.getUserInfo()
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.warningLabel.text = errorString
                            ActivityIndicatorView.shared.hideProgressView()
                        })
                        return
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

