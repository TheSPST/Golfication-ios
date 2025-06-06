//
//  SmartCaddieVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 15/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Charts
import FirebaseAnalytics

class SmartCaddieVC: UIViewController, CustomProModeDelegate,DemoFooterViewDelegate{

    @IBOutlet weak var smartCaddieStackView: UIStackView!
    @IBOutlet weak var lblControlAvg: UILabel!
    @IBOutlet weak var lblStrokesGainedPerClubAvg: UILabel!
    @IBOutlet weak var lblClubUsageAvg: UILabel!
    @IBOutlet weak var lblShortGameAvg: UILabel!
    @IBOutlet weak var lblClubRangeAvg: UILabel!
    @IBOutlet weak var lblClubDistanceAvg: UILabel!
    @IBOutlet weak var controlRadarChartView: RadarChartView!
    @IBOutlet weak var strokeGainedBarChartView: BarChartView!
    @IBOutlet weak var clubUsageBarChartView: BarChartView!
    @IBOutlet weak var shortGameBarChartView: BarChartView!
    @IBOutlet weak var clubRangeBarChartView: BarChartView!
    @IBOutlet weak var clubDistanceBarChartView: BarChartView!
    @IBOutlet weak var cardViewDistance: CardView!
    @IBOutlet weak var cardViewShortGame: CardView!
    @IBOutlet weak var cardViewControlRadar: CardView!
    @IBOutlet weak var actvtIndView: UIActivityIndicatorView!
    @IBOutlet weak var lblAvgDistance: UILabel!
    @IBOutlet weak var lblAvgRange: UILabel!
    @IBOutlet weak var lblAvgShortGame: UILabel!
    @IBOutlet weak var lblAvgUsage: UILabel!
//    @IBOutlet weak var lblAvgSG: UILabel!
    @IBOutlet weak var lblAvgControl: UILabel!
    @IBOutlet weak var lblProClubDistance: UILabel!

    
    var smartCaddieAvg = [(clubName: String,clubTotalDistance: Double,clubStrokesGained: Double,clubDistanceArray:[Double])]()
    let shortClubs = ["7i","8i","9i","Pw","Sw","Lw","Gw"]
    let clubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"
]
    var myDataArray = NSMutableArray()
    var filteredArray = [NSDictionary]()
    var cardViewMArray = NSMutableArray()
    var cardViewInfoArray = [(title:String,value:String)]()

    @IBAction func filterNavBarButtonClick(_ sender: Any) {
//        IAPHandler.shared.purchaseMyProduct(index: 0)
        FBSomeEvents.shared.singleParamFBEvene(param: "Filter Smart Caddie")
        let filterVc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        filterVc.isSmartCaddie = true
        self.navigationController?.pushViewController(filterVc, animated: true)
    }
    override func viewDidLoad() {
        FBSomeEvents.shared.singleParamFBEvene(param: "View Smart Caddie")
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        Analytics.logEvent("smart_caddie", parameters: [:])
        self.title = "Smart Caddie"
        
        let backBtn = UIBarButtonItem(image:(UIImage(named: "backArrow")), style: .plain, target: self, action: #selector(self.backAction(_:)))
        backBtn.tintColor = UIColor.glfBluegreen
        self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)

        Constants.finalFilterDic.removeAllObjects()
        self.setInitialUI()
        FBSomeEvents.shared.singleParamFBEvene(param: "View Club Stats")
    }
    @objc func backAction(_ sender: UIBarButtonItem) {
        FBSomeEvents.shared.singleParamFBEvene(param: "Click Smart Caddie Back")
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
            self.getSmartDataFromFirebase()
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
        
        //        var selectedRoundArray: ArraySlice = [""]
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
        //print("filteredArray = ", filteredArray)
        self.setDataInUI()
        
        if filteredArray.count==0{
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var checkCaddie:Bool{
        if totalCaddie > 0{
            return true
        }else{
            return false
        }
    }
    var totalCaddie = Int()
    func getSmartDataFromFirebase() {
        //smartCaddie
        totalCaddie = 0
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "scoring") { (snapshot) in
            var dataDic = NSDictionary()
            if snapshot.childrenCount > 0{
                dataDic = (snapshot.value as? NSDictionary)!
                self.setData(dataDic:dataDic)
                
                for (_, val) in dataDic{
                    let valDic = val as! NSDictionary
                    for (key1, _) in valDic{
                        if (key1 as! String  == "smartCaddie"){
                            self.totalCaddie += 1
                        }
                    }
                }
                if self.totalCaddie > 0{
                    if !Constants.isProMode {
                        //                    self.cardViewDistance.makeBlurView(targetView: self.cardViewDistance)
                        self.setProLockedUI(targetView: self.cardViewDistance, title: "Club Distance")
                        
                        self.lblProClubDistance.isHidden = true
                    }
                    else{
                        self.lblProClubDistance.backgroundColor = UIColor.clear
                        self.lblProClubDistance.layer.borderWidth = 1.0
                        self.lblProClubDistance.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
                        self.lblProClubDistance.textColor = UIColor(rgb: 0xFFC700)
                        
                        self.lblProClubDistance.isHidden = false
                    }
                    let originalImage1 = #imageLiteral(resourceName: "share")
                    let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    
                    let originalImage = #imageLiteral(resourceName: "icon_info_grey")
                    let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    
                    var viewTag = 0
                    self.cardViewInfoArray = [(title:String,value:String)]()
                    for v in self.smartCaddieStackView.subviews{
                        if v.isKind(of: CardView.self){
                            self.cardViewMArray.add(v)
                            switch viewTag{
                            case 0:
                                self.cardViewInfoArray.append((title:"Club Distance",value:StatsIntoConstants.clubDistance))
                                break
                            case 1:
                                self.cardViewInfoArray.append((title:"Club Range",value:StatsIntoConstants.clubRange))
                                break
                            case 2:
                                self.cardViewInfoArray.append((title:"Short Game",value:StatsIntoConstants.shortGame))
                                break
                            case 3:
                                self.cardViewInfoArray.append((title:"Club Usage",value:StatsIntoConstants.clubUsage))
                                break
                            case 4:
                                self.cardViewInfoArray.append((title:"Strokes Gained Per Club",value:StatsIntoConstants.strokesGainedPerClub))
                                break
                            case 5:
                                self.cardViewInfoArray.append((title:"Club Control",value:StatsIntoConstants.control))
                                break
                            default: break
                            }
                            if (!Constants.isProMode && !((v == self.cardViewDistance))){
                                let shareStatsButton = ShareStatsButton()
                                shareStatsButton.frame = CGRect(x: self.view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                                shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                                shareStatsButton.tintColor = UIColor.glfFlatBlue
                                shareStatsButton.tag = viewTag
                                shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                                v.addSubview(shareStatsButton)
                                
                                //Stats Info Button
                                let statsInfoButton = StatsInfoButton()
                                statsInfoButton.frame = CGRect(x: (self.view.frame.size.width-shareStatsButton.frame.size.width)-70, y: 16, width: 25, height: 25)
                                statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                                statsInfoButton.tintColor = UIColor.glfFlatBlue
                                statsInfoButton.tag = viewTag
                                statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                                v.addSubview(statsInfoButton)
                            }
                            else if Constants.isProMode{
                                let shareStatsButton = ShareStatsButton()
                                shareStatsButton.frame = CGRect(x: self.view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                                shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                                shareStatsButton.tintColor = UIColor.glfFlatBlue
                                shareStatsButton.tag = viewTag
                                if (v == self.cardViewDistance){
                                    shareStatsButton.tintColor = UIColor.white
                                }
                                shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                                v.addSubview(shareStatsButton)
                                
                                //Stats Info Button
                                let statsInfoButton = StatsInfoButton()
                                statsInfoButton.frame = CGRect(x: (self.view.frame.size.width-shareStatsButton.frame.size.width)-70, y: 16, width: 25, height: 25)
                                statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                                statsInfoButton.tintColor = UIColor.glfFlatBlue
                                statsInfoButton.tag = viewTag
                                if (v == self.cardViewDistance){
                                    statsInfoButton.tintColor = UIColor.white
                                }
                                statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                                v.addSubview(statsInfoButton)
                            }
                            viewTag = viewTag+1
                        }
                    }
                    if !Constants.isDevice {
                        self.cardViewShortGame.makeBlurView(targetView: self.cardViewShortGame)
                        self.setDeviceLockedUI(targetView: self.cardViewShortGame, title: "Short Game")
                        
                        self.cardViewControlRadar.makeBlurView(targetView: self.cardViewControlRadar)
                        self.setDeviceLockedUI(targetView: self.cardViewControlRadar, title: "Control")
                    }
                }
            }
            if self.totalCaddie == 0{
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "userData/m0BmtxOAiuXYIhDN0BGwFo3QjKq2/scoring") { (snapshot) in
                    dataDic = (snapshot.value as? NSDictionary)!
                    self.setData(dataDic:dataDic)
                    self.setDemoFotter()
                }
            }
        }
    }
    
    // MARK: - infoClicked
    @objc func infoClicked(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
        viewCtrl.title = cardViewInfoArray[sender.tag].title
        viewCtrl.desc = cardViewInfoArray[sender.tag].value
        self.navigationController?.pushViewController(viewCtrl, animated: true)
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
    }
    
    func setData(dataDic:NSDictionary){
        
        self.actvtIndView.isHidden = false
        self.actvtIndView.startAnimating()
        //print("Scores :\(dataDic)")
        
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
        
        let originalImage = #imageLiteral(resourceName: "icon_info_grey")
        let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        var viewTag = 0
        self.cardViewInfoArray = [(title:String,value:String)]()
        for v in self.smartCaddieStackView.subviews{
            if v.isKind(of: CardView.self){
                let demoLabel = DemoLabel()
                demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                v.addSubview(demoLabel)
                
                switch viewTag{
                case 0:
                    self.cardViewInfoArray.append((title:"Club Distance",value:StatsIntoConstants.clubDistance))
                    break
                case 1:
                    self.cardViewInfoArray.append((title:"Club Range",value:StatsIntoConstants.clubRange))
                    break
                case 2:
                    self.cardViewInfoArray.append((title:"Short Game",value:StatsIntoConstants.shortGame))
                    break
                case 3:
                    self.cardViewInfoArray.append((title:"Club Usage",value:StatsIntoConstants.clubUsage))
                    break
                case 4:
                    self.cardViewInfoArray.append((title:"Strokes Gained Per Club",value:StatsIntoConstants.strokesGainedPerClub))
                    break
                case 5:
                    self.cardViewInfoArray.append((title:"Club Control",value:StatsIntoConstants.control))
                    break
                default: break
                }
                //Stats Info Button
                let statsInfoButton = StatsInfoButton()
                statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-50, y: 16, width: 25, height: 25)
                statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                statsInfoButton.tintColor = UIColor.glfFlatBlue
                statsInfoButton.tag = viewTag
                if (v == self.cardViewDistance){
                    statsInfoButton.tintColor = UIColor.white
                }
                statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                v.addSubview(statsInfoButton)
                viewTag = viewTag+1
            }
        }
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
        //print("clubDict: \(clubDict)")
        
        self.smartCaddieAvg.removeAll()
        self.smartCaddieAvg = [(clubName: String,clubTotalDistance: Double,clubStrokesGained: Double,clubDistanceArray:[Double])]()
        
        for data in self.clubs{
            self.smartCaddieAvg.append((data,0.0,0.0,[0.0]))
        }
        
        for i in 0..<self.clubs.count{
            var distanceArray = [Double]()
            var value = 0.0
            var strokesGained = 0.0
            var index = 0
            
            for j in 0..<clubDict.count{
                if(CSTypeArray.count>0){
                    if CSTypeArray.contains(clubDict[j].0){
                        if(self.smartCaddieAvg[i].clubName  == clubDict[j].0){
                            value = self.smartCaddieAvg[i].clubTotalDistance
                            strokesGained = self.smartCaddieAvg[i].clubStrokesGained
                            let clubClass = clubDict[j].1 as Club
                            value += clubClass.distance
                            distanceArray.append(clubClass.distance)
                            strokesGained += clubClass.strokesGained
                            index = i
                            self.smartCaddieAvg[index] = (clubDict[j].0,value,strokesGained,distanceArray)
                        }
                    }
                }
                else{
                    if(self.smartCaddieAvg[i].clubName  == clubDict[j].0){
                        value = self.smartCaddieAvg[i].clubTotalDistance
                        strokesGained = self.smartCaddieAvg[i].clubStrokesGained
                        let clubClass = clubDict[j].1 as Club
                        value += clubClass.distance
                        distanceArray.append(clubClass.distance)
                        strokesGained += clubClass.strokesGained
                        index = i
                        self.smartCaddieAvg[index] = (clubDict[j].0,value,strokesGained,distanceArray)
                    }
                }
      
            }
        }
        self.setAllBarExpectGameBarChart()
        self.setGameBarChartView()
    }
    
    func transferDataIntoClasses(myDataArray:[NSDictionary])->[(String,Club)]{

        var clubDict = [(String,Club)]()
        
        for i in 0..<myDataArray.count {
            if let smartCaddieDic = ((myDataArray[i] as AnyObject).object(forKey:"smartCaddie") as? NSDictionary){
                var clubWiseArray = [Club]()
                for key in self.clubs{
                    var keysArray = smartCaddieDic.value(forKeyPath: " \(key)")
                    if (keysArray == nil){
                        keysArray = smartCaddieDic.value(forKey: "\(key)")
                    }
                    if((keysArray) != nil){
                        let valueArray = keysArray as! NSArray
                        for j in 0..<valueArray.count{
                            let clubData = Club()
                            if let backSwing = (valueArray[j] as AnyObject).object(forKey: "backswing") as? Double{
                                clubData.backswing = backSwing
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
                            
                            if let swingScore = (valueArray[j] as AnyObject).object(forKey: "swingScore") as? Double{
                                clubData.swingScore = swingScore
                            }
                            if let type = (valueArray[j] as AnyObject).object(forKey: "type") as? Int{
                                clubData.type = type
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
    
    func setGameBarChartView(){
        var shortClubDataValue = [Double]()
        var shortClubName = [String]()
        for i in 0..<self.smartCaddieAvg.count{
            if((self.shortClubs.contains(self.smartCaddieAvg[i].clubName)) && (self.smartCaddieAvg[i].1 != 0)){
                shortClubDataValue.append(self.smartCaddieAvg[i].clubTotalDistance/Double(self.smartCaddieAvg[i].clubDistanceArray.count))
                shortClubName.append(self.smartCaddieAvg[i].clubName)
            }
        }
        if !shortClubDataValue.isEmpty{
            self.shortGameBarChartView.setBarChart(dataPoints: shortClubName, values: shortClubDataValue, chartView: self.shortGameBarChartView, color: UIColor.glfBluegreen25, barWidth: 0.2, leftAxisMinimum: 0,labelTextColor: UIColor.glfWarmGrey,unit: "", valueColor: UIColor.clear)
            let formatter = NumberFormatter()
            formatter.positiveSuffix = " yd"
            if(Constants.distanceFilter == 1){
                formatter.positiveSuffix = " m"
            }
            shortGameBarChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
            shortGameBarChartView.leftAxis.axisMaximum = shortClubDataValue.max()! + 10.0
        }
    }
    
    func setAllBarExpectGameBarChart(){
        
        var dataPoints = [String]()
        var dataValues = [Double]()
        var dataCount = [Double]()
        var strokeGainedAvg = [Double]()
        var minimum = [Double]()
        var maximum = [Double]()
        for i in 0..<self.smartCaddieAvg.count{
            if(self.smartCaddieAvg[i].1 != 0){
                dataPoints.append(self.smartCaddieAvg[i].clubName)
                dataValues.append((self.smartCaddieAvg[i].clubTotalDistance)/Double((self.smartCaddieAvg[i].clubDistanceArray).count))
                dataCount.append(Double((self.smartCaddieAvg[i].clubDistanceArray).count))
                strokeGainedAvg.append((self.smartCaddieAvg[i].clubStrokesGained)/Double((self.smartCaddieAvg[i].clubDistanceArray).count))
                minimum.append((self.smartCaddieAvg[i].clubDistanceArray).min()!)
                maximum.append((self.smartCaddieAvg[i].clubDistanceArray).max()!)
            }
        }
        self.clubDistanceBarChartView.setBarChart(dataPoints: dataPoints, values: dataValues, chartView: self.clubDistanceBarChartView, color: UIColor.glfWhite, barWidth: 0.2, leftAxisMinimum: 0,labelTextColor: UIColor.glfWhite.withAlphaComponent(0.50), unit: "", valueColor: UIColor.glfWhite.withAlphaComponent(0.50))
        self.clubDistanceBarChartView.xAxis.labelCount = dataPoints.count
        
        let formatter = NumberFormatter()
        formatter.positiveSuffix = " yd"
        if(Constants.distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        clubDistanceBarChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        self.clubUsageBarChartView.setBarChart(dataPoints: dataPoints, values: dataCount, chartView: self.clubUsageBarChartView, color: UIColor.glfLightGreyBlue, barWidth: 0.2, leftAxisMinimum: 0,labelTextColor: UIColor.glfWarmGrey, unit: "", valueColor: UIColor.glfWarmGrey)
        clubUsageBarChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        self.clubUsageBarChartView.xAxis.labelCount = dataPoints.count
        self.clubUsageBarChartView.xAxis.wordWrapEnabled = false
        self.clubUsageBarChartView.leftAxis.labelTextColor = UIColor.clear
        
        if !dataCount.isEmpty{
            self.setClubUsagsLbl(dataArr: dataCount, clubArr: dataPoints)
        }
        
        self.strokeGainedBarChartView.setBarChartStrokesGained(dataPoints: dataPoints, values: strokeGainedAvg, chartView: self.strokeGainedBarChartView, color: UIColor.glfBluegreen50, barWidth: 0.2,valueColor: UIColor.glfWarmGrey)
        self.controlRadarChartView.setChart(dataPoints: dataPoints, values: dataValues, chartView: self.controlRadarChartView)
        self.clubRangeBarChartView.setBarChartWithRange(dataPoints: dataPoints, minimum: minimum, maximum: maximum, chartView: self.clubRangeBarChartView, color: [UIColor.clear , UIColor.glfBluegreen50], barWidth: 0.2)
        clubRangeBarChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        
        if !strokeGainedAvg.isEmpty{
            var absStrokesGained = [Double]()
            for data in strokeGainedAvg{
                absStrokesGained.append(abs(data))
            }
            let max = absStrokesGained.max()!
            let index = absStrokesGained.firstIndex(of: max)!
            let newMax = strokeGainedAvg[index]
            let club = BackgroundMapStats.getClubName(club: dataPoints[index])
            let publicScore = PublicScore()
            self.lblStrokesGainedPerClubAvg.isHidden = false
            self.lblStrokesGainedPerClubAvg.text = publicScore.getSGPerClubForSmartCaddie(setMaxAbsoluteValueStrokesGained: newMax, club: club)
        }
        

    }
    func setClubUsagsLbl(dataArr:[Double],clubArr:[String]){
        self.lblClubUsageAvg.isHidden = false
        self.lblAvgUsage.isHidden = false
        self.lblClubUsageAvg.text = "Your Most Used Club "
        var dataArr = dataArr
        var clubArr = clubArr
        let max = dataArr.max()!
        let index = dataArr.firstIndex(of: max)!
        let val =  clubArr[index]
        if val == "Pu"{
            dataArr.remove(at: index)
            clubArr.remove(at: index)
            let max = dataArr.max()!
            let index = dataArr.firstIndex(of: max)!
            let val =  clubArr[index]
            self.lblAvgUsage.text = " \(BackgroundMapStats.getClubName(club: val)) "
        }else{
            self.lblAvgUsage.text = " \(BackgroundMapStats.getClubName(club: val)) "
        }
        self.lblAvgUsage.sizeToFit()
    }
    
    func setInitialUI(){
        lblProClubDistance.layer.cornerRadius = 3.0
        lblProClubDistance.layer.masksToBounds = true
        
        cardViewDistance.setGradientColor(topColor: UIColor(red:58.0/255.0, green:124.0/255.0, blue:165.0/255.0, alpha:1.0), bottomColor: UIColor(red:0.0, green:138.0/255.0, blue:100.0/255.0, alpha:1.0))
        cardViewDistance.cornerRadius = 5
        lblAvgDistance.setCorner(color: UIColor.white.cgColor)
        lblAvgRange.setCorner(color: UIColor.glfBlack50.cgColor)
        lblAvgShortGame.setCorner(color: UIColor.glfBlack50.cgColor)
        lblAvgUsage.setCorner(color: UIColor.glfBlack50.cgColor)
//        lblAvgSG.setCorner(color: UIColor.glfBlack50.cgColor)
        lblAvgControl.setCorner(color: UIColor.glfBlack50.cgColor)
        
        controlRadarChartView.isUserInteractionEnabled = false
        strokeGainedBarChartView.isUserInteractionEnabled = false
        clubUsageBarChartView.isUserInteractionEnabled = false
        shortGameBarChartView.isUserInteractionEnabled = false
        clubRangeBarChartView.isUserInteractionEnabled = false
        clubDistanceBarChartView.isUserInteractionEnabled = false
        
        lblControlAvg.isHidden = true
        lblStrokesGainedPerClubAvg.isHidden = true
        lblClubUsageAvg.isHidden = true
        lblShortGameAvg.isHidden = true
        lblClubRangeAvg.isHidden = true
        lblClubDistanceAvg.isHidden = true
        
         lblAvgDistance.isHidden = true
         lblAvgRange.isHidden = true
         lblAvgShortGame.isHidden = true
         lblAvgUsage.isHidden = true
//         lblAvgSG.isHidden = true
         lblAvgControl.isHidden = true
    }
    
    func setProLockedUI(targetView:UIView?, title: String) {
        
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
//        customProModeView.backgroundColor = UIColor.clear
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
    func setDeviceLockedUI(targetView:UIView?, title: String) {
        
        let customProModeView = CustomProModeView()
        customProModeView.frame =  CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!-16, height: (targetView?.frame.size.height)!)
        customProModeView.delegate = self
        customProModeView.btnDevice.isHidden = false
        customProModeView.btnPro.isHidden = true
        
        customProModeView.proImageView.frame.size.width = 45
        customProModeView.proImageView.frame.size.height = 45
        customProModeView.proImageView.frame.origin.x = (customProModeView.frame.size.width)-45-4
        customProModeView.proImageView.frame.origin.y = 0
        
        customProModeView.label.frame.size.width = (customProModeView.bounds.width)-80
        customProModeView.label.frame.size.height = 50
        customProModeView.label.center = CGPoint(x: (customProModeView.bounds.midX), y: (customProModeView.bounds.midY)-40)
        customProModeView.label.backgroundColor = UIColor.clear

        customProModeView.btnDevice.frame.size.width = (customProModeView.label.frame.size.width/2)+10
        customProModeView.btnDevice.frame.size.height = 40
        customProModeView.btnDevice.center = CGPoint(x: customProModeView.bounds.midX, y: customProModeView.label.frame.origin.y + customProModeView.label.frame.size.height + 20)
        
        customProModeView.titleLabel.frame = CGRect(x: customProModeView.frame.origin.x + 16, y: customProModeView.frame.origin.y + 16, width: customProModeView.bounds.width, height: 30)
        customProModeView.titleLabel.backgroundColor = UIColor.clear
        customProModeView.titleLabelText = title
        customProModeView.titleLabel.textColor = UIColor.darkGray
        
        customProModeView.labelText = "Golfication X required"
        customProModeView.btnDeviceTitle = "Visit our store"
        customProModeView.proImageView.image = UIImage(named: "device")
        customProModeView.backgroundColor = UIColor.clear
        targetView?.addSubview(customProModeView)
    }
    
    func deviceLockBtnPressed(button:UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
        viewCtrl.linkStr = "https://www.golfication.com/product/golfication-x/"
        viewCtrl.fromIndiegogo = false
        viewCtrl.fromNotification = false
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    func proLockBtnPressed(button:UIButton) {

        if !checkCaddie{
            let mapViewController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
        else{
//            let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
//            self.navigationController?.pushViewController(viewCtrl, animated: true)
            FBSomeEvents.shared.singleParamFBEvene(param: "Click Smart Caddie Eddie")
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
            viewCtrl.source = "SmartCaddie"
            self.navigationController?.pushViewController(viewCtrl, animated: false)
        }
    }
}

