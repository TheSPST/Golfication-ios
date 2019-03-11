//
//  SettingCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 07/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var lblGoal: UILabel!
    @IBOutlet weak var lblMinGoal: UILabel!
    @IBOutlet weak var lblMaxGoal: UILabel!
    @IBOutlet weak var goalSlider: UISlider!
    @IBOutlet weak var goalStackView: UIStackView!
    @IBOutlet weak var lblClubHead: UILabel!

    @IBOutlet weak var lblGoalVal: UILabel!
    @IBOutlet weak var btnGoalInfo: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        let originalImage = #imageLiteral(resourceName: "icon_info_grey")
        let infoBtnImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnGoalInfo.setBackgroundImage(infoBtnImage, for: .normal)
        btnGoalInfo.tintColor = UIColor.glfFlatBlue
    }
}
