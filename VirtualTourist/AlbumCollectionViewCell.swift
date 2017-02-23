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
    
    func setPlaceholder() {
        self.imageView.image = #imageLiteral(resourceName: "Placeholder")
    }
    
    func setImage(_ image: Data) {
        imageView.image = deserializePhoto(image)
    }
    
    private func deserializePhoto(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
