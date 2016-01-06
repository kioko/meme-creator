//
//  MemeCollectionViewCell.swift
//  Meme Creator
//
//  Created by Kioko on 06/01/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    /* Show or hide the checkmark if cell is selected */
    func isSelected(selected: Bool) {
        if selected {
            selectedImageView.hidden = false
        } else {
            selectedImageView.hidden = true
        }
    }
    
}
