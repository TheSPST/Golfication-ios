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
    var scoreTopLbls:[UILabel]!
    var shotLbls : [UILabel]!
    var swingScoreCircularView: UICircularProgressRingView!
    var swingAngleCircular_Red: UICircularProgressRingView!
    var swingAngleCircular_Blue: UICircularProgressRingView!
    var backSwingClub : UIImageView!
    var backSwingUserImg : UIImageView!
    var clubSpeedLineChart: LineChartView!
    var headSpeedLineChart: LineChartView!

    var customColorSlider: CustomColorSlider!
    var lblClubHead : UILabel!
    var lblHandSpee : UILabel!
    var testStr = String()
    var backSwingLbl : UILabel!
    var downSwingLbl : UILabel!
    var shotsDetails = [[Any]]()
    var pageIndex = 0
    var benchMarkVal = String()
    var cardViewInfoArray = [(title:String,value:String)]()

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let currentPage = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageIndex = Int(currentPage)

        for subView in shotScrollView.subviews{
            subView.removeFromSuperview()
        }
        setCurrentScrollPage(i: Int(currentPage))
        btnTapped(tagVal:20)
        getUserData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("shotsDetails", shotsDetails.count)
        debugPrint("testStr",testStr)
        self.configureScrollView(totalCard: shotsDetails.count)
        btnTapped(tagVal:20)
        getUserData()
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
    
    // MARK: - infoClicked
    @objc func infoClicked(_ sender:UIButton){
        let viewCtrl = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "StatsInfoVC") as! StatsInfoVC
        viewCtrl.title = cardViewInfoArray[sender.tag].title
        viewCtrl.desc = cardViewInfoArray[sender.tag].value
        self.navigationController?.pushViewController(viewCtrl, animated: true)
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
        shotTopViews = ([shotTopView1, shotTopView2, shotTopView3, shotTopView4, shotTopView5, shotTopView6] as! [UIView])

        // -------------------------------Stats Info Button Functionality---------------------------------------
        self.cardViewInfoArray = [(title:String,value:String)]()
        let originalImage = #imageLiteral(resourceName: "icon_info_grey")
        let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        for i in 0..<shotTopViews.count{
            //Stats Info Button
            switch i{
            case 0:
                self.cardViewInfoArray.append((title:"Swing Score",value:StatsIntoConstants.swingScore))
                break
            case 1:
                self.cardViewInfoArray.append((title:"Clubhead Speed",value:StatsIntoConstants.clubheadSpeed))
                break
            case 2:
                self.cardViewInfoArray.append((title:"Club Plane",value:StatsIntoConstants.swingPath))
                break
            case 3:
                self.cardViewInfoArray.append((title:"Swing Tempo",value:StatsIntoConstants.clubTempo))
                break
            case 4:
                self.cardViewInfoArray.append((title:"Back Swing",value:StatsIntoConstants.backswingAngle))
                break
            case 5:
                self.cardViewInfoArray.append((title:"Hand Speed",value:StatsIntoConstants.gripSpeed))
                break
            default: break
            }
            let statsInfoButton = StatsInfoButton()
            statsInfoButton.frame = CGRect(x: self.view.frame.size.width-30, y: 16, width: 25, height: 25)
            statsInfoButton.setBackgroundImage(infoBtnImage, for: .normal)
            statsInfoButton.tintColor = UIColor.glfFlatBlue
            statsInfoButton.tag = i
            statsInfoButton.addTarget(self, action: #selector(self.infoClicked(_:)), for: .touchUpInside)
            shotTopViews[i].addSubview(statsInfoButton)
        }
        // --------------------------------------------------------------------------------------------

        let shotTopLbl1 = mapShotPopupView.viewWithTag(200)
        let shotTopLbl2 = mapShotPopupView.viewWithTag(201)
        let shotTopLbl3 = mapShotPopupView.viewWithTag(202)
        let shotTopLbl4 = mapShotPopupView.viewWithTag(203)
        let shotTopLbl5 = mapShotPopupView.viewWithTag(204)
        let shotTopLbl6 = mapShotPopupView.viewWithTag(205)
        shotTopLbls = [UILabel]()
        shotTopLbls = ([shotTopLbl1, shotTopLbl2, shotTopLbl3, shotTopLbl4, shotTopLbl5, shotTopLbl6] as! [UILabel])

        let shotBtnView1 = mapShotPopupView.viewWithTag(10)
        let shotBtnView2 = mapShotPopupView.viewWithTag(11)
        let shotBtnView3 = mapShotPopupView.viewWithTag(12)
        let shotBtnView4 = mapShotPopupView.viewWithTag(13)
        let shotBtnView5 = mapShotPopupView.viewWithTag(14)
        let shotBtnView6 = mapShotPopupView.viewWithTag(15)
        shotBtnViews = [UIView]()
        shotBtnViews = ([shotBtnView1, shotBtnView2, shotBtnView3, shotBtnView4, shotBtnView5, shotBtnView6] as! [UIView])

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
        shotBtnLbl3.text = "Comming Soon"//"\(scoreVal3)"

        let scoreVal4 =  self.shotsDetails[self.pageIndex][3] as! String
        let shotBtnLbl4 = mapShotPopupView.viewWithTag(43) as! UILabel
        shotBtnLbl4.text = "\(scoreVal4)"
        
        let scoreVal5 =  self.shotsDetails[self.pageIndex][4] as! String
        let shotBtnLbl5 = mapShotPopupView.viewWithTag(44) as! UILabel
        shotBtnLbl5.text = "\(Int(Double(scoreVal5)!.rounded(toPlaces: 2)))"
        
        let scoreVal6 =  self.shotsDetails[self.pageIndex][5] as! [Int]
        let finalScore6 = scoreVal6[3] as Int
        let shotBtnLbl6 = mapShotPopupView.viewWithTag(45) as! UILabel
        shotBtnLbl6.text = "\(finalScore6)"
        scoreTopLbls = ([shotBtnLbl1, shotBtnLbl2, shotTopLbl3, shotBtnLbl4, shotBtnLbl5,shotBtnLbl6] as! [UILabel])
        
        let shotLbl1 = mapShotPopupView.viewWithTag(555)
        let shotLbl2 = mapShotPopupView.viewWithTag(556)
        let shotLbl3 = mapShotPopupView.viewWithTag(557)
        let shotLbl4 = mapShotPopupView.viewWithTag(558)
        let shotLbl5 = mapShotPopupView.viewWithTag(559)
        let shotLbl6 = mapShotPopupView.viewWithTag(560)
        shotLbls = ([shotLbl1, shotLbl2, shotLbl3, shotLbl4, shotLbl5, shotLbl6] as! [UILabel])
        
        backSwingLbl = (mapShotPopupView.viewWithTag(1111) as! UILabel)
        downSwingLbl = (mapShotPopupView.viewWithTag(2222) as! UILabel)
        lblClubHead = (mapShotPopupView.viewWithTag(-1) as! UILabel)
        lblHandSpee = (mapShotPopupView.viewWithTag(-2) as! UILabel)
        
        let clubBtn1 = (mapShotPopupView.viewWithTag(-3) as! UIButton)
        let clubBtn2 = (mapShotPopupView.viewWithTag(-4) as! UIButton)
        let clubBtn3 = (mapShotPopupView.viewWithTag(-5) as! UIButton)
        let clubBtn4 = (mapShotPopupView.viewWithTag(-6) as! UIButton)
        var club = self.shotsDetails[self.pageIndex][6] as! String
        club = BackgroundMapStats.getClubName(club: club).uppercased()
        clubBtn1.setTitle(club, for: .normal)
        clubBtn2.setTitle(club, for: .normal)
        clubBtn3.setTitle(club, for: .normal)
        clubBtn4.setTitle(club, for: .normal)
        
        if Constants.distanceFilter == 1{
            lblClubHead.text = "KPH"
            lblHandSpee.text = "KPH"
        }
        swingScoreCircularView = (mapShotPopupView.viewWithTag(110) as! UICircularProgressRingView)
        swingScoreCircularView.fontColor = UIColor.clear
        swingScoreCircularView.innerCapStyle = .square
        swingScoreCircularView.outerCapStyle = .square
        
        swingAngleCircular_Red = (mapShotPopupView.viewWithTag(140) as! UICircularProgressRingView)
        swingAngleCircular_Red.fontColor = UIColor.clear
        swingAngleCircular_Red.innerCapStyle = .square
        
        swingAngleCircular_Blue = (mapShotPopupView.viewWithTag(4003) as! UICircularProgressRingView)
        swingAngleCircular_Blue.fontColor = UIColor.clear
        swingAngleCircular_Blue.innerCapStyle = .square
        
        backSwingUserImg = (mapShotPopupView.viewWithTag(4002) as! UIImageView)
        
        shotScrollView.addSubview(mapShotPopupView)
    }
    
    @objc func shotBtnAction(_ sender: UIButton!) {
        btnTapped(tagVal:sender.tag)
    }
    func getUserData(){
        let club = self.shotsDetails[self.pageIndex][6] as! String
            if club != "Pu" && !Constants.benchmark_Key.isEmpty{
                getBenchmarkData(benchMark: Constants.benchmark_Key, clubName:club)
            }
        }
    func getBenchmarkData(benchMark:String, clubName:String){
        
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "benchmarks/" + benchMark + "/" + clubName) { (snapshot) in
            self.benchMarkVal = snapshot.value as! String
            
            DispatchQueue.main.async(execute: {
                let scoreVal =  self.shotsDetails[self.pageIndex][1] as! [Int]
                let clubSpeed = Double(scoreVal[3])
                let clubSpeedTemp:Double = Double(self.benchMarkVal)!
                if(clubSpeedTemp*0.9<clubSpeed){
                    self.shotTopLbls[1].textColor = UIColor.glfGreenish
                    self.scoreTopLbls[1].textColor = UIColor.glfGreenish
                }else if(clubSpeedTemp*0.8<clubSpeed && clubSpeedTemp*0.9>clubSpeed){
                    self.shotTopLbls[1].textColor = UIColor.glfYellow
                    self.scoreTopLbls[1].textColor = UIColor.glfYellow
                }else if(clubSpeedTemp*0.8>clubSpeed){
                    self.shotTopLbls[1].textColor = UIColor.glfRed
                    self.scoreTopLbls[1].textColor = UIColor.glfRed
                }
                let scoreValT =  self.shotsDetails[self.pageIndex][3] as! String
                let tempo = Double(scoreValT)!
                if(tempo>=3.7 || tempo<=2.3){
                    self.shotTopLbls[3].textColor = UIColor.glfRed
                    self.scoreTopLbls[3].textColor = UIColor.glfRed
                }else if(tempo>=2.7 || tempo<=3.3){
                    self.shotTopLbls[3].textColor = UIColor.glfGreenish
                    self.scoreTopLbls[3].textColor = UIColor.glfGreenish
                }else{
                    self.shotTopLbls[3].textColor = UIColor.glfYellow
                    self.scoreTopLbls[3].textColor = UIColor.glfYellow
                }
                let scoreValBA = self.shotsDetails[self.pageIndex][4] as! String
                let backSwing = Double(scoreValBA)!
                if(Int(backSwing)>=260 && Int(backSwing)<=280){
                    self.shotTopLbls[4].textColor = UIColor.glfGreenish
                    self.scoreTopLbls[4].textColor = UIColor.glfGreenish
                }else if(Int(backSwing)>=245 && Int(backSwing)<=295){
                    self.shotTopLbls[4].textColor = UIColor.glfYellow
                    self.scoreTopLbls[4].textColor = UIColor.glfYellow
                }else{
                    self.shotTopLbls[4].textColor = UIColor.glfRed
                    self.scoreTopLbls[4].textColor = UIColor.glfRed
                }
            })
        }
    }

    func btnTapped(tagVal:Int) {
        //if tagVal != 22{
            
            for i in 0..<self.shotBtnViews.count{
                shotBtnViews[i].layer.cornerRadius = 3.0
                shotBtnViews[i].layer.borderWidth = 1.0
                shotBtnViews[i].layer.borderColor = UIColor(rgb: 0xDBE7EE).cgColor
                shotLbls[i].textColor = UIColor(rgb: 0xDBE7EE)
                
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
                        let scoreVal =  self.shotsDetails[self.pageIndex][1] as! [Int]
                        let clubSpeed = Double(scoreVal[3])
                        let clubSpeedTemp:Double = Double(self.benchMarkVal)!
                        if(clubSpeedTemp*0.9<clubSpeed){
                            self.shotBtnViews[i].layer.borderColor = UIColor.glfGreenish.cgColor
                            self.shotTopLbls[i].textColor = UIColor.glfGreenish
                            self.scoreTopLbls[i].textColor = UIColor.glfGreenish
                            self.shotLbls[i].textColor = UIColor.glfGreenish
                            self.lblClubHead.textColor = UIColor.glfGreenish
                        }else if(clubSpeedTemp*0.8<clubSpeed && clubSpeedTemp*0.9>clubSpeed){
                            self.shotBtnViews[i].layer.borderColor = UIColor.glfYellow.cgColor
                            self.shotTopLbls[i].textColor = UIColor.glfYellow
                            self.scoreTopLbls[i].textColor = UIColor.glfYellow
                            self.shotLbls[i].textColor = UIColor.glfYellow
                            self.lblClubHead.textColor = UIColor.glfYellow
                        }else if(clubSpeedTemp*0.8>clubSpeed){
                            self.shotBtnViews[i].layer.borderColor = UIColor.glfRed.cgColor
                            self.shotTopLbls[i].textColor = UIColor.glfRed
                            self.scoreTopLbls[i].textColor = UIColor.glfRed
                            self.shotLbls[i].textColor = UIColor.glfRed
                            self.lblClubHead.textColor = UIColor.glfRed
                        }
                    }else if tagVal+107 == 130{
                        DispatchQueue.main.async(execute: {
                            
                            let backSwingStr = self.shotsDetails[self.pageIndex][4] as! String
                            let downSwingStr = self.shotsDetails[self.pageIndex][7] as! String
                            let backSwing = Double(backSwingStr)!.rounded(toPlaces: 2) * 1000
                            let dowbSwing = Double(downSwingStr)!.rounded(toPlaces: 2) * 1000
                            
                            self.backSwingLbl.text = "\(Int(backSwing))MS"
                            self.downSwingLbl.text = "\(Int(dowbSwing))MS"
                            
                            let scoreVal =  self.shotsDetails[self.pageIndex][3] as! String
                            let tempo = Double(scoreVal)!
                            
                            if(tempo>=3.7 || tempo<=2.3){
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfRed.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfRed
                                self.shotTopLbls[i].textColor = UIColor.glfRed
                                self.shotLbls[i].textColor = UIColor.glfRed
                            }else if(tempo>=2.7 || tempo<=3.3){
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfGreenish.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfGreenish
                                self.shotTopLbls[i].textColor = UIColor.glfGreenish
                                self.shotLbls[i].textColor = UIColor.glfGreenish
                            }else{
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfYellow.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfYellow
                                self.shotTopLbls[i].textColor = UIColor.glfYellow
                                self.shotLbls[i].textColor = UIColor.glfYellow
                            }
                            
                        })
                    }
                    else if tagVal+116 == 140{
                        DispatchQueue.main.async(execute: {
                            let scoreVal =  self.shotsDetails[self.pageIndex][4] as! String
                            let backSwing = Double(scoreVal)!
                            if(Int(backSwing)>=260 && Int(backSwing)<=280){
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfGreenish.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfGreenish
                                self.shotTopLbls[i].textColor = UIColor.glfGreenish
                                self.shotLbls[i].textColor = UIColor.glfGreenish
                            }else if(Int(backSwing)>=245 && Int(backSwing)<=295){
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfYellow.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfYellow
                                self.shotTopLbls[i].textColor = UIColor.glfYellow
                                self.shotLbls[i].textColor = UIColor.glfYellow
                            }else{
                                self.shotBtnViews[i].layer.borderColor = UIColor.glfRed.cgColor
                                self.scoreTopLbls[i].textColor = UIColor.glfRed
                                self.shotTopLbls[i].textColor = UIColor.glfRed
                                self.shotLbls[i].textColor = UIColor.glfRed
                            }
                            self.setBackSwingAngleDesign(backSwingAngle:backSwing)
                        })
                    }
                    else if tagVal+125 == 150{

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
//            else if tagVal+180 == 202{
//                let scoreVal =  self.shotsDetails[self.pageIndex][2] as! String
//                shotTopLbls[2].text = "\(scoreVal)"
//            }
            else if tagVal+180 == 203{
                let scoreVal =  self.shotsDetails[self.pageIndex][3] as! String
                shotTopLbls[3].text = "\(scoreVal) : 1"
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
        //}
    }
    func setBackSwingAngleDesign(backSwingAngle:Double){
        swingAngleCircular_Red.shouldShowValueText = false
        swingAngleCircular_Blue.shouldShowValueText = false
        self.backSwingClub = UIImageView.init(image: UIImage(named: "club_horizontal"))
        backSwingClub.tag = 23
        for view in self.swingAngleCircular_Red.subviews where view is UIImageView{
            if view.tag == 23 {
                view.removeFromSuperview()
            }
        }
        var setBackSwingProgress = backSwingAngle*75/270;
        if(backSwingAngle>270){
            setBackSwingProgress = backSwingAngle*80/270;
        }
        let swing = Double(setBackSwingProgress * 62 / 100)
        DispatchQueue.main.async {
            self.swingAngleCircular_Red.setProgress(value:0, animationDuration:0)
            self.swingAngleCircular_Blue.setProgress(value:0, animationDuration:0)
            if(swing>=46){
                self.swingAngleCircular_Red.setProgress(value:(CGFloat(46 + (Int(swing)-46)/2)), animationDuration:2)
                self.swingAngleCircular_Blue.setProgress(value: 46, animationDuration: 1)
            }else{
                self.swingAngleCircular_Red.setProgress(value:46,animationDuration:2)
                self.swingAngleCircular_Blue.setProgress(value:CGFloat(swing), animationDuration:1)
            }
        }
        let newSwing = ceil(backSwingAngle/10)*10
        if backSwingAngle >= 0 && backSwingAngle < 100{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_0_100")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.maxY*0.485
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width*0.9
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
            backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(-90)) / 180.0 * CGFloat(Double.pi))
//            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(backSwingAngle-90)) / 180.0 * CGFloat(Double.pi))
//            }
        }else if backSwingAngle >= 100 && backSwingAngle < 200{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_100_200")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.maxY*0.285
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
//            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(newSwing-100)) / 180.0 * CGFloat(Double.pi))
//            }
        }else if backSwingAngle >= 200 && backSwingAngle < 350{
            self.backSwingUserImg.image = UIImage(named: "backswing_image_190_290")
            backSwingClub.frame.origin.y = self.backSwingUserImg.frame.minY-backSwingClub.frame.height*0.5
            backSwingClub.frame.origin.x = self.backSwingUserImg.frame.minX-backSwingClub.frame.width*0.8
            backSwingClub.layoutIfNeeded()
            BackgroundMapStats.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1), view: backSwingClub)
//            UIView.animate(withDuration: 1) {
                self.backSwingClub.transform = CGAffineTransform(rotationAngle: (CGFloat(newSwing-100)) / 180.0 * CGFloat(Double.pi))
//            }
        }
        self.swingAngleCircular_Red.addSubview(backSwingClub)
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
