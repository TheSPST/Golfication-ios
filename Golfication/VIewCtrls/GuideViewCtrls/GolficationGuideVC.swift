//
//  GolficationGuideVC.swift
//  Golfication
//
//  Created by Khelfie on 22/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class GolficationGuideVC: UIViewController,UIScrollViewDelegate{
    
    @IBOutlet weak var cardView1: CardView!
    @IBOutlet weak var cardView2: CardView!
    @IBOutlet weak var cardView3: CardView!
    @IBOutlet weak var cardView4: CardView!

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblDexcriptions: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    @IBOutlet weak var  scoringImgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var  rfImgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var  ultimateImgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var  statsImgTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var lblScoring: UILabel!
    @IBOutlet weak var lblRF: UILabel!
    @IBOutlet weak var lblUltimate: UILabel!
    @IBOutlet weak var lblStats: UILabel!

    @IBOutlet weak var scoreImageView: UIImageView!
    @IBOutlet weak var rfImageView: UIImageView!
    @IBOutlet weak var ultimateImageView: UIImageView!
    @IBOutlet weak var statsImageView: UIImageView!

    var fbId = String()
    var currentPageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        if let providerData = Auth.auth().currentUser?.providerData {
            for item in providerData {
                fbId = item.providerID
            }
        }
        if Auth.auth().currentUser != nil{
            if fbId  == "facebook.com" || (Auth.auth().currentUser?.isEmailVerified)!{
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
            }
        }
        if UIDevice.current.iPhoneX || UIDevice.current.iPhonePlus{
            scoringImgTopConstraint.constant = cardView1.center.y - scoreImageView.frame.size.height/2
            rfImgTopConstraint.constant = cardView2.center.y - rfImageView.frame.size.height/2
            ultimateImgTopConstraint.constant = cardView3.center.y - ultimateImageView.frame.size.height/2
            statsImgTopConstraint.constant = cardView4.center.y - statsImageView.frame.size.height/2
        }
        else if UIDevice.current.iPhone{
            scoringImgTopConstraint.constant = cardView1.center.y - scoreImageView.frame.size.height/2 - 70
            rfImgTopConstraint.constant = cardView2.center.y - rfImageView.frame.size.height/2 - 70
            ultimateImgTopConstraint.constant = cardView3.center.y - ultimateImageView.frame.size.height/2 - 70
            statsImgTopConstraint.constant = cardView4.center.y - statsImageView.frame.size.height/2 - 70
        }
        else if(UIDevice.current.iPad960){
            scoreImageView.image = #imageLiteral(resourceName: "slideimg_1_iPad960")
            scoringImgTopConstraint.constant = 0
            rfImgTopConstraint.constant = 0
            ultimateImgTopConstraint.constant = -20
            statsImgTopConstraint.constant = 0
        }
        
        lblScoring.text = "Record Hole scores, Fairways, GIRs and Putts for you and your friends."
        lblRF.text = "Fast and accurate Distances, Free club recommendations, and live scoring."
        lblUltimate.text = "Automatic tracking and stats for every shot. Ultimate game-improvement mode."
        lblStats.text = "Fairways, GIRs, Putts, Club stats, strokes gained and more."
        
        //https://www.dribba.com/uiscrollview-and-autolayout-with-ios8-and-swift/
        self.navigationController?.navigationBar.isHidden = true
        scrollView.delegate = self
    }

    // MARK: – ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){

        let pageWidth: CGFloat =  scrollView.frame.size.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(currentPage)

        let x =  CGFloat(self.pageControl.currentPage) * (pageWidth)
         scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)
        
        btnNext.setTitle("Next", for: .normal)
         if pageControl.currentPage == 3 {
            btnNext.setTitle("Start", for: .normal)
        }
        currentPageIndex = self.pageControl.currentPage
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        
        currentPageIndex = self.pageControl.currentPage + 1
        pageControl.currentPage += 1
        
        let x = CGFloat(pageControl.currentPage) * (scrollView.frame.size.width)
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
        btnNext.setTitle("Next", for: .normal)
         if currentPageIndex == 3 {
            btnNext.setTitle("Start", for: .normal)
        }
        if currentPageIndex == 4{
            currentPageIndex = 0
            self.btnSkipAction((Any).self)
        }
    }
    
    @IBAction func btnSkipAction(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            if fbId  == "facebook.com" || (Auth.auth().currentUser?.isEmailVerified)!{
                let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarCtrl
            }
            else{
                let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthParentVC") as! AuthParentVC
                self.navigationController?.pushViewController(viewCtrl, animated: false)
            }
        }
        else{
            let viewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthParentVC") as! AuthParentVC
            self.navigationController?.pushViewController(viewCtrl, animated: false)
        }
    }
}
