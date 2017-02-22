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
    
    func searchForPhotos(latitude: Double, longitude: Double,
                         completionHandler: @escaping flickerPhotosCompletionHandler) {
        
        let parameters = [
            Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
            Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
            Constants.ParameterKeys.BoundingBox: getBoundingBox(latitude: latitude, longitude: longitude),
            Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
            Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
            Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
            Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback,
            Constants.ParameterKeys.PerPage: Constants.ParameterValues.PerPage
        ]
        
        let _ = genericTask(parameters: parameters) { (results, error) in
            
            // Did the request failed?
            if error != nil {
                completionHandler(false, nil, "Fetching photos failed.")
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
                completionHandler(false, nil, "Error encoundered while parsing.")
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
    
    func getRandomPageNumber() {
        
    }
    
    // Mark: - Helpers
    
    private func constructPhotosData(_ photosList: [[String:AnyObject]]) -> [[String:String]] {
        var results: [[String:String]] = [Dictionary<String, String>]()
        
        for photo in photosList {
            let title = photo[Constants.ResponseKeys.Title] as? String
            let url = photo[Constants.ResponseKeys.MediumURL] as? String
            
            if let url = url {
                results.append(["title": title!, "image_url": url])
            }
        }
        return results
    }
    
    private func getBoundingBox(latitude: Double, longitude: Double) -> String {
        let minLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minLat = max(latitude  - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maxLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maxLat = min(latitude  + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
}
