//
//  ChippingViewController.swift
//  Golfication
//
//  Created by IndiRenters on 10/26/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import ActionButton
import FirebaseAnalytics

class ChippingViewController: UIViewController, IndicatorInfoProvider, CustomProModeDelegate {
    
    @IBOutlet weak var chippingStackView: UIStackView!
    @IBOutlet weak var lblChippingAccuracyAvg: UILabel!
    @IBOutlet weak var lblChipUpNDownAvg: UILabel!
    @IBOutlet weak var lblChippingProximityAvg: UILabel!
    @IBOutlet weak var lblSandSavesAvg: UILabel!
    @IBOutlet weak var lblSandAccuracyAvg: UILabel!
    @IBOutlet weak var lblSandProximityAvg: UILabel!
    
    @IBOutlet weak var lblLong: UILocalizedLabel!
    @IBOutlet weak var lblShort: UILocalizedLabel!
    @IBOutlet weak var lblRight: UILocalizedLabel!
    @IBOutlet weak var lblLeft: UILocalizedLabel!
    @IBOutlet weak var lblHit: UILabel!
    
    @IBOutlet weak var lblShortSnd: UILocalizedLabel!
    @IBOutlet weak var lblRightSnd: UILocalizedLabel!
    @IBOutlet weak var lblLeftSnd: UILocalizedLabel!
    @IBOutlet weak var lblHitSnd: UILabel!
    @IBOutlet weak var lblLongSnd: UILocalizedLabel!
    
    @IBOutlet weak var cardViewChippingAccuracy: CardView!
    @IBOutlet weak var cardViewChippingProximity: CardView!
    @IBOutlet weak var cardViewChippingSandAccuracy: CardView!
    @IBOutlet weak var cardViewChippingSandProximity: CardView!
    
    @IBOutlet weak var lblAvgChippAccValue: UILabel!
//    @IBOutlet weak var lblAvgChiUNDValue: UILabel!
    @IBOutlet weak var lblAvgChippingProximityValue: UILabel!
//    @IBOutlet weak var lblAvgSandSavesValue: UILabel!
    @IBOutlet weak var lblAvgSandAccuracyValue: UILabel!
    @IBOutlet weak var lblAvgSandProximityValue: UILabel!
    
    @IBOutlet weak var chippingAccuracyScatterView: ScatterChartView!
    @IBOutlet weak var chipUpDownBarChartView: BarChartView!
    @IBOutlet weak var chippingProximityScatterLineView: CombinedChartView!
    @IBOutlet weak var sandSaveStackedBarView: BarChartView!
    @IBOutlet weak var sandAccuracyScatterChart: ScatterChartView!
    @IBOutlet weak var sandProximityScatterWithLine: CombinedChartView!
    
    @IBOutlet weak var lblProChipAccu: UILabel!
    @IBOutlet weak var lblProChipProx: UILabel!
    @IBOutlet weak var lblProSandAccu: UILabel!
    @IBOutlet weak var lblProSandProx: UILabel!
    
    var isDemoUser :Bool!
    var scores = [Scores]()
    var clubFilter = [String]()
    var cardViewMArray = NSMutableArray()

    var checkCaddie = Bool()
    var cardViewInfoArray = [(title:String,value:String)]()

    @IBOutlet weak var sandAccuracyStackView: UIStackView!
    @IBOutlet weak var chippingAccuracyStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("my_scores_chipping", parameters: [:])
        if(Constants.distanceFilter == 1){

        var meterString = ["15m","10m","5m","5m","10m","15m"]
        var i = 0
        for view in self.chippingAccuracyStackView.arrangedSubviews{
            (view as! UILabel).text = meterString[i]
            i += 1
        }
        i = 0
        for view in self.sandAccuracyStackView.arrangedSubviews{
            (view as! UILabel).text = meterString[i]
            i += 1
        }
        }
        self.setupUI()
        self.setupchippingAccuracyScatterView()
        self.setupChippingProximityScatterViewWithChipUpDown()
        self.setupSandAccuracyScatterChart()
        self.setupSandProximityScatterViewWithSandUpDown()
    }
    func setupUI(){
        lblProChipAccu.layer.cornerRadius = 3.0
        lblProChipAccu.layer.masksToBounds = true
        lblProChipProx.layer.cornerRadius = 3.0
        lblProChipProx.layer.masksToBounds = true
        lblProSandAccu.layer.cornerRadius = 3.0
        lblProSandAccu.layer.masksToBounds = true
        lblProSandProx.layer.cornerRadius = 3.0
        lblProSandProx.layer.masksToBounds = true
        
        lblChippingAccuracyAvg.isHidden = true
        lblChipUpNDownAvg.isHidden = true
        lblChippingProximityAvg.isHidden = true
        lblSandSavesAvg.isHidden = true
        lblSandAccuracyAvg.isHidden = true
        lblSandProximityAvg.isHidden = true
        if(isDemoUser){
            for v in self.chippingStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)
                }
            }
        }
        else{
            if !Constants.isProMode {
                //cardViewChippingAccuracy.makeBlurView(targetView: cardViewChippingAccuracy)
                self.setProLockedUI(targetView: cardViewChippingAccuracy, title: "Chipping Accuracy".localized())
                
                //cardViewChippingProximity.makeBlurView(targetView: cardViewChippingProximity)
                self.setProLockedUI(targetView: cardViewChippingProximity, title: "Chip Proximity".localized())
                
                //cardViewChippingSandAccuracy.makeBlurView(targetView: cardViewChippingSandAccuracy)
                self.setProLockedUI(targetView: cardViewChippingSandAccuracy, title: "Sand Accuracy".localized())
                
                //cardViewChippingSandProximity.makeBlurView(targetView: cardViewChippingSandProximity)
                self.setProLockedUI(targetView: cardViewChippingSandProximity, title: "Sand Proximity".localized())
                
                lblProChipAccu.isHidden = true
                lblProChipProx.isHidden = true
                lblProSandAccu.isHidden = true
                lblProSandProx.isHidden = true
            }
            else{
                lblProChipAccu.backgroundColor = UIColor.clear
                lblProChipAccu.layer.borderWidth = 1.0
                lblProChipAccu.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
                lblProChipAccu.textColor = UIColor(rgb: 0xFFC700)
                
                lblProChipAccu.isHidden = false
                lblProChipProx.isHidden = false
                lblProSandAccu.isHidden = false
                lblProSandProx.isHidden = false
            }
            
            let originalImage1 = #imageLiteral(resourceName: "share")
            let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.chippingStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Chipping Accuracy",value:StatsIntoConstants.chippingAccuracy))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Chip: Up and Down",value:StatsIntoConstants.chipUpDown))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Chip Proximity",value:StatsIntoConstants.chipProximity))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Sand: Up and Down",value:StatsIntoConstants.sandUpDown))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"Sand Accuracy",value:StatsIntoConstants.sandAccuracy))
                        break
                    case 5:
                        self.cardViewInfoArray.append((title:"Sand Proximity",value:StatsIntoConstants.sandProximity))
                        break
                    default: break
                    }
                    if (!Constants.isProMode && !((v == cardViewChippingAccuracy) || (v == cardViewChippingProximity) || (v == cardViewChippingSandAccuracy) || (v == cardViewChippingSandProximity))){
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
                        if (v == cardViewChippingAccuracy){
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
                        if (v == cardViewChippingAccuracy){
                            statsInfoButton.tintColor = UIColor.white
                        }
                        statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                        v.addSubview(statsInfoButton)
                    }
                    viewTag = viewTag+1
                }
            }
        }
        lblAvgChippAccValue.isHidden = true
//        lblAvgChiUNDValue.isHidden = true
        lblAvgChippingProximityValue.isHidden = true
//        lblAvgSandSavesValue.isHidden = true
        lblAvgSandAccuracyValue.isHidden = true
        lblAvgSandProximityValue.isHidden = true
        
        chippingAccuracyScatterView.isUserInteractionEnabled = false
        chipUpDownBarChartView.isUserInteractionEnabled = false
        chippingProximityScatterLineView.isUserInteractionEnabled = false
        sandSaveStackedBarView.isUserInteractionEnabled = false
        sandAccuracyScatterChart.isUserInteractionEnabled = false
        sandProximityScatterWithLine.isUserInteractionEnabled = false
        lblLongSnd.textColor = UIColor.glfBlack50
        lblShortSnd.textColor = UIColor.glfBlack50
        lblRightSnd.textColor = UIColor.glfBlack50
        lblLeftSnd.textColor = UIColor.glfBlack50
        lblHitSnd.textColor = UIColor.glfBluegreen
        cardViewChippingAccuracy.backgroundColor = UIColor.glfBluegreen
        self.lblAvgChippAccValue.setCorner(color: UIColor.white.cgColor)
//        self.lblAvgChiUNDValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgChippingProximityValue.setCorner(color: UIColor.glfBlack50.cgColor)
//        self.lblAvgSandSavesValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgSandAccuracyValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgSandProximityValue.setCorner(color: UIColor.glfBlack50.cgColor)
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
    
    func setupSandProximityScatterViewWithSandUpDown(){
        var dataPoints = [Double]()
        var dataValues = [Double]()
        var date = [String]()
        var sandAttempt = [Double]()
        var sandAchieved = [Double]()
        for score in scores{
            var proximityXPoints = [Double]()
            var proximityYPoints = [Double]()
            for data in score.sand{
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
            }
            dataPoints.append(Double(proximityYPoints.count))
            if(Constants.distanceFilter == 1){
                for i in 0..<proximityXPoints.count{
                    dataValues.append((sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i])))
                }
            }else{
                for i in 0..<proximityXPoints.count{
                    dataValues.append((sqrt(proximityXPoints[i]*proximityXPoints[i] + proximityYPoints[i]*proximityYPoints[i])*3))
                }
            }
            date.append(score.date)
            sandAttempt.append(Double(score.sandUnD.attempts))
            sandAchieved.append(Double(score.sandUnD.achieved))
        }
        print(sandAttempt,sandAchieved)
        var newDataPoints = [Double]()
        var newDate = [String]()
        for i in 0..<dataPoints.count{
            if(dataPoints[i] != 0){
                newDataPoints.append(dataPoints[i])
                newDate.append(date[i])
            }
        }
        sandProximityScatterWithLine.setScatterChartWithLine(valueX: newDataPoints, valueY: dataValues, xAxisValue: newDate, chartView: sandProximityScatterWithLine, color: UIColor.glfGreenBlue)
        if !dataValues.isEmpty{
            self.lblSandProximityAvg.isHidden = false
            self.lblAvgSandProximityValue.isHidden = false
            let sum = dataValues.reduce(0,+)
            self.lblSandProximityAvg.text = "Average Proximity to Hole after Bunker-Shot"
            let msg = String(format:"%.01f ",(sum/Double(dataValues.count)))
            self.lblAvgSandProximityValue.text = "\(msg) \(Constants.distanceFilter == 1 ? "m" : "ft")"
        }
        var newSandAttemp = [Double]()
        var newSandAchieved = [Double]()
        var newDateForStacked = [String]()
        for i in 0..<date.count{
            if (sandAttempt[i] != 0 || sandAchieved[i] != 0){
                newDateForStacked.append(date[i])
                newSandAttemp.append(sandAttempt[i])
                newSandAchieved.append(sandAchieved[i])
            }
        }
        sandSaveStackedBarView.setStackedBarChart(dataPoints: newDateForStacked, value1: newSandAttemp , value2: newSandAchieved, chartView:sandSaveStackedBarView,color: [UIColor.glfBluegreen.withAlphaComponent(0.50),UIColor.glfBluegreen], barWidth:0.2)
        sandSaveStackedBarView.leftAxis.axisMinimum = 0.0
        sandSaveStackedBarView.leftAxis.axisMaximum = (newSandAttemp.max() ?? 2.0) + 1.0
        sandSaveStackedBarView.leftAxis.labelCount = 5
        if Constants.baselineDict != nil{
            debugPrint("baselineDict==",Constants.baselineDict)
            let publicScore  = PublicScore()
            let totalAttempt = newSandAttemp.reduce(0,+)
            let totalAchieved = newSandAchieved.reduce(0,+)
            let publicScoreStr = publicScore.getSandUND(p:(totalAchieved*100)/totalAttempt)
            self.lblSandSavesAvg.isHidden = false
            if publicScoreStr.length > 20{
                self.lblSandSavesAvg.attributedText = publicScoreStr
            }else{
                let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                let attributedText = NSMutableAttributedString()
                attributedText.append(NSAttributedString(string: "You make ", attributes: dict1))
                attributedText.append(publicScoreStr)
                attributedText.append(NSAttributedString(string: " than other golfers like you", attributes: dict1))
                self.lblSandSavesAvg.attributedText = attributedText
            }
        }
    }
    
    func setupSandAccuracyScatterChart(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        for score in scores{
            for data in score.sand{
                for i in 0..<data.count{
                    if(clubFilter.count > 0){
                        if(clubFilter.contains(data[i].club)){
                            if(Constants.distanceFilter == 1){
                                proximityXPoints.append(data[i].proximityX)
                                proximityYPoints.append(data[i].proximityY)
                            }else{
                                proximityXPoints.append(data[i].proximityX * 3)
                                proximityYPoints.append(data[i].proximityY * 3)
                            }
                            if(data[i].green){
                                hit += 1
                                color.append(UIColor.glfGreenBlue)
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
                        if(Constants.distanceFilter == 1){
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                        }else{
                            proximityXPoints.append(data[i].proximityX * 3)
                            proximityYPoints.append(data[i].proximityY * 3)
                            
                        }
                        if(data[i].green){
                            hit += 1
                            color.append(UIColor.glfGreenBlue)
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
        sandAccuracyScatterChart.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: sandAccuracyScatterChart, color: color)
        
        sandAccuracyScatterChart.leftAxis.enabled = false
        sandAccuracyScatterChart.xAxis.enabled = false
        sandAccuracyScatterChart.leftAxis.axisMaximum = 90
        sandAccuracyScatterChart.leftAxis.axisMinimum = -90
        sandAccuracyScatterChart.xAxis.axisMaximum = 150
        sandAccuracyScatterChart.xAxis.axisMinimum = -150
        
        var maxValueOfLeftRightLongShort = 0.0
        var toLeftRightLeftShort = ""
        let sumOfLSRL = long+short+right+left+hit
        if(sumOfLSRL != 0){
            lblLongSnd.text = "Long \(100*long/sumOfLSRL)%"
            lblShortSnd.text = "Short \(100*short/sumOfLSRL)%"
            lblRightSnd.text = "Right \(100*right/sumOfLSRL)%"
            lblLeftSnd.text = "Left \(100*left/sumOfLSRL)%"
            lblHitSnd.text = "Hit \(100*hit/sumOfLSRL)%"
            
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
            if (maxValueOfLeftRightLongShort != 0.0){
                self.lblSandAccuracyAvg.isHidden = false
                self.lblSandAccuracyAvg.text = "You miss " + String(format:"%.01f",maxValueOfLeftRightLongShort) + "% of the Greens " + toLeftRightLeftShort
            }

        }

    }
    
    func setupChippingProximityScatterViewWithChipUpDown(){
        var dataPoints = [Double]()
        var dataValues = [Double]()
        var chipAttempt = [Double]()
        var chipAchieved = [Double]()
        var date = [String]()

        for score in scores{
            var chippingProximityX = [Double]()
            var chippingProximityY = [Double]()
            for data in score.chipping{
                for i in 0..<data.count{
                    if(clubFilter.count > 0){
                        if(clubFilter.contains(data[i].club)){
                            chippingProximityX.append(data[i].proximityX)
                            chippingProximityY.append(data[i].proximityY)
                        }
                    }
                    else{
                            chippingProximityX.append(data[i].proximityX)
                            chippingProximityY.append(data[i].proximityY)
                        }
                    }
            }
            for i in 0..<chippingProximityX.count{
                if(Constants.distanceFilter == 1){
                    dataValues.append(sqrt(chippingProximityX[i]*chippingProximityX[i] + chippingProximityY[i]*chippingProximityY[i]))
                }else{
                    dataValues.append(sqrt(chippingProximityX[i]*chippingProximityX[i] + chippingProximityY[i]*chippingProximityY[i]) * 3)
                }

            }
            dataPoints.append(Double(chippingProximityX.count))
            date.append(score.date)
            chipAttempt.append(score.chipUnD.attempts)
            chipAchieved.append(score.chipUnD.achieved)
        }
        var newDataPoints = [Double]()
        var newDate = [String]()
        for i in 0..<dataPoints.count{
            if(dataPoints[i] != 0){
                newDataPoints.append(dataPoints[i])
                newDate.append(date[i])
            }
        }
        
        chippingProximityScatterLineView.setScatterChartWithLine(valueX: newDataPoints, valueY: dataValues, xAxisValue: newDate, chartView: chippingProximityScatterLineView,color: UIColor.glfBluegreen)
        let formatter = NumberFormatter()
        formatter.positiveSuffix = " ft"
        if(Constants.distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        if !dataValues.isEmpty{
            self.lblChippingProximityAvg.isHidden = false
            self.lblAvgChippingProximityValue.isHidden = false
            let sum = dataValues.reduce(0, +)
            let msg = String(format:"%.01f ",(sum/Double(dataValues.count)))
            self.lblAvgChippingProximityValue.text = "\(msg) \(Constants.distanceFilter == 1 ? "m" : "ft")"
            self.lblChippingProximityAvg.text = "Average Proximity to Hole after Chipping"
        }
        var newChipAttemp = [Double]()
        var newChipAchieved = [Double]()
        var newDateForStacked = [String]()
        for i in 0..<date.count{
            if (chipAttempt[i] != 0 || chipAchieved[i] != 0){
                newDateForStacked.append(date[i])
                newChipAttemp.append(chipAttempt[i])
                newChipAchieved.append(chipAchieved[i])
            }
        }
        chippingProximityScatterLineView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chipUpDownBarChartView.setStackedBarChart(dataPoints: newDateForStacked, value1: newChipAttemp, value2: newChipAchieved, chartView:chipUpDownBarChartView,color:[UIColor.glfBluegreen.withAlphaComponent(0.50),UIColor.glfBluegreen], barWidth:0.2)
        chipUpDownBarChartView.leftAxis.axisMinimum = 0.0
        if let newMax = newChipAttemp.max(){
            chipUpDownBarChartView.leftAxis.axisMaximum = newMax+1.0
        }else{
            chipUpDownBarChartView.leftAxis.axisMaximum = 3.0
        }
        
        chipUpDownBarChartView.leftAxis.labelCount = 5
        if Constants.baselineDict != nil{
            debugPrint("baselineDict==",Constants.baselineDict)
            let publicScore  = PublicScore()
            let totalAttempt = chipAttempt.reduce(0,+)
            let totalAchieved = chipAchieved.reduce(0,+)
            let publicScoreStr = publicScore.getChipUND(p:(totalAchieved*100)/totalAttempt)
            
            self.lblChipUpNDownAvg.isHidden = false
            if publicScoreStr.length > 20{
                self.lblChipUpNDownAvg.attributedText = publicScoreStr
            }else{
                let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                let attributedText = NSMutableAttributedString()
                attributedText.append(NSAttributedString(string: "You make ", attributes: dict1))
                attributedText.append(publicScoreStr)
                attributedText.append(NSAttributedString(string: " than other golfers like you", attributes: dict1))
                self.lblChipUpNDownAvg.attributedText = attributedText
            }
        }
    }
    
    
    func setupchippingAccuracyScatterView(){
        var proximityXPoints = [Double]()
        var proximityYPoints = [Double]()
        var long = Int()
        var short = Int()
        var right = Int()
        var left = Int()
        var hit = Int()
        var color = [UIColor]()
        for score in scores{
            for data in score.chipping{
                for i in 0..<data.count{
                    if(clubFilter.count > 0){
                        if(clubFilter.contains(data[i].club)){
                            if(Constants.distanceFilter == 1){
                                proximityXPoints.append(data[i].proximityX)
                                proximityYPoints.append(data[i].proximityY)
                            }else{
                                proximityXPoints.append(data[i].proximityX * 3)
                                proximityYPoints.append(data[i].proximityY * 3)
                            }
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
                        if(Constants.distanceFilter == 1){
                            proximityXPoints.append(data[i].proximityX)
                            proximityYPoints.append(data[i].proximityY)
                        }else{
                            proximityXPoints.append(data[i].proximityX * 3)
                            proximityYPoints.append(data[i].proximityY * 3)
                        }
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
        
        chippingAccuracyScatterView.setScatterChart(valueX: proximityXPoints, valueY: proximityYPoints, chartView: chippingAccuracyScatterView, color: color)
        chippingAccuracyScatterView.leftAxis.enabled = false
        chippingAccuracyScatterView.xAxis.enabled = false
        chippingAccuracyScatterView.leftAxis.axisMaximum = 90
        chippingAccuracyScatterView.leftAxis.axisMinimum = -90
        chippingAccuracyScatterView.xAxis.axisMaximum = 90
        chippingAccuracyScatterView.xAxis.axisMinimum = -90
        
        var maxValueOfLeftRightLongShort = 0.0
        var toLeftRightLeftShort = ""
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
            if maxValueOfLeftRightLongShort != 0{
                self.lblChippingAccuracyAvg.isHidden = false
                self.lblChippingAccuracyAvg.text = "You miss " + String(format:"%.01f",maxValueOfLeftRightLongShort) + "% of the Greens " + toLeftRightLeftShort
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Chipping".localized())
    }
    
}
