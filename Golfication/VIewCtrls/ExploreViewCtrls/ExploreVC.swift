//
//  ExploreVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import ActionButton
import SDWebImage

class ExploreVC: UIViewController, UIScrollViewDelegate {
    var exploreDataArray = [(title: String, position: String, ctgry: String, subTitle: [String], image: [String], videoYoutube: [String], ctgryIndex: [Int], parent: [String])]()
    
    //http://www.aegisiscblog.com/how-to-make-the-use-of-youtube-player-in-swift.html
    
    @IBOutlet weak var exploreTableView: UITableView!
    
    @IBOutlet weak var containerScrollVIew: UIScrollView!
    var progressView = SDLoader()
    
    var exploreScrollVIew: UIScrollView!
    
    var pageControl : UIPageControl!
    
    var lblTitle: UILabel!
    var lblSubTitle: UILabel!
    var exploreImageView: UIImageView!
    var btnViewAll: UIButton!
    var containerView: UIView!
    var tempArray:NSMutableArray!
    var viewSuperFrame:CGRect!
    var categoryData:NSMutableDictionary!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !(appDelegate.isInternet){
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(exploreDataArray.count == 0){
            self.getApiData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
    }
    func getApiData(){
        self.tempArray = NSMutableArray()
        viewSuperFrame = view.frame
        progressView.show()
        categoryData = NSMutableDictionary()
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "message/category") { (snapshot) in
            let dataDic = (snapshot.value as? NSDictionary)!
            
            for(key,value) in dataDic{
                let valDic  = value as! NSMutableDictionary
                valDic.setObject(key, forKey: "ctgry" as NSCopying)
                
                self.tempArray.add(valDic)
            }
            
            DispatchQueue.main.async( execute: {
                let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
                let array: NSArray = self.tempArray.sortedArray(using: [sortDescriptor]) as NSArray
                self.tempArray.removeAllObjects()
                self.tempArray = NSMutableArray()
                self.tempArray = array.mutableCopy() as! NSMutableArray
                
                for i in 0..<self.tempArray.count{
                    let title = ((self.tempArray[i] as AnyObject) .object(forKey:"title") as? String) ?? ""
                    if title == "Courses"{
                        self.tempArray.removeObject(at: i)
                        break
                    }
                }
                
                var key = String()
                let group = DispatchGroup()
                for j in 0..<self.tempArray.count{
                    group.enter()
                    
                    key = ((self.tempArray[j] as AnyObject) .object(forKey:"ctgry") as? String) ?? ""
                    
                    ref.child("message/content/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                        if snapshot.exists() {
                            
                            let contentData = (snapshot.value as? NSArray)!
                            
                            let title = ((self.tempArray[j] as AnyObject) .object(forKey:"title") as? String) ?? ""
                            let position = ((self.tempArray[j] as AnyObject) .object(forKey:"position") as? String) ?? ""
                            let ctgry = ((self.tempArray[j] as AnyObject) .object(forKey:"ctgry") as? String) ?? ""
                            
                            self.categoryData.setValue(contentData, forKey: ctgry)
                            
                            var subTitle = [String]()
                            var image = [String]()
                            var ctgryIndex = [Int]()
                            var parent = [String]()
                            var videoYoutube = [String]()
                            
                            for i in (contentData.count-5)..<contentData.count{
                                
                                subTitle.append(((contentData[i] as AnyObject).object(forKey:"title") as? String) ?? "")
                                image.append(((contentData[i] as AnyObject).object(forKey:"image") as? String) ?? "")
                                ctgryIndex.append(i)
                                parent.append(((contentData[i] as AnyObject).object(forKey:"parent") as? String) ?? "")
                                let dic = ((contentData[i] as AnyObject).object(forKey:"card1") as? NSDictionary)
                                videoYoutube.append((dic?.object(forKey: "videoYoutube") as? String) ?? "")
                            }
                            subTitle = subTitle.reversed()
                            image = image.reversed()
                            ctgryIndex = ctgryIndex.reversed()
                            parent = parent.reversed()
                            videoYoutube = videoYoutube.reversed()
                            
                            self.exploreDataArray.append((title: title, position: position, ctgry: ctgry, subTitle: subTitle, image: image, videoYoutube: videoYoutube, ctgryIndex: ctgryIndex, parent: parent))
                            
                            
                        }
                        group.leave()
                    })
                }
                group.notify(queue: .main) {
                    self.progressView.hide()
                    self.setData()
                }
            })
        }
    }
    
    func setData() {
        
        containerScrollVIew.showsHorizontalScrollIndicator = false
        containerScrollVIew.showsVerticalScrollIndicator = false
        
        for i in 0..<tempArray.count{
            let yXis: CGFloat = CGFloat(352*i)
            
            exploreScrollVIew = UIScrollView(frame: CGRect(x:0, y: yXis, width:viewSuperFrame.size.width, height: 352))
            exploreScrollVIew.delegate = self
            exploreScrollVIew.isPagingEnabled = true
            containerScrollVIew.addSubview(exploreScrollVIew)
            
            exploreScrollVIew.showsHorizontalScrollIndicator = false
            exploreScrollVIew.showsVerticalScrollIndicator = false
            
            for index in 0..<exploreDataArray.count {
                
                viewSuperFrame.origin.x = self.exploreScrollVIew.frame.size.width * CGFloat(index)
                viewSuperFrame.size = self.exploreScrollVIew.frame.size
                
                containerView = UIView(frame: viewSuperFrame)
                containerView.backgroundColor = UIColor.clear
                containerView.tag = (i*tempArray.count) + index

                configurePageControl(index: index)
                
                lblTitle = UILabel(frame: CGRect(x: 10, y:10, width: 70, height: 30))
                lblTitle.backgroundColor = UIColor.clear
                lblTitle.textColor = UIColor.black
                lblTitle.font = UIFont(name: "SFProDisplay-Semibold", size: 19.0)!
                lblTitle.text = exploreDataArray[i].title
                lblTitle.sizeToFit()
                containerView.addSubview(lblTitle)
                
                btnViewAll = UIButton(frame: CGRect(x: lblTitle.frame.origin.x+lblTitle.frame.size.width+10, y: lblTitle.frame.origin.y, width: 70, height: 30))
                btnViewAll.setTitle("View All", for: .normal)
                btnViewAll.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 15.0)!
                btnViewAll.setTitleColor(UIColor.blue, for: .normal)
                btnViewAll.backgroundColor = UIColor.clear
                containerView.addSubview(btnViewAll)
                btnViewAll.isHidden = true
                
                exploreImageView = UIImageView(frame: CGRect(x: 0, y: btnViewAll.frame.origin.y+btnViewAll.frame.size.height+10, width: viewSuperFrame.size.width, height: 196))
                exploreImageView.backgroundColor = UIColor.darkGray
                let imageUrl = URL(string: (exploreDataArray[i].image[index]))
                self.exploreImageView.sd_setImage(with: imageUrl)
                if (exploreDataArray[i].image[index]) == ""{
                    //videoYoutube
                    let videoImage =  "https://img.youtube.com/vi/"+(exploreDataArray[i].videoYoutube[index])+"/hqdefault.jpg"
                    let videoImageUrl = URL(string: videoImage)
                    self.exploreImageView.sd_setImage(with: videoImageUrl)
                }
                containerView.addSubview(exploreImageView)
                
                let containerGesture = UITapGestureRecognizer(target: self, action:  #selector (self.imageTapAction (_:)))
                containerView.addGestureRecognizer(containerGesture)
                
                let bgBottomView = UIView(frame: CGRect(x: 0, y: exploreImageView.frame.origin.y+exploreImageView.frame.size.height, width: view.frame.size.width, height: 113))
                bgBottomView.backgroundColor = UIColor.white
                containerView.addSubview(bgBottomView)
                
                lblSubTitle = UILabel(frame: CGRect(x: 10, y: 10, width: viewSuperFrame.size.width-20, height: 30))
                lblSubTitle.backgroundColor = UIColor.clear
                lblSubTitle.textColor = UIColor.black
                lblSubTitle.font = UIFont(name: "SFProDisplay-Semibold", size: 19.0)!
                lblSubTitle.text = exploreDataArray[i].subTitle[index]
                bgBottomView.addSubview(lblSubTitle)
                
                let btnReadMore = UIButton(frame: CGRect(x: 10, y: lblSubTitle.frame.origin.y+lblSubTitle.frame.size.height+10, width: 80, height: 30))
                btnReadMore.setTitle("Read More", for: .normal)
                btnReadMore.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 15.0)!
                btnReadMore.setTitleColor(UIColor.glfBluegreen, for: .normal)
                btnReadMore.backgroundColor = UIColor.clear
                btnReadMore.tag = (i*tempArray.count) + index
                btnReadMore.addTarget(self, action: #selector(self.readMoreAction(_:)), for: .touchUpInside)

                bgBottomView.addSubview(btnReadMore)
                
                // Set Like & Views
                /*let btnLikeText = UIButton(frame: CGRect(x: viewSuperFrame.size.width-30-10, y: btnReadMore.frame.origin.y, width: 30, height: 30))
                btnLikeText.backgroundColor = UIColor.clear
                btnLikeText.setTitleColor(UIColor.lightGray, for: .normal)
                btnLikeText.setTitle("25", for: .normal)
                bgBottomView.addSubview(btnLikeText)
                
                let btnLike = UIButton(frame: CGRect(x: viewSuperFrame.width-(btnLikeText.frame.size.width*2)-10*2, y: btnReadMore.frame.origin.y, width: 30, height: 30))
                btnLike.backgroundColor = UIColor.clear
                btnLike.setBackgroundImage(#imageLiteral(resourceName: "message"), for: .normal)
                bgBottomView.addSubview(btnLike)
                
                let btnViewsText = UIButton(frame: CGRect(x: viewSuperFrame.width-(btnLikeText.frame.size.width*3)-10*3, y: btnReadMore.frame.origin.y, width: 30, height: 30))
                btnViewsText.backgroundColor = UIColor.clear
                btnViewsText.setTitleColor(UIColor.lightGray, for: .normal)
                btnViewsText.setTitle("22", for: .normal)
                bgBottomView.addSubview(btnViewsText)
                
                let btnViews = UIButton(frame: CGRect(x: viewSuperFrame.width-(btnLikeText.frame.size.width*4)-10*4, y: btnReadMore.frame.origin.y, width: 30, height: 30))
                btnViews.backgroundColor = UIColor.clear
                btnViews.setBackgroundImage(#imageLiteral(resourceName: "showPd"), for: .normal)
                bgBottomView.addSubview(btnViews)*/
                
                self.exploreScrollVIew.addSubview(containerView)
                containerView.addSubview(pageControl)
            }
            
            self.exploreScrollVIew.contentSize = CGSize(width: self.exploreScrollVIew.frame.size.width * CGFloat(tempArray.count),height: self.exploreScrollVIew.frame.size.height)
            pageControl.addTarget(self, action: #selector(self.changePage(_:)), for: .valueChanged)
        }
        let dataCount:CGFloat = CGFloat(self.tempArray.count)
        containerScrollVIew.contentSize = CGSize(width:self.exploreScrollVIew.frame.size.width, height: self.exploreScrollVIew.frame.size.height*dataCount)
    }
    
    @objc func readMoreAction(_ sender: UIButton){
        let tag = sender.tag
        
        let rowTag =  Int(tag/tempArray.count)
        let cardTag =  tag % tempArray.count
        
        let category =  (exploreDataArray[rowTag].parent[cardTag])
        let categoryTitle =  exploreDataArray[rowTag].title
        let contentIndex =  exploreDataArray[rowTag].ctgryIndex[cardTag]
        
        let storyboard = UIStoryboard(name: "Explore", bundle: Bundle.main)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ExploreDetailPageVC") as! ExploreDetailPageVC
        viewCtrl.contentTag = contentIndex
        viewCtrl.ctgryKey = category
        viewCtrl.topBarTitle = categoryTitle
        viewCtrl.scrollIndex = cardTag
        viewCtrl.categoryData = categoryData.value(forKey: category) as! NSArray
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    @objc func imageTapAction(_ sender: UITapGestureRecognizer){
        let tag = sender.view!.tag

        let rowTag =  Int(tag/tempArray.count)
        let cardTag =  tag % tempArray.count

        let category =  (exploreDataArray[rowTag].parent[cardTag])
        let categoryTitle =  exploreDataArray[rowTag].title
        let contentIndex =  exploreDataArray[rowTag].ctgryIndex[cardTag]

        let storyboard = UIStoryboard(name: "Explore", bundle: Bundle.main)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "ExploreDetailPageVC") as! ExploreDetailPageVC
        viewCtrl.contentTag = contentIndex
        viewCtrl.ctgryKey = category
        viewCtrl.topBarTitle = categoryTitle
        viewCtrl.scrollIndex = cardTag
        viewCtrl.categoryData = categoryData.value(forKey: category) as! NSArray
        self.navigationController?.pushViewController(viewCtrl, animated: true)
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    @objc func changePage(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * exploreScrollVIew.frame.size.width
        exploreScrollVIew.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func configurePageControl(index: Int) {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x:0, y: containerView.frame.size.height-30, width:viewSuperFrame.size.width, height:30))
        
        self.pageControl.numberOfPages = tempArray.count
        self.pageControl.currentPage = index
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.glfBlueyGreen
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
