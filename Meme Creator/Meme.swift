//
//  Meme.swift
//  Meme Creator
//
//  Created by Kioko on 05/01/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    
    init(topText: String, bottomText: String, originalImage: UIImage,
        memedImage:UIImage){
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = originalImage
            self.memedImage = memedImage
    }
}
