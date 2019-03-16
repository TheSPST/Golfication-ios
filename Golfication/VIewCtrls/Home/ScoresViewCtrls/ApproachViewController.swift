//
//  ApprochViewController.swift
//  Golfication
//
//  Created by IndiRenters on 10/26/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import UICircularProgressRing
import FirebaseAnalytics

class ApproachViewController: UIViewController, IndicatorInfoProvider,CustomProModeDelegate {
    
    
    @IBOutlet weak var approachStackView: UIStackView!
    @IBOutlet weak var lblApproachAccuracyAvg: UILabel!
    @IBOutlet weak var lblAccuracyWithDriverAvg: UILabel!
    @IBOutlet weak var lblHoleProximityAvg: UILabel!
    @IBOutlet weak var lblGIRTrendsAvg: UILabel!
    @IBOutlet weak var lblGIRAvg: UILabel!
    
    @IBOutlet weak var approachAccuracyStackView: UIStackView!
    @IBOutlet weak var lblShort: UILocalizedLabel!
    @IBOutlet weak var lblRight: UILocalizedLabel!
    @IBOutlet weak var lblLeft: UILocalizedLabel!
    @IBOutlet weak var lblHit: UILabel!
    @IBOutlet weak var lblLong: UILocalizedLabel!
    @IBOutlet weak var lblProApproach: UILabel!
    @IBOutlet weak var lblProProximity: UILabel!

    @IBOutlet weak var cardViewApproach: CardView!
    @IBOutlet weak var lblAvgHoleProximityValue: UILabel!
    @IBOutlet weak var lblAvgGIRTrendsValue: UILabel!
    @IBOutlet weak var lblAvgGIRLikelinessValue: UILabel!
    @IBOutlet weak var greensWithFairwayMissPercentage: UILabel!
    @IBOutlet weak var greensWithFairwayHitPercentage: UILabel!
    @IBOutlet weak var approchAccuracyScatterChart: ScatterChartView!
    @IBOutlet weak var holeProximityScatterWithLineView: CombinedChartView!
    @IBOutlet weak var girCircularChart: UICircularProgressRingView!
    @IBOutlet weak var GIRTrendBarChart: BarChartView!
    @IBOutlet weak var GIRLikelinessLineChart: LineChartView!
    @IBOutlet weak var holeProximityCardView: CardView!
    
    var scores = [Scores]()
    var groupDict = [String:Double]()
    var clubFilter = [String]()
    var isDemoUser :Bool!
    var cardViewMArray = NSMutableArray()

    var checkCaddie = Bool()
    var cardViewInfoArray = [(title:String,value:String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("my_scores_approach", parameters: [:])
        if(Constants.distanceFilter == 1){

        var meterString = ["90m","60m","30m","30m","60m","90m"]
        var i = 0
        for view in self.approachAccuracyStackView.arrangedSubviews{
            (view as! UILabel).text = meterString[i]
            i += 1
        }
        }
        self.setupUI()
        self.setupApprochAccuracyScatterChart()
        self.setupGIRTrendBarChart()
        self.setupHoleProximityScatterChartView()
        self.setupGIRLikelinessLineChart()
        self.setupGirCircularChart()
        
        //print("clubFilter== \(clubFilter)")
    }
    func setupUI(){
        lblProApproach.layer.cornerRadius = 3.0
        lblProProximity.layer.cornerRadius = 3.0
        lblProApproach.layer.masksToBounds = true
        lblProProximity.layer.masksToBounds = true

        lblApproachAccuracyAvg.isHidden = true
        lblAccuracyWithDriverAvg.isHidden = true
        lblHoleProximityAvg.isHidden = true
        lblGIRTrendsAvg.isHidden = true
        lblGIRAvg.isHidden = true
        lblAvgHoleProximityValue.isHidden = true
        lblAvgGIRTrendsValue.isHidden = true
        lblAvgGIRLikelinessValue.isHidden = true
        
        if(isDemoUser){
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.approachStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)

                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Approach Accuracy",value:StatsIntoConstants.approachAccuracy))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Greens in Regulation (GIR)",value:StatsIntoConstants.GIR))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Hole Proximity",value:StatsIntoConstants.holeProximity))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"GIR Trend",value:StatsIntoConstants.girTrend))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"GIR Likeliness",value:StatsIntoConstants.girLikeliness))
                        break
                    default: break
                    }
                    //Stats Info Button
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-50, y: 16, width: 25, height: 25)
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == cardViewApproach){
                        statsInfoButton.tintColor = UIColor.white
                    }
                    statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                    v.addSubview(statsInfoButton)
                    viewTag = viewTag+1
                }
            }
        }else{
            if !Constants.isProMode {
                //cardViewApproach.makeBlurView(targetView: cardViewApproach)
//                self.setProLockedUI(targetView: cardViewApproach, title: "Approach Accuracy".localized())
                
                //holeProximityCardView.makeBlurView(targetView: holeProximityCardView)
//                self.setProLockedUI(targetView: holeProximityCardView, title: "Hole Proximity".localized())
                
                lblProApproach.isHidden = true
                lblProProximity.isHidden = true
            }
            else{
                lblProApproach.backgroundColor = UIColor.clear
                lblProApproach.layer.borderWidth = 1.0
                lblProApproach.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
                lblProApproach.textColor = UIColor(rgb: 0xFFC700)
                
                lblProApproach.isHidden = false
                lblProProximity.isHidden = false
            }
            
            let originalImage1 = #imageLiteral(resourceName: "share")
            let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.approachStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Approach Accuracy",value:StatsIntoConstants.approachAccuracy))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Greens in Regulation (GIR)",value:StatsIntoConstants.GIR))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Hole Proximity",value:StatsIntoConstants.holeProximity))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"GIR Trend",value:StatsIntoConstants.girTrend))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"GIR Likeliness",value:StatsIntoConstants.girLikeliness))
                        break
                    default: break
                    }
                    if (!Constants.isProMode && !((v == cardViewApproach) || (v == holeProximityCardView))){
                        let shareStatsButton = ShareStatsButton()
                        shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
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
                        shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                        shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                        shareStatsButton.tintColor = UIColor.glfFlatBlue
                        shareStatsButton.tag = viewTag
                        if (v == cardViewApproach){
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
                        if (v == cardViewApproach){
                            statsInfoButton.tintColor = UIColor.white
                        }
                        statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                        v.addSubview(statsInfoButton)
                    }
                    viewTag = viewTag+1
                }
            }
        }
        approchAccuracyScatterChart.isUserInteractionEnabled = false
        holeProximityScatterWithLineView.isUserInteractionEnabled = false
        girCircularChart.isUserInteractionEnabled = false
        GIRTrendBarChart.isUserInteractionEnabled = false
        GIRLikelinessLineChart.isUserInteractionEnabled = false
        
        cardViewApproach.backgroundColor = UIColor.glfBluegreen
        self.lblAvgHoleProximityValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgGIRTrendsValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgGIRLikelinessValue.setCorner(color: UIColor.glfBlack50.cgColor)
        
        if !Constants.isProMode{
            lblApproachAccuracyAvg.isHidden = true
            lblHoleProximityAvg.isHidden = true
            lblAvgHoleProximityValue.isHidden = true
            lblGIRAvg.isHidden = true
            lblAvgGIRLikelinessValue.isHidden = true
            
            let eddieStatsView = EddieStatsView()
            eddieStatsView.backgroundColor = UIColor.clear
            eddieStatsView.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-52, height: 30)
            eddieStatsView.lblTitle.text = "Unlock this stat with Eddie!"
            eddieStatsView.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            cardViewApproach.addSubview(eddieStatsView)
            
            let eddieStatsView1 = EddieStatsView()
            eddieStatsView1.backgroundColor = UIColor.clear
            eddieStatsView1.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-52, height: 30)
            eddieStatsView1.lblTitle.text = "Eddie has some insights for you."
            eddieStatsView1.lblTitle.textColor = UIColor(rgb:0xFFC700)
            eddieStatsView1.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            holeProximityCardView.addSubview(eddieStatsView1)
        }
        else{
            lblApproachAccuracyAvg.isHidden = false
            lblHoleProximityAvg.isHidden = false
            lblAvgHoleProximityValue.isHidden = false
            lblGIRAvg.isHidden = false
            lblAvgGIRLikelinessValue.isHidden = false
        }
    }
    
    @objc func eddieProClicked(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        self.navigationController?.pushViewController(viewCtrl, animated: false)
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
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
    }
    
    func setupGirCircularChart(){
        var girArray = [Double]()
        var girMissArray = [Double]()
        var totalFairwayHit = 0.0
        var totalFairwayMiss = 0.0
        var girFairwayHit = 0.0
        var girFairwayMiss = 0.0
        for score in scores{
            if score.gir != nil {
                girArray.append(score.gir)
            }
            if score.girMiss != nil {
                girMissArray.append(score.girMiss)
            }
            if score.fairwayHit != nil {
                totalFairwayHit += score.fairwayHit
            }
            if score.fairwayMiss != nil {
                totalFairwayMiss += score.fairwayMiss
            }
            if score.girWithFairway != nil {
                girFairwayHit += score.girWithFairway
            }
            if score.girWoFairway != nil {
                girFairwayMiss += score.girWoFairway
            }
        }
        let sum = girArray.reduce(0, +)
        let totalSum = (sum + girMissArray.reduce(0, +))
        if(totalFairwayHit != 0){
            self.greensWithFairwayHitPercentage.text = "\(((girFairwayHit/totalFairwayHit)*100).rounded(toPlaces: 1))%"
        }else{
            self.greensWithFairwayHitPercentage.text = "0.0%"
        }
        if(totalFairwayMiss != 0){
            self.greensWithFairwayMissPercentage.text = "\(((girFairwayMiss/totalFairwayMiss)*100).rounded(toPlaces: 1))%"
        }else{
            self.greensWithFairwayMissPercentage.text = "0.0%"
        }
        let girPercantage = (sum / totalSum)*100
        if(totalSum != 0){
            girCircularChart.setProgress(value: CGFloat(girPercantage), animationDuration: 1.0)
        }
        
        if Constants.baselineDict != nil{
            debugPrint("baselineDict==",Constants.baselineDict)
            let publicScore  = PublicScore()
            let publicScoreStr = publicScore.getApproachGIR(p:girPercantage)
            lblAccuracyWithDriverAvg.isHidden = false
            lblAccuracyWithDriverAvg.attributedText = publicScoreStr
        }
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
    
    func setupGIRLikelinessLineChart(){
        var girArray = [Double]()
        var avgGIRArray = [Double]()
        let KeysArray = ["None","1-2","3-4","5-6","7-8","9-More"]
        for keys in KeysArray{
            groupDict[keys] = 0
        }
        var totalGir = [Double]()
        var gir = [Double]()
        for score in scores where (score.gir+score.girMiss) != 0{
            girArray.append(score.gir)
            gir.append(score.gir)
            totalGir.append(score.gir+score.girMiss)
            avgGIRArray.append(((score.gir/(score.gir+score.girMiss))*18).rounded())
        }
        
        for i in avgGIRArray{
            if(i<=0){
                updateValue(keys: "None")
            }
            else if(i>=1 && i<=2){
                updateValue(keys: "1-2")
            }
            else if(i>=3 && i<=4){
                updateValue(keys: "3-4")
            }
            else if(i>=5 && i<=6){
                updateValue(keys: "5-6")
            }
            else if(i>=7 && i<=8){
                updateValue(keys: "7-8")
            }
            else{
                updateValue(keys: "9-More")
            }
        }
        var dataArray = [Double]()
        for i in 0..<KeysArray.count{
            dataArray.append(((groupDict[KeysArray[i]]!)*100)/Double(avgGIRArray.count))
        }
        GIRLikelinessLineChart.setLineChartWithColor(dataPoints:KeysArray , values: dataArray, chartView: GIRLikelinessLineChart,color:UIColor.glfFlatBlue)
        
        if !gir.isEmpty{
            self.lblGIRAvg.text = "Average GIR Per Round"
            let totalHit = (gir.reduce(0, +))
            let totalFair = (totalGir.reduce(0, +))
            let msg = String(format:"%.01f ",((totalHit/totalFair)*18))
            self.lblAvgGIRLikelinessValue.text = " \(msg) of 18  "
            self.lblAvgGIRLikelinessValue.sizeToFit()
        }
        
    }
    
    func setupApprochAccuracyScatterChart(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        var maxValueOfLeftRightLongShort = 0.0
        var toLeftRightLeftShort = ""
        
        var noApproach = false
        for score in scores{
            if score.approach.count == 0{
                noApproach = true
                break
            }
        }
        
        if noApproach{
            let demoLabel = DemoLabel()
            demoLabel.frame = CGRect(x: 0, y: cardViewApproach.frame.height/2-15, width: cardViewApproach.frame.width, height: 30)
            cardViewApproach.addSubview(demoLabel)

            for score in Constants.classicScores{
                for data in score.approach{
                    for i in 0..<data.count{
                        if(clubFilter.count > 0){
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                            if(clubFilter.contains(data[i].club)){
                                if(data[i].green){
                                    hit += 1
                                    color.append(UIColor.glfWhite)
                                }else{
                                    color.append(UIColor.glfRosyPink)
                                    if(data[i].proximityY >= abs(data[i].proximityX)){
                                        long += 1
                                    }
                                    else if(data[i].proximityY <= -abs(data[i].proximityX)){
                                        short += 1
                                    }
                                    else if(data[i].proximityX >= abs(data[i].proximityY)){
                                        right += 1
                                    }
                                    else if(data[i].proximityX <= -abs(data[i].proximityY)){
                                        left += 1
                                    }
                                }
                                
                            }
                        }
                        else{
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                            
                            if(data[i].green) != nil && (data[i].green){
                                hit += 1
                                color.append(UIColor.glfWhite)
                            }else{
                                color.append(UIColor.glfRosyPink)
                                
                                if(data[i].proximityY >= abs(data[i].proximityX)){
                                    long += 1
                                }
                                else if(data[i].proximityY <= -abs(data[i].proximityX)){
                                    short += 1
                                }
                                else if(data[i].proximityX >= abs(data[i].proximityY)){
                                    right += 1
                                }
                                else if(data[i].proximityX <= -abs(data[i].proximityY)){
                                    left += 1
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        else{
            for score in scores{
                for data in score.approach{
                    for i in 0..<data.count{
                        if(clubFilter.count > 0){
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                            if(clubFilter.contains(data[i].club)){
                                if(data[i].green){
                                    hit += 1
                                    color.append(UIColor.glfWhite)
                                }else{
                                    color.append(UIColor.glfRosyPink)
                                    if(data[i].proximityY >= abs(data[i].proximityX)){
                                        long += 1
                                    }
                                    else if(data[i].proximityY <= -abs(data[i].proximityX)){
                                        short += 1
                                    }
                                    else if(data[i].proximityX >= abs(data[i].proximityY)){
                                        right += 1
                                    }
                                    else if(data[i].proximityX <= -abs(data[i].proximityY)){
                                        left += 1
                                    }
                                }
                                
                            }
                        }
                        else{
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                            
                            if(data[i].green) != nil && (data[i].green){
                                hit += 1
                                color.append(UIColor.glfWhite)
                            }else{
                                color.append(UIColor.glfRosyPink)
                                
                                if(data[i].proximityY >= abs(data[i].proximityX)){
                                    long += 1
                                }
                                else if(data[i].proximityY <= -abs(data[i].proximityX)){
                                    short += 1
                                }
                                else if(data[i].proximityX >= abs(data[i].proximityY)){
                                    right += 1
                                }
                                else if(data[i].proximityX <= -abs(data[i].proximityY)){
                                    left += 1
                                }
                                
                            }
                        }
                    }
                }
            }
        }

        
        approchAccuracyScatterChart.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: approchAccuracyScatterChart, color: color)
        approchAccuracyScatterChart.leftAxis.enabled = false
        approchAccuracyScatterChart.leftAxis.axisMaximum = 90
        approchAccuracyScatterChart.leftAxis.axisMinimum = -90
        approchAccuracyScatterChart.xAxis.enabled = false
        approchAccuracyScatterChart.xAxis.axisMaximum = 90
        approchAccuracyScatterChart.xAxis.axisMinimum = -90
        
        
        let sumOfLSRL = long+short+right+left+hit
        if(sumOfLSRL != 0){
            lblLong.text = "Long \(100*long/sumOfLSRL)%"
            lblShort.text = "Short \(100*short/sumOfLSRL)%"
            lblRight.text = "Right \(100*right/sumOfLSRL)%"
            lblLeft.text = "Left \(100*left/sumOfLSRL)%"
            lblHit.text = "Hit \(100*hit/sumOfLSRL)%"
            
            if(maxValueOfLeftRightLongShort<Double(100*right/sumOfLSRL)){
                maxValueOfLeftRightLongShort = Double(100*right/sumOfLSRL)
                toLeftRightLeftShort = "to the Right";
            }
            if(maxValueOfLeftRightLongShort<Double(100*left/sumOfLSRL)){
                maxValueOfLeftRightLongShort = Double(100*left/sumOfLSRL);
                toLeftRightLeftShort = "to the Left";
            }
            if(maxValueOfLeftRightLongShort<Double(100*long/sumOfLSRL)){
                maxValueOfLeftRightLongShort = Double(100*long/sumOfLSRL);
                toLeftRightLeftShort = "Long";
            }
            if(maxValueOfLeftRightLongShort<Double(100*short/sumOfLSRL)){
                maxValueOfLeftRightLongShort = Double(100*short/sumOfLSRL);
                toLeftRightLeftShort = "Short";
            }
            lblApproachAccuracyAvg.text = "You miss " + String(format:"%.01f",maxValueOfLeftRightLongShort) + "% of the Greens " + toLeftRightLeftShort
        }else{
            
        }
    }
    func setupGIRTrendBarChart(){
        var girArray = [Double]()
        var date = [String]()
        var girTotal = [Double]()
        var girAvg = [Double]()
        for score in scores where (score.gir+score.girMiss) != 0{
            if(score.gir != nil){
                girArray.append(score.gir)
                date.append(score.date)
                girTotal.append(score.gir+score.girMiss)
                girAvg.append((score.gir/(score.gir+score.girMiss))*100)
            }
        }
        
        GIRTrendBarChart.setStackedBarChart(dataPoints: date, value1: girTotal, value2: girArray, chartView: GIRTrendBarChart, color: [UIColor.glfBluegreen.withAlphaComponent(0.50),UIColor.glfBluegreen], barWidth: 0.2)
        GIRTrendBarChart.leftAxis.axisMinimum = 0.0
        GIRTrendBarChart.leftAxis.axisMaximum = girTotal.max() ?? 1+1
        GIRTrendBarChart.leftAxis.labelCount = 5
        if girArray.count > 2 && Constants.baselineDict != nil{
            var attributedText = NSMutableAttributedString()
            let publicScoring = PublicScore()
            let data = publicScoring.getGIRTrendsData(dataValues:girAvg)
            self.lblGIRTrendsAvg.isHidden = false
            if let text = data.value(forKey: "text") as? NSAttributedString {
                attributedText.append(text)
            }
            if (attributedText.length > 11){
                self.lblGIRTrendsAvg.attributedText = attributedText
            }else{
                attributedText = NSMutableAttributedString()
                self.lblAvgGIRTrendsValue.isHidden = false
                let value = data.value(forKey: "percentGIRTrend") as! Double
                let string = data.value(forKey: "text") as! NSAttributedString
                let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                attributedText.append(NSAttributedString(string: "Your Accuracy has ", attributes: dict1))
                attributedText.append(string)
                if let color = data.value(forKey: "color") as? UIColor{
                    self.lblAvgGIRTrendsValue.textColor = color
                    self.lblAvgGIRTrendsValue.layer.borderColor = color.cgColor
                    let msg = String(format:"%.01f ",value)
                    self.lblAvgGIRTrendsValue.text = " \(msg)%  "
                    self.lblAvgGIRTrendsValue.sizeToFit()
                }
                self.lblGIRTrendsAvg.attributedText = attributedText
            }
        }
    }
    func setupHoleProximityScatterChartView(){
        var date = [String]()
        var distance = [Double]()
        var dataPoints = [Double]()
        
        var noApproach = false
        for score in scores{
            if score.approach.count == 0{
                noApproach = true
                break
            }
        }
        if noApproach{
            let demoLabel = DemoLabel()
            demoLabel.frame = CGRect(x: 0, y: holeProximityCardView.frame.height/2-15, width: holeProximityCardView.frame.width, height: 30)
            holeProximityCardView.addSubview(demoLabel)

            for score in Constants.classicScores{
                var proximityXPoints = [Double]()
                var proximityYPoints = [Double]()
                for data in score.approach{
                    for i in 0..<data.count{
                        if(clubFilter.count > 0){
                            if(clubFilter.contains(data[i].club)){
                                proximityXPoints.append(data[i].proximityX)
                                proximityYPoints.append(data[i].proximityY)
                            }
                        }
                        else{
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                        }
                    }
                    if(Constants.distanceFilter == 1){
                        for i in 0..<proximityXPoints.count{
                            distance.append(sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i]))
                        }
                    }else{
                        for i in 0..<proximityXPoints.count{
                            distance.append(sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i])*3)
                        }
                    }
                    date.append(score.date)
                    dataPoints.append(Double(proximityYPoints.count))
                }
            }
        }
        else{
            for score in scores{
                var proximityXPoints = [Double]()
                var proximityYPoints = [Double]()
                for data in score.approach{
                    for i in 0..<data.count{
                        if(clubFilter.count > 0){
                            if(clubFilter.contains(data[i].club)){
                                proximityXPoints.append(data[i].proximityX)
                                proximityYPoints.append(data[i].proximityY)
                            }
                        }
                        else{
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                        }
                    }
                    if(Constants.distanceFilter == 1){
                        for i in 0..<proximityXPoints.count{
                            distance.append(sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i]))
                        }
                    }else{
                        for i in 0..<proximityXPoints.count{
                            distance.append(sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i])*3)
                        }
                    }
                    
                    date.append(score.date)
                    dataPoints.append(Double(proximityYPoints.count))
                }
            }
        }

        if !dataPoints.isEmpty{
            holeProximityScatterWithLineView.setScatterChartWithLine(valueX: dataPoints, valueY: distance, xAxisValue: date, chartView: holeProximityScatterWithLineView, color: UIColor.glfGreenBlue)
            holeProximityScatterWithLineView.leftAxis.labelCount = 3
            let sum = distance.reduce(0, +)
            self.lblAvgHoleProximityValue.text = "\(Int(sum/Double(distance.count))) \(Constants.distanceFilter == 1 ? "m" : "yd")"
            self.lblHoleProximityAvg.text = "Average Proximity to Hole after Approach"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Approach".localized())
    }
    func updateValue(keys:String){
        for (key,value) in groupDict{
            if(keys==key){
                var x = value
                x += 1
                groupDict.updateValue(x, forKey: keys)
            }
        }
    }
    
}
