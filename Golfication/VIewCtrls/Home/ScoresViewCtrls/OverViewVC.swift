//
//  MyScoreVC.swift
//  Golfication
//
//  Created by IndiRenters on 10/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import FirebaseAnalytics

class OverViewVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var overviewStackView: UIStackView!
    @IBOutlet weak var lblRoundsAvg: UILabel!
    @IBOutlet weak var lblScoreDistributionAvg: UILabel!
    @IBOutlet weak var lblScoringAvg: UILabel!
    @IBOutlet weak var lblParAvg: UILabel!
    @IBOutlet weak var lblPenaltyTrendsAvg: UILabel!
    
    @IBOutlet weak var lblAvgRoundsValue: UILabel!
    @IBOutlet weak var roundCardView: CardView!
    @IBOutlet weak var lblAvgScoreDistributionValue: UILabel!
    @IBOutlet weak var lblAvgScoringValue: UILabel!
    @IBOutlet weak var lblAvgPerformanceValue: UILabel!
    @IBOutlet weak var lblAvgParValue: UILabel!
    @IBOutlet weak var lblAvgPenaltiesTrendsValue: UILabel!
    @IBOutlet weak var barViewPenaltiesTrend: BarChartView!
    @IBOutlet weak var barViewParAverages: BarChartView!
    @IBOutlet weak var pieViewScoring: PieChartView!
    @IBOutlet weak var barViewScoreDistribution: LineChartView!
    @IBOutlet weak var barViewRounds: BarChartView!
    @IBOutlet weak var lblAvgScoreDistribution: UILabel!
    
    var bestRound = Double()
    var avgScore = Double()
    var scores = [Scores]()
    var isDemoUser :Bool!
    var groupDict = [String:Double]()
    var cardViewMArray = NSMutableArray()
    
    var checkCaddie = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("my_scores_overview", parameters: [:])

        self.setupUI()
        //print("Scores in ViewDid Load : \(scores)")
        self.setData()
        self.setOverviewBarChart()
        //        self.roundLabelData.text = "Best Round :\(self.bestRound)"
        self.setScoreDistribution()
        self.setPenaltiesTrendBarCharts()
        self.setViewScoringPieChart()
        self.setViewParAveragesBarChart()
        
    }
    func setupUI(){
        
        //        lblRoundsAvg.isHidden = true
        lblScoreDistributionAvg.isHidden = true
        lblScoringAvg.isHidden = true
        lblParAvg.isHidden = true
        //        lblPenaltyTrendsAvg.isHidden = true
        //        lblAvgPenaltiesTrendsValue.isHidden = true
        lblAvgParValue.isHidden = true
        lblAvgScoringValue.isHidden = true
        //        lblAvgRoundsValue.isHidden = true
        lblAvgPerformanceValue.isHidden = true
        
        roundCardView.backgroundColor = UIColor.glfBluegreen
        if(isDemoUser){
            for v in self.overviewStackView.subviews{
                if v.isKind(of: CardView.self){
                    let demoLabel = DemoLabel()
                    demoLabel.frame = CGRect(x: 0, y: v.frame.height/2-15, width: v.frame.width, height: 30)
                    v.addSubview(demoLabel)
                }
            }
        }
        else{
            let originalImage1 = #imageLiteral(resourceName: "share")
            let sharBtnImage = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            
            var viewTag = 0
            for v in self.overviewStackView.subviews{
                if v.isKind(of: CardView.self){
                    cardViewMArray.add(v)
                    
                        let shareStatsButton = ShareStatsButton()
                        shareStatsButton.frame = CGRect(x: view.frame.size.width-25-10-10-10, y: 16, width: 25, height: 25)
                        shareStatsButton.setBackgroundImage(sharBtnImage, for: .normal)
                        shareStatsButton.tintColor = UIColor.glfFlatBlue
                        shareStatsButton.tag = viewTag
                        if (v == roundCardView){
                            shareStatsButton.tintColor = UIColor.white
                        }
                        shareStatsButton.addTarget(self, action: #selector(self.shareClicked(_:)), for: .touchUpInside)
                        v.addSubview(shareStatsButton)
                        viewTag = viewTag+1
                }
            }
        }
        
        barViewPenaltiesTrend.isUserInteractionEnabled = false
        barViewParAverages.isUserInteractionEnabled = false
        pieViewScoring.isUserInteractionEnabled = false
        barViewScoreDistribution.isUserInteractionEnabled = false
        barViewRounds.isUserInteractionEnabled = false
        self.lblAvgScoreDistributionValue.isHidden = true
        self.lblAvgScoreDistribution.isHidden = true
        self.lblAvgRoundsValue.setCorner(color: UIColor.white.cgColor)
        self.lblAvgScoreDistributionValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgScoringValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgPerformanceValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgParValue.setCorner(color: UIColor.glfBlack50.cgColor)
        self.lblAvgPenaltiesTrendsValue.setCorner(color: UIColor.glfBlack50.cgColor)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViewParAveragesBarChart(){
        let parCount = ParWise.init()
        for item in scores{
            if (item.parWise) != nil {
                if((item.parWise["three"]) != nil){
                    parCount.three = parCount.three + Double((item.parWise["three"]?.count)!)
                }
                if((item.parWise["four"]) != nil){
                    parCount.four = parCount.four + Double((item.parWise["four"]?.count)!)
                }
                if((item.parWise["five"]) != nil){
                    parCount.five = parCount.five + Double((item.parWise["five"]?.count)!)
                }
            }
        }
        let parValues = ParWise.init()
        for item in scores{
            if (item.parWise) != nil {
                if((item.parWise["three"]) != nil){
                    for (_,value) in (item.parWise["three"] as Dictionary!){
                        parValues.three = parValues.three + Double(UInt32(value))
                    }
                }
                if((item.parWise["four"]) != nil){
                    for (_,value) in (item.parWise["four"] as Dictionary!){
                        parValues.four = parValues.four + Double(UInt32(value))
                    }
                }
                if((item.parWise["five"]) != nil){
                    for (_,value) in (item.parWise["five"] as Dictionary!){
                        parValues.five = parValues.five + Double(UInt32(value))
                    }
                }
            }
        }
        //print(parValues)
        let finalParScore = ParWise()
        finalParScore.three = parValues.three/parCount.three
        finalParScore.four = parValues.four/parCount.four
        finalParScore.five = parValues.five/parCount.five
        let dataLable = ["Par3","Par4","Par5"]
        let dataPoints1 = [finalParScore.three,finalParScore.four,finalParScore.five]
        barViewParAverages.setStackedBarChart(dataPoints: dataLable, value1: dataPoints1 as! [Double] , chartView: barViewParAverages,barWidth:0.4)
    }
    func setViewScoringPieChart(){
        var scoringArray = [Scoring]()
        for item in scores{
            let scoring = Scoring()
            scoring.doubleBogey = Double(item.scoring["2"]!) + Double(item.scoring["3"]!)
            scoring.bogey = Double(item.scoring["1"]!)
            scoring.par = Double(item.scoring["0"]!)
            scoring.birdie = Double(item.scoring["-1"]!)
            scoring.eagle = Double(item.scoring["-2"]!) + Double(item.scoring["-3"]!)
            
            scoringArray.append(scoring)
        }
        let score = Scoring.init()
        for item in scoringArray{
            score.doubleBogey = score.doubleBogey + item.doubleBogey
            score.bogey = score.bogey + item.bogey
            score.par = score.par + item.par
            score.birdie = score.birdie + item.birdie
            score.eagle = score.eagle + item.eagle
            //print(score)
        }
        let finalScoreInPercentage = Scoring.init()
        let totalSum = score.doubleBogey + score.bogey + (score.par as Double) + score.birdie + score.eagle
        finalScoreInPercentage.doubleBogey = (score.doubleBogey*100)/totalSum
        finalScoreInPercentage.bogey = (score.bogey*100)/totalSum
        finalScoreInPercentage.par = (score.par*100)/totalSum
        finalScoreInPercentage.birdie = (score.birdie*100)/totalSum
        finalScoreInPercentage.eagle = (score.eagle*100)/totalSum
        //print(finalScoreInPercentage)
        let dataLabel = ["2Bs","Bogeys","Pars","Birdies","Eagles"]
        let dataPoints = [finalScoreInPercentage.doubleBogey,finalScoreInPercentage.bogey,finalScoreInPercentage.par,finalScoreInPercentage.birdie,finalScoreInPercentage.eagle]
        
        pieViewScoring.setChartForScoring(dataPoints: dataLabel, values: dataPoints as! [Double], chartView: pieViewScoring,color:UIColor.glfSeafoamBlue,isValueEnable: true)
        
        
    }
    func setPenaltiesTrendBarCharts(){
        
        var xAxisLabelArray = [String]()
        var barDataArray = [Double]()
        for item in scores{
            if (item.penalty) != nil && item.penalty > 0{
                xAxisLabelArray.append(item.date)
                barDataArray.append(item.penalty)
            }
        }
        var avgPenalties = barDataArray.reduce(0, +)
        if(barDataArray.count > 0){
            avgPenalties = avgPenalties/Double(barDataArray.count)
        }
        lblAvgPenaltiesTrendsValue.text = "\(Int(avgPenalties))"
        if(barDataArray.count > 0){
            barViewPenaltiesTrend.setBarChart(dataPoints: xAxisLabelArray, values: barDataArray, chartView: barViewPenaltiesTrend,color: UIColor.glfRosyPink, barWidth: 0.2, leftAxisMinimum: 0, labelTextColor: UIColor.glfWarmGrey,unit: "", valueColor: UIColor.glfWarmGrey)
            barViewPenaltiesTrend.leftAxis.axisMinimum = 0
            barViewPenaltiesTrend.leftAxis.axisMaximum = barDataArray.max()! + 1.0
            barViewPenaltiesTrend.leftAxis.labelCount = Int(barDataArray.max()!) + 1
        }
    }
    func setData(){
        var scoreArray = [Double]()
        for score in scores{
            scoreArray.append(score.score)
        }
        if(scoreArray.count > 0){
            bestRound = scoreArray.max()!
            avgScore = scoreArray.reduce(0,+)/Double(scoreArray.count)
        }
    }
    func setOverviewBarChart(){
        var dataPointsDate = [String]()
        var values = [Double]()
        var gameType = [String]()
        var avgScoreValue = Double()
        for score in scores{
            if(score.score != 0){
                dataPointsDate.append(score.date)
                values.append(score.score)
                gameType.append(score.type)
                if(score.type == "9 holes"){
                    avgScoreValue += 2*score.score
                }else{
                    avgScoreValue += score.score
                }
            }
        }
        if(values.count > 0){
            avgScoreValue = avgScoreValue/Double(values.count)
        }
        lblAvgRoundsValue.text = "\(Int(avgScoreValue))"
        barViewRounds.setBarChartGameType(dataPoints: dataPointsDate, values: values, gameType: gameType, chartView: barViewRounds, barWidth: 0.2)
        barViewRounds.xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.75)
        barViewRounds.leftAxis.labelTextColor = UIColor.white.withAlphaComponent(0.75)
        barViewRounds.leftAxis.gridColor = UIColor.white.withAlphaComponent(0.25)
        barViewRounds.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        barViewRounds.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
    }
    
    func setScoreDistribution(){
        var scoreArray = [Double]()
        let KeysArray = ["Below-85","86-90","91-95","96-100","101-105","105-Above"]
        for keys in KeysArray{
            groupDict[keys] = 0
        }
        //print(groupDict)
        for i in 0..<scores.count{
            if(scores[i].type == "9 hole"){
                scoreArray.append((scores[i].score)*2)
            }
            else{
                scoreArray.append(scores[i].score)
            }
        }
        
        for i in scoreArray{
            if(i<=85){
                updateValue(keys: "Below-85")
            }
            else if(i>85 && i<=90){
                updateValue(keys: "86-90")
            }
            else if(i>90 && i<=95){
                updateValue(keys: "91-95")
            }
            else if(i>95 && i<=100){
                updateValue(keys: "96-100")
            }
            else if(i>100 && i<=105){
                updateValue(keys: "101-105")
            }
            else{
                updateValue(keys: "105-Above")
            }
        }
        //print("This is Group Dict: ")
        //print(groupDict)
        var dataArray = [Double]()
        for i in 0..<KeysArray.count{
            //print(i,groupDict)
            dataArray.append(((groupDict[KeysArray[i]]!)*100)/Double(scoreArray.count))
        }
        //        let maxIndex = dataArray.index(of: dataArray.max()!)
        //        let label = Chatlogo()
        barViewScoreDistribution.setLineChartSimple(dataPoints:KeysArray , values: dataArray, chartView: barViewScoreDistribution,color:UIColor.glfFlatBlue)
        
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
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Overview")
    }
}

