//
//  EditPreviousGame.swift
//  Golfication
//
//  Created by Khelfie on 01/09/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class EditPreviousGame: NSObject {
    var isActiveMatch = false
    var matchData = NSDictionary()
    var userData = NSDictionary()
    var scoringMode = String()
    func continuePreviousMatch(matchId:String,userId:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "") { (snapshot) in
            if let user = snapshot.value as? NSDictionary{
                self.userData = user
            }
            DispatchQueue.main.async( execute: {
                if(self.userData.value(forKey: "activeMatches") != nil){
                    self.isActiveMatch = true
                }
                if(!self.isActiveMatch){
                    self.scoringMode = self.matchData.value(forKey: "scoringMode") as! String
                    if let scoring = self.userData.value(forKey: "scoring") as? NSDictionary{
                        let dataArray = scoring.allValues as NSArray
                        if(dataArray.count > 1){
                            
                        }else{
                            
                        }
                    }else{
                        
                    }
                }
            })
            
        }
    }
}
