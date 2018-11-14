//
//  StrokesGainedVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Charts
import UICircularProgressRing
import ActionButton
import FirebaseAnalytics

class StrokesGainedVC: UIViewController, CustomProModeDelegate,DemoFooterViewDelegate {
    
    @IBOutlet weak var strokesGainedStackView: UIStackView!
    @IBOutlet weak var lblStrokesGainedPerClubAvg: UILabel!
    @IBOutlet weak var lblStrokesGainedOffTheTeeAvg: UILocalizedLabel!
    @IBOutlet weak var lblStrokesGainedApproachTheGreenAvg: UILocalizedLabel!
    @IBOutlet weak var lblStrokesGainedAroundTheGreenAvg: UILocalizedLabel!
    @IBOutlet weak var lblStrokesGainedPuttingAvg: UILocalizedLabel!
    
    @IBOutlet weak var offTheTeeCardView: CardView!
    @IBOutlet weak var puttingCardView: CardView!
    @IBOutlet weak var aroundTheGreenCardView: CardView!
    @IBOutlet weak var approchCardView: CardView!
    @IBOutlet weak var lblPuttingSG: UILabel!
    @IBOutlet weak var lblAroundtheGreenSG: UILabel!
    @IBOutlet weak var lblApprochTheGreenSG: UILabel!
    @IBOutlet weak var lblOffTheTeeSG: UILabel!
    @IBOutlet weak var strokeGainedChartView: CardView!
    @IBOutlet weak var aroundTheGreenConsistancy: UICircularProgressRingView!
    @IBOutlet weak var aroundTheGreenSwingScore: UICircularProgressRingView!
    @IBOutlet weak var approchTheGreenConsistancy: UICircularProgressRingView!
    @IBOutlet weak var approchTheGreenSwingScore: UICircularProgressRingView!
    @IBOutlet weak var offTheTeeConsistancy: UICircularProgressRingView!
    @IBOutlet weak var offTheTeeSwingScore: UICircularProgressRingView!
    @IBOutlet weak var lblFirstPuttProximity: UILabel!
    @IBOutlet weak var strokesGainedPerClubBarChart: BarChartView!
    @IBOutlet weak var lblHoleOutDistance: UILabel!
    
    @IBOutlet weak var lblProSG: UILabel!
    @IBOutlet weak var lblProOTT: UILabel!
    @IBOutlet weak var lblProPutting: UILabel!
    @IBOutlet weak var lblProATG: UILabel!
    @IBOutlet weak var lblProApproach: UILabel!
    
    var actvtIndView: UIActivityIndicatorView!
    
    var totalSwingScore = Double()//1
    var strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
    var totalProximity = [Double]()//2
    var totalHoleOutDistance = [Double]()//3
    
    let catagoryWise = ["Off The Tee","Approach","Around The Green","Putting"]
    let clubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"]
    
    var myDataArray = NSMutableArray()
    var filteredArray = [NSDictionary]()
    var cardViewMArray = NSMutableArray()

    @IBAction func filterNavBarButtonClick(_ sender: Any) {
        
        let filterVc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        self.navigationController?.pushViewController(filterVc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Strokes Gained".localized()
        
        Constants.finalFilterDic.removeAllObjects()
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupActivityIndicator()
        self.setInitialUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Analytics.logEvent("strokes_gained", parameters: [:])

        self.navigationController?.navigationBar.isHidden = false
        var RSTypeArray: [String] = []
        var CSTypeArray: [String] = []
        var HoleTypeArray: [String] = []
        var CoursesTypeArray: [String] = []
        
        if Constants.finalFilterDic.count>0 {
            
            RSTypeArray = Constants.finalFilterDic.value(forKey: "RSTypeArray") as! [String]
            CSTypeArray = Constants.finalFilterDic.value(forKey: "CSTypeArray") as! [String]
            HoleTypeArray = Constants.finalFilterDic.value(forKey: "HoleTypeArray") as! [String]
            CoursesTypeArray = Constants.finalFilterDic.value(forKey: "CoursesTypeArray") as! [String]
        }
        if RSTypeArray.count>0 || CSTypeArray.count>0 || HoleTypeArray.count>0 || CoursesTypeArray.count>0{
            
            self.getFilteredValue(roundTimeArr: RSTypeArray, clubTypeArr: CSTypeArray, holeTypeArr: HoleTypeArray, coursesTypeArr: CoursesTypeArray)
        }
        else{
            self.getStrokesGainedFirebase()
        }
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
//            print("selectedRoundArray = ", selectedRoundArray)
            
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
//        print("filteredArray = ", filteredArray)
        self.setDataInUI()
        
        if filteredArray.count==0{
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var checkCaddie:Bool{
        if totalCaddie > 0{
            return true
        }else{
            return false
        }
    }
    var totalCaddie = Int()
    func getStrokesGainedFirebase(){
        self.totalCaddie = 0
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "scoring") { (snapshot) in
            var dataDic = NSDictionary()
            
            if(snapshot.childrenCount > 0){
                dataDic = (snapshot.value as? NSDictionary)!
                
                for (_, val) in dataDic{
                    let valDic = val as! NSDictionary
                    for (key1, _) in valDic{
                        if (key1 as! String  == "smartCaddie"){
                            self.totalCaddie += 1
                        }
                    }
                }
                if !Constants.isProMode {
                    
                    //self.strokeGainedChartView.makeBlurView(targetView: self.strokeGainedChartView)
                    self.setProLockedUI(targetView: self.strokeGainedChartView, title: "Strokes Gained Per Club")
                    
                    //self.offTheTeeCardView.makeBlurView(targetView: self.offTheTeeCardView)
                    self.setProLockedUI(targetView: self.offTheTeeCardView, title: "Off The Tee")
                    
                    //self.puttingCardView.makeBlurView(targetView: self.puttingCardView)
                    self.setProLockedUI(targetView: self.puttingCardView, title: "Putting")
                    
                    //self.aroundTheGreenCardView.makeBlurView(targetView: self.aroundTheGreenCardView)
                    self.setProLockedUI(targetView: self.aroundTheGreenCardView, title: "Around The Green ")
                    
                    //self.approchCardView.makeBlurView(targetView: self.approchCardView)
                    self.setProLockedUI(targetView: self.approchCardView, title: "Approach The Green ")
                    
                    self.lblProSG.isHidden = true
                    self.lblProOTT.isHidden = true
                    self.lblProPutting.isHidden = true
                    self.lblProATG.isHidden = true
                    self.lblProApproach.isHidden = true
                }
                else{
                    self.lblProSG.backgroundColor = UIColor.clear
                    self.lblProSG.layer.borderWidth = 1.0
                    self.lblProSG.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
                    self.lblProSG.textColor = UIColor(rgb: 0xFFC700)
                    
                    self.lblProSG.isHidden = false
                    self.lblProOTT.isHidden = false
                    self.lblProPutting.isHidden = false
                    self.lblProATG.isHidden = false
                    self.lblProApproach.isHidden = false
                }
                let originalImage1 = #imageLiteral(resourceName: "share")
                let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                
                var viewTag = 0
                for v in self.strokesGainedStackView.subviews{
                    if v.isKind(of: CardView.self){
                        self.cardViewMArray.add(v)
                        if (!Constants.isProMode && !((v == self.strokeGainedChartView) || (v == self.offTheTeeCardView) || (v == self.puttingCardView) || (v == self.aroundTheGreenCardView) || (v == self.approchCardView))){
                            let shareStatsButton = ShareStatsButton()
                            shareStatsButton.frame = CGRect(x: self.view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                            shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                            shareStatsButton.tintColor = UIColor.glfFlatBlue
                            shareStatsButton.tag = viewTag
                            shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                            v.addSubview(shareStatsButton)
                        }
                        else if Constants.isProMode{
                            let shareStatsButton = ShareStatsButton()
                            shareStatsButton.frame = CGRect(x: self.view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                            shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                            shareStatsButton.tintColor = UIColor.glfFlatBlue
                            shareStatsButton.tag = viewTag
                            if (v == self.strokeGainedChartView){
                                shareStatsButton.tintColor = UIColor.white
                            }
                            shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                            v.addSubview(shareStatsButton)
                        }
                        viewTag = viewTag+1
                    }
                }
                self.getData(dataDic: dataDic)
            }
            else{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/user1/scores") { (snapshot) in
                    dataDic = (snapshot.value as? NSDictionary)!
                    self.getData(dataDic: dataDic)
                    self.setDemoFotter()
                }
            }
        }
    }
    func getData(dataDic:NSDictionary){
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
//        print("Scores :\(dataDic)")
        
        let dataArray = dataDic.allValues as NSArray
        
        let group = DispatchGroup()
        // Remove Filter Score Data if Exist
        Constants.section5 = [String]()
        //-----------------------------------
        for i in 0..<dataArray.count {
            group.enter()
            
            self.myDataArray[i] = dataArray[i]
            // Pass Score Data to filter screen
            if let course = ((self.myDataArray[i] as AnyObject).object(forKey:"course") as? String){
                Constants.section5.append(course)
                //--------------------------------
            }
            group.leave()
        }
        
        group.notify(queue: .main){
            self.actvtIndView.isHidden = true
            self.actvtIndView.stopAnimating()
            self.filteredArray = self.myDataArray as! [NSDictionary]
            
            self.setDataInUI()
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
        for v in self.strokesGainedStackView.subviews{
            if v.isKind(of: CardView.self){
                let demoLabel = DemoLabel()
                demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                v.addSubview(demoLabel)
            }
        }
    }
    
    // MARK: - shareClicked
    @objc func shareClicked(_ sender:UIButton){
        let tagVal = sender.tag
        
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ShareStatsVC") as! ShareStatsVC
        viewCtrl.shareCardView = (cardViewMArray[tagVal] as! CardView)
        viewCtrl.fromFeed = false
        
        let navCtrl = UINavigationController(rootViewController: viewCtrl)
        navCtrl.modalPresentationStyle = .overCurrentContext
        self.present(navCtrl, animated: false, completion: nil)
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    func playGameButton(button: UIButton) {
        let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    func setDataInUI() {
        var CSTypeArray: [String] = []
        if Constants.finalFilterDic.count>0 {
            CSTypeArray = Constants.finalFilterDic.value(forKey: "CSTypeArray") as! [String]
        }
        let clubDict = self.transferDataIntoClasses(myDataArray: self.filteredArray)
        
//        print("clubDict: \(clubDict)")
        
        totalSwingScore = Double()//1
        totalProximity = [Double]()//2
        totalHoleOutDistance = [Double]()//3
        
        strokesGainedData.removeAll()
        strokesGainedData = [(clubType: String,clubTotalDistance: Double,clubStrokesGained: Double,clubCount:Int,clubSwingScore:Double)]()
        
        for data in self.catagoryWise{
            self.strokesGainedData.append((data,0.0,0.0,0,0.0))
        }
        
        for i in 0..<clubDict.count{
            if(CSTypeArray.count>0){
                if CSTypeArray.contains(clubDict[i].0){
                    
                    let clubClass = clubDict[i].1 as Club
                    self.strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                    self.strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                    self.strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                    self.strokesGainedData[clubClass.type].clubCount += 1
                    self.totalSwingScore += clubClass.swingScore
                    if(clubClass.proximity != 0){
                        self.totalProximity.append(clubClass.proximity)
                    }
                    if(clubClass.holeout != 0){
                        self.totalHoleOutDistance.append(clubClass.holeout)
                    }
                }
            }
            else{
                
                let clubClass = clubDict[i].1 as Club
                if(clubClass.type >= 0 && clubClass.type < 4){
                    self.strokesGainedData[clubClass.type].clubTotalDistance += clubClass.distance
                    self.strokesGainedData[clubClass.type].clubStrokesGained += clubClass.strokesGained
                    self.strokesGainedData[clubClass.type].clubSwingScore += clubClass.swingScore
                    self.strokesGainedData[clubClass.type].clubCount += 1
                    self.totalSwingScore += clubClass.swingScore
                    if(clubClass.proximity != 0){
                        self.totalProximity.append(clubClass.proximity)
                    }
                    if(clubClass.holeout != 0){
                        self.totalHoleOutDistance.append(clubClass.holeout)
                    }
                }
            }
        }
        print(strokesGainedData)
        self.setStrokesGainedPerClubBarChart()
        self.setOffTheTeeSwingScore()
        self.setOffTheTeeConsistancy()
        self.setAroundTheGreenSwingScore()
        self.setAroundTheGreenConsistancy()
        self.setApprochTheGreenSwingScore()
        self.setApprochTheGreenConsistancy()
        self.setHoleOutDistanceWithPuttProximity()
//        print("strokesGainedData: \(self.strokesGainedData)")
//        print("Total Hole Out: \(self.totalHoleOutDistance)")
//        print("Proximity : \(self.totalProximity)")
    }
    
    func transferDataIntoClasses(myDataArray:[NSDictionary])->[(String,Club)]{
        //        var scores = [Scores]()
        var clubDict = [(String,Club)]()
        
        for i in 0..<myDataArray.count{
            //            let score = Scores()
            if let smartCaddieDic = ((myDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                for key in self.clubs{
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
                                    clubData.distance = distance/YARD
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
                                    clubData.proximity = proximity/YARD
                                }
                                
                            }
                            let holeout = (valueArray[j] as AnyObject).object(forKey: "holeOut")
                            if((holeout) != nil){
                                clubData.holeout = holeout as! Double
                            }
                            
                            clubWiseArray.append(clubData)
                            clubDict.append((key,clubData))
                        }
                    }
                }
            }
        }
        return clubDict
    }
    
    func setHoleOutDistanceWithPuttProximity(){
        var isTotalProximity = false
        var isHoleOutTrue = false
        if(totalHoleOutDistance.count > 0){
            let sum = totalHoleOutDistance.reduce(0, +)
            self.lblHoleOutDistance.text = "\((sum/Double(totalHoleOutDistance.count)).rounded(toPlaces: 1)) ft"
        }
        else{
            self.lblHoleOutDistance.isHidden = true
            self.lblHoleOutDistance.text = "0.0ft"
            isHoleOutTrue = true
        }
        if(totalProximity.count > 0){
            let sum = totalProximity.reduce(0, +)
            self.lblFirstPuttProximity.text = "\((sum/Double(totalProximity.count)).rounded(toPlaces: 1)) ft"
            self.lblStrokesGainedPuttingAvg.isHidden = false
            self.lblPuttingSG.isHidden = false
            self.lblStrokesGainedPuttingAvg.text = "Proximity to Hole after Approach Putt"
            self.lblPuttingSG.text = "\((sum/Double(totalProximity.count)).rounded(toPlaces: 1)) ft"
        }
        else{
            self.lblFirstPuttProximity.text = "0.0 ft"
            isTotalProximity = true
        }
        if(isTotalProximity && isHoleOutTrue){
            puttingCardView.isHidden = true
        }
        
    }
    
    func setAroundTheGreenConsistancy(){
        self.aroundTheGreenConsistancy.setProgress(value: CGFloat(66.7), animationDuration: 1.0)
    }
    func setAroundTheGreenSwingScore(){
        if(self.totalSwingScore > 0){
            self.aroundTheGreenSwingScore.setProgress(value: CGFloat((strokesGainedData[2].clubSwingScore / self.totalSwingScore)*100), animationDuration: 1.0)
        }
        else{
            aroundTheGreenCardView.isHidden = true
        }
        
    }
    func setApprochTheGreenConsistancy(){
        self.approchTheGreenConsistancy.setProgress(value: CGFloat(55.6), animationDuration: 1.0)
    }
    func setApprochTheGreenSwingScore(){
        if(self.totalSwingScore > 0){
            self.approchTheGreenSwingScore.setProgress(value: CGFloat((strokesGainedData[1].clubSwingScore / self.totalSwingScore)*100), animationDuration: 1.0)
        }
        else{
            approchCardView.isHidden = true
        }
    }
    func setOffTheTeeConsistancy(){
        self.offTheTeeConsistancy.setProgress(value: CGFloat(49.5), animationDuration: 1.0)
    }
    func setOffTheTeeSwingScore(){
        if(self.totalSwingScore > 0){
            self.offTheTeeSwingScore.setProgress(value: CGFloat((strokesGainedData[0].clubSwingScore / self.totalSwingScore)*100), animationDuration: 1.0)
        }
        else{
            offTheTeeCardView.isHidden = true
        }
    }
    
    func setStrokesGainedPerClubBarChart(){
        var dataPoints = [String]()
        var dataValues = [Double]()
        
        for data in self.strokesGainedData{
            dataPoints.append(data.clubType)
            dataValues.append((data.clubStrokesGained / Double(totalCaddie)).rounded(toPlaces: 1))
            print(data)
        }
        self.strokesGainedPerClubBarChart.setBarChartStrokesGained(dataPoints: dataPoints, values: dataValues, chartView: self.strokesGainedPerClubBarChart, color: UIColor.glfWhite, barWidth: 0.4,valueColor: UIColor.glfWhite.withAlphaComponent(0.5))
        strokesGainedPerClubBarChart.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.25)
        strokesGainedPerClubBarChart.leftAxis.labelTextColor  = UIColor.glfWhite.withAlphaComponent(0.5)
        strokesGainedPerClubBarChart.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        
            let publicScore  = PublicScore()
            let publicScoreStr = publicScore.getSGPerClub(gainAvg: dataValues[0], gainAvg1: dataValues[1], gainAvg2: dataValues[2], gainAvg3: dataValues[3])
            lblStrokesGainedPerClubAvg.isHidden = false
            lblStrokesGainedPerClubAvg.text = publicScoreStr
    }
    
    func setInitialUI(){
        lblProSG.layer.cornerRadius = 3.0
        lblProSG.layer.masksToBounds = true
        lblProOTT.layer.cornerRadius = 3.0
        lblProOTT.layer.masksToBounds = true
        lblProPutting.layer.cornerRadius = 3.0
        lblProPutting.layer.masksToBounds = true
        lblProATG.layer.cornerRadius = 3.0
        lblProATG.layer.masksToBounds = true
        lblProApproach.layer.cornerRadius = 3.0
        lblProApproach.layer.masksToBounds = true
        
        lblStrokesGainedPerClubAvg.isHidden = true
        lblStrokesGainedOffTheTeeAvg.isHidden = true
        lblStrokesGainedApproachTheGreenAvg.isHidden = true
        lblStrokesGainedAroundTheGreenAvg.isHidden = true
        lblStrokesGainedPuttingAvg.isHidden = true
        
        lblPuttingSG.isHidden = true
        lblApprochTheGreenSG.isHidden = true
        lblAroundtheGreenSG.isHidden = true
        lblOffTheTeeSG.isHidden = true
        
        strokeGainedChartView.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        
        self.lblPuttingSG.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblApprochTheGreenSG.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAroundtheGreenSG.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblOffTheTeeSG.setCorner(color: UIColor.glfBlack50.cgColor)
        

    }
    
    func setProLockedUI(targetView:UIView?, title:String) {
        
        let customProModeView = CustomProModeView()
        customProModeView.frame =  CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!-16, height: (targetView?.frame.size.height)!)
        customProModeView.delegate = self
        customProModeView.btnDevice.isHidden = true
        customProModeView.btnPro.isHidden = false
        
        customProModeView.proImageView.frame.size.width = 45
        customProModeView.proImageView.frame.size.height = 45
        customProModeView.proImageView.frame.origin.x = (customProModeView.frame.size.width)-45-4
        customProModeView.proImageView.frame.origin.y = 0
        
        customProModeView.label.frame.size.width = (customProModeView.bounds.width)-80
        customProModeView.label.frame.size.height = 50
        customProModeView.label.center = CGPoint(x: (customProModeView.bounds.midX), y: (customProModeView.bounds.midY)-40)
        customProModeView.label.backgroundColor = UIColor.clear
        
        customProModeView.btnPro.frame.size.width = (customProModeView.label.frame.size.width/2)+10
        customProModeView.btnPro.frame.size.height = 40
        customProModeView.btnPro.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 20)
        
        customProModeView.titleLabel.frame = CGRect(x: customProModeView.frame.origin.x + 16, y: customProModeView.frame.origin.y + 16, width: customProModeView.bounds.width, height: 30)
        customProModeView.titleLabel.backgroundColor = UIColor.clear
        customProModeView.titleLabelText = title
        
        customProModeView.labelText = "Pro members only"
        customProModeView.btnTitle = "Become a Pro"
        //customProModeView.backgroundColor = UIColor.clear
        customProModeView.backgroundColor = UIColor(red:110.0/255.0, green:185.0/255.0, blue:165.0/255.0, alpha:1.0)
        
        if !checkCaddie{
            customProModeView.btnPro.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 30)

            customProModeView.titleLabel.textColor = UIColor.darkGray
            customProModeView.labelText = "Unlock this stat by playing a round with Shot Tracking"
            customProModeView.btnTitle = "Play Now"
            customProModeView.backgroundColor = UIColor.white
        }
        targetView?.addSubview(customProModeView)
    }
    
    func proLockBtnPressed(button:UIButton) {
        if !checkCaddie{
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
        else{
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
            self.navigationController?.pushViewController(viewCtrl, animated: true)
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    func setupActivityIndicator(){
        actvtIndView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        actvtIndView.color = UIColor.darkGray
        actvtIndView.center = view.center
        actvtIndView.startAnimating()
        self.view.addSubview(actvtIndView)
        actvtIndView.isHidden = true
    }
}
