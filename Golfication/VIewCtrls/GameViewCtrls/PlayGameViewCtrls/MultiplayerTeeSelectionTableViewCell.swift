//
//  MultiplayerTeeSelectionTableViewCell.swift
//  Golfication
//
//  Created by Khelfie on 07/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class MultiplayerTeeSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var btnUserImg: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var startingTeeCardView: CardView!
    @IBOutlet weak var btnDropDownTee: UIButton!
    @IBOutlet weak var lblTeeName: UILabel!
    @IBOutlet weak var lblTeeType: UILabel!
    @IBOutlet weak var lblTeeRating: UILabel!
    @IBOutlet weak var lblTeeSlope: UILabel!
    @IBOutlet weak var btnHandicap: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnUserImg.setCornerWithCircle(color: UIColor.glfBluegreen.cgColor)
        self.btnUserImg.layer.borderWidth = 3.0
        self.btnHandicap.setCorner(color: UIColor.glfBluegreen.cgColor)
        self.btnHandicap.layer.borderWidth = 2.0
        self.startingTeeCardView.layer.borderWidth = 2.0
        self.startingTeeCardView.layer.borderColor = UIColor.glfBluegreen.cgColor
        self.startingTeeCardView.backgroundColor = UIColor.glfWhite
        
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
