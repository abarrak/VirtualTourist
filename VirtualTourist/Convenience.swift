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
    
    typealias internalContinuationHandler = (_ pageNum: String) -> Void
    
    
    // Mark: - High level methods
    
    func searchForPhotos(latitude: Double, longitude: Double,
                         completionHandler: @escaping flickerPhotosCompletionHandler) {
        
        // Get a random page ..
        randomPageNum(latitude: latitude, longitude: longitude, completionHandler: completionHandler) {
            (pageNum) in
            
            // Then kick off another request ..
            let params = self.requestParams(latitude: latitude, longitude: longitude, pageNum: pageNum)
            
            let _ = self.genericTask(parameters: params) {
                (results, error) in
                
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
                
                guard photosArray != nil else {
                    completionHandler(false, nil, "Photos Unprocessed correctly !")
                    return
                }
                
                if (photosArray?.count)! > 0 {
                    completionHandler(true, self.constructPhotosData(photosArray!), "No photos found.")
                } else {
                    completionHandler(false, nil, "No photos found.")
                }
            }
        }
    }
    
    private func randomPageNum(latitude: Double, longitude: Double,
                       completionHandler: @escaping flickerPhotosCompletionHandler,
                       continuationHandler: @escaping internalContinuationHandler) {
        var random = 1
        
        let _ = genericTask(parameters: requestParams(latitude: latitude, longitude: longitude)) {
            (results, error) in
            
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
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.ResponseKeys.Pages] as? Int else {
                completionHandler(false, nil, "No pages found.")
                return
            }
            
            // pick a random page ..
            let pageLimit = min(totalPages, 40)
            random = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            continuationHandler(String(random))
        }
    }
    
    
    // Mark: - Helpers
    
    private func requestParams(latitude: Double, longitude: Double, pageNum: String? = nil) -> [String:String] {
        return [
            Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
            Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
            Constants.ParameterKeys.BoundingBox: getBoundingBox(latitude: latitude, longitude: longitude),
            Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
            Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
            Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
            Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback,
            Constants.ParameterKeys.PerPage: Constants.ParameterValues.PerPage,
            Constants.ParameterKeys.Page: pageNum ?? "1",
        ]
    }
    
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
