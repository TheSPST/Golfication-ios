//
//  NewHomeFeedViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 05/04/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class NewHomeFeedViewCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblScoreTitle: UILabel!
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
    @IBOutlet weak var btnEditRound: UIButton!
    @IBOutlet weak var btnScoreCard: UIButton!

    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var shareImageHConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblSharedMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
