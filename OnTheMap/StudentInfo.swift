//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/27.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation

struct StudentInfo {
    
    // MARK: Properties
    
    var createAt = ""
    var firstName = ""
    var lastName = ""
    var latitude = 0.00
    var longitude = 0.00
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    var updatedAt = ""
    
    // MARK: Initializers
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        createAt = dictionary[ParseClient.JSONResponseKeys.createdAt] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.lastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.longitude] as! Double
        mapString = dictionary[ParseClient.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.mediaURL] as! String
        objectId = dictionary[ParseClient.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.uniqueKey] as! String
        updatedAt = dictionary[ParseClient.JSONResponseKeys.updatedAt] as! String
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInfo objects */
    static func studentFromResults(results: [[String : AnyObject]]) -> [StudentInfo] {
        var students = [StudentInfo]()
        
        for result in results {
            students.append(StudentInfo(dictionary: result))
        }
        
        return students
    }
}