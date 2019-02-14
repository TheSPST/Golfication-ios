//
//  ShareStatsButton.swift
//  Golfication
//
//  Created by Rishabh Sood on 28/03/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class ShareStatsButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBackgroundImage(#imageLiteral(resourceName: "share"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
class StatsInfoButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBackgroundImage(#imageLiteral(resourceName: "icon_info_grey"), for: .normal)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
