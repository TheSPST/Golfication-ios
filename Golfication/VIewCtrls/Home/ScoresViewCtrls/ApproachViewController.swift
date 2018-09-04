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
    @IBOutlet weak var lblFairwayHitAvg: UILabel!
    
    @IBOutlet weak var approachAccuracyStackView: UIStackView!
    @IBOutlet weak var lblShort: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblHit: UILabel!
    @IBOutlet weak var lblLong: UILabel!
    @IBOutlet weak var lblProApproach: UILabel!
    @IBOutlet weak var lblProProximity: UILabel!

    @IBOutlet weak var cardViewApproach: CardView!
    @IBOutlet weak var lblAvgApproachAccuracyValue: UILabel!
    @IBOutlet weak var lblAvgAccuracyWithGIRValue: UILabel!
    @IBOutlet weak var lblAvgHoleProximityValue: UILabel!
    @IBOutlet weak var lblAvgGIRTrendsValue: UILabel!
    @IBOutlet weak var lblAvgGIRLikelinessValue: UILabel!
    @IBOutlet weak var greensWithFairwayMissPercentage: UILabel!
    @IBOutlet weak var greensWithFairwayHitPercentage: UILabel!
    @IBOutlet weak var approchAccuracyScatterChart: ScatterChartView!
    @IBOutlet weak var holeProximityScatterWithLineView: CombinedChartView!
    @IBOutlet weak var girCircularChart: UICircularProgressRingView!
    @IBOutlet weak var GIRTrendBarChart: CombinedChartView!
    @IBOutlet weak var GIRLikelinessLineChart: LineChartView!
    @IBOutlet weak var holeProximityCardView: CardView!
    
    var scores = [Scores]()
    var groupDict = [String:Double]()
    var clubFilter = [String]()
    var isDemoUser :Bool!
    var cardViewMArray = NSMutableArray()

    var checkCaddie = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("my_scores_approach", parameters: [:])
        if(distanceFilter == 1){

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
        lblFairwayHitAvg.isHidden = true
        lblAvgApproachAccuracyValue.isHidden = true
        lblAvgAccuracyWithGIRValue.isHidden = true
        lblAvgHoleProximityValue.isHidden = true
        lblAvgGIRTrendsValue.isHidden = true
        lblAvgGIRLikelinessValue.isHidden = true
        
        if(isDemoUser){
            for v in self.approachStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)
                }
            }
        }else{
            if !isProMode {
                //cardViewApproach.makeBlurView(targetView: cardViewApproach)
                self.setProLockedUI(targetView: cardViewApproach, title: "Approach Accuracy")
                
                //holeProximityCardView.makeBlurView(targetView: holeProximityCardView)
                self.setProLockedUI(targetView: holeProximityCardView, title: "Hole Proximity")
                
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
            
            var viewTag = 0
            for v in self.approachStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    if (!isProMode && !((v == cardViewApproach) || (v == holeProximityCardView))){
                        let shareStatsButton = ShareStatsButton()
                        shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                        shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                        shareStatsButton.tintColor = UIColor.glfFlatBlue
                        shareStatsButton.tag = viewTag
                        shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                        v.addSubview(shareStatsButton)
                    }
                    else if isProMode{
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
        self.lblAvgApproachAccuracyValue.setCorner(color: UIColor.white.cgColor)
        self.lblAvgAccuracyWithGIRValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgHoleProximityValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgGIRTrendsValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgGIRLikelinessValue.setCorner(color: UIColor.glfBlack50.cgColor)
        
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
        self.navigationController?.push(viewController: viewCtrl, transitionType: kCATransitionFromTop, duration: 0.05)
        
        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        }
    }
    
    func setupGIRLikelinessLineChart(){
        var fairwayArray = [Double]()
        let KeysArray = ["None","1-2","3-4","5-6","7-8","9-More"]
        for keys in KeysArray{
            groupDict[keys] = 0
        }
        for score in scores{
            if score.gir != nil{
                if(score.type == "9 hole"){
                    fairwayArray.append(2 * score.gir)
                }
                else{
                    fairwayArray.append(score.gir)
                }
            }
        }
        
        for i in fairwayArray{
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
            //            print(i,groupDict)
            dataArray.append(((groupDict[KeysArray[i]]!)*100)/Double(fairwayArray.count))
        }
        GIRLikelinessLineChart.setLineChartWithColor(dataPoints:KeysArray , values: dataArray, chartView: GIRLikelinessLineChart,color:UIColor.glfFlatBlue)
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
        }else{
            
        }

        
    }
    func setupGIRTrendBarChart(){
        var girArray = [Double]()
        var date = [String]()
        var legend = [String]()
        for score in scores {
            if(score.gir != nil){
                girArray.append(score.gir)
                date.append(score.date)
                legend.append(score.type)
            }
        }
        GIRTrendBarChart.setBarChartWithLines(dataPoints: date, values: girArray,legend:legend, chartView: GIRTrendBarChart, color: UIColor.glfSeafoamBlue, barWidth: 0.2)
        
    }
    func setupHoleProximityScatterChartView(){
        var date = [String]()
        var distance = [Double]()
        var dataPoints = [Double]()
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
                
                for i in 0..<proximityXPoints.count{
                    distance.append(sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i]))
                }
                date.append(score.date)
                dataPoints.append(Double(proximityYPoints.count))
            }
        }
        
        holeProximityScatterWithLineView.setScatterChartWithLine(valueX: dataPoints, valueY: distance, xAxisValue: date, chartView: holeProximityScatterWithLineView, color: UIColor.glfGreenBlue)
        holeProximityScatterWithLineView.leftAxis.labelCount = 3
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Approach")
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
