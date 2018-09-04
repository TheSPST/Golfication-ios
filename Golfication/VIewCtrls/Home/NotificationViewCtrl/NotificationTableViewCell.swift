//
//  NotificationTableViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 02/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMesg: UILabel!
    @IBOutlet weak var txtViewContent: UITextView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblMesg.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
