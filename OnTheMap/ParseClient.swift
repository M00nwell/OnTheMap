//
//  ParseClient.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/27.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    struct JSONResponseKeys {

        static let userID = "key"
        static let account = "account"
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
        static let results = "results"
        
    }
    
    struct Constants {
        static let BaseURLSecure = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    var session: NSURLSession
    var students: [StudentInfo] = [StudentInfo]()
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure
        
        Client.taskForGETMethod(1, session: session, urlString: urlString){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Get Student Locations Failed (error).")
            } else if JSONResult == nil{
                completionHandler(success: false, errorString: "Get Student Locations Failed (status code invalid).")
            } else {
                if let results = JSONResult[JSONResponseKeys.results] as? [[String:AnyObject]] {
                    self.students = StudentInfo.studentFromResults(results)
                    print(results.count)
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Get Student Locations Failed (no results).")
                }
            }
        }
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
}