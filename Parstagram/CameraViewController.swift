//
//  CameraViewController.swift
//  Parstagram
//
//  Created by ALBERT TADROS on 3/26/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func onSubmitButton(_ sender: Any) {
        // create a new data table (i.e dictionary or classname called Posts) in Parse API
        let post = PFObject(className: "Posts") // using a object
        
        // columns in table
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        
        // to load image data
        let imageData = imageView.image?.pngData() // retrieve scaled image to original resolution and format as png
        let file = PFFileObject(data: imageData!)
        
        // image column
        post["image"] = file
        
        // now push newly created table to API
        post.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Saved!")
            }else {
                print("Error!")
            }
        }
        
    }
    
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
}
