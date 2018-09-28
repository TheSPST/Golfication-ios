//
//  RequestSFPopup.swift
//  Golfication
//
//  Created by Rishabh Sood on 26/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import ActionSheetPicker_3_0

class RequestSFPopup: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let progressView = SDLoader()

    var requestSFPopupView: UIView!
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        self.cameraBtn.layer.cornerRadius = 3.0
        self.cameraBtn.addTarget(self, action: #selector(self.submitAction(_:)), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(self.closeSFPopup(_:)), for: .touchUpInside)
        self.submitBtn.layer.cornerRadius = 3.0
        self.submitBtn.addTarget(self, action: #selector(self.submitAction(_:)), for: .touchUpInside)

    }
    
    func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        })
    }
    
    @objc func closeSFPopup(_ sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @objc func submitAction(_ sender: UIButton!) {
        ActionSheetStringPicker.show(withTitle: "Select a source:", rows: ["Camera", "Gallery"], initialSelection: 0, doneBlock: {
            picker, value, index in
            if value == 0 {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.cameraCaptureMode = .photo
                    self.imagePicker.modalPresentationStyle = .fullScreen
                    self.present(self.imagePicker,animated: true,completion: nil)
                }
                else {
                    self.noCamera()
                }
            }
            else{
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            return
        }, cancel: { ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)

        DispatchQueue.main.async(execute: {

//        self.progressView.show(atView: self.view, navItem: self.navigationItem)
        
        let imageRef = Storage.storage().reference().child("stablefordImages").child("\(Auth.auth().currentUser!.uid)-\(Timestamp)-ios-stablefordImage.png")
        
        self.uploadImage(chosenImage, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            
            let courseDetailDic = NSMutableDictionary()
            let courseDic = NSMutableDictionary()
            let courseId = ref!.child("stablefordRequest").childByAutoId().key
            courseDic.setObject(selectedGolfID, forKey: "courseId" as NSCopying)
            courseDic.setObject(selectedGolfName, forKey: "courseName" as NSCopying)
            courseDic.setObject(urlString, forKey: "image" as NSCopying)
            courseDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
            courseDic.setObject(Auth.auth().currentUser!.uid, forKey: "userKey" as NSCopying)
            courseDic.setObject(Auth.auth().currentUser!.displayName!, forKey: "userName" as NSCopying)
            courseDetailDic.setObject(courseDic, forKey: courseId as NSCopying)
            ref.child("stablefordRequest").updateChildValues(courseDetailDic as! [AnyHashable : Any])
            
            ref.child("userData/\(Auth.auth().currentUser!.uid)/stablefordCourse/").updateChildValues([selectedGolfID:Timestamp])
//            self.progressView.hide(navItem: self.navigationItem)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideStableFord"),object : nil)
        }
        })
    }
}
