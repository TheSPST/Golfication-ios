//
//  DetailView.swift
//  Golfication
//
//  Created by Rishabh Sood on 16/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class DetailView: UIView {

    @IBOutlet weak var nameLbl: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }


private func commonInit() {
    if UIDevice.current.orientation.isLandscape {
        let s: CGSize = UIScreen.main.bounds.size
        self.frame = CGRect(x:0, y:0, width:s.height, height:s.width);
    } else {
        self.frame = UIScreen.main.bounds
    }
}

@IBAction func close(_ sender: Any){
self.removeFromSuperview()
}
}
