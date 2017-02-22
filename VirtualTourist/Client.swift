//
//  Client.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

class FlickerClient : AbstractAPI {
    // MARK: - Properties
    
    var session = URLSession.shared
    
    
    // MARK: - Methods
    
    func genericTask(parameters: [String:String], httpMethod: String = "GET", completionHandler: @escaping handlerType) {
        
        // Exit properly if no connection available.
        if !isNetworkAvaliable() {
            notifyDisconnectivity(completionHandler)
            return
        }
        
        // Build the request from URL and configure it ..
        var request = URLRequest(url: flickerURLFromParameters(parameters as [String : AnyObject]))
        request.httpMethod = httpMethod
        
        // Make the request ..
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func reportError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForSessionlogin", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                reportError("There was an error with the server connection: \(error)")
                return
            }
            
            /* GUARD: Did we get a status code out of the api expected ones ? */
            let statusCode = ((response as? HTTPURLResponse)?.statusCode)!
            guard statusCode >= 200 && statusCode <= 299 else {
                reportError("(\(statusCode)) There was an unexpected error from the server. Try again.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                reportError("Data curruption from the server. Sorry for the inconvenience.")
                return
            }
            
            // Extact the raw data and pass it for parsing.
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandler)
        })
        
        // Start the request ..
        task.resume()
    }
    
    // MARK: - Helpers
    
    private func flickerURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print(components.url!)
        return components.url!
    }
    
    
    // Given raw JSON, return a usable Foundation object.
    private func convertDataWithCompletionHandler(_ data: Data,
                                                  completionHandlerForConvertData: handlerType) {
        var parsedResult: [String:Any]? = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil,
                                            NSError(domain: "convertDataWithCompletionHandler",
                                                    code: 1,
                                                    userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: - Shared Instance
    
    class var shared: FlickerClient {
        get {
            struct Singleton {
                static var sharedInstance = FlickerClient()
            }
            return Singleton.sharedInstance
        }
    }
}
