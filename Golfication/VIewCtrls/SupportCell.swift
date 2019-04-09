//
//  SupportCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 08/04/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class SupportCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var viewRadio: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewRadio.layer.cornerRadius = viewRadio.frame.size.height/2
        viewRadio.layer.borderWidth = 1.0
        viewRadio.layer.borderColor = UIColor.lightGray.cgColor
        viewRadio.layer.masksToBounds = true

        btnRadio.layer.cornerRadius = btnRadio.frame.size.height/2
        btnRadio.layer.masksToBounds = true
        btnRadio.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
