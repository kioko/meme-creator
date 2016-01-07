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
    @IBOutlet weak var navShareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var selectedTextField: UITextField?
    
    var editMeme: Meme?
    var memedImage: UIImage!
    var userIsEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Congifure the UI to its default state
        self.setDefaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotification()
        self.subscribeToShakeNotifications()
        
        //Check if the camera is available then enable/disable the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubsribeToKeyboardNotification() //Disable keyboard notifications
        self.unsubsribeToShakeNotification()
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
            
            /* Hide or Show the buttons based on whether the user is editing */
            navShareButton.enabled = userIsEditing
            navCancelButton.enabled = userIsEditing
            navSaveButton.enabled = userIsEditing
            
            userIsEditing = true
        } else {
            /*Set the title if creating a Meme */
            navBar.topItem?.title = "Create a Meme"
            navCancelButton.enabled = true
            navSaveButton.enabled = userCanSave()
        }
        
        /* Hide or Show the buttons based on whether the user is editing */
        navShareButton.enabled = userIsEditing
        navCancelButton.enabled = userIsEditing
        navSaveButton.enabled = userIsEditing
    }
    
    
    @IBAction func cancelEditiedMeme(sender: UIBarButtonItem) {
        clearView()
    }
    
    /* Alert the user if something is missing from the meme when they try to save */
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
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
    
    /* Present the ActivityViewController programmatically to share a Meme */
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        let ac = UIActivityViewController(activityItems: [generateMemedImage()],
            applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveMeme(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* Create the meme and save it to the Meme Model */
    @IBAction func saveMeme(sender: AnyObject) -> Void {
        
        /* Check If all items are filled out */
        if userCanSave() {
            
            /* Initialize a new meme to save or update */
            let meme = Meme(topText: topText.text!, bottomText: bottomText.text!,
                originalImage: imageView.image!, memedImage: generateMemedImage())
            
            /* If you are editing a meme, update it, if new, save it */
            if userIsEditing {
                
                /* Unwrap then update the meme if there is one to update */
                if let editMeme = editMeme {
                    MemeCollection.update(atIndex: MemeCollection.indexOf(editMeme), withMeme: meme)
                }
                /* Unwind to table view once meme is updated */
                performSegueWithIdentifier("unwindMemeEditor", sender: sender)
                
            } else {
                /* Add the Meme if user is not editing */
                MemeCollection.add(meme)
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            /* Alert user if something is missing and you can't save */
            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topText.text = ""
                self.bottomText.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }
    }
    
    /* Respond to shake notifications and alert to reset text fields to default */
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?",
            message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            
        })
        
        /* Alert user with reset and cancel actions */
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
}


//# -- MARK Extend UIImagePickerDelegate Methods for MemeEditorViewController
extension MemeEditorViewController {
    
    /* UIImagePickerDelegate methods */
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
            dismissViewControllerAnimated(true, completion: nil)
            imageView.image = image
            
            /* Enable share & cancel buttons once image is returned */
            navShareButton.enabled = userCanSave()
            navSaveButton.enabled = userCanSave()
            navCancelButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//#-MARK: Extension for the UITextFieldDelegate and Keyboard Notification Methods for MemeEditorViewController
extension MemeEditorViewController {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        
        /* Enable save button if fields are filled and resign first responder */
        navSaveButton.enabled = userCanSave()
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        /* Enable save button if fields are filled out  */
        navSaveButton.enabled = userCanSave()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        if selectedTextField == bottomText && view.frame.origin.y == 0.0 {
            
            view.frame.origin.y = -getKeyboardHeight(notification)
            navSaveButton.enabled = false
            
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        navSaveButton.enabled = userCanSave()
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}


//#-MARK:Shake to reset Extension of UIViewController:
extension UIViewController {
    
    /* Subsribe to shake notifications */
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "alertForReset", name: "shake", object: nil)
    }
    
    /* Unsubsribe to shake notifications */
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
    
    /* Allow view to become first responder to respond to shake notifications */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /* Handle motion events and respond to shake notification */
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
        }
    }
}

