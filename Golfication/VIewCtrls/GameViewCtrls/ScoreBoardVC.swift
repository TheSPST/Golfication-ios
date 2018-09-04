//
//  ScoreBoardVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/12/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import FirebaseAuth

class BottomViewInScore:UIView{
    let btn = UIButton()
    init(){
        super.init(frame: .zero)
        btn.backgroundColor = UIColor.glfBluegreen
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(UIColor.glfWhite, for: .normal)
//        btn.layer.cornerRadius = 15
        backgroundColor = UIColor.glfBlack75
        
        addSubview(btn)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ScoreBoardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var playerData = NSMutableArray()
    let bView = BottomViewInScore()
    var scrollView: UIScrollView!
    var tblView: UITableView!
    var superView : Bool!
    let kHeaderSectionTag: Int = 6900
    
    var menueTableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    
    var plyerViseScore = [[(gir:Bool,fairwayHit:String)]]()
    var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    
    let padding: CGFloat = 10.0
    let width: CGFloat = 50.0

    /*func scrollViewDidEndDragging(_ scrollView1: UIScrollView,
     willDecelerate decelerate: Bool)
     {
     scrollView = (scrollView1 == tblView) ? menueTableView : tblView
     scrollView.setContentOffset(scrollView1.contentOffset, animated: false)
     
     /*let x =  CGFloat(self.pageControl.currentPage) * (pageWidth - 20)
     scrollView.setContentOffset(CGPoint(x:x, y:0), animated: false)*/
     }*/
    
    func scrollViewDidScroll(_ scrollView1: UIScrollView)
    {
        //http://jayeshkawli.ghost.io/manually-scrolling-uiscrollview-ios-swift/
        //https://stackoverflow.com/questions/6949142/iphone-how-to-scroll-two-uitableviews-symmetrically
        
        if (!(scrollView1.contentOffset.x>0 || scrollView1.contentOffset.x<0)) && scrollView1 == self.menueTableView {
           tblView.isScrollEnabled = true

           self.scrollView = (scrollView1 == self.menueTableView) ? self.tblView : scrollView1
           self.scrollView.setContentOffset(scrollView1.contentOffset, animated: false)
        }
        else
        {
            tblView.isScrollEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
           self.navigationController?.navigationBar.isHidden = false
    }
    @objc func btnContinueAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "continueAction"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.glfBluegreen
        // Do any additional setup after loading the view.
        bView.frame = CGRect(x: 0, y: self.view.frame.height-40, width: self.view.frame.width, height: 40)
        bView.btn.frame = CGRect(x: 0, y: 0, width: bView.frame.size.width, height: bView.frame.size.height)
        bView.btn.addTarget(self, action: #selector(btnContinueAction), for: .touchUpInside)

        bView.isHidden = true
        for data in playerData{
            if let player = data as? NSMutableDictionary{
                let id = player.value(forKey: "id") as! String
                if id == Auth.auth().currentUser!.uid{
                    let status = player.value(forKey: "status") as! Int
                    if status == 2{
                        bView.isHidden = false
                        break
                    }
                }
            }
        }
        self.title = "Your Scorecard"
        self.view.backgroundColor = UIColor(rgb: 0xF8F8F7)
        self.navigationController?.navigationBar.backItem?.title = ""
        self.automaticallyAdjustsScrollViewInsets = false

        let tempDic = NSMutableDictionary()
        tempDic.setObject("parId", forKey: "id" as NSCopying)
        tempDic.setObject("Par", forKey: "name" as NSCopying)
        sectionNames.insert(tempDic, at: 0)
        
        for i in 0..<playerData.count{
            
            sectionNames.insert(playerData[i], at: i+1)
        }
        debugPrint("sectionNames== ",sectionNames)

        //debugPrint("mode== ",mode) // mode 3 = classic, mode 1 = Advance, mode 3 = Rf
        sectionItems = [[],["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Drive Accuracy","GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        if mode == 1{
        sectionItems = [[],["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"],
                        ["Driving Distance", "Drive Accuracy", "Approach Distance", "GIR", "Chip/Down", "Sand/Down", "Putts","Penalty"]]
        }
        menueTableView =  UITableView(frame: CGRect(x: 0, y: 64+10, width: 180, height: self.view.frame.size.height-(64+10)), style: .grouped)
        menueTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenueCell")
        menueTableView.dataSource = self
        menueTableView.delegate = self
        menueTableView.tag = 0
        menueTableView.backgroundColor = UIColor.clear
        menueTableView.separatorStyle = .none
        //menueTableView.alwaysBounceVertical = false
        menueTableView.showsVerticalScrollIndicator = false
        self.menueTableView!.tableFooterView = UIView()
        view.addSubview(menueTableView)
        
        scrollView =  UIScrollView(frame: CGRect(x: menueTableView.frame.origin.x + menueTableView.frame.size.width, y: menueTableView.frame.origin.y, width: view.frame.size.width - menueTableView.frame.size.width-2, height: menueTableView.frame.size.height-40))
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        view.addSubview(bView)
        var tableWidth = CGFloat()
        for i in 0..<scoreData.count{
            
            tableWidth = 10+(width+padding)*CGFloat(i+2)
        }
        tblView =  UITableView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: scrollView.frame.size.height), style: .grouped)
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "DataCell")
        tblView.dataSource = self
        tblView.delegate = self
        tblView.tag = 1
        tblView.backgroundColor = UIColor.clear
        tblView.separatorColor = UIColor(rgb: 0x01AD8C)
        tblView.alwaysBounceVertical = false
        tblView.tableFooterView = UIView()
        scrollView.addSubview(tblView)
        
        scrollView.contentSize = CGSize(width: tblView.frame.size.width, height: tblView.frame.size.height)
        
        let imgView = UIImageView()
        self.expandedSectionHeaderNumber = 1
        tableViewExpandSection(1, imageView: imgView)
    }
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.menueTableView.backgroundView = messageLabel
            self.tblView.backgroundView = messageLabel
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 0
        }
        else if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let header = UIView()
        header.backgroundColor = UIColor.white
        
        if tableView.tag == 0 {
            
            let usrImageView = UIImageView(frame: CGRect(x: 10, y: 6, width: 32, height: 32))
            usrImageView.setCircle(frame: usrImageView.frame)
            if section != 0{
                usrImageView.image = #imageLiteral(resourceName: "you")
                if let url = (self.sectionNames[section] as AnyObject).value(forKey: "image") as? String{
                    usrImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "you"), completed: nil)
                    if url == ""{
                        usrImageView.image = #imageLiteral(resourceName: "you")
                    }
                }
                usrImageView.tag = kHeaderSectionTag + section
                let label = UILabel()
                
                label.frame = CGRect(x: usrImageView.frame.origin.x + usrImageView.frame.size.width+10, y: 13, width: 80, height: 15)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.textColor = UIColor.glfBluegreen
                label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                header.addSubview(label)
                
                //header.textLabel?.textColor = UIColor.blue
                
                if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
                    viewWithTag.removeFromSuperview()
                }
                let headerFrame = self.menueTableView.frame.size
                
                let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18))
                theImageView.image = UIImage(named: "Chevron-Dn-Wht")
                theImageView.tag = kHeaderSectionTag + section
                
                header.addSubview(theImageView)
                header.addSubview(usrImageView)
                
                // make headers touchable
                header.tag = section
                let headerTapGesture = UITapGestureRecognizer()
                headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
                header.addGestureRecognizer(headerTapGesture)
                
//                UIView.animate(withDuration: 0.4, animations: {
//                    theImageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//                })
//                if (self.expandedSectionHeaderNumber == section) {
//                    UIView.animate(withDuration: 0.4, animations: {
//                        theImageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//                    })
//                }
               }
            else{
                let label = UILabel()
                
                label.frame = CGRect(x: usrImageView.frame.origin.x + usrImageView.frame.size.width+10, y: 16, width: 80, height: 15)
                label.text = (self.sectionNames[section] as AnyObject).value(forKey: "name") as? String
                label.sizeToFit()
                header.addSubview(label)
                let holeLbl = UILabel()
                holeLbl.frame = CGRect(x: label.frame.origin.x + label.frame.size.width+5, y: 5, width: 80, height: 15)
                holeLbl.textColor = UIColor.glfBluegreen
                holeLbl.text = "Hole"
                header.addSubview(holeLbl)
            }
        }
        else{
            if section == 0{
                header.backgroundColor = UIColor.white
                //header.textLabel?.textColor = UIColor.black
                
                for i in 0..<scoreData.count{
                    //var scoreData = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
                    let label =  UILabel(frame: CGRect(x: 10+(width + padding)*CGFloat(i), y: 20, width: 50, height: 15))
                    label.text = "\(self.scoreData[i].par)"
                    label.textAlignment = .center
                    label.textColor = UIColor.black
                    header.addSubview(label)
                }
                let label =  UILabel(frame: CGRect(x: 10+(width + padding)*CGFloat(scoreData.count), y: 20, width: 50, height: 15))
                label.text = "Total"
                label.textAlignment = .center
                label.textColor = UIColor.black
                header.addSubview(label)

                for i in 0..<scoreData.count{
                    
                    let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 7, width: 50, height: 15))
                    label.text = "\(i+1)"
                    label.textAlignment = .center
                    label.textColor = UIColor.glfBluegreen
                    
                    header.addSubview(label)
                }
            }
            else{
                header.backgroundColor = UIColor(rgb: 0x2E9F80)
                
                let playerId = (self.sectionNames[section] as AnyObject).value(forKey: "id") as? String
                for view in header.subviews{
                    if view.isKind(of: UILabel.self){
                        view.removeFromSuperview()
                    }
                }
                
                var totalStrokes = 0
                for i in 0..<self.scoreData.count{
                    
                    let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(i), y: 5, width: 35, height: 35))
                    subView.backgroundColor = UIColor.clear
                    header.addSubview(subView)
                    
                    let btn =  UIButton(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
                    btn.titleLabel?.textAlignment = .center
                    btn.titleLabel?.textColor = UIColor.white
                    btn.setTitle("-", for: .normal)
                    subView.addSubview(btn)
                    
                    for dataDict in self.scoreData[i].players{
                        for (key,value) in dataDict{
                            
                            let dic = value as! NSDictionary
                            if dic.value(forKey: "holeOut") as! Bool == true{
                                
                                if(key as? String == playerId){
                                    
                                    if(key as? String == playerId){
                                        
                                        for (key,value) in value as! NSMutableDictionary
                                        {
                                            var totalShots = 0
                                            var allScore = Int()
                                            if(key as! String == "shots"){
                                                let shotsArray = value as! NSArray
                                                allScore  = shotsArray.count - (self.scoreData[i].par)
                                                totalShots = shotsArray.count
                                                btn.setTitle("\(totalShots)", for: .normal)
                                                
                                                totalStrokes += totalShots
                                            }
                                            else if (key as! String == "strokes"){
                                                allScore  = (value as! Int) - (self.scoreData[i].par)
                                                totalShots = (value as! Int)
                                                btn.setTitle("\(totalShots)", for: .normal)
                                                
                                                totalStrokes += totalShots
                                            }
                                            if allScore <= -2 || allScore <= -3{
                                                //double circle
                                                subView.layer.borderWidth = 1.0
                                                subView.layer.cornerRadius = subView.frame.size.height/2
                                                subView.layer.borderColor = UIColor.white.cgColor
                                                
                                                btn.layer.borderWidth = 1.0
                                                btn.layer.cornerRadius = btn.frame.size.height/2
                                                btn.layer.borderColor = UIColor.white.cgColor
                                            }
                                            else if allScore == -1{
                                                //single circle
                                                btn.layer.borderWidth = 1.0
                                                btn.layer.cornerRadius = btn.frame.size.height/2
                                                btn.layer.borderColor = UIColor.white.cgColor
                                            }
                                            else if allScore == 1{
                                                //single square
                                                btn.layer.borderWidth = 1.0
                                                btn.layer.borderColor = UIColor.white.cgColor
                                            }
                                            else if allScore >= 2 || allScore >= 3{
                                                //double square
                                                subView.layer.borderWidth = 1.0
                                                subView.layer.borderColor = UIColor.white.cgColor
                                                btn.layer.borderWidth = 1.0
                                                btn.layer.borderColor = UIColor.white.cgColor
                                            }
                                            else{
                                                // do nothing
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let subView =  UIView(frame: CGRect(x: 25+(width + padding)*CGFloat(scoreData.count), y: 5, width: 35, height: 35))
                subView.backgroundColor = UIColor.clear
                header.addSubview(subView)
                let btn =  UIButton(frame: CGRect(x: 3, y: 5, width: 25, height: 25))
                btn.titleLabel?.textAlignment = .center
                btn.titleLabel?.textColor = UIColor.white
                btn.setTitle("-", for: .normal)
                btn.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 16.0)
                if totalStrokes > 0{
                    btn.setTitle("\(totalStrokes)", for: .normal)
                }
                subView.addSubview(btn)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 32.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String
        
        if tableView.tag == 0 {
            cellIdentifier = "MenueCell"
        }
        else{
            cellIdentifier = "DataCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.section > 0{
            
            if tableView.tag == 0 {
                let section = self.sectionItems[indexPath.section] as! NSArray
                cell.textLabel?.text = section[indexPath.row] as? String
                
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
            }
            else{
                cell.backgroundColor = UIColor(rgb: 0x2E9F80)
                cell.textLabel?.textColor = UIColor.clear
                cell.textLabel?.text = ""
                let playerId = (self.sectionNames[indexPath.section] as AnyObject).value(forKey: "id") as? String
                
                for subView in cell.contentView.subviews{
                    subView.removeFromSuperview()
                }
                var drDistance = 0
                var drivingCount = 0
                var frwHit = 0
                var aprchDistance = 0
                var aprchCount = 0
                var girTotal = 0
                var chipDown = 0
                var sandTotal = 0
                var puttsTotal = 0
                var penaltyTotal = 0
                for i in 0..<scoreData.count{

                    let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 40, height: 32))
                    label.text = "-"
                    label.textAlignment = .center
                    label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                    label.textColor = UIColor.white
                    label.backgroundColor = UIColor.clear
                    cell.contentView.addSubview(label)
                    
                    let theImageView = UIButton(frame: CGRect(x: 20+(width + padding)*CGFloat(i), y: 0, width: 32, height: 32))
                    
                    for dataDict in self.scoreData[i].players{

                        for (key,value) in dataDict{

                            var imgArray = [#imageLiteral(resourceName: "hit"),#imageLiteral(resourceName: "gir_false")]
                            if(key as? String == playerId){
                                if let dict = value as? NSMutableDictionary{
                                for (key,value) in dict{
                                    if mode == 1{
                                    if indexPath.row == 0{
                                        if(key as! String == "drivingDistance"){
                                            var drivingDistance = value as! Double
                                            var suffix = "m"
                                            if(distanceFilter != 1){
                                                drivingDistance = drivingDistance*YARD
                                                suffix = "yd"
                                            }
                                            label.text = "\(Int(drivingDistance))\(suffix)"
                                            drDistance += (Int(drivingDistance))
                                            drivingCount += 1
                                        }
                                    }
                                    else if indexPath.row == 1{
                                        if(key as! String == "fairway"){
                                            let fairway = value as! String
                                            label.text = ""
                                            if(fairway == "H"){
                                                let backBtnImage1 = #imageLiteral(resourceName: "hit").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                theImageView.setImage(backBtnImage1, for: .normal)
                                                frwHit += 1

                                            }else if(fairway == "L"){
                                                let backBtnImage1 = #imageLiteral(resourceName: "fairway_left").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                theImageView.setImage(backBtnImage1, for: .normal)
                                            }else{
                                                let backBtnImage1 = #imageLiteral(resourceName: "fairway_right").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                theImageView.setImage(backBtnImage1, for: .normal)
                                            }
                                            theImageView.tintColor = UIColor.glfWhite
                                            theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                            cell.contentView.addSubview(theImageView)
                                        }
                                    }
                                    else if indexPath.row == 2{
                                        if(key as! String == "approachDistance"){
                                            var approchDist = value as! Double
                                            var suffix = "m"
                                            if(distanceFilter != 1){
                                                approchDist = approchDist*YARD
                                                suffix = "yd"
                                            }
                                            label.text = "\(Int(approchDist))\(suffix)"
                                            aprchDistance += (Int(approchDist))
                                            aprchCount += 1
                                        }
                                    }
                                    else if indexPath.row == 3{
                                        if(key as! String == "gir"){
                                            let gir = value as! Bool
                                            label.text = ""
                                            if gir{
                                                let originalImage1 = imgArray[0]
                                                let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                theImageView.setImage(backBtnImage1, for: .normal)
                                                girTotal += 1
                                            }else{
                                                let originalImage1 = imgArray[1]
                                                let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                theImageView.setImage(backBtnImage1, for: .normal)
                                            }
                                            theImageView.tintColor = UIColor.glfWhite
                                            theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                            cell.contentView.addSubview(theImageView)
                                        }
                                    }
                                    else if indexPath.row == 4{
                                        if(key as! String == "chipUpDown"){
                                            if let chipUpDown = value as? Bool{
                                                label.text = ""
                                                if chipUpDown{
                                                    let originalImage1 = imgArray[0]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    theImageView.setImage(backBtnImage1, for: .normal)
                                                    chipDown += 1
                                                }else{
                                                    let originalImage1 = imgArray[1]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    theImageView.setImage(backBtnImage1, for: .normal)
                                                }
                                                theImageView.tintColor = UIColor.glfWhite
                                                theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                cell.contentView.addSubview(theImageView)
                                            }
                                        }
                                    }
                                    else if indexPath.row == 5{
                                        if(key as! String == "sandUpDown"){
                                            if let sandDown = value as? Bool{
                                                label.text = ""
                                                if sandDown{
                                                    let originalImage1 = imgArray[0]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    theImageView.setImage(backBtnImage1, for: .normal)
                                                    sandTotal += 1
                                                }else{
                                                    let originalImage1 = imgArray[1]
                                                    let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                    theImageView.setImage(backBtnImage1, for: .normal)
                                                }
                                                theImageView.tintColor = UIColor.glfWhite
                                                theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                cell.contentView.addSubview(theImageView)
                                            }
                                        }
                                    }
                                    else if indexPath.row == 6{
                                        if(key as! String == "putting"){
                                            let approchDist = value as! Int
                                            label.text = "\(approchDist)"
                                            puttsTotal += approchDist
                                        }
                                    }
                                    else if indexPath.row == 7{
                                        if(key as! String == "penaltyCount"){
                                            let approchDist = value as! Int
                                            label.text = "\(approchDist)"
                                            penaltyTotal += approchDist
                                        }
                                    }
                                    }
                                    else{
                                            if indexPath.row == 0{
                                                if(key as! String == "fairway"){
                                                    let fairway = value as! String
                                                    label.text = ""
                                                    if(fairway == "H"){
                                                        let backBtnImage1 = #imageLiteral(resourceName: "hit").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        theImageView.setImage(backBtnImage1, for: .normal)
                                                        frwHit += 1
                                                        
                                                    }else if(fairway == "L"){
                                                        let backBtnImage1 = #imageLiteral(resourceName: "fairway_left").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        theImageView.setImage(backBtnImage1, for: .normal)
                                                    }else{
                                                        let backBtnImage1 = #imageLiteral(resourceName: "fairway_right").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        theImageView.setImage(backBtnImage1, for: .normal)
                                                    }
                                                    theImageView.tintColor = UIColor.glfWhite
                                                    theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                    cell.contentView.addSubview(theImageView)
                                                }
                                            }
                                            else if indexPath.row == 1{
                                                if(key as! String == "gir"){
                                                    let gir = value as! Bool
                                                    label.text = ""
                                                    if gir{
                                                        let originalImage1 = imgArray[0]
                                                        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        theImageView.setImage(backBtnImage1, for: .normal)
                                                        girTotal += 1
                                                    }else{
                                                        let originalImage1 = imgArray[1]
                                                        let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                        theImageView.setImage(backBtnImage1, for: .normal)
                                                    }
                                                    theImageView.tintColor = UIColor.glfWhite
                                                    theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                    cell.contentView.addSubview(theImageView)
                                                }

                                            }
                                            else if indexPath.row == 2{
                                                if(key as! String == "chipUpDown"){
                                                    if let chipUpDown = value as? Bool{
                                                        label.text = ""
                                                        if chipUpDown{
                                                            let originalImage1 = imgArray[0]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            theImageView.setImage(backBtnImage1, for: .normal)
                                                            chipDown += 1
                                                        }else{
                                                            let originalImage1 = imgArray[1]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            theImageView.setImage(backBtnImage1, for: .normal)
                                                        }
                                                        theImageView.tintColor = UIColor.glfWhite
                                                        theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(theImageView)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 3{
                                                if(key as! String == "sandUpDown"){
                                                    if let sandDown = value as? Bool{
                                                        label.text = ""
                                                        if sandDown{
                                                            let originalImage1 = imgArray[0]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            theImageView.setImage(backBtnImage1, for: .normal)
                                                            sandTotal += 1
                                                        }else{
                                                            let originalImage1 = imgArray[1]
                                                            let backBtnImage1 = originalImage1.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                                            theImageView.setImage(backBtnImage1, for: .normal)
                                                        }
                                                        theImageView.tintColor = UIColor.glfWhite
                                                        theImageView.imageView?.tintImageColor(color: UIColor.glfWhite)
                                                        cell.contentView.addSubview(theImageView)
                                                    }
                                                }
                                            }
                                            else if indexPath.row == 4{
                                                if(key as! String == "putting"){
                                                    let approchDist = value as! Int
                                                    label.text = "\(approchDist)"
                                                    puttsTotal += approchDist
                                                }
                                            }
                                            else if indexPath.row == 5{
                                                if(key as! String == "penaltyCount"){
                                                    let approchDist = value as! Int
                                                    label.text = "\(approchDist)"
                                                    penaltyTotal += approchDist
                                                }
                                            }
                                      }
                                    }
                                }
                            }
                        }
                    }
                }
                let label =  UILabel(frame: CGRect(x: 20+(width + padding)*CGFloat(scoreData.count), y: 0, width: 40, height: 32))
                label.text = "-"
                
                if mode == 1{
                if indexPath.row == 0{
                    if drDistance>0{
                        var suffix = "m"
                        if(distanceFilter != 1){
                            suffix = "yd"
                        }
                        label.text = "\(Int(drDistance/drivingCount))\(suffix)"
                    }
                }
                else if indexPath.row == 1{
                    if frwHit>0{
                        label.text = "\(frwHit)"
                    }
                }
                else if indexPath.row == 2{
                    if aprchDistance>0{
                        var suffix = "m"
                        if(distanceFilter != 1){
                            suffix = "yd"
                        }
                        label.text = "\(Int(aprchDistance/aprchCount))\(suffix)"
                    }
                }
                else if indexPath.row == 3{
                    if girTotal>0{
                        label.text = "\(girTotal)"
                    }
                }
                else if indexPath.row == 4{
                    if chipDown>0{
                        label.text = "\(chipDown)"
                    }
                }
                else if indexPath.row == 5{
                    if sandTotal>0{
                        label.text = "\(sandTotal)"
                    }
                }
                else if indexPath.row == 6{
                    if puttsTotal>0{
                    label.text = "\(puttsTotal)"
                    }
                }
                else if indexPath.row == 7{
                    if penaltyTotal>0{
                    label.text = "\(penaltyTotal)"
                    }
                }
                }
                else{
                        if indexPath.row == 0{
                            if frwHit>0{
                                label.text = "\(frwHit)"
                            }
                        }
                        else if indexPath.row == 1{
                            if girTotal>0{
                                label.text = "\(girTotal)"
                            }
                        }
                        else if indexPath.row == 2{
                            if chipDown>0{
                                label.text = "\(chipDown)"
                            }
                        }
                        else if indexPath.row == 3{
                            if sandTotal>0{
                                label.text = "\(sandTotal)"
                            }
                        }
                        else if indexPath.row == 4{
                            if puttsTotal>0{
                            label.text = "\(puttsTotal)"
                            }
                        }
                        else if indexPath.row == 5{
                            if penaltyTotal>0{
                            label.text = "\(penaltyTotal)"
                            }
                        }
                }
                label.textAlignment = .center
                label.textColor = UIColor.white
                label.font = UIFont(name: "SFProDisplay-Regular", size: 14.0)
                label.backgroundColor = UIColor.clear
                cell.contentView.addSubview(label)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        //let headerView = sender.view as! UITableViewHeaderFooterView
        let headerView = sender.view
        
        let section    = headerView?.tag
        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section!
            tableViewExpandSection(section!, imageView: eImageView!)
        }
        else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section!, imageView: eImageView!)
            }
            else {
//                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: eImageView!)
                tableViewExpandSection(section!, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1
        if (sectionData.count == 0) {
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.menueTableView!.beginUpdates()
            self.menueTableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1
            return
        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            
            self.menueTableView!.beginUpdates()
            self.menueTableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.menueTableView!.endUpdates()
            
            self.tblView!.beginUpdates()
            self.tblView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tblView!.endUpdates()
        }
    }
}
