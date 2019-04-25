//
//  CustomTabBarCtrl.swift
//  GifterySampleApp
//
//  Created by Guest User on 13/06/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit
import FirebaseAuth
var isShowCase : Bool!

class CustomTabBarCtrl: UITabBarController,UITabBarControllerDelegate {

    var playNavCtrl:UINavigationController!
    var meNavCtrl:UINavigationController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isShowCase = false
        // Do any additional setup after loading the view.
        self.delegate = self
        //Golfication Me Setup
        
        let meVC = UIStoryboard(name: "Home", bundle:nil).instantiateViewController(withIdentifier: "NewHomeVC") as! NewHomeVC
        meVC.title = "Golfication"
        meVC.tabBarItem.image = #imageLiteral(resourceName: "homeTab")
        meVC.tabBarItem.title = "Home".localized()
        
        meVC.tabBarItem.selectedImage = UIImage(contentsOfFile: "homeTabSe")?.maskWithColor(color:
            UIColor.glfBluegreen)
        self.tabBar.tintColor = UIColor.glfBluegreen
        // select image
        meVC.view.backgroundColor = UIColor.white
        meNavCtrl = UINavigationController(rootViewController: meVC)
        
        // Golfication Together Setup
        let togetherVC = UIStoryboard(name: "Together", bundle:nil).instantiateViewController(withIdentifier: "TogetherVC") as! TogetherVC
        togetherVC.title = "Together".localized()
        togetherVC.tabBarItem.title = "Together".localized()
        togetherVC.tabBarItem.image = #imageLiteral(resourceName: "together_0")
        // deselect image
        togetherVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "together_1")
        // select image
        togetherVC.view.backgroundColor = UIColor.white
        let togetherNavCtrl = UINavigationController(rootViewController: togetherVC)

        let profileVC = UIStoryboard(name: "Home", bundle:nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.title = "Profile".localized()
        profileVC.tabBarItem.title = "Profile".localized()
        profileVC.tabBarItem.image = #imageLiteral(resourceName: "avatar_0")
        // deselect image
        profileVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "avatar_1")
        // select image
        let profileVCNavCtrl = UINavigationController(rootViewController: profileVC)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.glfBlack], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.glfDarkSlateBlue], for:.selected)
        
        //viewControllers = [meNavCtrl, togetherNavCtrl, exploreVCNavCtrl,playNavCtrl]
        viewControllers = [meNavCtrl, togetherNavCtrl, profileVCNavCtrl]
    }
   
    
    // MARK: - Play Action
    @objc private func playBtnAction(sender: UIButton) {
        //selectedIndex = 3
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
