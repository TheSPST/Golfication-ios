//
//  SearchLocationTableViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 12/05/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class SearchLocationTableViewCell: UITableViewCell {
    
    //    @IBOutlet weak var btnMapped: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblMapped: UILabel!
    @IBOutlet weak var classicImageView: UIImageView!
    @IBOutlet weak var rfImageView: UIImageView!
    @IBOutlet weak var advanceImageView: UIImageView!
    @IBOutlet weak var leftModeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
