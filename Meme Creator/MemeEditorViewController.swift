//
//  MemeEditorViewController.swift
//  Meme Creator
//
//  Created by Kioko on 05/01/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{
    
    /* Global variable definitions */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumButton: UITabBarItem!
    @IBOutlet weak var cameraButton: UITabBarItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var navSaveButton: UIBarButtonItem!
    @IBOutlet weak var navCancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var editMeme: Meme?
    var memedImage: UIImage!
    var userIsEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
        
        //Check if the camera is available then enable/disable the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications() //Disable keyboard notifications
    }
    
    //Allow the user to select an image from the gallery
    @IBAction func pickImageFromGallery(sender: UIBarButtonItem) {
        //Launch the Image picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        self.presentViewController(imagePickerController, animated: true,
            completion: nil)
    }
    
    //Allow user to take an image using the camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Allow the user to select an image from the album
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    /**
     This function enables us to retrieve the selected image and set it to the
     ImageView
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    /*
    Hide status bar to avoid bug where status bar shows when imageview pushed
    up by keyboard
    */
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    /*
    Set the state of the User Interface to editing or creating
    If you are editing a Meme, then configure and set the appropriate fields
    Otherwise, configure default state for text fields
    */
    func setDefaultUIState() {
        //text style attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 0.0
        ]
        
        self.topText.delegate = self;
        self.bottomText.delegate = self;
        self.topText.defaultTextAttributes = memeTextAttributes
        self.bottomText.defaultTextAttributes = memeTextAttributes
        
        /* Set the meme to edit if there is an editMeme */
        if let editMeme = editMeme {
            navBar.topItem?.title = "Edit your Meme"
            
            topText.text = editMeme.topText
            bottomText.text = editMeme.bottomText
            imageView.image = editMeme.originalImage
            
            navCancelButton.enabled = true
            navSaveButton.enabled = userCanSave()
            
            
            userIsEditing = true
        } else {
            /*Set the title if creating a Meme */
            navBar.topItem?.title = "Create a Meme"
            navCancelButton.enabled = true
            navSaveButton.enabled = userCanSave()
        }
        
    }
    
    /** This function hides the keyboard when the user hits return**/
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func saveEditedMeme(sender: AnyObject) {
        
        if userCanSave(){
            /* Initialize a new meme to save or update */
            let meme = Meme(topText: topText.text!, bottomText: bottomText.text!,
                originalImage: imageView.image!, memedImage: generateMemedImage())
        }
    }
    
    
    @IBAction func cancelEditiedMeme(sender: UIBarButtonItem) {
        clearView()
    }
    
    /* Clear the view if user presses cancel */
    func clearView() {
        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
    }
    
    /* Test to see whether the user can save or not */
    func userCanSave() -> Bool {
        if topText.text == nil || bottomText.text == nil || imageView.image == nil {
            return false
        } else {
            return true
        }
    }
    
    func generateMemedImage() -> UIImage
    {
        /* Hide everything but the image */
        hideNavItems(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* Show all views that were hidden */
        hideNavItems(false)
        
        return memedImage
    }
    
    private func hideNavItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        navBar.hidden = hide
        bottomToolbar.hidden = hide
    }
}

