//
//  OTTViewController.swift
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

class OTTViewController: UIViewController, IndicatorInfoProvider, CustomProModeDelegate {
    
    @IBOutlet weak var ottStackView: UIStackView!
    @IBOutlet weak var lblSpreadOffAvg: UILabel!
    @IBOutlet weak var lblFairwayHitAvg: UILabel!
    @IBOutlet weak var lblFairwaysLiklinessAvg: UILabel!
    @IBOutlet weak var lblDriveDistanceAvg: UILabel!
    @IBOutlet weak var lblAccuracyWithDriver: UILabel!
    
    @IBOutlet weak var cardViewSpreadOffTee: CardView!
    @IBOutlet weak var cardViewDistanceOffTee: CardView!
    
    @IBOutlet weak var lblRight: UILabel!
    @IBOutlet weak var lblCenter: UILabel!
    @IBOutlet weak var lblLeft: UILabel!
    
    @IBOutlet weak var lblAvgSpreadOffTheTeeValue: UILabel!
//    @IBOutlet weak var lblAvgDrivingAccuracyValue: UILabel!
    @IBOutlet weak var lblAvgDriveDistanceValue: UILabel!
    @IBOutlet weak var lblAvgFairwaysHitTrendValue: UILabel!
    @IBOutlet weak var lblAvgFairwayHitValue: UILabel!
    @IBOutlet weak var scattredSpreadOfTheTeeChart: ScatterChartView!
    @IBOutlet weak var drivingAccuracyPieChart: UIView!
    @IBOutlet weak var FairwaysLiklinessLineChart: LineChartView!
    @IBOutlet weak var driveDistanceScatterChartView: CombinedChartView!
    @IBOutlet weak var barChartFairwaysHitTrend: BarChartView!
    @IBOutlet weak var lblProSpreadOffTee: UILabel!
    @IBOutlet weak var lblProDistanceOffTee: UILabel!

    let view1 = customPieViewLeft()
    let view2 = customPieViewCenter()
    let view3 = customPieViewRight()
    let lblFairwayLeft = UILabel()
    let lblFairwayRight = UILabel()
    let lblFairwayHit = UILabel()
    let leftImg = UIImageView(image: #imageLiteral(resourceName: "left"))
    let rightImg = UIImageView(image: #imageLiteral(resourceName: "right"))
    let hitImg = UIImageView(image: #imageLiteral(resourceName: "path15"))
    var isDemoUser :Bool!
    var fairway = [(hit:Int,left:Int,right:Int)]()
    var scores = [Scores]()
    var holesInAllRounds = [Hole]()
    var holesInAllRoundsClassic = [Hole]()

    var groupDict = [String:Double]()
    var clubFilter = [String]()
    
    var cardViewMArray = NSMutableArray()
    
    var checkCaddie = Bool()
    var cardViewInfoArray = [(title:String,value:String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("my_scores_ott", parameters: [:])

        self.setupUI()
        self.setData()
        self.setSpreadOffTheTeaGraph()
        self.setDrivingAccuracyChart()
        self.setDriveDistanceScatterChartView()
        self.setFairwayHitTrends()
        self.setFairwayLiklinessChart()
    }
    
    func setupUI(){
        
        scattredSpreadOfTheTeeChart.isUserInteractionEnabled = false
        drivingAccuracyPieChart.isUserInteractionEnabled = false
        FairwaysLiklinessLineChart.isUserInteractionEnabled = false
        driveDistanceScatterChartView.isUserInteractionEnabled = false
        barChartFairwaysHitTrend.isUserInteractionEnabled = false
        
        lblProSpreadOffTee.layer.cornerRadius = 3.0
        lblProDistanceOffTee.layer.cornerRadius = 3.0
        lblProSpreadOffTee.layer.masksToBounds = true
        lblProDistanceOffTee.layer.masksToBounds = true

//        lblSpreadOffAvg.isHidden = false
        lblFairwayHitAvg.isHidden = true
        lblFairwaysLiklinessAvg.isHidden = true
        lblDriveDistanceAvg.isHidden = true
        lblAccuracyWithDriver.isHidden = true
        
        let vi0 = UIView()
        vi0.frame.origin = .zero
        vi0.frame.size = CGSize(width:self.view.frame.width * 0.25,height:cardViewSpreadOffTee.frame.height)
        vi0.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        
        let vi1 = UIView()
        vi1.frame.origin = CGPoint(x:self.view.frame.width*0.75-20 ,y:0)
        vi1.frame.size = vi0.frame.size
        vi1.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        cardViewSpreadOffTee.addSubview(vi0)
        cardViewSpreadOffTee.addSubview(vi1)
        
        cardViewSpreadOffTee.backgroundColor = UIColor.glfBluegreen

        if(isDemoUser){
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.ottStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)

                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Spread of the tee",value:StatsIntoConstants.spreadOffTheTee))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Drive Accuracy",value:StatsIntoConstants.driveAccuracy))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Drive Distance",value:StatsIntoConstants.driveDistance))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Fairway Hit Trend",value:StatsIntoConstants.fairwayHitTrend))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"Fairway Hit Likeliness",value:StatsIntoConstants.fairwayHitLikeliness))
                        break
                    default: break
                    }
                    let statsInfoButton = StatsInfoButton()
                    statsInfoButton.frame = CGRect(x: (self.view.frame.size.width)-50, y: 16, width: 25, height: 25)
                    statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
                    statsInfoButton.tintColor = UIColor.glfFlatBlue
                    statsInfoButton.tag = viewTag
                    if (v == cardViewSpreadOffTee){
                        statsInfoButton.tintColor = UIColor.white
                    }
                    statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                    v.addSubview(statsInfoButton)
                    viewTag = viewTag+1
                }
            }
        }
        else{
            
            if !Constants.isProMode {
                
//                cardViewSpreadOffTee.makeBlurView(targetView: cardViewSpreadOffTee)
//                self.setProLockedUI(targetView: cardViewSpreadOffTee, title: "Spread of the tee".localized())
                
//                cardViewDistanceOffTee.makeBlurView(targetView: cardViewDistanceOffTee)
//                self.setProLockedUI(targetView: cardViewDistanceOffTee, title: "Drive Distance".localized())
                
                lblProSpreadOffTee.isHidden = true
                lblProDistanceOffTee.isHidden = true
            }
            else{
                lblProSpreadOffTee.backgroundColor = UIColor.clear
                lblProSpreadOffTee.layer.borderWidth = 1.0
                lblProSpreadOffTee.layer.borderColor = UIColor(rgb: 0xFFC700).cgColor
                lblProSpreadOffTee.textColor = UIColor(rgb: 0xFFC700)
                
                lblProSpreadOffTee.isHidden = false
                lblProDistanceOffTee.isHidden = false
            }
            
            let originalImage1 = #imageLiteral(resourceName: "share")
            let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            let originalImage = #imageLiteral(resourceName: "icon_info_grey")
            let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

            var viewTag = 0
            self.cardViewInfoArray = [(title:String,value:String)]()
            for v in self.ottStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    switch viewTag{
                    case 0:
                        self.cardViewInfoArray.append((title:"Spread of the tee",value:StatsIntoConstants.spreadOffTheTee))
                        break
                    case 1:
                        self.cardViewInfoArray.append((title:"Drive Accuracy",value:StatsIntoConstants.driveAccuracy))
                        break
                    case 2:
                        self.cardViewInfoArray.append((title:"Drive Distance",value:StatsIntoConstants.driveDistance))
                        break
                    case 3:
                        self.cardViewInfoArray.append((title:"Fairway Hit Trend",value:StatsIntoConstants.fairwayHitTrend))
                        break
                    case 4:
                        self.cardViewInfoArray.append((title:"Fairway Hit Likeliness",value:StatsIntoConstants.fairwayHitLikeliness))
                        break
                    default: break
                    }
                    if (!Constants.isProMode && !((v == cardViewSpreadOffTee) || (v == cardViewDistanceOffTee))){
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
                        if (v == cardViewSpreadOffTee){
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
                        if (v == cardViewSpreadOffTee){
                            statsInfoButton.tintColor = UIColor.white
                        }
                        statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
                        v.addSubview(statsInfoButton)

                    }
                    viewTag = viewTag+1
                }
            }
        }
//        lblAvgSpreadOffTheTeeValue.isHidden = true
//        lblAvgDrivingAccuracyValue.isHidden = true
        lblAvgDriveDistanceValue.isHidden = true
        lblAvgFairwaysHitTrendValue.isHidden = true
        lblAvgFairwayHitValue.isHidden = true
        
        lblFairwayRight.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        lblFairwayHit.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        lblFairwayLeft.font = UIFont(name: "SFProDisplay-Regular", size: 12.0)
        
        self.lblAvgSpreadOffTheTeeValue.setCorner(color: UIColor.white.cgColor)
//        self.lblAvgDrivingAccuracyValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgDriveDistanceValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgFairwaysHitTrendValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgFairwayHitValue.setCorner(color: UIColor.glfBlack50.cgColor)
        
        //        let size = CGSize(width: 300, height: drivingAccuracyPieChart.frame.height*0.7+40)
        let combinedView = UIView()
        combinedView.frame = CGRect(x: 0, y:0, width: self.view.frame.size.width-40, height: drivingAccuracyPieChart.frame.size.height)
        view1.frame = CGRect(x: 8, y: 30, width: combinedView.frame.width/2.5, height: drivingAccuracyPieChart.frame.height*0.6)
        view1.center.y = combinedView.bounds.midY
        leftImg.frame.origin = CGPoint(x: #imageLiteral(resourceName: "left").size.width + view1.frame.size.height*0.20, y: view1.frame.height*0.56)
        lblFairwayLeft.frame = CGRect(origin: CGPoint(x: leftImg.frame.origin.x - 30, y: leftImg.frame.origin.y - 20), size: CGSize(width:30,height:20))
        view1.addSubview(leftImg)
        view1.addSubview(lblFairwayLeft)
        //        view1.backgroundColor = UIColor.black
        
        view2.frame.size.width = view1.frame.width
        view2.frame.size.height = view1.frame.height+10
        view2.center.x = combinedView.bounds.midX
        view2.frame.origin.y = view1.frame.origin.y-20
        //        view2.backgroundColor = UIColor.blue
        hitImg.frame.origin = CGPoint(x: view2.frame.width/2 - #imageLiteral(resourceName: "path15").size.width/2, y:#imageLiteral(resourceName: "path15").size.height + view2.frame.size.height*0.1)
        lblFairwayHit.frame = CGRect(origin: CGPoint(x: hitImg.frame.origin.x, y:hitImg.frame.origin.y - 30), size: CGSize(width:30,height:20))
        view2.addSubview(lblFairwayHit)
        view2.addSubview(hitImg)
        
        view3.frame = CGRect(x: combinedView.frame.size.width-view2.frame.width-8, y: view1.frame.origin.y, width: view2.frame.width, height:view1.frame.height)
        //        view3.backgroundColor = UIColor.black
        rightImg.frame.origin = CGPoint(x: view3.frame.width - #imageLiteral(resourceName: "right").size.width - view3.frame.size.height*0.15, y:view3.frame.height*0.60)
        lblFairwayRight.frame = CGRect(origin: CGPoint(x: rightImg.frame.origin.x + 5, y:rightImg.frame.origin.y - 20), size: CGSize(width:30,height:20))
        view3.addSubview(lblFairwayRight)
        view3.addSubview(rightImg)
        
        combinedView.addSubview(view1)
        combinedView.addSubview(view3)
        combinedView.addSubview(view2)
        //        combinedView.backgroundColor = UIColor.brown
        //        combinedView.center = CGPoint(x:drivingAccuracyPieChart.bounds.midX,y:drivingAccuracyPieChart.bounds.midY)
        drivingAccuracyPieChart.addSubview(combinedView)
        
        if !Constants.isProMode{
            lblSpreadOffAvg.isHidden = true
            lblAvgSpreadOffTheTeeValue.isHidden = true
            lblAccuracyWithDriver.isHidden = true
            lblFairwaysLiklinessAvg.isHidden = true
            lblAvgFairwayHitValue.isHidden = true
            lblDriveDistanceAvg.isHidden = true
            lblAvgDriveDistanceValue.isHidden = true
            
            let eddieStatsView = EddieStatsView()
            eddieStatsView.backgroundColor = UIColor.clear
            eddieStatsView.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-52, height: 30)
            eddieStatsView.lblTitle.text = "Unlock this stat with Eddie!"
            eddieStatsView.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            cardViewSpreadOffTee.addSubview(eddieStatsView)
            
            let eddieStatsView1 = EddieStatsView()
            eddieStatsView1.backgroundColor = UIColor.clear
            eddieStatsView1.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-52, height: 30)
            eddieStatsView1.lblTitle.text = "Eddie has some insights for you."
            eddieStatsView1.lblTitle.textColor = UIColor(rgb:0xFFC700)
            eddieStatsView1.btnView.addTarget(self, action: #selector(self.eddieProClicked(_:)), for: .touchUpInside)
            cardViewDistanceOffTee.addSubview(eddieStatsView1)
        }
        else{
            self.lblDriveDistanceAvg.isHidden = false
            self.lblAvgDriveDistanceValue.isHidden = false
            self.lblFairwaysLiklinessAvg.isHidden = false
            self.lblAvgFairwayHitValue.isHidden = false
        }
    }
    
    @objc func eddieProClicked(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
        viewCtrl.source = "OTT"
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
//        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ProMemberPopUpVC") as! ProMemberPopUpVC
//        self.navigationController?.pushViewController(viewCtrl, animated: true)
            let viewCtrl = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EddieProVC") as! EddieProVC
            viewCtrl.source = "OTT"
            self.navigationController?.pushViewController(viewCtrl, animated: false)

        playButton.contentView.isHidden = true
        playButton.floatButton.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFairwayLiklinessChart(){
        var fairwayArray = [Double]()
        var totalFairway = [Double]()
        var avgFairway = [Double]()
        let KeysArray = ["below".localized() + "-5","6","7","8","9","10-" + "above".localized()]
        for keys in KeysArray{
            groupDict[keys] = 0
        }
        
        for round in scores where (round.fairwayHit+round.fairwayMiss) != 0{
                fairwayArray.append((round.fairwayHit))
                totalFairway.append(round.fairwayHit+round.fairwayMiss)
                avgFairway.append(((round.fairwayHit/(round.fairwayHit+round.fairwayMiss))*14).rounded())
        }
        for i in avgFairway{
            if(i<=5){
                updateValue(keys: "below".localized() + "-5")
            }
            else if(i>5 && i<=6){
                updateValue(keys: "6")
            }
            else if(i>6 && i<=7){
                updateValue(keys: "7")
            }
            else if(i>7 && i<=8){
                updateValue(keys: "8")
            }
            else if(i>8 && i<=9){
                updateValue(keys: "9")
            }
            else{
                updateValue(keys: "10-" + "above".localized())
            }
        }
        var dataArray = [Double]()
        for i in 0..<KeysArray.count{
            dataArray.append(((groupDict[KeysArray[i]]!)*100)/Double(avgFairway.count))
        }
        FairwaysLiklinessLineChart.setLineChartWithColor(dataPoints:KeysArray , values: dataArray, chartView: FairwaysLiklinessLineChart,color:UIColor.glfFlatBlue)
        
        self.lblFairwaysLiklinessAvg.text = "Average Fairways Hit Per Round"
        let totalHit = (fairwayArray.reduce(0, +))
        let totalFair = (totalFairway.reduce(0, +))
        let msg = String(format:"%.01f ",((totalHit/totalFair)*14))
        self.lblAvgFairwayHitValue.text = "\(msg) of 14"
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
    
    func setFairwayHitTrends(){
        var dataPoints = [String]()
        var dataValues = [Double]()
        var newDataPoint = [Double]()
        var avgPerc = [Double]()
        for round in scores{
            if round.type == "18 holes" || round.type == "18 hole"{
                if (round.fairwayHit+round.fairwayMiss != 0){
                    dataPoints.append(round.date)
                    dataValues.append(round.fairwayHit)
                    newDataPoint.append(round.fairwayHit+round.fairwayMiss)
                    avgPerc.append((round.fairwayHit/(round.fairwayHit+round.fairwayMiss))*100)
                }
            }else{
                if (round.fairwayHit+round.fairwayMiss) != 0{
                    dataPoints.append(round.date)
                    dataValues.append(round.fairwayHit)
                    newDataPoint.append(round.fairwayHit+round.fairwayMiss)
                    avgPerc.append((round.fairwayHit/(round.fairwayHit+round.fairwayMiss))*100)
                }
            }
        }
        
        if(dataValues.count > 0){
            barChartFairwaysHitTrend.setStackedBarChart(dataPoints: dataPoints, value1: newDataPoint, value2: dataValues, chartView: barChartFairwaysHitTrend, color: [UIColor.glfBluegreen.withAlphaComponent(0.50),UIColor.glfBluegreen], barWidth: 0.2)
            barChartFairwaysHitTrend.leftAxis.axisMinimum = 0.0
            barChartFairwaysHitTrend.leftAxis.axisMaximum = newDataPoint.max()!+1
            barChartFairwaysHitTrend.leftAxis.labelCount = 5
            if dataValues.count > 2 && Constants.baselineDict != nil{
                var attributedText = NSMutableAttributedString()
                let publicScoring = PublicScore()
                let data = publicScoring.getFairwaysHitTrendsData(dataValues:avgPerc)
                self.lblFairwayHitAvg.isHidden = false
                if let text = data.value(forKey: "text") as? NSAttributedString {
                    attributedText.append(text)
                }
                if (attributedText.length > 11){
                    self.lblFairwayHitAvg.attributedText = attributedText
                }else{
                    attributedText = NSMutableAttributedString()
                    self.lblAvgFairwaysHitTrendValue.isHidden = false
                    let value = data.value(forKey: "percentFairwayTrend") as! Double
                    let string = data.value(forKey: "text") as! NSAttributedString
                    let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                    attributedText.append(NSAttributedString(string: "Your Accuracy has ", attributes: dict1))
                    attributedText.append(string)
                    if let color = data.value(forKey: "color") as? UIColor{
                        self.lblAvgFairwaysHitTrendValue.textColor = color
                        self.lblAvgFairwaysHitTrendValue.layer.borderColor = color.cgColor
                        let msg = String(format:"%.01f ",value)
                        self.lblAvgFairwaysHitTrendValue.text = "\(msg)%"
                    }
                    self.lblFairwayHitAvg.attributedText = attributedText
                }
            }
        }
        
    }
    func setDriveDistanceScatterChartView(){
        var teesArray = [NSDictionary]()
        var dataPoints = [Double]()
        var dataValues = [Double]()
        var date = [String]()
        
        if holesInAllRounds.count > 0{
            for round in scores{
                if round.tees != nil {
                    //                print(round.tees)
                    teesArray.append(round.tees)
                    var count = 0.0
                    for tees in round.tees{
                        if(clubFilter.count > 0){
                            if(clubFilter.contains((tees.value as AnyObject).object(forKey: "club") as! String)) {
                                count += 1
                            }
                        }
                        else{
                            count += 1
                        }
                    }
                    dataPoints.append(count)
                    date.append(round.date)
                }
            }
            for item in holesInAllRounds{
                dataValues.append(item.distance)
            }
        }
        else{
            let demoLabel = DemoLabel()
            demoLabel.frame = CGRect(x: 0, y: cardViewDistanceOffTee.frame.height/2-15, width: cardViewDistanceOffTee.frame.width, height: 30)
            cardViewDistanceOffTee.addSubview(demoLabel)
            
            setClassicData()
            for round in Constants.classicScores{
                if round.tees != nil {
                    //print(round.tees)
                    teesArray.append(round.tees)
                    var count = 0.0
                    for tees in round.tees{
                        if(clubFilter.count > 0){
                            if(clubFilter.contains((tees.value as AnyObject).object(forKey: "club") as! String)) {
                                count += 1
                            }
                        }
                        else{
                            count += 1
                        }
                    }
                    dataPoints.append(count)
                    date.append(round.date)
                }
            }
            for item in holesInAllRoundsClassic{
                dataValues.append(item.distance)
            }
        }

        driveDistanceScatterChartView.setScatterChartWithLineOnlyDriveDistance(valueX:dataPoints, valueY: dataValues,xAxisValue:date ,chartView: driveDistanceScatterChartView, color: UIColor.glfPaleTeal)
        driveDistanceScatterChartView.leftAxis.labelCount = 3
        
        self.lblDriveDistanceAvg.text = "Average Drive"
        if !dataValues.isEmpty{
            let sum = Int(dataValues.reduce(0, +))
            self.lblAvgDriveDistanceValue.text = "\(Int(sum/dataValues.count)) \(Constants.distanceFilter == 1 ? "m":"yd")"
        }else{
            self.lblAvgDriveDistanceValue.text = "0 \(Constants.distanceFilter == 1 ? "m":"yd")"
        }
    }
    
    func setSpreadOffTheTeaGraph(){
        //        print(holesInAllRounds)
        var dataXAxis = [Double]()
        var dataYAxis = [Double]()
        var color = [UIColor]()
        if holesInAllRounds.count>0{
        for item in holesInAllRounds{
            
            if(item.spread <= 25  && item.spread >= -25){
                color.append(UIColor.glfWhite)
            }
            else{
                color.append(UIColor.glfRosyPink)
            }
            dataXAxis.append(item.spread)
            
            dataYAxis.append(item.distance)
        }
        }
        else{
            let demoLabel = DemoLabel()
            demoLabel.frame = CGRect(x: 0, y: cardViewSpreadOffTee.frame.height/2-15, width: cardViewSpreadOffTee.frame.width, height: 30)
            cardViewSpreadOffTee.addSubview(demoLabel)

            setClassicData()
            for item in holesInAllRoundsClassic{
                
                if(item.spread <= 25  && item.spread >= -25){
                    color.append(UIColor.glfWhite)
                }
                else{
                    color.append(UIColor.glfRosyPink)
                }
                dataXAxis.append(item.spread)
                
                dataYAxis.append(item.distance)
            }
        }
        scattredSpreadOfTheTeeChart.setScatterChart(valueX: dataXAxis, valueY: dataYAxis, chartView: scattredSpreadOfTheTeeChart, color: color)
        scattredSpreadOfTheTeeChart.leftAxis.axisLineColor = UIColor.clear
        scattredSpreadOfTheTeeChart.leftAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        scattredSpreadOfTheTeeChart.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.5)
        if(dataYAxis.count != 0){
            scattredSpreadOfTheTeeChart.leftAxis.axisMinimum = dataYAxis.min()! - 5
            lblSpreadOffAvg.text = "Longest Drive"
            lblAvgSpreadOffTheTeeValue.text = "\(Int(dataYAxis.max()!)) \(Constants.distanceFilter == 1 ? "m":"yd")"
        }else{
            lblAvgSpreadOffTheTeeValue.text = "0 \(Constants.distanceFilter == 1 ? "m":"yd")"
        }

        scattredSpreadOfTheTeeChart.leftAxis.labelCount = 3
        let formatter = NumberFormatter()
        if(Constants.distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }else{
            formatter.positiveSuffix = " yd"
        }
        scattredSpreadOfTheTeeChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        scattredSpreadOfTheTeeChart.xAxis.enabled = false
        lblRight.text = "Right Rough".localized()
        lblLeft.text = "Left Rough".localized()
        lblCenter.text = "Fairway".localized()
        
    }
    
    func setClassicData(){
        for round in Constants.classicScores{
            var fHit = Int()
            var fLeft = Int()
            var fRight = Int()
            
            if (round.tees) != nil {
                let holes = (round.tees).allValues
                
                for i in 0..<holes.count{
                    let hole = Hole()
                    hole.club = (holes[i] as AnyObject).object(forKey:"club") as! String
                    hole.distance = (holes[i] as AnyObject).object(forKey:"distance") as! Double
                    hole.spread = (holes[i] as AnyObject).object(forKey:"spread") as! Double
                    if(Constants.distanceFilter == 1){
                        hole.distance = hole.distance/Constants.YARD
                    }
                    if let fHit = (holes[i] as AnyObject).object(forKey:"fairway") as? String{
                        hole.hitMiss = fHit
                    }
                    
                    if(clubFilter.count > 0){
                        if(clubFilter.contains(hole.club)){
                            if(hole.hitMiss == "H"){
                                fHit += 1
                            }else if(hole.hitMiss == "L"){
                                fLeft += 1
                            }else{
                                fRight += 1
                            }
                            holesInAllRoundsClassic.append(hole)
                        }
                    }
                    else{
                        if(hole.hitMiss == "H"){
                            fHit += 1
                        }else if(hole.hitMiss == "L"){
                            fLeft += 1
                        }else{
                            fRight += 1
                        }
                        holesInAllRoundsClassic.append(hole)
                    }
                }
            }else{
                if((round.fairwayHit) != nil){
                    fHit = Int(round.fairwayHit)
                }
                if((round.fairwayLeftValue) != nil){
                    fLeft = Int(round.fairwayLeftValue)
                }
                if((round.fairwayRightValue) != nil){
                    fRight = Int(round.fairwayRightValue)
                }
            }
//            self.fairway.append((hit: fHit, left: fLeft, right: fRight))
        }
    }
    func setDrivingAccuracyChart(){
        var fairwayLeft = Int()
        var fairwayHit = Int()
        var fairwayRight = Int()
        
        for item in self.fairway{
            fairwayHit += item.hit
            fairwayLeft += item.left
            fairwayRight += item.right
        }
        let totalFairway = Double(fairwayHit+fairwayLeft+fairwayRight)
        var fairwayLeftInPercentage = 0.0
        var fairwayHitInPercentage = 0.0
        var fairwayRightInPercentage = 0.0
        if(fairwayLeft != 0){
            fairwayLeftInPercentage = Double((fairwayLeft)*100)/(totalFairway)
        }
        if(fairwayHit != 0){
            fairwayHitInPercentage = Double((fairwayHit)*100)/(totalFairway)
        }
        if(fairwayRight != 0){
            fairwayRightInPercentage = Double((fairwayRight)*100)/(totalFairway)
        }
        self.lblRight.text = "Right Rough".localized() + " \(String(format:"%.01f ",fairwayRightInPercentage))%"

        self.lblCenter.text = "Fairway \(String(format:"%.01f ",fairwayHitInPercentage))%"
        self.lblLeft.text = "Left Rough".localized() + " \(String(format:"%.01f ",fairwayLeftInPercentage))%"

        self.lblFairwayRight.text = " \(String(format:"%.01f ",fairwayRightInPercentage))% "
        self.lblFairwayHit.text = " \(String(format:"%.01f ",fairwayHitInPercentage))% "
        self.lblFairwayLeft.text = " \(String(format:"%.01f ",fairwayLeftInPercentage))% "
        self.lblFairwayRight.sizeToFit()
        self.lblFairwayHit.sizeToFit()
        self.lblFairwayLeft.sizeToFit()
        if(fairwayHitInPercentage > 90){
            hitImg.removeFromSuperview()
        }
        if(fairwayLeftInPercentage > 90){
            leftImg.removeFromSuperview()
        }
        if(fairwayRightInPercentage > 90){
            rightImg.removeFromSuperview()
        }
        view1.updateViewWithColor(rect: view1.frame, color: UIColor.glfRosyPink, radius: view1.frame.height*CGFloat(fairwayLeftInPercentage)/100)
        view2.updateViewWithColor(rect: view2.frame, color: UIColor.glfPaleTeal, radius: view2.frame.height*CGFloat(fairwayHitInPercentage)/100)
        view3.updateViewWithColor(rect: view3.frame, color: UIColor.glfRosyPink, radius: view3.frame.height*CGFloat(fairwayRightInPercentage)/100)
        if Constants.baselineDict != nil{
            let publicScoring = PublicScore()
            let data = publicScoring.getDriveAccuracyData(fairHit:fairwayHitInPercentage)
            self.lblAccuracyWithDriver.isHidden = false
            if data.length > 15{
                self.lblAccuracyWithDriver.attributedText = data
            }else{
                let dict1: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfWarmGrey]
                let attributedText = NSMutableAttributedString()
                attributedText.append(NSAttributedString(string: "You ", attributes: dict1))
                attributedText.append(data)
                attributedText.append(NSAttributedString(string: " more fairways than other golfers like you", attributes: dict1))
                self.lblAccuracyWithDriver.attributedText = attributedText
            }
        }
    }
    func setData(){
        for round in scores{
            var fHit = Int()
            var fLeft = Int()
            var fRight = Int()
            
            if (round.tees) != nil {
                let holes = (round.tees).allValues
                
                for i in 0..<holes.count{
                    let hole = Hole()
                    hole.club = (holes[i] as AnyObject).object(forKey:"club") as! String
                    hole.distance = (holes[i] as AnyObject).object(forKey:"distance") as! Double
                    hole.spread = (holes[i] as AnyObject).object(forKey:"spread") as! Double
                    if(Constants.distanceFilter == 1){
                        hole.distance = hole.distance/Constants.YARD
                    }
                    if let fHit = (holes[i] as AnyObject).object(forKey:"fairway") as? String{
                        hole.hitMiss = fHit
                    }

                    if(clubFilter.count > 0){
                        if(clubFilter.contains(hole.club)){
                            if(hole.hitMiss == "H"){
                                fHit += 1
                            }else if(hole.hitMiss == "L"){
                                fLeft += 1
                            }else{
                                fRight += 1
                            }
                            holesInAllRounds.append(hole)
                            
                        }
                    }
                    else{
                        if(hole.hitMiss == "H"){
                            fHit += 1
                        }else if(hole.hitMiss == "L"){
                            fLeft += 1
                        }else{
                            fRight += 1
                        }
                        holesInAllRounds.append(hole)
                    }
                }
            }else{
                if((round.fairwayHit) != nil){
                    fHit = Int(round.fairwayHit)
                }
                if((round.fairwayLeftValue) != nil){
                    fLeft = Int(round.fairwayLeftValue)
                }
                if((round.fairwayRightValue) != nil){
                    fRight = Int(round.fairwayRightValue)
                }
            }
            
            self.fairway.append((hit: fHit, left: fLeft, right: fRight))
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Off the Tee".localized())
    }
}

