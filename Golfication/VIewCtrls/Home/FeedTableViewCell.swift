//
//  FeedTableViewCell.swift
//  Golfication
//
//  Created by IndiRenters on 10/18/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell{
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var activityDetailsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalLikes: UILabel!
    @IBOutlet weak var recentActView: UIView!
    let combination = NSMutableAttributedString()
    var attributedStringArray = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.setCircle(frame: userImageView.frame)
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureWithItem(feeds: Feeds) {
        if (feeds.userImage != nil) {
            self.userImageView.sd_setImage(with: URL(string:feeds.userImage!), completed: nil)
            self.activityDetailsLabel.numberOfLines = 0
            self.activityDetailsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.activityDetailsLabel.font = UIFont.systemFont(ofSize: 14.0)
            var array = [String]()
            if feeds.taggedUsers != nil  {
                for (_,value) in feeds.taggedUsers!{
                    array.append(value as! String)
                }
            }
            let taggedUser = array.joined(separator: ", ")
            if feeds.location == nil && feeds.taggedUsers == nil{
                self.activityDetailsLabel.text = feeds.userName
            }
            else if feeds.location != nil && feeds.taggedUsers == nil{
                self.activityDetailsLabel.text = "\(feeds.userName ?? "") at \(feeds.location ?? "")"
            }
            else if feeds.location == nil && feeds.taggedUsers != nil{
                
                self.activityDetailsLabel.text = "\(feeds.userName ?? "") with \(taggedUser)"
            }
            else{
                
                let yourAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                let yourOtherAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                let yourOtherAttributes2 = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                let yourOtherAttributes3 = [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
                
                let userName = NSMutableAttributedString(string: "\(feeds.userName ?? "") at ", attributes: yourAttributes)
                let locations = NSMutableAttributedString(string: "\(feeds.location ?? "") ", attributes: yourOtherAttributes)
                let taggedUserWith = NSMutableAttributedString(string: "with ", attributes: yourOtherAttributes2)
                let taggedUserWithComma = NSMutableAttributedString(string: taggedUser, attributes: yourOtherAttributes3)
                
                attributedStringArray.append(feeds.userName!)
                attributedStringArray.append(feeds.location!)
            
                for (_,value) in feeds.taggedUsers!{
                    attributedStringArray.append(value as! String)
                }
                
                combination.append(userName)
                combination.append(locations)
                combination.append(taggedUserWith)
                combination.append(taggedUserWithComma)

                self.activityDetailsLabel.attributedText = combination
            }
            
            self.activityDetailsLabel.sizeToFit()
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
            self.activityDetailsLabel.addGestureRecognizer(tap)
            self.activityDetailsLabel.isUserInteractionEnabled = true
            timeLabel.text = NSDate(timeIntervalSince1970:(feeds.timeStamp)!/1000).timeAgoSinceNow
//            if(feeds.likesCount > 0 ){
//                self.totalLikes.text = "\(feeds.likesCount!) Likes"
//                print("likes : \(totalLikes.text ?? "")")
//            }
//            else{
                self.totalLikes.text = "Like"
//            }
        }
    }
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        for attributedText in attributedStringArray {
            guard let range = self.activityDetailsLabel.text?.range(of: attributedText)?.nsRange else {
                return
            }
            if tap.didTapAttributedTextInLabel(label: self.activityDetailsLabel, inRange: range) {
                //print("You Clicked On : \(attributedText)")
                
            }
        }
    }
    
}


extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
