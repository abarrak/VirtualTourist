//
//  Convenience.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

extension FlickerClient {
    // Mark: - Definitions
    
    typealias flickerPhotosCompletionHandler =
        (_ success: Bool, _ photoDictionary: [[String: String]]?, _ errorString: String?) -> Void
    
    
    // Mark: - High level methods
    
    func searchForPhotos(completionHandler: @escaping flickerPhotosCompletionHandler) {
        let parameters = ["":""]
        
        let _ = genericFlickerTask(parameters: parameters as [String:AnyObject]) { (results, error) in
            
            // Did the request failed?
            if error != nil {
                completionHandler(false, nil, "Fetching students' info failed.")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            let status = results?[Constants.ResponseKeys.Status] as? String
            guard status == Constants.ResponseValues.OKStatus else {
                completionHandler(false, nil, "Request Failed (\(status)).")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = results?[Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler(false, nil, "Error encoundered. \(error)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            let photosArray = photosDictionary[Constants.ResponseKeys.Photo] as? [[String: AnyObject]]
            
            guard photosArray != nil else {
                completionHandler(false, nil, "Photos Unprocessed correctly !")
                return
            }
            
            if (photosArray?.count)! > 0 {
                completionHandler(true, self.constructPhotosData(photosArray!), nil)
            } else {
                completionHandler(false, nil, "No photos found.")
            }
        }
    }
    
    func constructPhotosData(_ photosList: [[String:AnyObject]]) -> [[String:String]]? {
        var results: [Dictionary<String, String>]?
        
        for photo in photosList {
            let title = photo[FlickerClient.Constants.ResponseKeys.Title] as? String
            let url = photo[FlickerClient.Constants.ResponseKeys.MediumURL] as? String
            if let url = url {
                results?.append(["title": title!, "image_url": url])
            }
        }
        return results
    }
}
