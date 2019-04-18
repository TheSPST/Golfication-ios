//
//  ExploreDetailPageVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 17/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import UICircularProgressRing

class ExploreDetailPageVC:  UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    var viewYouTube: YTPlayerView!
    var progressView = SDLoader()
    var pageViewController: UIPageViewController?

    var dataArray: NSMutableArray!
    var contentArray: NSArray!
    var finalDataArray: NSMutableArray!

    var contentTag = Int()
    var scrollIndex = Int()
    var ctgryKey = String()
    var topBarTitle = String()
    var categoryData: NSArray!
    var pageControllers = [UIViewController]()
    var scrollIndexUpdated = false
    
    @IBAction func backAction(){
        // do other task
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureScrollView(totalCard:Int) {
        scrollView.isPagingEnabled = true
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalCard), height: scrollView.frame.size.height)
        
        scrollView.delegate = self
        setInitialScrollPage()
    }
    
    func setInitialScrollPage() {
        
        setCurrentScrollPage(i: scrollIndex)
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(scrollIndex) * scrollView.frame.size.width, y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: true)
    }
    
    func setCurrentScrollPage(i:Int) {
        let testView = Bundle.main.loadNibNamed("TestView", owner: self, options: nil)![0] as! UIView
        
        testView.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: scrollView.frame.origin.y-64, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        testView.backgroundColor = UIColor.white
        
        let imageView = testView.viewWithTag(222) as! UIImageView
        imageView.backgroundColor = UIColor.darkGray
        let imageStr = ((((self.finalDataArray[i] as AnyObject).object(forKey:"image")) as? String) ?? "")
        let imageUrl = URL(string: imageStr)
        imageView.sd_setImage(with: imageUrl)
        if imageStr == ""{
            let youtubeStr = ((((self.finalDataArray[i] as AnyObject).object(forKey:"videoYoutube")) as? String) ?? "")
            let videoImage =  "https://img.youtube.com/vi/"+youtubeStr+"/hqdefault.jpg"
            let videoUrl = URL(string: videoImage)
            imageView.sd_setImage(with: videoUrl)
        }
        
        let btnYouTube = testView.viewWithTag(666) as! UIButton
            viewYouTube = (testView.viewWithTag(30000) as! YTPlayerView)
        let imageLink = ((((self.finalDataArray[i] as AnyObject).object(forKey:"image")) as? String) ?? "")
        if imageLink == ""{
            imageView.isHidden = true
            btnYouTube.tag = i
            btnYouTube.isHidden = false
            btnYouTube.addTarget(self, action: #selector(self.playeVideoAction(_:)), for: .touchUpInside)
            
            let youtubeStr = ((((self.finalDataArray[i] as AnyObject).object(forKey:"videoYoutube")) as? String) ?? "")
            viewYouTube.isHidden = false
            viewYouTube.load(withVideoId: youtubeStr)
        }
        else{
            imageView.isHidden = false
            btnYouTube.isHidden = true
            viewYouTube.isHidden = true
        }
        
        let label = testView.viewWithTag(10000) as! UILabel
        label.text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"title")) as? String) ?? "")
        
        let lblDetail = testView.viewWithTag(20000) as! UILabel
        let text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"text")) as? String) ?? "")
        lblDetail.text = text
        lblDetail.numberOfLines = 0
        if UIDevice.current.iPhone5 {
            lblDetail.numberOfLines = 7
        }
        lblDetail.sizeToFit()

        let circularView = testView.viewWithTag(40000)
        if text == ""{
            lblDetail.isHidden = true
            circularView?.isHidden = false
            
            let label1 = testView.viewWithTag(50000) as! UILabel
            label1.text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"param1")) as? String) ?? "").localized()
            
            let label2 = testView.viewWithTag(60000) as! UILabel
            label2.text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"param2")) as? String) ?? "")

            let label3 = testView.viewWithTag(70000) as! UILabel
            label3.text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"param3")) as? String) ?? "")

            let label4 = testView.viewWithTag(80000) as! UILabel
            label4.text = ((((self.finalDataArray[i] as AnyObject).object(forKey:"param4")) as? String) ?? "")

            let value1: Double = Double((((self.finalDataArray[i] as AnyObject).object(forKey:"value1")) as? String) ?? "")!
            let value2: Double = Double((((self.finalDataArray[i] as AnyObject).object(forKey:"value2")) as? String) ?? "")!
            let value3: Double = Double((((self.finalDataArray[i] as AnyObject).object(forKey:"value3")) as? String) ?? "")!
            let value4: Double = Double((((self.finalDataArray[i] as AnyObject).object(forKey:"value4")) as? String) ?? "")!

            let circularView1 = testView.viewWithTag(500000) as! UICircularProgressRingView
            circularView1.setProgress(value: CGFloat(value1), animationDuration: 1.0)
            circularView1.valueIndicator = "/10"
            
            let circularView2 = testView.viewWithTag(600000) as! UICircularProgressRingView
            circularView2.setProgress(value: CGFloat(value2), animationDuration: 1.0)
            circularView2.valueIndicator = "/10"

            let circularView3 = testView.viewWithTag(700000) as! UICircularProgressRingView
            circularView3.setProgress(value: CGFloat(value3), animationDuration: 1.0)
            circularView3.valueIndicator = "/10"

            let circularView4 = testView.viewWithTag(800000) as! UICircularProgressRingView
            circularView4.setProgress(value: CGFloat(value4), animationDuration: 1.0)
            circularView4.valueIndicator = "/10"

        }
        else{
            lblDetail.isHidden = false
            circularView?.isHidden = true
        }
        
        let linkType = ((((self.finalDataArray[i] as AnyObject).object(forKey:"linkType")) as? String) ?? "")
        let linkAction = ((((self.finalDataArray[i] as AnyObject).object(forKey:"linkAction")) as? String) ?? "")

        let btnVisit = testView.viewWithTag(555) as! UIButton
        btnVisit.layer.borderWidth = 1.0
        btnVisit.layer.cornerRadius = 2.0
        btnVisit.layer.borderColor = UIColor.glfBluegreen.cgColor
        if (linkType == "external") && !(linkAction == ""){
            btnVisit.tag = i
            btnVisit.isHidden = false
            btnVisit.addTarget(self, action: #selector(self.linkClicked(_:)), for: .touchUpInside)
        }
        else{
            btnVisit.isHidden = true
        }
        
        scrollView.addSubview(testView)
    }
    
    @objc func linkClicked(_ sender: UIButton!) {
        let tag = sender.tag
        
        let linkAction = ((((self.finalDataArray[tag] as AnyObject).object(forKey:"linkAction")) as? String) ?? "")
        let storyboard = UIStoryboard(name: "Explore", bundle: Bundle.main)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ExploreWebView") as! ExploreWebView
        viewCtrl.linkStr = linkAction
        viewCtrl.title = self.title
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    @objc func playeVideoAction(_ sender: UIButton!) {
       // let tag = sender.tag
        
          viewYouTube.playVideo()

    }
    
    func configurePageControl(totalCard:Int) {
        pageControl.numberOfPages = totalCard
        pageControl.currentPage = contentTag
        //pageControl.addTarget(self, action: #selector(self.changePageAction(_:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK: UIScrollViewDelegate method implementation
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width);
        pageControl.currentPage = Int(currentPage)
        setCurrentScrollPage(i: Int(currentPage))
    }
    
    
    // MARK: IBAction method implementation
    @objc func changePageAction(_ sender: UIPageControl) {
        var newFrame = scrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
    }

    
    @IBAction func changePage(_ sender: UIPageControl) {
        var newFrame = scrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.topBarTitle

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.getContentData(contentKey: self.ctgryKey)
    }
    
    func getContentData(contentKey: String) {
        self.contentArray = NSArray()
        finalDataArray = NSMutableArray()
        self.progressView.show()

//        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "message/content/\(contentKey)") { (snapshot) in
//            let contentData = (snapshot.value as? NSArray)!
        
            self.contentArray = categoryData.reversed() as NSArray
//            print("contentArray", self.contentArray)

            DispatchQueue.main.async( execute: {
                //var totalCount = 0
                let queue = OperationQueue()
                let blockOperation = BlockOperation {
                    //http://www.thomashanning.com/a-simple-nsblockoperation-example/
                    for i in 0..<self.contentArray.count{
                        let dataDic = self.contentArray[i] as! NSDictionary
                        
                        var index = 0
                        //Update ScrollIndex according to category and number of cards as one category have multiple cards
                        if self.scrollIndex == i && !self.scrollIndexUpdated {
                            self.scrollIndex = self.finalDataArray.count
                            self.scrollIndexUpdated = true
                        }
                        for(key,value) in dataDic{
                            let key  = key as! String
                            
                            if (value is NSDictionary) && key.range(of:"card") != nil{

                            let tempDic = dataDic.object(forKey: "card\(index+1)") as! NSDictionary

                                self.finalDataArray.addObjects(from: [tempDic])
                                index = index + 1
                            }
                        }
                    }
                    OperationQueue.main.addOperation {
                        self.progressView.hide()                        
                        if self.finalDataArray.count>0{
                        self.configureScrollView(totalCard: self.finalDataArray.count)
                        self.configurePageControl(totalCard: self.finalDataArray.count)
                        }
                    }
                }
                
                queue.addOperation(blockOperation)

            })
//        }
    }   
}
extension UIDevice {
    var iPhoneXSMax: Bool {
        return UIScreen.main.nativeBounds.height == 2688
    }
    var iPhoneXR: Bool {
        return UIScreen.main.nativeBounds.height == 1792
    }
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhonePlus: Bool {
        return UIScreen.main.nativeBounds.height == 2208
    }
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    var iPhoneSE: Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    var iPad: Bool{
        return UIDevice.current.model.range(of: "iPad") != nil
    }
    var iPad960: Bool{
        return UIScreen.main.nativeBounds.height == 960
    }
    var iPad1334: Bool{
        return UIScreen.main.nativeBounds.height == 1334
    }
    var iPhone: Bool{
        return UIScreen.main.nativeBounds.height == 1334
    }
}
