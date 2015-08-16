//
//  RestAPIHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/14/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestAPIHelper {
    
    func connectToAPI () {
        let baseURL = NSURL(string: "http://52.25.48.116:9000/tasks")
        let request = NSURLRequest(URL: baseURL!)
    }
    
    

}