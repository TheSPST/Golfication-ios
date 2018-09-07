//
//  MapShotPopupVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 31/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Charts
import UICircularProgressRing

class MapShotPopupVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var shotScrollView: UIScrollView!
    var shotBtnViews: [UIView]!
    var shotTopViews: [UIView]!
    var shotTopLbls:[UILabel]!
    var swingScoreCircularView: UICircularProgressRingView!
    var backSwingCircularView: UICircularProgressRingView!
    var clubSpeedLineChart: LineChartView!
    var headSpeedLineChart: LineChartView!

    var customColorSlider: CustomColorSlider!

    var testStr = String()
    var backSwingLbl : UILabel!
    var downSwingLbl : UILabel!
    
    var shotsDetails = [[Any]]()
    var pageIndex = 0
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let currentPage = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageIndex = Int(currentPage)

        for subView in shotScrollView.subviews{
            subView.removeFromSuperview()
        }
        setCurrentScrollPage(i: Int(currentPage))
        btnTapped(tagVal:20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("shotsDetails", shotsDetails.count)
        debugPrint("testStr",testStr)
        self.configureScrollView(totalCard: shotsDetails.count)
        btnTapped(tagVal:20)
    }
    
    func configureScrollView(totalCard:Int) {
        shotScrollView.isPagingEnabled = true
        
        shotScrollView.showsHorizontalScrollIndicator = false
        shotScrollView.showsVerticalScrollIndicator = false
        shotScrollView.scrollsToTop = false
        
        shotScrollView.contentSize = CGSize(width: (self.view.frame.size.width-20) * CGFloat(totalCard), height: shotScrollView.frame.size.height)
        
        shotScrollView.delegate = self
        
        setCurrentScrollPage(i: pageIndex)
        shotScrollView.scrollRectToVisible(CGRect(x: CGFloat(pageIndex) * (self.view.frame.size.width-20), y: shotScrollView.frame.origin.y, width: shotScrollView.frame.size.width, height: shotScrollView.frame.size.height), animated: true)
    }
    
    func setCurrentScrollPage(i:Int) {
        let mapShotPopupView = Bundle.main.loadNibNamed("MapShotPopupView", owner: self, options: nil)![0] as! UIView
        mapShotPopupView.frame = CGRect(x: CGFloat(i) * (self.view.frame.size.width-20), y: 0, width: shotScrollView.frame.size.width, height: shotScrollView.frame.size.height)
        mapShotPopupView.backgroundColor = UIColor.clear
        
        let shotNumLbl = mapShotPopupView.viewWithTag(500) as! UILabel
        shotNumLbl.text = "SHOT \(i+1)"
        
        let shotTopView1 = mapShotPopupView.viewWithTag(30)
        let shotTopView2 = mapShotPopupView.viewWithTag(31)
        let shotTopView3 = mapShotPopupView.viewWithTag(32)
        let shotTopView4 = mapShotPopupView.viewWithTag(33)
        let shotTopView5 = mapShotPopupView.viewWithTag(34)
        let shotTopView6 = mapShotPopupView.viewWithTag(35)
        shotTopViews = [UIView]()
        shotTopViews = [shotTopView1, shotTopView2, shotTopView3, shotTopView4, shotTopView5, shotTopView6] as! [UIView]

        let shotTopLbl1 = mapShotPopupView.viewWithTag(200)
        let shotTopLbl2 = mapShotPopupView.viewWithTag(201)
        let shotTopLbl3 = mapShotPopupView.viewWithTag(202)
        let shotTopLbl4 = mapShotPopupView.viewWithTag(203)
        let shotTopLbl5 = mapShotPopupView.viewWithTag(204)
        let shotTopLbl6 = mapShotPopupView.viewWithTag(205)
        shotTopLbls = [UILabel]()
        shotTopLbls = [shotTopLbl1, shotTopLbl2, shotTopLbl3, shotTopLbl4, shotTopLbl5, shotTopLbl6] as! [UILabel]

        let shotBtnView1 = mapShotPopupView.viewWithTag(10)
        let shotBtnView2 = mapShotPopupView.viewWithTag(11)
        let shotBtnView3 = mapShotPopupView.viewWithTag(12)
        let shotBtnView4 = mapShotPopupView.viewWithTag(13)
        let shotBtnView5 = mapShotPopupView.viewWithTag(14)
        let shotBtnView6 = mapShotPopupView.viewWithTag(15)
        shotBtnViews = [UIView]()
        shotBtnViews = [shotBtnView1, shotBtnView2, shotBtnView3, shotBtnView4, shotBtnView5, shotBtnView6] as! [UIView]

        let shotBtn1 = mapShotPopupView.viewWithTag(20) as! UIButton
        let shotBtn2 = mapShotPopupView.viewWithTag(21) as! UIButton
        let shotBtn3 = mapShotPopupView.viewWithTag(22) as! UIButton
        let shotBtn4 = mapShotPopupView.viewWithTag(23) as! UIButton
        let shotBtn5 = mapShotPopupView.viewWithTag(24) as! UIButton
        let shotBtn6 = mapShotPopupView.viewWithTag(25) as! UIButton
        shotBtn1.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)
        shotBtn2.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)
        shotBtn3.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)
        shotBtn4.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)
        shotBtn5.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)
        shotBtn6.addTarget(self, action: #selector(self.shotBtnAction(_:)), for: .touchUpInside)

        let scoreVal1 =  self.shotsDetails[self.pageIndex][0] as! String
        let shotBtnLbl1 = mapShotPopupView.viewWithTag(40) as! UILabel
        shotBtnLbl1.text = scoreVal1

        let scoreVal2 =  self.shotsDetails[self.pageIndex][1] as! [Int]
        let finalScore2 = scoreVal2[3] as Int
        let shotBtnLbl2 = mapShotPopupView.viewWithTag(41) as! UILabel
        shotBtnLbl2.text = "\(Int(finalScore2))"

        let scoreVal3 =  self.shotsDetails[self.pageIndex][2] as! String
        let shotBtnLbl3 = mapShotPopupView.viewWithTag(42) as! UILabel
        shotBtnLbl3.text = "\(scoreVal3)"

        let scoreVal4 =  self.shotsDetails[self.pageIndex][3] as! String
        let shotBtnLbl4 = mapShotPopupView.viewWithTag(43) as! UILabel
        shotBtnLbl4.text = scoreVal4
        
        let scoreVal5 =  self.shotsDetails[self.pageIndex][4] as! String
        let shotBtnLbl5 = mapShotPopupView.viewWithTag(44) as! UILabel
        shotBtnLbl5.text = "\(Int(Double(scoreVal5)!.rounded(toPlaces: 2)))"
        
        let scoreVal6 =  self.shotsDetails[self.pageIndex][5] as! [Int]
        let finalScore6 = scoreVal6[3] as Int
        let shotBtnLbl6 = mapShotPopupView.viewWithTag(45) as! UILabel
        shotBtnLbl6.text = "\(finalScore6)"

        backSwingLbl = mapShotPopupView.viewWithTag(1111) as! UILabel
        downSwingLbl = mapShotPopupView.viewWithTag(2222) as! UILabel
        
        
        swingScoreCircularView = mapShotPopupView.viewWithTag(110) as! UICircularProgressRingView
        swingScoreCircularView.fontColor = UIColor.clear
        self.swingScoreCircularView.innerCapStyle = .square
        self.swingScoreCircularView.outerCapStyle = .square

        clubSpeedLineChart = mapShotPopupView.viewWithTag(120) as! LineChartView
        
        customColorSlider = mapShotPopupView.viewWithTag(130) as! CustomColorSlider
        customColorSlider.minimumValue = 0
        customColorSlider.maximumValue = 6
        customColorSlider.isEnabled = false

        backSwingCircularView = mapShotPopupView.viewWithTag(140) as! UICircularProgressRingView
        backSwingCircularView.fontColor = UIColor.clear
        self.backSwingCircularView.innerCapStyle = .square
        self.backSwingCircularView.outerCapStyle = .square

        headSpeedLineChart = mapShotPopupView.viewWithTag(150) as! LineChartView
        
        shotScrollView.addSubview(mapShotPopupView)
    }
    
    @objc func shotBtnAction(_ sender: UIButton!) {
        btnTapped(tagVal:sender.tag)
    }
    
    func btnTapped(tagVal:Int) {

        for i in 0..<self.shotBtnViews.count{
            shotBtnViews[i].layer.cornerRadius = 3.0
            shotBtnViews[i].layer.borderWidth = 1.0
            shotBtnViews[i].layer.borderColor = UIColor(rgb: 0xDBE7EE).cgColor

            if shotBtnViews[i].tag == tagVal-10{
                shotBtnViews[i].layer.cornerRadius = 3.0
                shotBtnViews[i].layer.borderWidth = 1.0
                shotBtnViews[i].layer.borderColor = UIColor.glfFlatBlue.cgColor
            }
        }
        for i in 0..<shotTopViews.count{
            shotTopViews[i].isHidden = true
            if shotTopViews[i].tag == tagVal+10{
                shotTopViews[i].isHidden = false
                if tagVal+90 == 110{
                    DispatchQueue.main.async(execute: {
                        let scoreVal =  self.shotsDetails[self.pageIndex][0] as! String
                        self.swingScoreCircularView.setProgress(value: CGFloat(Int(scoreVal)!), animationDuration: 1)
                    })
                }
                else if tagVal+99 == 120{
                    let avgVhArr =  self.shotsDetails[self.pageIndex][1] as! [Int]
                    let avgVh1 = Double(avgVhArr[0])
                    let avgVh2 = Double(avgVhArr[1])
                    let avgVh3 = Double(avgVhArr[2])

                    clubSpeedLineChart.setLineChartHandSpeed(dataPoints:["", "", "", "", "", "" ,"" ,"" ,"" ,"","",""] , values: [0.2, 0.5, 1.0, 2.2,avgVh1,1.7,2.5,avgVh2,4.9,avgVh3,10.6,5.0], chartView: clubSpeedLineChart,color:UIColor.glfFlatBlue)
                    clubSpeedLineChart.leftAxis.axisLineColor = UIColor.white
                    clubSpeedLineChart.xAxis.axisLineColor = UIColor.white
                }
                /*else if tagVal+138 == 160{
                    DispatchQueue.main.async(execute: {
//                        let scoreVal =  self.shotsDetails[self.pageIndex][2] as! Double
                    })
                }*/
                else if tagVal+107 == 130{
                    DispatchQueue.main.async(execute: {
                        let backSwingStr = self.shotsDetails[self.pageIndex][4] as! String
                        let downSwingStr = self.shotsDetails[self.pageIndex][7] as! String
                        let backSwing = Double(backSwingStr)!.rounded(toPlaces: 2) * 1000
                        let dowbSwing = Double(downSwingStr)!.rounded(toPlaces: 2) * 1000
                        
                        self.backSwingLbl.text = "\(Int(backSwing))MS"
                        self.downSwingLbl.text = "\(Int(dowbSwing))MS"
                        
                        let scoreVal =  self.shotsDetails[self.pageIndex][3] as! String
                        let remaining = String(scoreVal.dropLast(4))
                        self.customColorSlider.setValue(CGFloat(Double(remaining)!), animated: true)
                    })
                }
                else if tagVal+116 == 140{
                    DispatchQueue.main.async(execute: {
                        let scoreVal =  self.shotsDetails[self.pageIndex][4] as! String
                        self.backSwingCircularView.setProgress(value: CGFloat(Double(scoreVal)!), animationDuration: 1)
                    })
                }
                else if tagVal+125 == 150{
                    let avgVhArr =  self.shotsDetails[self.pageIndex][5] as! [Int]
                    let avgVh1 = Double(avgVhArr[0])
                    let avgVh2 = Double(avgVhArr[1])
                    let avgVh3 = Double(avgVhArr[2])
                    headSpeedLineChart.setLineChartHandSpeed(dataPoints:["", "", "", "", "", "" ,"" ,"" ,"" ,"","",""] , values: [0.2, 0.5, 1.0, 2.2,avgVh1,1.7,2.5,avgVh2,4.9,avgVh3,10.6,5.0], chartView: headSpeedLineChart,color:UIColor.glfFlatBlue)
                    headSpeedLineChart.leftAxis.axisLineColor = UIColor.white
                    headSpeedLineChart.xAxis.axisLineColor = UIColor.white
                }
            }
        }
        
            if tagVal+180 == 200{
             let scoreVal =  self.shotsDetails[self.pageIndex][0] as! String
                shotTopLbls[0].text = scoreVal
            }
            else if tagVal+180 == 201{
                let scoreVal =  self.shotsDetails[self.pageIndex][1] as! [Int]
                let finalScoreVal = scoreVal[3] as Int
                shotTopLbls[1].text = "\(finalScoreVal)"
            }
            else if tagVal+180 == 202{
                 let scoreVal =  self.shotsDetails[self.pageIndex][2] as! String
                shotTopLbls[2].text = "\(scoreVal)"
            }
            else if tagVal+180 == 203{
                 let scoreVal =  self.shotsDetails[self.pageIndex][3] as! String
                shotTopLbls[3].text = scoreVal
            }
            else if tagVal+180 == 204{
                 let scoreVal =  self.shotsDetails[self.pageIndex][4] as! String
                shotTopLbls[4].text = "\(Int(Double(scoreVal)!.rounded(toPlaces: 2)))"
            }
            else if tagVal+180 == 205{
                let scoreVal =  self.shotsDetails[self.pageIndex][5] as! [Int]
                let finalScoreVal = scoreVal[3]
                shotTopLbls[5].text = "\(finalScoreVal)"
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func dismissPopupAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != shotScrollView {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
