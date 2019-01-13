//
//  AssignTagVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 22/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreBluetooth
class AssignTagVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var shadowView: UIView!
    var clubs = NSMutableDictionary()
    var golfBagArr = NSMutableArray()
    let progressView = SDLoader()

    var golfBag = [String]()
    
    var golfBagDriverArray = [String]()
    var golfBagWoodArray = [String]()
    var golfBagHybridArray = [String]()
    var golfBagIronArray = [String]()
    var golfBagWageArray = [String]()
    var golfBagPuttArray = [String]()
    var allClubs = ["Dr","3w","4w","5w","7w","1i","2i","3i","4i","5i","6i","7i","8i","9i","1h","2h","3h","4h","5h","6h","7h","Pw","Gw","Sw","Lw","Pu"]

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var array = [UIViewController]()
        for i in 0..<golfBag.count{
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "AssignTabsVC") as! AssignTabsVC
            viewCtrl.golfBagStr = golfBag[i]
            viewCtrl.golfBagDriverArray = golfBagDriverArray
            viewCtrl.golfBagIronArray = golfBagIronArray
            viewCtrl.golfBagWoodArray = golfBagWoodArray
            viewCtrl.golfBagWageArray = golfBagWageArray
            viewCtrl.golfBagHybridArray = golfBagHybridArray
            viewCtrl.golfBagPuttArray = golfBagPuttArray
            viewCtrl.clubs = clubs
            viewCtrl.golfBagArr = self.golfBagArr
            array.append(viewCtrl)
        }
        return array
}
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    @objc func btnContinueAction(){
        debugPrint("Continue")
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            self.progressView.show(atView: self.view, navItem: self.navigationItem)
            if let tempArray = snapshot.value as? NSMutableArray{
                self.golfBagArr = tempArray
            }
            
            DispatchQueue.main.async(execute: {
                self.calculateTagWithClubNumber()
            })
        }
    }
    func calculateTagWithClubNumber(){
        Constants.tagClubNumber.removeAll()
        for j in 0..<self.golfBagArr.count{
            if let club = self.golfBagArr[j] as? NSMutableDictionary{
                if club.value(forKey: "tag") as! Bool{
                    let tagNumber = club.value(forKey: "tagNum") as! String
                    var num = 0
                    if tagNumber.contains("a") || tagNumber.contains("A") || tagNumber.contains("b") || tagNumber.contains("B") || tagNumber.contains("c") || tagNumber.contains("C") || tagNumber.contains("d") || tagNumber.contains("D") || tagNumber.contains("e") || tagNumber.contains("E") || tagNumber.contains("f") || tagNumber.contains("F"){
                        num = Int(tagNumber, radix: 16)!
                    }else{
                        num = Int(tagNumber)!
                    }
                    let clubName = club.value(forKey: "clubName") as! String
                    let clubNumber = self.allClubs.index(of: clubName)! + 1
                    Constants.tagClubNumber.append((tag: num, club: clubNumber,clubName:clubName))
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command2"), object: Constants.tagClubNumber)
    }
    @objc func startMatch(_ notification:NSNotification){
        if let game = notification.object as? String{
            if(game == "New Match"){
                let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
                self.navigationController?.pushViewController(mapViewController, animated: true)
            }else{
                let viewCtrl = UIStoryboard(name: "Device", bundle:nil).instantiateViewController(withIdentifier: "ScanningVC") as! ScanningVC
                self.navigationController?.pushViewController(viewCtrl, animated: true)
            }
        }
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
          self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
//        NotificationCenter.default.addObserver(self, selector: #selector(btnContinueAction), name: NSNotification.Name(rawValue: "command"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startMatch(_:)), name: NSNotification.Name(rawValue: "startMatch"), object: nil)
        self.tabBarController?.tabBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        let btn = UIBarButtonItem(title: "Continue".localized(), style: .done, target: self, action: #selector(self.btnContinueAction))
        btn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setRightBarButtonItems([btn], animated: true)
        
        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.chkBluetoothStatus(_:)), name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)

        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.glfBluegreen
        settings.style.buttonBarItemFont = UIFont(name: "SFProDisplay-Medium", size: 14.0)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        super.viewDidLoad()
        self.title = "Assign Tags"
        self.progressView.hide(navItem: self.navigationItem)
    }
    @objc func chkBluetoothStatus(_ notification: NSNotification) {
        let notifBleStatus = notification.object as! String
        if  !(notifBleStatus == "") && (notifBleStatus == "Bluetooth_ON"){
            
        }
        else{
            self.navigationController?.popViewController(animated: false)
            
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BluetoothStatus"), object: nil)
    }
}
