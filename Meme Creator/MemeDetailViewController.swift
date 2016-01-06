//
//  MemeDetailViewController.swift
//  Meme Creator
//
//  Created by Kioko on 06/01/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    //Meme Object
    var meme : Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meme = meme{
            imageView.image = meme.memedImage
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeEditor"{
            let editorViewController = segue.destinationViewController as! MemeEditorViewController
            editorViewController.editMeme = meme
            
            editorViewController.userIsEditing = true
        }
    }
    
}
