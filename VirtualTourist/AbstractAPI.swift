//
//  AbstractAPI.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit

class AbstractAPI: NSObject {
    
    // Mark: - Type definitions
    
    // Define a generic completion handler closure for api tasks.
    typealias handlerType = (_ result: [String:Any]?, _ error: NSError?) -> Void
        

    // Mark: - Methods

    func isNetworkAvaliable() -> Bool {
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            return false
        } else {
            return true
        }
    }
    
    func notifyDisconnectivity(_ completionHandler: @escaping handlerType) {
        let userInfo = [NSLocalizedDescriptionKey : "No connectivity !"]
        completionHandler(nil, NSError(domain: "Network Status", code: 2, userInfo: userInfo))
    }
}
