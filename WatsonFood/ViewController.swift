//
//  ViewController.swift
//  WatsonFood
//
//  Created by Ashiq Sulaiman on 30/10/17.
//  Copyright © 2017 Ashiq Sulaiman. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "" //removed api key
    let version = "2017-10-31"
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    let imagePickerController = UIImagePickerController()
    var classificationResults = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }



    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            //Disable the camera so the user cannot take multiple pics when the photo is processed
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            imageView.image  = image
            //compress the UIImage:
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            // convert the jpeg image to a url
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpeg")
            
            //save the jpeg to the fileURL
            try? imageData?.write(to: fileURL)
            
             let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                // get the names of all the classifications and save it to classification results array.
                self.classificationResults.removeAll()
                for index in 0..<classes.count{
                    self.classificationResults.append(classes[index].classification)
                }
                    //enables the camera again
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.cameraButton.isEnabled = true
                }
                
                if self.classificationResults.isEmpty {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Sorry no results"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                    }
                }else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = self.classificationResults.first?.capitalized
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                    }
                }
                
                //print(self.classificationResults)
            })
        } else {
            print("error picking up the image")
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func takePicture(_ sender: Any) {
        imagePickerController.sourceType = .savedPhotosAlbum //change to camer to access the take pics using camera
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
        
        
        
    }
    
}

