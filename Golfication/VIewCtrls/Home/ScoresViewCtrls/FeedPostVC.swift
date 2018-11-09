//
//  FeedPostVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 30/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class FeedPostVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var usrImgView: UIImageView!
    @IBOutlet weak var screenShotImgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var screenshot = UIImage()
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtView.layer.borderColor = UIColor.lightGray.cgColor
        txtView.layer.borderWidth = 1.0
        txtView.layer.cornerRadius = 3.0
        txtView.text = "Say Something"
        txtView.textColor = UIColor.lightGray
        
        usrImgView.layer.cornerRadius = usrImgView.frame.size.height/2
        usrImgView.layer.masksToBounds = true

        usrImgView.sd_setImage(with: Auth.auth().currentUser?.photoURL, completed: nil)
        if Auth.auth().currentUser?.photoURL == nil{
           usrImgView.image = UIImage(named:"you")
        }
        screenShotImgView.image = screenshot
    }
    
    // MARK: - cancelAction
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - postAction
    @IBAction func postAction(_ sender: UIBarButtonItem){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        var postText = txtView.text
        if txtView.text == "Say Something"{
            postText = ""
        }
        
        let feedId = ref!.child("feedData").childByAutoId().key
        ref.child("userData/\(Auth.auth().currentUser!.uid)/myFeeds").updateChildValues([feedId:false])
        ref.child("feedData/\(feedId)").updateChildValues(["message":postText!])
        ref.child("feedData/\(feedId)").updateChildValues(["type":"1"])
        
        ref.child("feedData/\(feedId)").updateChildValues(["timestamp": beginTimestamp])
        var imagUrl = String()
        if(Auth.auth().currentUser?.photoURL != nil){
            imagUrl = "\((Auth.auth().currentUser?.photoURL)!)"
        }
        ref.child("feedData/\(feedId)").updateChildValues(["userImage": imagUrl])
        ref.child("feedData/\(feedId)").updateChildValues(["userKey": Auth.auth().currentUser!.uid])
        ref.child("feedData/\(feedId)").updateChildValues(["userName": Auth.auth().currentUser!.displayName!])

        self.txtView.resignFirstResponder()
        let imageRef = Storage.storage().reference().child("shareImages").child("\(Auth.auth().currentUser!.uid)-\(beginTimestamp)-ios-shareImage.png")
        
        uploadImage(screenshot, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            ref.child("feedData/\(feedId)").updateChildValues(["shareImage":urlString])
            
            Constants.fromStatsPost = true

            FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "friends") { (snapshot) in
                var dataDic = [String:Bool]()
                if(snapshot.childrenCount > 0){
                    dataDic = (snapshot.value as? [String : Bool])!
                }
                if dataDic.count > 0{
                for (key, _) in dataDic{
                    Notification.sendNotification(reciever: key, message: "Your friend \(Auth.auth().currentUser!.displayName ?? "") shared an update. ", type: "12", category: "FeedPost", matchDataId: "", feedKey: feedId)
                  }
                }
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.navigationController?.popViewController(animated: false)
                })
            }
        }
    }
    
    var beginTimestamp: Int {
        return Int(NSDate().timeIntervalSince1970)*1000
    }
    
     func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        //https://www.makeschool.com/online-courses/tutorials/build-a-photo-sharing-app-9f153781-8df0-4909-8162-bb3b3a2f7a81/uploading-photos-to-firebase
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
        
    // MARK: - UITextView Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Say Something"
            textView.textColor = UIColor.lightGray
        }
    }
}
