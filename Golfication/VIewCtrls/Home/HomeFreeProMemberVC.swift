//
//  HomeFreeProMemberVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 24/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeFreeProMemberVC: UIViewController, UIScrollViewDelegate {
    
    // MARK: – Set Outlets
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var lblPricePerMonth: UILabel!
    @IBOutlet weak var cardView1: CardView!
    @IBOutlet weak var cardView2: CardView!
    @IBOutlet weak var cardView3: CardView!
    @IBOutlet weak var cardView4: CardView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewUpgradeTrial: UIView!
    @IBOutlet weak var viewJoinBtnContainer: UIView!
    @IBOutlet weak var viewJoinBtn: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblCongrats: UILabel!
    
    // MARK: – Set Variables
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var descTitleLabel: UILabel!
    var usrImageView: UIImageView!
    
    var fromUpgrade = Bool()
    var fromNewUserPopUp = Bool()
    
    // MARK: – closeAction
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinAction(_ sender: Any) {
        viewUpgradeTrial.isHidden = false
        viewJoinBtnContainer.isHidden = true
        
         let timeStart = NSDate(timeIntervalSince1970: (TimeInterval(Timestamp/1000)))
         let timeEnd = Calendar.current.date(byAdding: .day, value: 30, to: timeStart as Date)
         let formatter = DateFormatter()
         formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
         let expiryStr = formatter.string(from: timeEnd!)
         let trnStr = formatter.string(from: timeStart as Date)
         
         let membershipDict = NSMutableDictionary()
         membershipDict.setObject(0, forKey: "isMembershipActive" as NSCopying)
         membershipDict.setObject(trnStr, forKey: "transactionDate" as NSCopying)
         membershipDict.setObject(expiryStr, forKey: "expiryDate" as NSCopying)
         membershipDict.setObject("Free_Membership", forKey: "productID" as NSCopying)
         membershipDict.setObject(Timestamp, forKey: "timestamp" as NSCopying)
         
         let proMembership = ["proMembership":membershipDict]
         ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
         ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
         
         let subDic = NSMutableDictionary()
         subDic.setObject("Free_Membership", forKey: "productID" as NSCopying)
         subDic.setObject(Timestamp, forKey: "timestamp" as NSCopying)
         subDic.setObject("purchase", forKey: "type" as NSCopying)
         let subKey = ref!.child("\(Auth.auth().currentUser!.uid)").childByAutoId().key
         let subscriptionDict = NSMutableDictionary()
         subscriptionDict.setObject(subDic, forKey: subKey as NSCopying)
         ref.child("subscriptions/\(Auth.auth().currentUser!.uid)/").updateChildValues(subscriptionDict as! [AnyHashable : Any])
         
         UserDefaults.standard.set(false, forKey: "isNewUser")
         UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Free30DaysProActivated"), object: nil)
    }
    
    // MARK: – viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        viewUpgradeTrial.isHidden = true
        lblCongrats.text = "Your 30 days free trial has been activated"
        
//        viewUpgradeTrial.layer.cornerRadius = 5.0
//        viewJoinBtnContainer.layer.cornerRadius = 5.0
        viewJoinBtn.layer.cornerRadius = 25

        //        let attributeString =  NSMutableAttributedString(string: "$3.99/month")
//        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributeString.length))
//        lblPrice.attributedText = attributeString
        
        closeBtn.setCircle(frame: closeBtn.frame)
        
        cardView1.shadowOffsetHeight = Int(0.5)
        cardView1.shadowOpacity = 0.1
        
        cardView2.shadowOffsetHeight = Int(0.5)
        cardView2.shadowOpacity = 0.1
        
        cardView3.shadowOffsetHeight = Int(0.5)
        cardView3.shadowOpacity = 0.1
        
        cardView4.shadowOffsetHeight = Int(0.5)
        cardView4.shadowOpacity = 0.1
        
        //https://www.dribba.com/uiscrollview-and-autolayout-with-ios8-and-swift/
        scrollView.delegate = self
        
//        let rectShape = CAShapeLayer()
//        rectShape.bounds = self.viewJoinBtnContainer.frame
//        rectShape.position = self.viewJoinBtnContainer.center
//        rectShape.path = UIBezierPath(roundedRect: self.viewJoinBtnContainer.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 5, height: 5)).cgPath
//        self.viewJoinBtnContainer.layer.backgroundColor = UIColor.white.cgColor
//        self.viewJoinBtnContainer.layer.mask = rectShape
    }
    
    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)
        
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 10)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
    }
}
