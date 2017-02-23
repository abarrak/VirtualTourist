//
//  AsyncHelpers.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

func performAsync(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
