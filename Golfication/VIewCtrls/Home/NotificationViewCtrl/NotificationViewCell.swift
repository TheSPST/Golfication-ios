//
//  NotificationViewCell.swift
//  Golfication
//
//  Created by Khelfie on 27/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {

    @IBOutlet weak var notifiactionMsg: UILabel!
    @IBOutlet weak var timeAgoLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.setCircle(frame: self.userImageView.frame)
        
        self.userImageView.layer.masksToBounds = true
        self.userImageView.image = #imageLiteral(resourceName: "you")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
