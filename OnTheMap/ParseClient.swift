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
    var userPin: StudentInfo? = nil
    var mapNeedReload = false
    var listNeedReload = false
    
    // MARK: Initializers
    let udacity = UdacityClient.sharedInstance()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + "?order=-updatedAt"
        
        Client.taskForGETMethod(1, session: session, urlString: urlString){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Get Student Locations Failed (status code invalid)")
                completionHandler(success: false, errorString: "Get Student Locations Failed")
            } else {
                if let results = JSONResult[JSONResponseKeys.results] as? [[String:AnyObject]] {
                    self.students = StudentInfo.studentFromResults(results)
                    print(results.count)
                    completionHandler(success: true, errorString: nil)
                } else {
                    print("Get Student Locations Failed (no result)")
                    completionHandler(success: false, errorString: "Get Student Locations Failed.")
                }
            }
        }
    }
    
    func queryStudentLocation(completionHandler: (success: Bool, count: Int, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + "?where=%7B%22uniqueKey%22%3A%22" + udacity.getUniqueKey() + "%22%7D"
        
        Client.taskForGETMethod(1, session: session, urlString: urlString){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, count: 0, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Query Location Failed (status code invalid)")
                completionHandler(success: false, count: 0, errorString: "Query Location Failed.")
            } else {
                if let results = JSONResult[JSONResponseKeys.results] as? [[String:AnyObject]] {
                    self.userPin = StudentInfo.studentFromResults(results)[0]
                    print(results)
                    completionHandler(success: true, count: results.count, errorString: nil)
                } else {
                    print("Query Location Failed (no result)")
                    completionHandler(success: false, count: 0, errorString: "Query Location Failed.")
                }
            }
        }
    }
    
    func addStudentLocation(mapString: String, mediaUrl: String, latitude: Double, Longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure
        let jsonBody: [String: AnyObject] = [JSONResponseKeys.uniqueKey: udacity.getUniqueKey(),
            JSONResponseKeys.firstName: udacity.getFirstName(),
            JSONResponseKeys.lastName: udacity.getLastName(),
            JSONResponseKeys.mapString: mapString,
            JSONResponseKeys.mediaURL: mediaUrl,
            JSONResponseKeys.latitude: latitude,
            JSONResponseKeys.longitude: Longitude]
        
        Client.taskForPOSTMethod(1, session: session, urlString: urlString, jsonBody: jsonBody){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Add Locations Failed (status code invalid)")
                completionHandler(success: false, errorString: "Add Locations Failed.")
            } else {
                if let objectID = JSONResult[JSONResponseKeys.objectId] as? String {
                    print(objectID)
                    completionHandler(success: true, errorString: nil)
                } else {
                    print("Add Locations Failed (no objectID)")
                    completionHandler(success: false, errorString: "Add Locations Failed.")
                }
            }
        }
    }
    
    func replaceStudentLocation(mapString: String, mediaUrl: String, latitude: Double, Longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let urlString = Constants.BaseURLSecure + "/" + userPin!.objectId
        let jsonBody: [String: AnyObject] = [JSONResponseKeys.uniqueKey: udacity.getUniqueKey(),
            JSONResponseKeys.firstName: udacity.getFirstName(),
            JSONResponseKeys.lastName: udacity.getLastName(),
            JSONResponseKeys.mapString: mapString,
            JSONResponseKeys.mediaURL: mediaUrl,
            JSONResponseKeys.latitude: latitude,
            JSONResponseKeys.longitude: Longitude]
        
        Client.taskForPUTMethod(1, session: session, urlString: urlString, jsonBody: jsonBody){ (JSONResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, errorString: "Bad Internet Connection.")
            } else if JSONResult == nil{
                print("Replace Locations Failed (status code invalid)")
                completionHandler(success: false, errorString: "Replace Locations Failed.")
            } else {
                if let updateAt = JSONResult[JSONResponseKeys.updatedAt] as? String {
                    print(updateAt)
                    completionHandler(success: true, errorString: nil)
                } else {
                    print("Replace Locations Failed (no objectID)")
                    completionHandler(success: false, errorString: "Replace Locations Failed.")
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