//
//  NotesTableViewCell.swift
//  Golfication
//
//  Created by Rishabh Sood on 19/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class NotesTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var dateTrashSV: UIStackView!

    //04-03-2019 5:10 PM
    var textChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        
        let originalImage = UIImage(named:"trash")!
        let courseImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnTrash.tintColor = UIColor.glfBluegreen
        btnTrash.setImage(courseImage, for: .normal)

    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
    }
}
