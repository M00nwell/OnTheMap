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
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        static let username = "username"
        static let password = "password"
        static let udacity = "udacity"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Authorization
        static let userID = "key"
        static let account = "account"
        
    }
    
    var userID : String? = nil
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
        
        Client.taskForPOSTMethod(session, urlString: urlString, jsonBody: jsonBody){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Login Failed (error).")
            } else if JSONResult == nil{
                completionHandler(success: false, errorString: "Login Failed (Incorrect Email or Password).")
            } else {
                if let account = JSONResult[JSONResponseKeys.account] as? [String:AnyObject] {
                    if let userID
                        = account[JSONResponseKeys.userID] as? String {
                        self.userID = userID
                        completionHandler(success: true, errorString: nil)
                    }else{
                        completionHandler(success: false, errorString: "Login Failed (no ID).")
                    }

                } else {
                    completionHandler(success: false, errorString: "Login Failed (no account).")
                }
            }
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