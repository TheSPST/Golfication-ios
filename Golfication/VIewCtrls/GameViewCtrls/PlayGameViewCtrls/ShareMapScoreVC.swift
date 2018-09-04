//
//  ShareMapScoreVC.swift
//  Golfication
//
//  Created by Khelfie on 20/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import GoogleMaps
import Social

class ShareMapScoreVC: UIViewController , UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var btnShareFeed: UIButton!
    @IBOutlet weak var sharePopUpView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var shareStackView: UIStackView!
    @IBOutlet weak var shareOnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharePopBottomConstraint: NSLayoutConstraint!
    
    var documentInteractionController: UIDocumentInteractionController = UIDocumentInteractionController()
    var shareMapView = GMSMapView()
    var shareStack = StackView()
    var screenShot = UIImage()
    var screenShot1 = UIImage()
    var isVertical = false
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--------- Take Screenshots and save to photo library --------------------
        //https://gist.github.com/tomasbasham/10533743
        var scaledImageRect = CGRect.zero
        let size = shareMapView.frame.size
        
        let aspectWidth:CGFloat = size.width / size.width
        let aspectHeight:CGFloat = size.height / size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        //--------------------------------------------------------------------------
        
        btnShareFeed.backgroundColor = UIColor.white
        btnShareFeed.titleLabel?.textColor = UIColor.glfBluegreen
        btnShareFeed.layer.borderWidth = 1.0
        btnShareFeed.layer.borderColor = UIColor.glfBluegreen.cgColor
        btnShareFeed.layer.cornerRadius = 3.0

        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        shareMapView.layer.render(in: UIGraphicsGetCurrentContext()!)
        screenShot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //--------------------------------------------------------------------------
        if(isVertical){
            screenShot = mergedImageWithAnother(frontImage: screenShot.image(withRotation: -.pi/2), backgroundImage: screenShot1)
        }else{
            screenShot = mergedImageWith(frontImage: screenShot, backgroundImage: screenShot1)
        }

        UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil)

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
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func mergedImageWith(frontImage:UIImage, backgroundImage: UIImage) -> UIImage{
        
        let size = CGSize(width:(frontImage.size.width)*2, height:frontImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        frontImage.draw(in: CGRect.init(x: 0, y: 0, width: (size.width)/2, height: frontImage.size.height))
        backgroundImage.draw(in: CGRect.init(x: size.width/2, y: 0, width: (size.width)/2, height: backgroundImage.size.height))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func mergedImageWithAnother(frontImage:UIImage, backgroundImage: UIImage) -> UIImage{
        
        let size = CGSize(width:frontImage.size.width, height:frontImage.size.height + backgroundImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        frontImage.draw(in: CGRect.init(x: 0, y: 0, width: frontImage.size.width, height: frontImage.size.height))
        backgroundImage.draw(in: CGRect.init(x: 0, y: frontImage.size.height, width: frontImage.size.width, height: backgroundImage.size.height))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - shareOnFeedAction
    @IBAction func shareOnFeedAction(_ sender: UIButton) {
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FeedPostVC") as! FeedPostVC
        viewCtrl.screenshot = screenShot
        self.navigationController?.pushViewController(viewCtrl, animated: false)
    }
    
    // MARK: - dismissView
    @objc func dismissView(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: false, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShareShots"), object: nil)
    }
    
    // MARK: - shareAction
    @objc func shareAction(_ sender: UIButton) {
        let tagVal = sender.tag
        
        switch tagVal {
        case 0:
            //Share To Facebook:
            
            //if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            if let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook){
                vc.add(screenShot)
                //vc.add(URL(string: ""))
                //vc.setInitialText("Initial text here.")
                self.present(vc, animated: true, completion: nil)
            }
            //}else{self.showAlert(service: "Facebook") }
            
        case 1:
            //Share To Twitter:
            
            // if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            if let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter){
                vc.add(screenShot)
                //vc.add(URL(string: ""))
                //vc.setInitialText("Initial text here.")
                self.present(vc, animated: true, completion: nil)
            }
            //}else{self.showAlert(service: "Twitter") }
            
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
                        
                        print(error)
                    }
                    
                    let fileURL = URL(fileURLWithPath: writePath)
                    
                    self.documentInteractionController = UIDocumentInteractionController(url: fileURL)
                    
                    self.documentInteractionController.delegate = self
                    
                    self.documentInteractionController.uti = "com.instagram.exlusivegram"
                    
                    self.documentInteractionController.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
                    
                } else {
                    
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
extension UIView {
        func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
}
extension UIImage {
    func image(withRotation radians: CGFloat) -> UIImage {
        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!
        
        drawRect = drawRect.applying(tf)
        
        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        return resultImage
    }
}
