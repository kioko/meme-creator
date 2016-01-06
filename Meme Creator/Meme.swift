//
//  Meme.swift
//  Meme Creator
//
//  Created by Kioko on 05/01/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

struct Meme {
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

/* Add the Equatable Protocol and make equal if the memedImages match */
extension Meme: Equatable {}

func ==(lhs: Meme, rhs: Meme) -> Bool {
    return lhs.memedImage == rhs.memedImage
}

/* Convenience methods and variables for accessing and altering the collection of Memes */
struct MemeCollection {
    
    /* Get all memes from our app delegate */
    static var allMemes: [Meme] {
        return getMemeStorage().memes
    }
    
    /*!
    * @discussion This function returns a Meme at a given index/position
    * @param Position
    * @return Meme object
    */
    static func getMeme(atIndex index: Int) -> Meme {
        return allMemes[index]
    }
    
    /*!
    * @discussion Find the index of a given Meme
    * @return first index/number of Memes
    */
    static func indexOf(meme: Meme) -> Int {
        
        /* If the meme is in the collection, return first index, otherwise return count of Memes */
        if let index = allMemes.indexOf({$0 == meme}) {
            return Int(index)
        } else {
            print(allMemes.count)
            return allMemes.count
        }
    }
    
    /*!
    * @discussion This functions adds a meme to the last position of the meme collection
    * @param Meme Object
    */
    static func add(meme: Meme) {
        getMemeStorage().memes.append(meme)
    }
    
    /*!
    * @discussion This function updates a given Meme with a new Meme at a given index
    * @param position
    * @param Meme Object
    */
    static func update(atIndex index: Int, withMeme meme: Meme) {
        getMemeStorage().memes[index] = meme
    }
    
    /*!
    * @discussion Remove a Meme at a given index
    * @param position/index
    */
    static func remove(atIndex index: Int) {
        getMemeStorage().memes.removeAtIndex(index)
    }
    
    /*!
    * @discussion Get a count of all Memes in our Meme Collection
    */
    static func count() -> Int {
        return getMemeStorage().memes.count
    }
    
    /*!
    * @discussion Locate the Meme storage location in our App Delegate
    * @return object
    */
    static func getMemeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
}
