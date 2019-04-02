//
//  ShareStatsVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Social

class ShareStatsVC: UIViewController, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var btnShareFeed: UIButton!
    @IBOutlet weak var sharePopUpView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var shareStackView: UIStackView!
    @IBOutlet weak var shareOnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharePopBottomConstraint: NSLayoutConstraint!
    
    var documentInteractionController: UIDocumentInteractionController = UIDocumentInteractionController()
    var shareCardView = CardView()
    var screenShot = UIImage()
    var fromFeed = Bool()
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        if fromFeed{
            shareOnTopConstraint.constant = -20.0
            sharePopBottomConstraint.constant = (self.view.center.y) - (sharePopUpView.frame.size.height/2)
            btnShareFeed.isHidden = true
        }
        else{
            //            shareOnTopConstraint.constant = 20.0
            
            btnShareFeed.isHidden = false
            
            if Constants.fromStatsPost{
                Constants.fromStatsPost = false
                for v in shareCardView.subviews{
                    if v.isKind(of: ShareStatsButton.self){
                        v.isHidden = false
                    }
                }
                self.dismiss(animated: false, completion: nil)
            }
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if fromFeed{
            self.dismiss(animated: false, completion: nil)
        }
    }
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for v in shareCardView.subviews{
            if v.isKind(of: ShareStatsButton.self){
                v.isHidden = true
            }
        }
        
        //--------- Take Screenshots and save to photo library --------------------
        //https://gist.github.com/tomasbasham/10533743
        var scaledImageRect = CGRect.zero
        let size = shareCardView.frame.size
        let aspectWidth:CGFloat = size.width / size.width
        let aspectHeight:CGFloat = size.height / size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        shareCardView.layer.render(in: UIGraphicsGetCurrentContext()!)
        screenShot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil)
        //--------------------------------------------------------------------------
        
        btnShareFeed.backgroundColor = UIColor.white
        btnShareFeed.titleLabel?.textColor = UIColor.glfBluegreen
        btnShareFeed.layer.borderWidth = 1.0
        btnShareFeed.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnShareFeed.layer.cornerRadius = 3.0
        
        let gestureView = UITapGestureRecognizer(target: self, action:  #selector (self.dismissView (_:)))
        dismissView.addGestureRecognizer(gestureView)
        
        var btnTag = 0
        for subView in self.shareStackView.subviews{
            if subView.isKind(of: UIButton.self){
                subView.tag = btnTag
                (subView as! UIButton).addTarget(self, action: #selector(self.shareAction(_:)), for: .touchUpInside)
                btnTag = btnTag+1
            }
        }
    }
    
    // MARK: - shareOnFeedAction
    @IBAction func shareOnFeedAction(_ sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FeedPostVC") as! FeedPostVC
        viewCtrl.screenshot = screenShot
        self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    
    // MARK: - dismissView
    @objc func dismissView(_ sender: UITapGestureRecognizer){
        for v in shareCardView.subviews{
            if v.isKind(of: ShareStatsButton.self){
                v.isHidden = false
            }
        }
        self.dismiss(animated: false, completion: nil)
        
    }
    
    // MARK: - shareAction
    @objc func shareAction(_ sender: UIButton) {
        let tagVal = sender.tag
        
        switch tagVal {
        case 0:
            //Share To Facebook:
            let share = [screenShot]
            let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
            
        case 1:
            //Share To Twitter:
            let share = [screenShot]
            let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        case 2:
            DispatchQueue.main.async {
                
                //Share To Instagrma:
                let instagramURL = URL(string: "instagram://app")
                if UIApplication.shared.canOpenURL(instagramURL!) {
                    let imageData = UIImageJPEGRepresentation(self.screenShot, 100)
                    let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
                    do {
                        try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
                    } catch {
                        debugPrint(error)
                    }
                    let fileURL = URL(fileURLWithPath: writePath)
                    self.documentInteractionController = UIDocumentInteractionController(url: fileURL)
                    self.documentInteractionController.delegate = self
                    self.documentInteractionController.uti = "com.instagram.exlusivegram"
                    self.documentInteractionController.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error", message: "Please install Instagram app", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        case 3:
            //Share To Whatsapp:
            let urlWhats = "whatsapp://app"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                        if let imageData = UIImageJPEGRepresentation(screenShot, 1.0) {
                            let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.write(to: tempFile, options: .atomic)
                                self.documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                self.documentInteractionController.uti = "net.whatsapp.image"
                                self.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                            } catch {
                                debugPrint(error)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Please install Whatsapp app", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        default: break
            //
        }
    }
    
    func showAlert(service:String)
    {
        let alert = UIAlertController(title: "Please Log In", message: "You need to be logged into the \(service) app to share this.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
