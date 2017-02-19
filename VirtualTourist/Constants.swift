//
//  Constants.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/18/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

extension FlickerClient {
    struct Constants {
        static let APIScheme    = "https"
        static let APIHost      = "api.flickr.com"
        static let APIPath      = "/services/rest"
        
        static let SearchBBoxHalfWidth  = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange       = (-90.0, 90.0)
        static let SearchLonRange       = (-180.0, 180.0)
        
        // MARK: - Parameter Keys
        struct ParameterKeys {
            static let Method           = "method"
            static let APIKey           = "api_key"
            static let GalleryID        = "gallery_id"
            static let Extras           = "extras"
            static let Format           = "format"
            static let NoJSONCallback   = "nojsoncallback"
            static let SafeSearch       = "safe_search"
            static let Text             = "text"
            static let BoundingBox      = "bbox"
            static let Page             = "page"
        }
        
        // MARK: - Parameter Values
        struct ParameterValues {
            static let APISecret            = "f94a04df55861719"
            static let APIKey               = "f67948fa8a1eaf81a2f5aea3b18e8a01"
            static let SearchMethod         = "flickr.photos.search"
            static let ResponseFormat       = "json"
            static let DisableJSONCallback  = "1"                                   // 1 == "yes"
            static let GalleryPhotosMethod  = "flickr.galleries.getPhotos"
            static let GalleryID            = "5704-72157622566655097"
            static let MediumURL            = "url_m"
            static let UseSafeSearch        = "1"
        }
        
        // MARK: - Response Keys
        struct ResponseKeys {
            static let Status       = "stat"
            static let Photos       = "photos"
            static let Photo        = "photo"
            static let Title        = "title"
            static let MediumURL    = "url_m"
            static let Pages        = "pages"
            static let Total        = "total"
        }
        
        // MARK: - Response Values
        struct ResponseValues {
            static let OKStatus = "ok"
        }
    }
}
