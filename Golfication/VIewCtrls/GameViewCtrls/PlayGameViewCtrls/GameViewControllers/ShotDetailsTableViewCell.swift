//
//  ShotDetailsTableViewCell.swift
//  Golfication
//
//  Created by Khelfie on 29/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class ShotDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblShot: UILabel!
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblLandedOn: UILabel!
    @IBOutlet weak var lblStrokesGained: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblShot.setCircle(frame: self.lblShot.frame)
        self.lblLandedOn.setCornerWithRadius(color: UIColor.clear.cgColor, radius: self.lblLandedOn.frame.height/2)
    }
    func initDesign(shot:String,club:String,distance:String,landedOn:String,color:UIColor,sg:String){
        self.lblClubName.text = club
        self.lblDistance.text = distance
        self.lblLandedOn.text = landedOn
        self.lblLandedOn.backgroundColor = color
        self.lblStrokesGained.text = sg
        self.lblShot.text = shot
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class BarChartCellForMultiplayer: UITableViewCell {    
    @IBOutlet weak var btnUserImg: UIButton!
    @IBOutlet weak var btnViewProgress: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnUserImg.layer.cornerRadius = 20.0
        btnViewProgress.layer.cornerRadius = 2
    }
    func initDesign(club:String,recommended:String){
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
