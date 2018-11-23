//
//  PracticePageContainerVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 14/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import ActionSheetPicker_3_0

class PracticePageContainerVC: ButtonBarPagerTabStripViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var shadowView: UIView!
    var shotsArray = [String]()
    @IBOutlet weak var barBtnBLE: UIBarButtonItem!
    @IBOutlet weak var barBtnMenu: UIBarButtonItem!
    
    @IBOutlet weak var swingDetailsView: UIView!
    @IBOutlet weak var swingTableView: UITableView!
    
    @IBAction func backAction(_ sender: Any) {
        if(swingDetailsView.isHidden){
            if superClassName == "SwingSessionVC"{
                    swingDetailsView.isHidden = false
//                self.navigationController?.popViewController(animated: true)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            if superClassName == "SwingSessionVC"{
                self.navigationController?.popViewController(animated: true)
            }else{
                swingDetailsView.isHidden = true
            }

        }
    }
    var swingKey = String()
    var tempArray1 = NSArray()
    var isFirst = false
    var count:Int!
    var superClassName : String!
    override func viewDidLoad() {
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
        
        superClassName = NSStringFromClass((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].classForCoder)!).components(separatedBy: ".").last!
        if superClassName == "SwingSessionVC"{
            self.swingDetailsView.isHidden = false
            self.navigationItem.rightBarButtonItems = nil
            
        }else{
            UIApplication.shared.isIdleTimerDisabled = true
            self.swingDetailsView.isHidden = true
            NotificationCenter.default.addObserver(self, selector: #selector(self.showShotsAfterSwing(_:)), name: NSNotification.Name(rawValue: "getSwingInside"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPopUp(_:)), name: NSNotification.Name(rawValue: "practiceFinished"), object: nil)
            self.moveToViewController(at: shotsArray.count-1)
        }
    }
    @IBAction func barBtnBLEAction(_ sender: Any) {
    }

    @IBAction func barBtnMenuAction(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Menu", rows: ["Finish","View All"], initialSelection: 0, doneBlock: { (picker, value, index) in
            if(value == 0){
                debugPrint("Finished")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command8"), object: "Finish")
            }else if(value == 1){
                debugPrint("ViewALL")
                self.swingDetailsView.isHidden = false
            }
            
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin:sender)

    }
    //MARK: PracticeMatchFinished
    @objc func finishedPopUp(_ notification:NSNotification){
        self.backAction(Any.self)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "practiceFinished"))
    }
    //MARK: showShotsAfterSwing
    @objc func showShotsAfterSwing(_ notification:NSNotification){
        if let dict = notification.object as? NSMutableDictionary{
            let swingKey = dict.value(forKey: "id") as! String
            FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "swingSessions/\(swingKey)/") { (snapshot) in
                var dict = NSMutableDictionary()
                if let diction = snapshot.value as? NSMutableDictionary{
                    dict = diction
                }
                DispatchQueue.main.async(execute: {
                    let swingArr = dict.value(forKey: "swings") as! NSArray
                    var shotsAr = [String]()
                    for i in 0..<swingArr.count{
                        shotsAr.append("Shot \(i+1)")
                    }
                    self.shotsArray = shotsAr
                    self.tempArray1 = swingArr
                    self.isFirst = false
                    self.moveToViewController(at: shotsAr.count-1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.reloadPagerTabStripView()
                        self.moveToViewController(at: shotsAr.count-1)
                    })
                })
            }
        }
    }
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        if playButton != nil{
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        superClassName = NSStringFromClass((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].classForCoder)!).components(separatedBy: ".").last!
        if !isFirst{
            isFirst = true
            shotsArray.append("Shot \(shotsArray.count+1)")
            if superClassName == "SwingSessionVC"{
                shotsArray.removeLast()
            }
        }
        
        let myArray = NSMutableArray()
        myArray.addObjects(from: shotsArray)
        var finalArray = NSMutableArray()
        finalArray = myArray.mutableCopy() as! NSMutableArray
        for i in 0..<tempArray1.count{
            let swingDetails = tempArray1[i] as! NSMutableDictionary
            if let club = swingDetails.value(forKey: "club") as? String{
                if club == "Pu"{
                    finalArray.removeObject(at: i)
                    break
                }
            }
        }
        var array = [UIViewController]()
        for i in 0..<finalArray.count{
            let storyboard = UIStoryboard(name: "Device", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "PracticeSessionVC") as! PracticeSessionVC
            viewCtrl.shotNumStr = finalArray[i] as! String
            viewCtrl.shotsArray = finalArray as! [String]
            viewCtrl.count = self.count
            viewCtrl.superClassName = superClassName
            if(i < tempArray1.count){
                viewCtrl.swingDetails = tempArray1[i] as! NSMutableDictionary
            }
            array.append(viewCtrl)
        }
        return array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swingTableViewCell", for: indexPath) as! SwingTableViewCell
        if let swingDetails = tempArray1[indexPath.item] as? NSMutableDictionary{
            cell.lblTitle.text = "Session \(indexPath.item+1)"
            if let club = swingDetails.value(forKey: "club") as? String{
                cell.clubImageView.image = UIImage(imageLiteralResourceName: club == "" ? "Dr":club)
                cell.lblSubtitle.text = club
            }else{
                cell.clubImageView.image = #imageLiteral(resourceName: "club")
            }
            if let time = swingDetails.value(forKey: "timestamp") as? Int64{
                let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en")
                dateFormatter.dateFormat = "MMM d, yyyy"
                let strDate = dateFormatter.string(from: date)

                cell.lblTimeStamp.text = "\(strDate)"
            }else{
                cell.lblTimeStamp.text = "No Time Available"
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let swingDetails = tempArray1[indexPath.item] as? NSMutableDictionary{
            if let club = swingDetails.value(forKey: "club") as? String{
                if club != "Pu"{
                    self.moveToViewController(at: indexPath.item)
                    self.swingDetailsView.isHidden = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(66.0)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if superClassName != "SwingSessionVC"{
            return shotsArray.count-1
        }else{
            return shotsArray.count
        }
    }
}
