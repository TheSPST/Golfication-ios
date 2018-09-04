//
//  ProfileProMemberPopUPVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 06/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

var fromIndiegogo = Bool()

class ProfileProMemberPopUPVC: UIViewController, UIScrollViewDelegate {

    // MARK: – Set Outlets
    @IBOutlet weak var closeBtn: UIButton!

    @IBOutlet weak var cardView1: CardView!
    @IBOutlet weak var cardView2: CardView!
    @IBOutlet weak var cardView3: CardView!
    @IBOutlet weak var cardView4: CardView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewUpgradeTrial: UIView!

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
        
        if UserDefaults.standard.object(forKey: "isNewUser") as? Bool != nil{
        let newUser = UserDefaults.standard.object(forKey: "isNewUser") as! Bool
        if (newUser && fromNewUserPopUp){
            UserDefaults.standard.set(false, forKey: "isNewUser")
            UserDefaults.standard.synchronize()
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
        else{
            dismiss(animated: true, completion: nil)
            }
        }
        else{
            dismiss(animated: true, completion: nil)
        }
        if fromIndiegogo{
            fromIndiegogo = false
//            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarCtrl
        }
    }
    
    // MARK: – viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        if fromIndiegogo{
            lblCongrats.text = "Your 1 year pro membership has been activated"
        }
        else{
            lblCongrats.text = "Your 30 days free trial has been activated"
        }
        viewUpgradeTrial.layer.cornerRadius = 5.0
        if fromUpgrade || fromNewUserPopUp{
            viewUpgradeTrial.isHidden = false
        }
        else{
            viewUpgradeTrial.isHidden = true
        }
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
        
        /*titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: (self.view.frame.size.width)-20, height: 25))
        titleLabel.text = "Golfication Pro Membership"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "SFProDisplay-Medium", size: 21.0)
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.clear
        
        usrImageView = UIImageView(frame: CGRect(x: 50, y: titleLabel.frame.origin.y + titleLabel.frame.size.height+10, width: self.view.frame.size.width-40-40-40, height: self.view.frame.size.width-40-40-50))
        usrImageView.backgroundColor = UIColor.clear
        usrImageView.contentMode = .scaleAspectFit
        
        subTitleLabel = UILabel(frame: CGRect(x: 20, y: usrImageView.frame.origin.y + usrImageView.frame.size.height+5, width: (self.view.frame.size.width)-40-20, height: 40))
        subTitleLabel.numberOfLines = 1
        subTitleLabel.textAlignment = .center
        subTitleLabel.font = UIFont(name: "SFProDisplay-Medium", size: 19.0)
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.backgroundColor = UIColor.clear
        
        descTitleLabel = UILabel(frame: CGRect(x: 20, y: subTitleLabel.frame.origin.y + subTitleLabel.frame.size.height-10, width: (self.view.frame.size.width)-40-20, height: 40))
        descTitleLabel.numberOfLines = 2
        descTitleLabel.textAlignment = .center
        descTitleLabel.font = UIFont(name: "SFProDisplay-Regular", size: 13.0)
        descTitleLabel.textColor = UIColor.white
        descTitleLabel.backgroundColor = UIColor.clear
        
        
        subTitleLabel.text = "Advanced Stats"
        descTitleLabel.text = "Distance, range and accuracy for all your clubs"
        usrImageView.image = #imageLiteral(resourceName: "Advancedstats")
        
        cardView1.addSubview(titleLabel)
        cardView1.addSubview(descTitleLabel)
        cardView1.addSubview(usrImageView)
        cardView1.addSubview(subTitleLabel)*/
    }

    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
//        titleLabel.removeFromSuperview()
//        subTitleLabel.removeFromSuperview()
//        usrImageView.removeFromSuperview()
        
        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)
        
        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 10)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        /*if pageControl.currentPage == 0 {
            subTitleLabel.text = "Advance Stats"
            descTitleLabel.text = "Distance, range and accuracy for all your clubs"
            usrImageView.image = #imageLiteral(resourceName: "Advancedstats")
            
            cardView1.addSubview(titleLabel)
            cardView1.addSubview(subTitleLabel)
            cardView1.addSubview(descTitleLabel)
            cardView1.addSubview(usrImageView)
        }
        else if pageControl.currentPage == 1 {
            subTitleLabel.text = "Club Selection & Control"
            descTitleLabel.text = "Know which clubs you need to hit often, and which you'd better leave out."
            usrImageView.image = #imageLiteral(resourceName: "controlPro")
            
            cardView2.addSubview(titleLabel)
            cardView2.addSubview(subTitleLabel)
            cardView2.addSubview(descTitleLabel)
            cardView2.addSubview(usrImageView)
        }
        else if pageControl.currentPage == 2 {
            subTitleLabel.text = "Super Early-Bird Discount"
            descTitleLabel.text = "Get a $100 pre-order discount coupon for Golf's most powerful wearable on launch day"
            usrImageView.image = #imageLiteral(resourceName: "device1")
            
            cardView3.addSubview(titleLabel)
            cardView3.addSubview(subTitleLabel)
            cardView3.addSubview(descTitleLabel)
            cardView3.addSubview(usrImageView)
        }
            
        else if pageControl.currentPage == 3 {
            subTitleLabel.text = "Strokes Gained Analysis"
            descTitleLabel.text = "Break down each selection of your game, to better plan your training sessions."
            usrImageView.image = #imageLiteral(resourceName: "sg")
            
            cardView4.addSubview(titleLabel)
            cardView4.addSubview(subTitleLabel)
            cardView4.addSubview(descTitleLabel)
            cardView4.addSubview(usrImageView)
        }*/
    }
}
