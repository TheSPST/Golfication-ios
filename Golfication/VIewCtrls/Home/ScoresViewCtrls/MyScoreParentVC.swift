//
//  MyScoreParantVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/26/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MyScoreParentVC: ButtonBarPagerTabStripViewController,DemoFooterViewDelegate{
    var dataDic = NSDictionary()
    @IBOutlet weak var shadowView: UIView!
    var isDemoUser = false

    var actvtIndView: UIActivityIndicatorView!
    var scoreArray = [Double]()
    var myDataArray = NSMutableArray()
    
    var filteredArray = [NSDictionary]()
//    var classicScores = [ClassicScores]()

    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)
        self.title = "My Scores".localized()
        Constants.finalFilterDic.removeAllObjects()
        buttonBarView.isHidden = true
        self.setupActivityIndicator()
        //self.getScoreDataFromFirebase()
    }
    
    @objc func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    func setupActivityIndicator(){
        actvtIndView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        actvtIndView.color = UIColor.darkGray
        actvtIndView.center = view.center
        actvtIndView.startAnimating()
        self.view.addSubview(actvtIndView)
        actvtIndView.isHidden = true
    }
    
    var checkCaddie = false
    var totalCaddie = Int()

    func getScoreDataFromFirebase() {
        self.totalCaddie = 0
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "scoring") { (snapshot) in
            
            if(snapshot.childrenCount > 0){
                self.dataDic = (snapshot.value as? NSDictionary)!
                for (_, val) in self.dataDic{
                    let valDic = val as! NSDictionary
                    for (key1, _) in valDic{
                        if (key1 as! String  == "smartCaddie"){
                            self.checkCaddie = true
                            self.totalCaddie += 1
                            break
                        }
                    }
                }
                self.setData(dataDic: self.dataDic)
                self.isDemoUser = false
            }
            else{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/scoring") { (snapshot) in
                    self.dataDic = (snapshot.value as? NSDictionary)!
                    self.setData(dataDic: self.dataDic)
                    self.isDemoUser = true
                    self.setDemoFotter()
                }
            }
        }
    }
    func setData(dataDic:NSDictionary){
        
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        buttonBarView.isHidden = true
        let dataArray = self.dataDic.allValues
        let group = DispatchGroup()
        
        // Remove Filter Score Data if Exist
        Constants.section5 = [String]()
        //--------------------------------
        
        for i in 0..<dataArray.count {
            group.enter()
            self.myDataArray[i] = dataArray[i]
            // Pass Score Data to filter screen
            let course = ((self.myDataArray[i] as AnyObject).object(forKey:"course") ?? "") as! String
            Constants.section5.append(course)
            //--------------------------------
            
            group.leave()
        }
        group.notify(queue: .main){
            
            //let sortedScore = self.scores.sorted { ($0 as! Scores).timestamp > ($1 as! Scores).timestamp } as NSArray
            //self.scores = NSMutableArray(array:sortedScore)
            
            //print("myDataArray: \(self.myDataArray)")
            self.buttonBarView.isHidden = false
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
            self.filteredArray = self.myDataArray as! [NSDictionary]

            self.reloadPagerTabStripView()
        }
    }
    
    func setDemoFotter(){
        let demoView = DemoFooterView()
        demoView.frame = CGRect(x: 0.0, y: self.view.frame.height-44, width: self.view.frame.width, height: 44.0)
        demoView.delegate = self
        demoView.backgroundColor = UIColor.glfFlatBlue
        demoView.label.frame = CGRect(x: 0, y: 0, width: demoView.frame.width * 0.7, height: 44.0)
        demoView.btnPlayGame.frame = CGRect(x:demoView.frame.width * 0.75 , y: 10, width: demoView.frame.width * 0.2, height: 24.0)
        self.view.addSubview(demoView)
    }
    func playGameButton(button: UIButton) {
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    func transferDataIntoClasses(myDataArray:[NSDictionary])->[Scores]{
        var scores = [Scores]()
        for i in 0..<myDataArray.count{
            let score = Scores()
            //            score.roundName = (myDataArray[i] as AnyObject).object(forKey:"roundName") as! String
            score.timestamp = ((myDataArray[i] as AnyObject).object(forKey:"timestamp") as! NSNumber).doubleValue
            let date = NSDate(timeIntervalSince1970:(score.timestamp)/1000)
            score.date = date.toString(dateFormat: "dd MMM")
            score.course = (myDataArray[i] as AnyObject).object(forKey:"course") as? String
            score.courseId = (myDataArray[i] as AnyObject).object(forKey:"courseId") as? String
            score.fairwayHit = (myDataArray[i] as AnyObject).object(forKey:"fairwayHit") as? Double
            score.fairwayMiss = (myDataArray[i] as AnyObject).object(forKey:"fairwayMiss") as? Double
            score.fairwayLeftValue = (myDataArray[i] as AnyObject).object(forKey:"fairwayLeftValue") as? Double
            score.fairwayRightValue = (myDataArray[i] as AnyObject).object(forKey:"fairwayRightValue") as? Double
            score.gir = (myDataArray[i] as AnyObject).object(forKey:"gir") as? Double
            score.girMiss = (myDataArray[i] as AnyObject).object(forKey:"girMiss") as? Double
            score.par = (myDataArray[i] as AnyObject).object(forKey:"par") as? Int
            score.penalty = (myDataArray[i] as AnyObject).object(forKey:"penalty") as? Double
            score.score = (myDataArray[i] as AnyObject).object(forKey:"score") as? Double
            score.type = (myDataArray[i] as AnyObject).object(forKey:"type") as? String
            score.parWise = (myDataArray[i] as AnyObject).object(forKey:"parWise") as? Dictionary<String, Dictionary<String,Int>>
            score.scoring = (myDataArray[i] as AnyObject).object(forKey:"scoring") as? Dictionary<String, Int>
            score.tees = (myDataArray[i] as AnyObject).object(forKey:"tees") as? NSDictionary
            score.putts = (myDataArray[i] as AnyObject).object(forKey:"putts") as? Array<Double>
            
            score.girWithFairway = (myDataArray[i] as AnyObject).object(forKey:"girWithFairway") as? Double
            score.girWoFairway = (myDataArray[i] as AnyObject).object(forKey:"girWoFairway") as? Double
            if let chipping = ((myDataArray[i] as AnyObject).object(forKey:"chipping") as? NSArray){
                var chippingArray = [Chipping]()
                for i in 0..<chipping.count{
                    let chip = Chipping()
                    chip.club = (chipping[i] as AnyObject).object(forKey:"club") as? String
                    chip.distance = (chipping[i] as AnyObject).object(forKey:"distance") as? Double
                    chip.hole = (chipping[i] as AnyObject).object(forKey:"hole") as? Int
                    chip.proximityX = (chipping[i] as AnyObject).object(forKey:"proximityX") as? Double
                    chip.proximityY = (chipping[i] as AnyObject).object(forKey:"proximityY") as? Double
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    chip.und = (chipping[i] as AnyObject).object(forKey:"und") as? Int
                    chip.green = (chipping[i] as AnyObject).object(forKey:"green") as? Bool
                    chippingArray.append(chip)
                    //print(chip)
                }
                if let chipUandD = ((myDataArray[i] as AnyObject).object(forKey:"chipUnD") as? NSDictionary){
                    score.chipUnD.achieved = chipUandD.value(forKey: "achieved") as? Double
                    score.chipUnD.attempts = chipUandD.value(forKey: "attempts") as? Double
                    score.chipping.append(chippingArray)
                    // Set Model view to with data Sand
                }
            }
            if let sand = ((myDataArray[i] as AnyObject).object(forKey:"sand") as? NSArray){
                var sandArray = [Chipping]()
                for i in 0..<sand.count{
                    let chip = Chipping()
                    chip.club = (sand[i] as AnyObject).object(forKey:"club") as? String
                    chip.distance = (sand[i] as AnyObject).object(forKey:"distance")as? Double
                    chip.hole = (sand[i] as AnyObject).object(forKey:"hole") as? Int
                    chip.proximityX = (sand[i] as AnyObject).object(forKey:"proximityX") as? Double
                    chip.proximityY = (sand[i] as AnyObject).object(forKey:"proximityY") as? Double
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    chip.green = (sand[i] as AnyObject).object(forKey:"green") as? Bool
                    if let und = ((sand[i] as AnyObject).object(forKey:"und") as? Int){
                        chip.und = und
                    }
                    sandArray.append(chip)
                }
                score.sand.append(sandArray)
            }
            if let sandUnD = ((myDataArray[i] as AnyObject).object(forKey:"sandUnD") as? NSDictionary){
                score.sandUnD.achieved = sandUnD.value(forKey: "achieved") as? Double
                score.sandUnD.attempts = sandUnD.value(forKey: "attempts") as? Double
            }
            // Model View Set Approch Array
            if let approach = ((myDataArray[i] as AnyObject).object(forKey:"approach") as? NSArray){
                var approachArray = [Chipping]()
                for i in 0..<approach.count{
                    let chip = Chipping()
                    chip.club = (approach[i] as AnyObject).object(forKey:"club") as! String
                    chip.distance = (approach[i] as AnyObject).object(forKey:"distance") as! Double
                    chip.hole = (approach[i] as AnyObject).object(forKey:"hole") as! Int
                    chip.proximityX = (approach[i] as AnyObject).object(forKey:"proximityX") as! Double
                    chip.proximityY = (approach[i] as AnyObject).object(forKey:"proximityY") as! Double
                    chip.green = (approach[i] as AnyObject).object(forKey:"green") as? Bool
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    if let und = ((approach[i] as AnyObject).object(forKey:"und") as? Int){
                        chip.und = und
                    }
                    approachArray.append(chip)
                }
                score.approach.append(approachArray)
            }
            if let smartCaddieDic = ((myDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                for key in Constants.allClubs{
                    var keysArray = smartCaddieDic.value(forKey: " \(key)")
                    if(keysArray == nil){
                        keysArray = smartCaddieDic.value(forKey: "\(key)")
                    }
                    if((keysArray) != nil){
                        let valueArray = keysArray as! NSArray
                        for j in 0..<valueArray.count{
                            let clubData = Club()
                            let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing")
                            if((backSwing) != nil){
                                clubData.backswing = backSwing as! Double
                            }
                            if let distance = (valueArray[j] as AnyObject).object(forKey: "distance") as? Double{
                                clubData.distance = distance
                                if(Constants.distanceFilter == 1){
                                    clubData.distance = distance/Constants.YARD
                                }
                            }
                            var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                            if let strk = (valueArray[j] as AnyObject).object(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double{
                                strokesGained = strk
                            }
                            clubData.strokesGained = strokesGained
                            
                            let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore")
                            if((swingScore) != nil){
                                clubData.swingScore = swingScore as! Double
                            }
                            let type = (valueArray[j] as AnyObject).object(forKey: "type")
                            if((type) != nil){
                                clubData.type = type as! Int
                            }
                            if let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity") as? Double{
                                clubData.proximity = proximity
                                if(Constants.distanceFilter == 1){
                                    clubData.proximity = proximity/Constants.YARD
                                }
                                
                            }
                            let holeout = (valueArray[j] as AnyObject).object(forKey: "holeOut")
                            if((holeout) != nil){
                                clubData.holeout = holeout as! Double
                            }
                            
                            clubWiseArray.append(clubData)
                            score.clubDict.append((key,clubData))
                        }
                    }
                }
            }
            scores.append(score)
            self.scoreArray.append(score.score)
        }
        scores = scores.sorted(by: { $0.timestamp < $1.timestamp })
        return scores
    }
    @IBAction func filterNavBarButtonClick(_ sender: Any) {
        
        let index =  self.buttonBarView.selectedIndex
        let filterVc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        if (index == 4 || index == 0) {
            filterVc.fromScorePutting = true
        }
        self.navigationController?.pushViewController(filterVc, animated: true)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var array = [UIViewController]()
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let child1 = storyboard.instantiateViewController(withIdentifier: "OverViewVC") as! OverViewVC
        let child2 = storyboard.instantiateViewController(withIdentifier: "OTTViewController") as! OTTViewController
        let child3 = storyboard.instantiateViewController(withIdentifier: "ApprochViewController") as! ApproachViewController
        let child4 = storyboard.instantiateViewController(withIdentifier: "ChippingViewController") as! ChippingViewController
        let child5 = storyboard.instantiateViewController(withIdentifier: "PuttingViewController") as! PuttingViewController
        child1.isDemoUser = self.isDemoUser
        child2.isDemoUser = self.isDemoUser
        child3.isDemoUser = self.isDemoUser
        child4.isDemoUser = self.isDemoUser
        child5.isDemoUser = self.isDemoUser
        
        child1.checkCaddie = self.checkCaddie
        child2.checkCaddie = self.checkCaddie
        child3.checkCaddie = self.checkCaddie
        child4.checkCaddie = self.checkCaddie
        child5.checkCaddie = self.checkCaddie
        
        let index = self.buttonBarView.selectedIndex
        
        var CSTypeArray = [String]()
        if(Constants.finalFilterDic.count>0){
            CSTypeArray = Constants.finalFilterDic.value(forKey: "CSTypeArray") as! [String]
        }
        
        if index == 0{
            //print(transferDataIntoClasses(myDataArray: self.filteredArray))
            child1.scores = transferDataIntoClasses(myDataArray: self.filteredArray)
            child2.scores = transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary])
            child3.scores = child2.scores
            child4.scores = child2.scores
            child5.scores = child2.scores
        }
        else if index == 1{
            //print(transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary]))
            child2.scores = transferDataIntoClasses(myDataArray: self.filteredArray)
            child2.clubFilter = CSTypeArray
            child1.scores = transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary])
            child3.scores = child1.scores
            child4.scores = child1.scores
            child5.scores = child1.scores
        }
        else if index == 2{
            //print(transferDataIntoClasses(myDataArray: self.filteredArray))
            child3.scores = transferDataIntoClasses(myDataArray: self.filteredArray)
            child3.clubFilter = CSTypeArray
            child1.scores = transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary])
            child2.scores = child1.scores
            child4.scores = child1.scores
            child5.scores = child1.scores
        }
        else if index == 3{
            //print(transferDataIntoClasses(myDataArray: self.filteredArray))
            child4.scores = transferDataIntoClasses(myDataArray: self.filteredArray)
            child1.scores = transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary])
            child2.scores = child1.scores
            child3.scores = child1.scores
            child4.clubFilter = CSTypeArray
            child5.scores = child1.scores
        }
        else if index == 4{
            //print(transferDataIntoClasses(myDataArray: self.filteredArray))
            child5.scores = transferDataIntoClasses(myDataArray: self.filteredArray)
            child1.scores = transferDataIntoClasses(myDataArray: self.myDataArray as! [NSDictionary])
            child2.scores = child1.scores
            child3.scores = child1.scores
            child4.scores = child1.scores
        }
        array = [child1,child2,child3,child4,child5]
        return array
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false

        //let index =  self.buttonBarView.selectedIndex
        var RSTypeArray: [String] = []
        var HoleTypeArray: [String] = []
        var CoursesTypeArray: [String] = []
        var CSTypeArray: [String] = []
        
        
        if Constants.finalFilterDic.count>0 {
            
            RSTypeArray = Constants.finalFilterDic.value(forKey: "RSTypeArray") as! [String]
            CSTypeArray = Constants.finalFilterDic.value(forKey: "CSTypeArray") as! [String]
            HoleTypeArray = Constants.finalFilterDic.value(forKey: "HoleTypeArray") as! [String]
            CoursesTypeArray = Constants.finalFilterDic.value(forKey: "CoursesTypeArray") as! [String]
        }
        if RSTypeArray.count>0 || CSTypeArray.count>0 || HoleTypeArray.count>0 || CoursesTypeArray.count>0{
            self.getFilteredValue(roundTimeArr: RSTypeArray, clubTypeArr: CSTypeArray, holeTypeArr: HoleTypeArray, coursesTypeArr: CoursesTypeArray)
        }else{
            self.getScoreDataFromFirebase()
        }
        getUser3Data()
    }
    
    func getUser3Data(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/scoring") { (snapshot) in
            let dataDic = (snapshot.value as? NSDictionary)!
            self.setDemoData(dataDic: dataDic)
//            self.isDemoUser = true
//            self.setDemoFotter()
        }
    }
    
    func setDemoData(dataDic:NSDictionary){
        let demoDataArray = NSMutableArray()

        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        buttonBarView.isHidden = true
        let dataArray = dataDic.allValues
        let group = DispatchGroup()
        
        // Remove Filter Score Data if Exist
        Constants.section5 = [String]()
        //--------------------------------
        
        for i in 0..<dataArray.count {
            group.enter()
            demoDataArray[i] = dataArray[i]
            // Pass Score Data to filter screen
            let course = ((demoDataArray[i] as AnyObject).object(forKey:"course") ?? "") as! String
            Constants.section5.append(course)
            //--------------------------------
            group.leave()
        }
        group.notify(queue: .main){
            
//            self.buttonBarView.isHidden = false
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
            self.filteredArray = demoDataArray as! [NSDictionary]
//            self.reloadPagerTabStripView()
            Constants.classicScores = self.getData(demoDataArray: demoDataArray as! [NSDictionary])
            
        }
    }
    
    func getData(demoDataArray:[NSDictionary])->[Scores]{
        var scores = [Scores]()
        for i in 0..<demoDataArray.count{
            let score = Scores()
            //            score.roundName = (demoDataArray[i] as AnyObject).object(forKey:"roundName") as! String
            score.timestamp = ((demoDataArray[i] as AnyObject).object(forKey:"timestamp") as! NSNumber).doubleValue
            let date = NSDate(timeIntervalSince1970:(score.timestamp)/1000)
            score.date = date.toString(dateFormat: "dd MMM")
            score.course = (demoDataArray[i] as AnyObject).object(forKey:"course") as? String
            score.courseId = (demoDataArray[i] as AnyObject).object(forKey:"courseId") as? String
            score.fairwayHit = (demoDataArray[i] as AnyObject).object(forKey:"fairwayHit") as? Double
            score.fairwayMiss = (demoDataArray[i] as AnyObject).object(forKey:"fairwayMiss") as? Double
            score.fairwayLeftValue = (demoDataArray[i] as AnyObject).object(forKey:"fairwayLeftValue") as? Double
            score.fairwayRightValue = (demoDataArray[i] as AnyObject).object(forKey:"fairwayRightValue") as? Double
            score.gir = (demoDataArray[i] as AnyObject).object(forKey:"gir") as? Double
            score.girMiss = (demoDataArray[i] as AnyObject).object(forKey:"girMiss") as? Double
            score.par = (demoDataArray[i] as AnyObject).object(forKey:"par") as? Int
            score.penalty = (demoDataArray[i] as AnyObject).object(forKey:"penalty") as? Double
            score.score = (demoDataArray[i] as AnyObject).object(forKey:"score") as? Double
            score.type = (demoDataArray[i] as AnyObject).object(forKey:"type") as? String
            score.parWise = (demoDataArray[i] as AnyObject).object(forKey:"parWise") as? Dictionary<String, Dictionary<String,Int>>
            score.scoring = (demoDataArray[i] as AnyObject).object(forKey:"scoring") as? Dictionary<String, Int>
            score.tees = (demoDataArray[i] as AnyObject).object(forKey:"tees") as? NSDictionary
            score.putts = (demoDataArray[i] as AnyObject).object(forKey:"putts") as? Array<Double>
            
            score.girWithFairway = (demoDataArray[i] as AnyObject).object(forKey:"girWithFairway") as? Double
            score.girWoFairway = (demoDataArray[i] as AnyObject).object(forKey:"girWoFairway") as? Double
            if let chipping = ((demoDataArray[i] as AnyObject).object(forKey:"chipping") as? NSArray){
                var chippingArray = [Chipping]()
                for i in 0..<chipping.count{
                    let chip = Chipping()
                    chip.club = (chipping[i] as AnyObject).object(forKey:"club") as? String
                    chip.distance = (chipping[i] as AnyObject).object(forKey:"distance") as? Double
                    chip.hole = (chipping[i] as AnyObject).object(forKey:"hole") as? Int
                    chip.proximityX = (chipping[i] as AnyObject).object(forKey:"proximityX") as? Double
                    chip.proximityY = (chipping[i] as AnyObject).object(forKey:"proximityY") as? Double
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    chip.und = (chipping[i] as AnyObject).object(forKey:"und") as? Int
                    chip.green = (chipping[i] as AnyObject).object(forKey:"green") as? Bool
                    chippingArray.append(chip)
                    //print(chip)
                }
                if let chipUandD = ((demoDataArray[i] as AnyObject).object(forKey:"chipUnD") as? NSDictionary){
                    score.chipUnD.achieved = chipUandD.value(forKey: "achieved") as? Double
                    score.chipUnD.attempts = chipUandD.value(forKey: "attempts") as? Double
                    score.chipping.append(chippingArray)
                    // Set Model view to with data Sand
                }
            }
            if let sand = ((demoDataArray[i] as AnyObject).object(forKey:"sand") as? NSArray){
                var sandArray = [Chipping]()
                for i in 0..<sand.count{
                    let chip = Chipping()
                    chip.club = (sand[i] as AnyObject).object(forKey:"club") as? String
                    chip.distance = (sand[i] as AnyObject).object(forKey:"distance")as? Double
                    chip.hole = (sand[i] as AnyObject).object(forKey:"hole") as? Int
                    chip.proximityX = (sand[i] as AnyObject).object(forKey:"proximityX") as? Double
                    chip.proximityY = (sand[i] as AnyObject).object(forKey:"proximityY") as? Double
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    chip.green = (sand[i] as AnyObject).object(forKey:"green") as? Bool
                    if let und = ((sand[i] as AnyObject).object(forKey:"und") as? Int){
                        chip.und = und
                    }
                    sandArray.append(chip)
                }
                score.sand.append(sandArray)
            }
            if let sandUnD = ((demoDataArray[i] as AnyObject).object(forKey:"sandUnD") as? NSDictionary){
                score.sandUnD.achieved = sandUnD.value(forKey: "achieved") as? Double
                score.sandUnD.attempts = sandUnD.value(forKey: "attempts") as? Double
            }
            // Model View Set Approch Array
            if let approach = ((demoDataArray[i] as AnyObject).object(forKey:"approach") as? NSArray){
                var approachArray = [Chipping]()
                for i in 0..<approach.count{
                    let chip = Chipping()
                    chip.club = (approach[i] as AnyObject).object(forKey:"club") as! String
                    chip.distance = (approach[i] as AnyObject).object(forKey:"distance") as! Double
                    chip.hole = (approach[i] as AnyObject).object(forKey:"hole") as! Int
                    chip.proximityX = (approach[i] as AnyObject).object(forKey:"proximityX") as! Double
                    chip.proximityY = (approach[i] as AnyObject).object(forKey:"proximityY") as! Double
                    chip.green = (approach[i] as AnyObject).object(forKey:"green") as? Bool
                    if(Constants.distanceFilter == 1){
                        chip.proximityX = chip.proximityX/Constants.YARD
                        chip.proximityY = chip.proximityY/Constants.YARD
                        chip.distance = chip.distance/Constants.YARD
                    }
                    if let und = ((approach[i] as AnyObject).object(forKey:"und") as? Int){
                        chip.und = und
                    }
                    approachArray.append(chip)
                }
                score.approach.append(approachArray)
            }
            if let smartCaddieDic = ((demoDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                for key in Constants.allClubs{
                    var keysArray = smartCaddieDic.value(forKey: " \(key)")
                    if(keysArray == nil){
                        keysArray = smartCaddieDic.value(forKey: "\(key)")
                    }
                    if((keysArray) != nil){
                        let valueArray = keysArray as! NSArray
                        for j in 0..<valueArray.count{
                            let clubData = Club()
                            let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing")
                            if((backSwing) != nil){
                                clubData.backswing = backSwing as! Double
                            }
                            if let distance = (valueArray[j] as AnyObject).object(forKey: "distance") as? Double{
                                clubData.distance = distance
                                if(Constants.distanceFilter == 1){
                                    clubData.distance = distance/Constants.YARD
                                }
                            }
                            var strokesGained = (valueArray[j] as AnyObject).object(forKey: "strokesGained") as! Double
                            if let strk = (valueArray[j] as AnyObject).object(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double{
                                strokesGained = strk
                            }
                            clubData.strokesGained = strokesGained
                            
                            let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore")
                            if((swingScore) != nil){
                                clubData.swingScore = swingScore as! Double
                            }
                            let type = (valueArray[j] as AnyObject).object(forKey: "type")
                            if((type) != nil){
                                clubData.type = type as! Int
                            }
                            if let proximity = (valueArray[j] as AnyObject).object(forKey: "proximity") as? Double{
                                clubData.proximity = proximity
                                if(Constants.distanceFilter == 1){
                                    clubData.proximity = proximity/Constants.YARD
                                }
                                
                            }
                            let holeout = (valueArray[j] as AnyObject).object(forKey: "holeOut")
                            if((holeout) != nil){
                                clubData.holeout = holeout as! Double
                            }
                            
                            clubWiseArray.append(clubData)
                            score.clubDict.append((key,clubData))
                        }
                    }
                }
            }
            scores.append(score)
//            self.scoreArray.append(score.score)
        }
        scores = scores.sorted(by: { $0.timestamp < $1.timestamp })
        return scores
    }
    
    func getFilteredValue(roundTimeArr: [String], clubTypeArr: [String], holeTypeArr: [String], coursesTypeArr: [String] ){
        
        
        if self.filteredArray.count>0{
            //self.filteredArray.removeAll()
            self.filteredArray = NSMutableArray() as! [NSDictionary]
        }
        let marrPredicates = NSMutableArray()
        
        var swingRoundArray = [String]()
        
        var roundTimeTypeStr = ""
        
        var last4Char: String = ""
        var timeStr: String = ""
        var newTimeStamp = 0.0
        
        for i in 0..<roundTimeArr.count{
            timeStr = roundTimeArr[i]
            last4Char = String(timeStr.suffix(4))
            
            if last4Char == "Days"{
                let newTimeStr = timeStr.dropLast(5)
                var timeStampInDays = 2592000000.0 // 30 Days timestamp
                if newTimeStr == "90"{
                    timeStampInDays = timeStampInDays*3
                }
                else if newTimeStr == "180"{
                    timeStampInDays = timeStampInDays*6
                }
                let nowDouble = (NSDate().timeIntervalSince1970) * 1000
                newTimeStamp = nowDouble - timeStampInDays
            }
            else{
                // for rounds
                
                for i in 0..<self.myDataArray.count {
                    
                    if let swingRound = (self.myDataArray[i] as AnyObject).object(forKey:"roundName") as? String{
                        swingRoundArray.append(swingRound)
                    }

                }
            }
            swingRoundArray = Array(Set(swingRoundArray))
            swingRoundArray.sort()
        }
        
        //var selectedRoundArray: ArraySlice = [""]
        var selectedRoundArray = ArraySlice<String>() // changed by shubham
        
        if last4Char == "Days"{
            
            roundTimeTypeStr.append("self.timestamp >= '\(NSNumber(value:newTimeStamp))'")
            
            let roundTimeTypePredicate = NSPredicate(format: ("self.timestamp >= \(NSNumber(value:newTimeStamp))"))
            marrPredicates.add(roundTimeTypePredicate)
        }
        else{
            // for rounds
            if roundTimeArr.contains("10 Rounds"){
                
                let round10Array = swingRoundArray.suffix(10)
                selectedRoundArray = round10Array
            }
            else if roundTimeArr.contains("20 Rounds"){
                
                let round20Array = swingRoundArray.suffix(20)
                selectedRoundArray = round20Array
            }
            else if roundTimeArr.contains("50 Rounds"){
                
                let round50Array = swingRoundArray.suffix(50)
                selectedRoundArray = round50Array
            }
            //print("selectedRoundArray = ", selectedRoundArray)
            
            for roundType in selectedRoundArray {
                
                if roundType == selectedRoundArray.last {
                    
                    roundTimeTypeStr.append("self.roundName == '\(roundType)'")
                    
                    let roundTimeTypePredicate = NSPredicate(format: roundTimeTypeStr)
                    marrPredicates.add(roundTimeTypePredicate)
                }
                else{
                    roundTimeTypeStr.append("self.roundName == '\(roundType)' or ")
                }
            }
        }
        
        var holeTypeStr = ""
        for holeType in holeTypeArr {
            
            if holeType == holeTypeArr.last {
                
                holeTypeStr.append("self.type == '\(holeType)'")
                
                let holeTypePredicate = NSPredicate(format: holeTypeStr)
                marrPredicates.add(holeTypePredicate)
            }
            else {
                holeTypeStr.append("self.type == '\(holeType)' or ")
            }
        }
        
        var courseStr = ""
        for courseType in coursesTypeArr {
            
            if courseType == coursesTypeArr.last {
                
                courseStr.append("self.course == '\(courseType)'")
                
                let coursePredicate = NSPredicate(format: courseStr)
                marrPredicates.add(coursePredicate)
            }
                
            else {
                courseStr.append("self.course == '\(courseType)' or ")
            }
        }
        //--------------------------------------------------------
        
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: marrPredicates as! [NSPredicate])
        
        filteredArray = self.myDataArray.filtered(using: andPredicate) as! [NSDictionary]
        debugPrint("filteredArray = ", filteredArray)
        
        self.reloadPagerTabStripView()
        
        if filteredArray.count==0{
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
