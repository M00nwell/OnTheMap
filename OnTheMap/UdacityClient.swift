//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/25.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    struct Constants {
        // MARK: URLs
       static let BaseURLSecure : String = "https://www.udacity.com/api/"
    }
    
    // MARK: Methods
    struct Methods {

        static let Session = "session"
        static let User = "users/"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        static let username = "username"
        static let password = "password"
        static let udacity = "udacity"
        static let FB = "facebook_mobile"
        static let token = "access_token"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Authorization
        static let userID = "key"
        static let account = "account"
        static let user = "user"
        static let lastName = "last_name"
        static let firstName = "first_name"
        static let uniqueKey = "key"
    }
    
    var userID : String? = nil
    var userInfo = [String:AnyObject]()
    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: GET
    
    func creatSession(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + Methods.Session
        let loginInfo = [JSONBodyKeys.username: username, JSONBodyKeys.password: password]
        let jsonBody = [JSONBodyKeys.udacity: loginInfo]
        
        Client.taskForPOSTMethod(0, session: session, urlString: urlString, jsonBody: jsonBody){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Login Failed (Incorrect Email or Password)")
                completionHandler(success: false, errorString: "Login Failed (Incorrect Email or Password).")
            } else {
                if let account = JSONResult[JSONResponseKeys.account] as? [String:AnyObject] {
                    if let userID
                        = account[JSONResponseKeys.userID] as? String {
                        self.userID = userID
                        completionHandler(success: true, errorString: nil)
                    }else{
                        print("Login Failed (no ID)")
                        completionHandler(success: false, errorString: "Login Failed.")
                    }

                } else {
                    print("Login Failed (no account)")
                    completionHandler(success: false, errorString: "Login Failed.")
                }
            }
        }
    }
    
    func creatSessionWithFB(FBToken: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + Methods.Session
        let loginInfo = [JSONBodyKeys.token: FBToken]
        let jsonBody = [JSONBodyKeys.FB: loginInfo]
        
        Client.taskForPOSTMethod(0, session: session, urlString: urlString, jsonBody: jsonBody){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Login with Facebook Failed")
                completionHandler(success: false, errorString: "Login with Facebook Failed.")
            } else {
                if let account = JSONResult[JSONResponseKeys.account] as? [String:AnyObject] {
                    if let userID
                        = account[JSONResponseKeys.userID] as? String {
                            self.userID = userID
                            completionHandler(success: true, errorString: nil)
                    }else{
                        print("Login Failed (no ID)")
                        completionHandler(success: false, errorString: "Login with Facebook Failed.")
                    }
                    
                } else {
                    print("Login Failed (no account)")
                    completionHandler(success: false, errorString: "Login with Facebook Failed.")
                }
            }
        }
    }

    
    func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + Methods.User + userID!
        
        Client.taskForGETMethod(0, session: session, urlString: urlString){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                completionHandler(success: false, errorString: "Login Failed (cannot get user data).")
            } else {
                if let userInfo = JSONResult[JSONResponseKeys.user] as? [String:AnyObject] {
                    self.userInfo = userInfo
                    completionHandler(success: true, errorString: nil)
                } else {
                    print("Login Failed (no user)")
                    completionHandler(success: false, errorString: "Login Failed (cannot get user data).")
                }
            }
        }
    }
    
    func deleteSession(){
        let urlString = Constants.BaseURLSecure + Methods.Session
        Client.taskForDELETEMethod(session, urlString: urlString){ (JSONResult, error) in
            if let error = error {
                print(error)
                //try again
                self.deleteSession()
            } 
        }
    }
    
    func getLastName() -> String{
        if let lastName = userInfo[JSONResponseKeys.lastName] as? String{
            return lastName
        }else{
            return ""
        }
    }
    
    func getFirstName() -> String{
        if let lastName = userInfo[JSONResponseKeys.firstName] as? String{
            return lastName
        }else{
            return ""
        }
    }
    
    func getUniqueKey() -> String{
        if let lastName = userInfo[JSONResponseKeys.uniqueKey] as? String{
            return lastName
        }else{
            return ""
        }
    }
        
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }


}