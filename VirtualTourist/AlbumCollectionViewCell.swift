//
//  AlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    // Mark: -  Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Mark: - Methods
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}
