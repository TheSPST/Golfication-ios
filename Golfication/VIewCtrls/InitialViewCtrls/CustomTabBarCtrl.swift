//
//  CustomTabBarCtrl.swift
//  GifterySampleApp
//
//  Created by Guest User on 13/06/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit
import ActionButton
import FirebaseAuth
var isShowCase : Bool!
var playButton: ActionButton!

class CustomTabBarCtrl: UITabBarController,UITabBarControllerDelegate {
    var twitter = ActionButtonItem(title: "", image:UIImage())
    var google = ActionButtonItem(title: "", image:UIImage() )

    var playNavCtrl:UINavigationController!
    var meNavCtrl:UINavigationController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true

//        playButton.contentView.isHidden = false
//        playButton.floatButton.isHidden = false
    }

//    profileVC.tabBarItem.image = #imageLiteral(resourceName: "homeTab")
//    profileVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "homeTabSelected")

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
        // deselect image
//        let originalImage = #imageLiteral(resourceName: "homeTabSe")
//        let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//        UITabBar.appearance().tintColor
        meVC.tabBarItem.selectedImage = UIImage(contentsOfFile: "homeTabSe")?.maskWithColor(color:
            UIColor.glfBluegreen)
        self.tabBar.tintColor = UIColor.glfBluegreen
        // select image
        meVC.view.backgroundColor = UIColor.white
        meNavCtrl = UINavigationController(rootViewController: meVC)
//        meNavCtrl.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
//        meNavCtrl.navigationItem.rightBarButtonItem?.tintColor = UIColor.glfBluegreen
//        meNavCtrl.navigationBar.tintColor = UIColor.glfGreenBlue
        
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
//        togetherNavCtrl.navigationBar.tintColor = UIColor.glfGreenBlue

        /*let exloreVC = UIStoryboard(name: "Explore", bundle:nil).instantiateViewController(withIdentifier: "ExploreVC") as! ExploreVC
        exloreVC.title = "Explore".localized()
        exloreVC.tabBarItem.title = "Explore".localized()
        exloreVC.tabBarItem.image = #imageLiteral(resourceName: "explore_0")
        // deselect image
        exloreVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "explore_1")
        // select image
        exloreVC.view.backgroundColor = UIColor.white
        let exploreVCNavCtrl = UINavigationController(rootViewController: exloreVC)
//        exploreVCNavCtrl.navigationBar.tintColor = UIColor.glfGreenBlue*/

        let profileVC = UIStoryboard(name: "Home", bundle:nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.title = "Profile".localized()
        profileVC.tabBarItem.title = "Profile".localized()
        profileVC.tabBarItem.image = #imageLiteral(resourceName: "avatar_0")
        // deselect image
        profileVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "avatar_1")
        // select image
        let profileVCNavCtrl = UINavigationController(rootViewController: profileVC)
        
        //        exploreVCNavCtrl.navigationBar.tintColor = UIColor.glfGreenBlue
//        let playActionVC = UIViewController()
//        playActionVC.view.backgroundColor = UIColor(rgb: 0xdad2d5)
//        playNavCtrl = UINavigationController(rootViewController: playActionVC)
//        playNavCtrl.navigationBar.tintColor = UIColor.glfBluegreen

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.glfBlack], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.glfDarkSlateBlue], for:.selected)

        //self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.glfBlack], for: .normal)
//        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.glfDarkSlateBlue], for:.selected);
//        self.tabBar.barTintColor = UIColor.glfDarkSlateBlue
        
        //viewControllers = [meNavCtrl, togetherNavCtrl, exploreVCNavCtrl,playNavCtrl]
        viewControllers = [meNavCtrl, togetherNavCtrl, profileVCNavCtrl]
        setupPlayTabButton()
    }
   

    // MARK: - Setup Play Button
    func setupPlayTabButton() {
        
        twitter = ActionButtonItem(title: "Twitter", image: #imageLiteral(resourceName: "twitter_icon"))
        twitter.action = {
            item in print("Twitter...")
        }
        
        google = ActionButtonItem(title: "Map View", image: UIImage(named:""))
        google.action = { item in
            
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.playNavCtrl = (self.selectedViewController as? UINavigationController)!
            self.playNavCtrl.pushViewController(mapViewController, animated: true)
            
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
        
        playButton = ActionButton(attachedToView: self.view, items: [twitter, google])
        playButton.action = { button in            
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.playNavCtrl = (self.selectedViewController as? UINavigationController)!
            self.playNavCtrl.pushViewController(mapViewController, animated: true)
            
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
        playButton.setImage(#imageLiteral(resourceName: "addScore"), forState: .normal)
        if(UIDevice.current.iPad){
            playButton.setImage(#imageLiteral(resourceName: "addScoreSmall"), forState: .normal)
        }
        
        // changed by Amit
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        view.layoutIfNeeded()
    }
    
    // MARK: - Play Action
    @objc private func playBtnAction(sender: UIButton) {
        //selectedIndex = 3
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController == tabBarController.viewControllers?[3] {
//            return false
//        } else {
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        return true
        //}
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
