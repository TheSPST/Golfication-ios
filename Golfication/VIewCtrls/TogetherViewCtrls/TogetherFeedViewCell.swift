//
//  TogetherFeedViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
class TogetherFeedViewCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblScoreTitle: UILabel!
//    @IBOutlet weak var scoreView1: UIView!
//    @IBOutlet weak var scoreView2: UIView!
    
    @IBOutlet weak var scoreView1: UIStackView!
    @IBOutlet weak var scoreView2: UIStackView!
    
    @IBOutlet weak var scoreView1Par: UIStackView!
    @IBOutlet weak var scoreView1Shots: UIStackView!
    
    @IBOutlet weak var scoreView2Par: UIStackView!
    @IBOutlet weak var scoreView2Shots: UIStackView!
    
    @IBOutlet weak var cardView: CardView!
    let borderWidth:CGFloat = 2.0
    
    @IBOutlet weak var stackViewToClick: StackView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var btnScoreCard: UIButton!

    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var shareImageHConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblSharedMsg: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        userImg.setCircle(frame: userImg.frame)
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureWithItems(feeds:Feeds){
        
        if (feeds.userImage != nil) {
//            Alamofire.request(feeds.userImage!).responseImage { response in
//                debugPrint(response)
//                if let image = response.result.value {
//                    let scaledImage = image.af_imageScaled(to: CGSize(width: (self.userImg.frame.size.width), height: (self.userImg.frame.size.height)))
//                    self.userImg.image = scaledImage
//                }
//            }
            self.userImg.sd_setImage(with: URL(string:feeds.userImage!), completed: nil)
            self.userName.text = feeds.userName
            //let userName = NSMutableAttributedString(string: "\(feeds.userName ?? "") at ", attributes: yourAttributes)
            //let locations = NSMutableAttributedString(string: "\(feeds.location ?? "") ", attributes: yourOtherAttributes)
            let subtitle = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
            if((feeds.location) != nil){
                self.lblSubtitle.text = "\(subtitle) at \(feeds.location!)"
            }
        }
        if(feeds.locationKey == nil){
//        for view in self.scoreView1.subviews{
//            view.removeFromSuperview()
//        }
//        for view in self.scoreView2.subviews{
//            view.removeFromSuperview()
//        }
        
        let width = Double(self.scoreView1.frame.width) * 0.7
        var offset = Double(self.scoreView1.frame.width) * 0.3 / 8
        if(UIDevice.current.iPhone5){
            offset = 3
        }
        let height = Double(self.scoreView1.frame.height)
        var x = 0.0
        if let holesData = (feeds.holeShotsArray){
            var shotSum = 0
            var parSum = 0
            for i in 0..<holesData.count{
                let shotsNumber = UIButton()
                let parNumber = UILabel()
                shotsNumber.setTitleColor(UIColor.glfBlack, for: .normal)
                parNumber.textAlignment = .center
                shotsNumber.titleLabel?.font = UIFont(name: "SFProDisplay-Heavy", size: FONT_SIZE)
                parNumber.textColor = UIColor.glfFlatBlue
                shotsNumber.setTitle("-", for: .normal)
                parNumber.frame = CGRect(x: x, y: 0, width: height/2, height: height/2)
                shotsNumber.frame = CGRect(x: x, y: Double(parNumber.frame.maxY), width: height/2, height: height/2)
                parNumber.font = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)
                parNumber.text = "\(holesData[i].par!)"
                let layer = CALayer()
                layer.frame = CGRect(x: 3, y:  3, width: shotsNumber.frame.width - 6, height: shotsNumber.frame.height - 6)
                layer.borderColor = UIColor.black.cgColor
                shotsNumber.layer.addSublayer(layer)
                shotsNumber.tag = i + 1
                shotsNumber.layer.borderColor = UIColor.black.cgColor
                
                if(holesData[i].shot != 0){
                    shotSum += holesData[i].shot
                    parSum += holesData[i].par
                    shotsNumber.setTitle("\(holesData[i].shot!)", for: .normal)
                    self.updateButtons(allScore: holesData[i].par-holesData[i].shot, holeLbl: shotsNumber)
                }else{
                    self.scoreView1.addSubview(shotsNumber)
                    self.scoreView1.addSubview(parNumber)
                }
                if(i < 9){
                    x += offset + width/9
                    self.scoreView1.addSubview(shotsNumber)
                    self.scoreView1.addSubview(parNumber)
                    if(i == 8){
                        x = 0.0
                    }
                }
                else{
                    x += offset + width/9
                    self.scoreView2.addSubview(shotsNumber)
                    self.scoreView2.addSubview(parNumber)
                }
            }
            self.scoreView2.isHidden = false
            self.scoreView1.isHidden = false
            self.shareImageView.isHidden = true
            
            if(holesData.count == 9){
                self.scoreView2.isHidden = true
                //self.heightOfCardView.constant = self.heightOfCardView.constant - 60
            }
            let shotDetails = shotSum > parSum ? "-over":"-under"
            let anoterString = shotSum > parSum ? "\(shotSum-parSum)":"\(parSum-shotSum)"
            self.lblScoreTitle.text =  "\(anoterString) \(shotDetails) \(parSum)"
            if(shotSum-parSum) == 0{
                self.lblScoreTitle.text =  "Even par \(parSum)"
            }
            }
        }
        else{
            self.scoreView2.isHidden = true
            self.scoreView1.isHidden = true
            self.shareImageView.isHidden = false
 
            if (feeds.locationKey != nil) {
//                Alamofire.request(feeds.locationKey!, method: .get).responseImage { response in
//                    guard let image = response.result.value else {
//                        // Handle error
//                        return
//                    }
                    // Do stuff with your image
                    self.shareImageView.sd_setImage(with: URL(string: feeds.locationKey!), completed: nil)
                    self.shareImageHConstraint.constant = 300
                    self.layoutIfNeeded()
//                }
            }
        }
    }
    
    func updateButtons(allScore:Int,holeLbl:UIButton){
        
        if allScore < -1{
            //double square
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = borderWidth
                    layer.borderColor = UIColor.glfRosyPink.cgColor
                }
            }
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfRosyPink.cgColor
            holeLbl.titleLabel?.layer.borderWidth = 0
            
        }
            
        else if allScore == -1{
            //single square
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfRosyPink.cgColor
            holeLbl.titleLabel?.layer.borderWidth = 0
        }
        else if allScore == 1{
            //single circle
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.titleLabel?.layer.borderWidth = 0
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfPaleTeal.cgColor
            holeLbl.layer.cornerRadius = holeLbl.frame.size.height/2
        }
        else if allScore > 1{
            //double circle
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = borderWidth
                    layer.borderColor = UIColor.glfPaleTeal.cgColor
                    layer.cornerRadius = layer.frame.height/2
                }
            }
            holeLbl.titleLabel?.layer.borderWidth = 0
            holeLbl.layer.borderWidth = borderWidth
            holeLbl.layer.borderColor = UIColor.glfPaleTeal.cgColor
            holeLbl.layer.cornerRadius = holeLbl.frame.size.height/2
        }else{
            if let layers = holeLbl.layer.sublayers{
                for layer in layers{
                    layer.borderWidth = 0
                }
            }
            holeLbl.layer.borderWidth = 0
            holeLbl.titleLabel?.layer.borderWidth = 0
        }
    }
}

