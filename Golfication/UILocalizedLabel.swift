//
//  UILocalizedLabel.swift
//  Golfication
//
//  Created by Rishabh Sood on 10/11/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

final class UILocalizedLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
    }
}

final class UILocalizedSegmentCtrl: UISegmentedControl {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitle(titleForSegment(at: 0)?.localized(), forSegmentAt: 0)
        setTitle(titleForSegment(at: 1)?.localized(), forSegmentAt: 1)
    }
}

final class UILocalizedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let title = self.title(for: .normal)?.localized()
        setTitle(title, for: .normal)
    }
}

final class UILocalizedTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
    }
}

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
