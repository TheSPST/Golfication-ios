    //
    //  GenerateStats.swift
    //  Golfication
    //
    //  Created by Rishabh Sood on 01/05/18.
    //  Copyright © 2018 Khelfie. All rights reserved.
    //
    
    //ZiOLAZY5k5S2OF8ZlnhqLJajweI3   me: testing
    //-LB_cW1EoClfYzG34UaN match Id
    //activeMatches
    import UIKit
    import FirebaseAuth
    
    class GenerateStats: NSObject {
        
        var matchKey: String!
        var parValue = 0
        var scoreValue = 0
        
        var holeOutTrueParVal = 0
        var allParVal = 0

        //var generateStatsInt = 0
        
        var threeValue = [String: Int](), fourValue = [String: Int](), fiveValue = [String: Int]()
        var teesValue = [String : NSMutableDictionary]()
        
        var smartCaddieValue = [String : NSMutableArray]()
        
        var approachValue = [NSMutableDictionary](), sandValue = [NSMutableDictionary](), chippingValue = [NSMutableDictionary]()
        
        var threeUnder = 0, twoUnder = 0, oneUnder = 0, zeroUnder = 0, oneOver = 0, twoOver = 0, threeOver = 0
        
        var chipUnDAchievedValue = 0, chipUnDAttemptsValue = 0, sandUnDAttemptsValue = 0, sandUnDAchievedValue = 0
        var onePuttValue = 0, twoPuttValue = 0, threePuttValue = 0, fourPuttValue = 0, zeroPuttValue = 0
        var puttCountValue = 0, holeCountValue = 0, driveCountValue = 0
        var fairwayHitValue = 0, fairwayMissValue = 0, girValue = 0, girMissValue = 0, girWithFairwayValue = 0, girWoFairwayValue = 0, penaltyValue = 0, fairwayLeftValue = 0, fairwayRightValue = 0
        var avgStrokesGainedValue = 0.0, strokesGainedDataValue = 0.0, avgStrokesGained1Value = 0.0, strokesGained1DataValue = 0.0, avgStrokesGained2Value = 0.0, strokesGained2DataValue = 0.0, avgStrokesGained3Value = 0.0, strokesGained3DataValue = 0.0, avgStrokesGained4Value = 0.0, strokesGained4DataValue = 0.0
        
        var strokesGainedClub = [Double : String](), strokesGainedClubCount = [Double : String](), strokesGainedClubDistance = [Double : String]()
        
        var driveDistanceValue = 0.0
        
        var maxClub = ""
        var maxValue = -100.0
        var avgDis = 0.0
        var timestampVal = Double()
        var roundData = NSMutableDictionary()
        
        func generateStats() {
            if (matchKey.count>2){
                FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(matchKey!)/") { (snapshot) in
                    
                    if(snapshot.childrenCount > 0 && snapshot.exists()){
                        if  let matchDict = (snapshot.value as? NSDictionary){
                            Constants.matchDataDic = matchDict as! NSMutableDictionary
                            var scoreArray = NSArray()
                            
                            var keyData = String()
                            for (key,value) in matchDict{
                                keyData = key as! String
                                
                                if (keyData == "scoring"){
                                    scoreArray = (value as! NSArray)
                                }
                            }
                            for i in 0..<scoreArray.count{
                                var shotsArray:NSArray!
                                var strokes:Int!
                                
                                let score = scoreArray[i] as! NSDictionary
                                for(key,value) in score{
                                    if(key as! String == "par"){
                                        self.parValue = value as! Int
                                        self.allParVal += value as! Int
                                    }else if((key as! String) == Auth.auth().currentUser!.uid) && (((value as! NSMutableDictionary).value(forKey: "holeOut")) as! Bool) == true{
                                        self.holeOutTrueParVal +=  score.value(forKey: "par") as! Int
                                        self.holeCountValue = self.holeCountValue + 1
                                        self.parValue = score.value(forKey: "par") as! Int

                                        //self.generateStatsInt += 1
                                        if let shots = (((value as! NSMutableDictionary).value(forKey: "shots")) as? NSArray){
                                            shotsArray = shots
                                            self.scoreValue = self.scoreValue + shotsArray.count
                                        }
                                        else {
                                            if let strokeVal = (((value as! NSMutableDictionary).value(forKey: "strokes")) as? Int){
                                                strokes = strokeVal
                                                self.scoreValue = self.scoreValue + strokes!
                                            }
                                        }
                                        let k = i + 1
                                        if (shotsArray != nil){
                                            debugPrint(self.parValue)
                                            if self.parValue == 3{
                                                self.threeValue["hole\(k)"] = shotsArray.count
                                            }
                                            else if self.parValue == 4{
                                                self.fourValue["hole\(k)"] = shotsArray.count
                                            }
                                            else if self.parValue == 5{
                                                self.fiveValue["hole\(k)"] = shotsArray.count
                                            }
                                            
                                            let s: Int = shotsArray.count - self.parValue
                                            if s <= -3
                                            {
                                                self.threeUnder += 1
                                            }
                                            else if s == -2
                                            {
                                                self.twoUnder += 1
                                            }
                                            else if s == -1
                                            {
                                                self.oneUnder += 1
                                            }
                                            else if s == 0
                                            {
                                                self.zeroUnder += 1
                                            }
                                            else if s == 1
                                            {
                                                self.oneOver += 1
                                            }
                                            else if s==2
                                            {
                                                self.twoOver += 1
                                            }
                                            else if s>=3
                                            {
                                                self.threeOver += 1
                                            }
                                        }
                                        else {
                                            if self.parValue == 3{
                                                self.threeValue["hole\(k)"] = strokes
                                            }
                                            else if self.parValue == 4{
                                                self.fourValue["hole\(k)"] = strokes
                                            }
                                            else if self.parValue == 5{
                                                self.fiveValue["hole\(k)"] = strokes
                                            }
                                            
                                            if let chipUpDown = (((value as! NSMutableDictionary).value(forKey: "chipUpDown")) as? Bool){
                                                self.chipUnDAttemptsValue += 1
                                                if chipUpDown == true{
                                                    self.chipUnDAchievedValue += 1
                                                }
                                            }
                                            if let sandUpDown = (((value as! NSMutableDictionary).value(forKey: "sandUpDown")) as? Bool){
                                                self.sandUnDAttemptsValue += 1
                                                if sandUpDown == true{
                                                    self.sandUnDAchievedValue += 1
                                                }
                                            }
                                            
                                            let s: Int = strokes - self.parValue
                                            if s <= -3 {
                                                self.threeUnder += 1
                                            }
                                            else if s == -2 {
                                                self.twoUnder += 1
                                            }
                                            else if s == -1 {
                                                self.oneUnder += 1
                                            }
                                            else if s == 0 {
                                                self.zeroUnder += 1
                                            }
                                            else if s == 1 {
                                                self.oneOver += 1
                                            }
                                            else if s == 2{
                                                self.twoOver += 1
                                            }
                                            else if s >= 3{
                                                self.threeOver += 1
                                            }
                                        }
                                        
                                        if let putting = (((value as! NSMutableDictionary).value(forKey: "putting")) as? Int){
                                            
                                            if putting == 1 {
                                                self.onePuttValue += 1
                                            }
                                            else if putting == 2 {
                                                self.twoPuttValue += 1
                                            }
                                            else if putting == 3 {
                                                self.threePuttValue += 1
                                            }
                                            else if putting == 4 {
                                                self.fourPuttValue += 1
                                            }
                                            else {
                                                self.zeroPuttValue += 1
                                            }
                                            
                                            self.puttCountValue = self.puttCountValue + putting
                                        }
                                        
                                        if let fairway = (((value as! NSMutableDictionary).value(forKey: "fairway")) as? String){
                                            if fairway == "H"{
                                                self.fairwayHitValue += 1
                                            }
                                            else if fairway == "L" || fairway == "R"{
                                                if fairway == "L"{
                                                    self.fairwayLeftValue += 1
                                                }
                                                if fairway == "R"{
                                                    self.fairwayRightValue += 1
                                                }
                                                self.fairwayMissValue += 1
                                            }
                                        }
                                        if let gir = (((value as! NSMutableDictionary).value(forKey: "gir")) as? Bool){
                                            if gir == true{
                                                self.girValue += 1
                                                if let fairway = (((value as! NSMutableDictionary).value(forKey: "fairway")) as? String){
                                                    
                                                    if fairway == "H"{
                                                        self.girWithFairwayValue += 1
                                                    }
                                                    else if fairway == "L" || fairway == "R"{
                                                        self.girWoFairwayValue += 1
                                                    }
                                                }
                                            }
                                            else{
                                                self.girMissValue += 1
                                            }
                                        }
                                        if let penaltyCount = (((value as! NSMutableDictionary).value(forKey: "penaltyCount")) as? Int){
                                            if penaltyCount>0{
                                                self.penaltyValue += 1
                                            }
                                        }
                                        
                                        if (shotsArray != nil){
                                            for j in 0..<shotsArray.count{
                                                let shotsDic = shotsArray[j] as! NSDictionary
                                                self.strokesGainedDataValue = self.strokesGainedDataValue + (shotsDic.value(forKey: "strokesGained") as? Double)!
                                                
                                                var typeValue = 2
                                                if (j == 0 && self.parValue > 3){
                                                    typeValue = 0
                                                    if (shotsDic.value(forKey: "club") as? String)?.trim() == "Dr"{
                                                        self.driveCountValue += 1
                                                        self.driveDistanceValue = self.driveDistanceValue + (shotsDic.value(forKey: "distance") as? Double)!
                                                    }
                                                    
                                                    var spread = 0.0
                                                    
                                                    if let fair = (((value as! NSMutableDictionary).value(forKey: "fairway")) as? String){
                                                        if fair == "H" {
                                                            spread = Double(arc4random_uniform(50)) - 25
                                                        }
                                                        else if fair == "L" {
                                                            spread = Double(arc4random_uniform(25)) - 50
                                                        }
                                                        else if fair == "R" {
                                                            spread = 50 - Double(arc4random_uniform(25))
                                                        }
                                                        
                                                        let newDic = NSMutableDictionary()
                                                        newDic.setValue((shotsDic.value(forKey: "club") as? String)?.trim(), forKey: "club")
                                                        newDic.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                        newDic.setValue(spread, forKey: "spread")
                                                        newDic.setValue(fair, forKey: "fairway")
                                                        self.teesValue["hole\(k)"] = newDic
                                                    }
                                                }
                                                
                                                if (shotsDic.value(forKey: "penalty") as? Bool) == true{
                                                    self.penaltyValue += 1
                                                }
                                                let pv1 : Int = self.parValue
                                                let dv1 : Double = (shotsDic.value(forKey: "distanceToHole0") as? Double)!
                                                
                                                if (pv1 > 3 && j > 0 && dv1 <= 400) || pv1==3 {
                                                    if let penalty = (shotsDic.value(forKey: "penalty") as? Bool){
                                                        if penalty == false{
                                                            typeValue = 2
                                                            let a : Double = (shotsDic.value(forKey: "distance") as? Double)!
                                                            let b : Double = (shotsDic.value(forKey: "distanceToHole0") as? Double)!
                                                            let c : Double = (shotsDic.value(forKey: "distanceToHole1") as? Double)!
                                                            
                                                            var A = 0.0, x = 0.0, y = 0.0
                                                            var und = false
                                                            if (a+b<=c || a+c<=b || b+c<=a) {
                                                                x = 0
                                                                y = c
                                                                if a > b {
                                                                    y = 0 - y
                                                                }
                                                            }
                                                            else {
                                                                let s: Double = (a+b+c)/2
                                                                A = (s*(s-a)*(s-b)*(s-c)).squareRoot()
                                                                x = 2*A/b
                                                                
                                                                if (c*c-x*x>0) {
                                                                    y = (c*c-x*x).squareRoot()
                                                                }
                                                                if ((a*a-x*x).squareRoot()<b) {
                                                                    y = 0 - y
                                                                }
                                                                if (shotsDic.value(forKey: "heading") as? String) == "L"{
                                                                    x = 0 - x
                                                                }
                                                            }
                                                            if (b>70 && b<250){
                                                                typeValue=1
                                                                var approachGreenValue = false
                                                                if (shotsDic.value(forKey: "end") as? String) == "G"{
                                                                    approachGreenValue = true
                                                                }
                                                                
                                                                let newDic1 = NSMutableDictionary()
                                                                newDic1.setValue((shotsDic.value(forKey: "club") as? String)?.trim(), forKey: "club")
                                                                newDic1.setValue(a, forKey: "distance")
                                                                newDic1.setValue(i+1, forKey: "hole")
                                                                newDic1.setValue(x, forKey: "proximityX")
                                                                newDic1.setValue(y, forKey: "proximityY")
                                                                newDic1.setValue(approachGreenValue, forKey: "green")
                                                                self.approachValue.append(newDic1)
                                                            }
                                                            else if (b<=70 && ((shotsDic.value(forKey: "start") as? String) != "G") && (((shotsDic.value(forKey: "start") as? String) == "GB") || ((shotsDic.value(forKey: "start") as? String) == "FB"))){
                                                                und = false
                                                                self.sandUnDAttemptsValue += 1
                                                                var sandGreenValue = false
                                                                if (shotsArray.count <= j+2) && (shotsDic.value(forKey: "end") as? String) == "G"{
                                                                    und = true
                                                                    self.sandUnDAchievedValue += 1
                                                                }
                                                                if (shotsDic.value(forKey: "end") as? String) != "G"{
                                                                    sandGreenValue = false
                                                                }
                                                                let newDic2 = NSMutableDictionary()
                                                                newDic2.setValue((shotsDic.value(forKey: "club") as? String)?.trim(), forKey: "club")
                                                                newDic2.setValue(a, forKey: "distance")
                                                                newDic2.setValue(i+1, forKey: "hole")
                                                                newDic2.setValue(x, forKey: "proximityX")
                                                                newDic2.setValue(y, forKey: "proximityY")
                                                                newDic2.setValue(sandGreenValue, forKey: "green")
                                                                newDic2.setValue(und, forKey: "und")
                                                                self.sandValue.append(newDic2)
                                                            }
                                                            else if (b<=70 && !((shotsDic.value(forKey: "start") as? String) == "G")){
                                                                und = false
                                                                self.chipUnDAttemptsValue += 1
                                                                
                                                                var chipGreenValue = false
                                                                if (shotsDic.value(forKey: "end") as? String) == "G"{
                                                                    chipGreenValue = true
                                                                }
                                                                if (shotsArray.count <= j+1) {
                                                                    und = true
                                                                    self.chipUnDAchievedValue += 1
                                                                }
                                                                let newDic3 = NSMutableDictionary()
                                                                newDic3.setValue((shotsDic.value(forKey: "club") as? String)?.trim(), forKey: "club")
                                                                newDic3.setValue(a, forKey: "distance")
                                                                newDic3.setValue(i+1, forKey: "hole")
                                                                newDic3.setValue(x, forKey: "proximityX")
                                                                newDic3.setValue(y, forKey: "proximityY")
                                                                newDic3.setValue(chipGreenValue, forKey: "green")
                                                                newDic3.setValue(und, forKey: "und")
                                                                self.chippingValue.append(newDic3)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let penalty = (shotsDic.value(forKey: "penalty") as? Bool){
                                                    if penalty == false{
                                                        var smartCaddie = NSMutableArray()
                                                        var strGainClub = 0.0
                                                        var strGainClubCount = 0.0
                                                        var strGainClubDistance = 0.0
                                                        
                                                        if self.smartCaddieValue.count > 0{
                                                            for (key,_) in self.smartCaddieValue{
                                                                if key == (shotsDic.value(forKey: "club") as? String)?.trim(){
                                                                    smartCaddie = self.smartCaddieValue[key]!
                                                                }
                                                            }
                                                        }
                                                        if self.strokesGainedClub.count > 0{
                                                            for (key,value) in self.strokesGainedClub{
                                                                if value == (shotsDic.value(forKey: "club") as? String)!.trim(){
                                                                    strGainClub = key
                                                                    self.strokesGainedClub.removeValue(forKey: key)
                                                                    break
                                                                }
                                                            }
                                                        }
                                                        if self.strokesGainedClubCount.count > 0{
                                                            for (key,value) in self.strokesGainedClubCount{
                                                                if value == (shotsDic.value(forKey: "club") as? String)!.trim(){
                                                                    strGainClubCount = key
                                                                    self.strokesGainedClubCount.removeValue(forKey: key)
                                                                    break
                                                                }
                                                            }
                                                        }
                                                        if self.strokesGainedClubDistance.count > 0{
                                                            for (key,value) in self.strokesGainedClubDistance{
                                                                if value == (shotsDic.value(forKey: "club") as? String)!.trim(){
                                                                    strGainClubDistance = key
                                                                    self.strokesGainedClubDistance.removeValue(forKey: key)
                                                                    break
                                                                }
                                                            }
                                                        }
                                                        
                                                        if (shotsDic.value(forKey: "club") as? String)?.trim() == "Pu"{
                                                            typeValue = 3
                                                            
                                                            let a1 : Double = (shotsDic.value(forKey: "distance") as? Double)! * 3
                                                            //                                                        let b1 : Double = (shotsDic.value(forKey: "distanceToHole0") as? Double)! * 3
                                                            let c1 = (shotsDic.value(forKey: "distanceToHole1") as? Double)! * 3
                                                            
                                                            if (shotsArray.count == j+1 && j > 0 && !(((shotsArray[j-1] as! NSDictionary).value(forKey: "club") as? String)?.trim() == "Pu")){
                                                                
                                                                let newDic4 = NSMutableDictionary()
                                                                newDic4.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                                newDic4.setValue((shotsDic.value(forKey: "strokesGained") as? Double), forKey: "strokesGained")
                                                                newDic4.setValue((shotsDic.value(forKey: "strokesGained1") as? Double), forKey: "strokesGained1")
                                                                newDic4.setValue((shotsDic.value(forKey: "strokesGained2") as? Double), forKey: "strokesGained2")
                                                                newDic4.setValue((shotsDic.value(forKey: "strokesGained3") as? Double), forKey: "strokesGained3")
                                                                newDic4.setValue((shotsDic.value(forKey: "strokesGained4") as? Double), forKey: "strokesGained4")
                                                                newDic4.setValue(typeValue, forKey: "type")
                                                                newDic4.setValue(0.00001, forKey: "proximity")
                                                                newDic4.setValue(a1, forKey: "holeOut")
                                                                smartCaddie.add(newDic4)
                                                                self.smartCaddieValue[(shotsDic.value(forKey: "club") as? String)!.trim()] = smartCaddie
                                                            }
                                                            else if (shotsArray.count == j+1) {
                                                                
                                                                let newDic5 = NSMutableDictionary()
                                                                newDic5.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                                newDic5.setValue((shotsDic.value(forKey: "strokesGained") as? Double), forKey: "strokesGained")
                                                                newDic5.setValue((shotsDic.value(forKey: "strokesGained1") as? Double), forKey: "strokesGained1")
                                                                newDic5.setValue((shotsDic.value(forKey: "strokesGained2") as? Double), forKey: "strokesGained2")
                                                                newDic5.setValue((shotsDic.value(forKey: "strokesGained3") as? Double), forKey: "strokesGained3")
                                                                newDic5.setValue((shotsDic.value(forKey: "strokesGained4") as? Double), forKey: "strokesGained4")
                                                                newDic5.setValue(typeValue, forKey: "type")
                                                                newDic5.setValue(a1, forKey: "holeOut")
                                                                
                                                                smartCaddie.add(newDic5)
                                                                self.smartCaddieValue[(shotsDic.value(forKey: "club") as? String)!.trim()] = smartCaddie
                                                            }
                                                            else if (j>0 && !(((shotsArray[j-1] as! NSDictionary).value(forKey: "club") as? String)?.trim() == "Pu")) {
                                                                let newDic6 = NSMutableDictionary()
                                                                newDic6.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                                newDic6.setValue((shotsDic.value(forKey: "strokesGained") as? Double), forKey: "strokesGained")
                                                                newDic6.setValue((shotsDic.value(forKey: "strokesGained1") as? Double), forKey: "strokesGained1")
                                                                newDic6.setValue((shotsDic.value(forKey: "strokesGained2") as? Double), forKey: "strokesGained2")
                                                                newDic6.setValue((shotsDic.value(forKey: "strokesGained3") as? Double), forKey: "strokesGained3")
                                                                newDic6.setValue((shotsDic.value(forKey: "strokesGained4") as? Double), forKey: "strokesGained4")
                                                                newDic6.setValue(typeValue, forKey: "type")
                                                                newDic6.setValue(c1, forKey: "proximity")
                                                                smartCaddie.add(newDic6)
                                                                self.smartCaddieValue[(shotsDic.value(forKey: "club") as? String)!.trim()] = smartCaddie
                                                            }
                                                            else {
                                                                let newDic7 = NSMutableDictionary()
                                                                newDic7.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                                newDic7.setValue((shotsDic.value(forKey: "strokesGained") as? Double), forKey: "strokesGained")
                                                                newDic7.setValue((shotsDic.value(forKey: "strokesGained1") as? Double), forKey: "strokesGained1")
                                                                newDic7.setValue((shotsDic.value(forKey: "strokesGained2") as? Double), forKey: "strokesGained2")
                                                                newDic7.setValue((shotsDic.value(forKey: "strokesGained3") as? Double), forKey: "strokesGained3")
                                                                newDic7.setValue((shotsDic.value(forKey: "strokesGained4") as? Double), forKey: "strokesGained4")
                                                                newDic7.setValue(typeValue, forKey: "type")
                                                                smartCaddie.add(newDic7)
                                                                self.smartCaddieValue[(shotsDic.value(forKey: "club") as? String)!.trim()] = smartCaddie
                                                            }
                                                        }
                                                        else {
                                                            let newDic8 = NSMutableDictionary()
                                                            newDic8.setValue((shotsDic.value(forKey: "distance") as? Double), forKey: "distance")
                                                            newDic8.setValue((shotsDic.value(forKey: "strokesGained") as? Double), forKey: "strokesGained")
                                                            newDic8.setValue((shotsDic.value(forKey: "strokesGained1") as? Double), forKey: "strokesGained1")
                                                            newDic8.setValue((shotsDic.value(forKey: "strokesGained2") as? Double), forKey: "strokesGained2")
                                                            newDic8.setValue((shotsDic.value(forKey: "strokesGained3") as? Double), forKey: "strokesGained3")
                                                            newDic8.setValue((shotsDic.value(forKey: "strokesGained4") as? Double), forKey: "strokesGained4")
                                                            newDic8.setValue(typeValue, forKey: "type")
                                                            smartCaddie.add(newDic8)
                                                            self.smartCaddieValue[(shotsDic.value(forKey: "club") as? String)!.trim()] = smartCaddie
                                                        }
                                                        self.strokesGainedClub[strGainClub+(shotsDic.value(forKey: "strokesGained") as? Double)!] = (shotsDic.value(forKey: "club") as? String)?.trim()
                                                        self.strokesGainedClubDistance[strGainClubDistance+(shotsDic.value(forKey: "distance") as? Double)!] = (shotsDic.value(forKey: "club") as? String)?.trim()
                                                        self.strokesGainedClubCount[strGainClubCount+1] = (shotsDic.value(forKey: "club") as? String)?.trim()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            self.timestampVal = matchDict.value(forKey: "timestamp") as! Double
                            self.roundData.setValue(matchDict.value(forKey: "courseName"), forKey: "course")
                            self.roundData.setValue(matchDict.value(forKey: "courseId"), forKey: "courseId")
                            self.roundData.setValue(matchDict.value(forKey: "timestamp"), forKey: "timestamp")
                            self.roundData.setValue(matchDict.value(forKey: "matchType"), forKey: "type")
                            self.roundData.setValue(self.holeOutTrueParVal, forKey: "par")
                            
//                            if (self.allParVal != self.holeOutTrueParVal){
//                                let val : Double = (Double(self.scoreValue) / Double(self.holeOutTrueParVal))
//                                self.scoreValue = Int(val * Double(self.allParVal))
//                            }
                            self.roundData.setValue(self.allParVal, forKey: "totalPar")
                            self.roundData.setValue(self.scoreValue, forKey: "score")
                            self.roundData.setValue(self.fairwayHitValue, forKey: "fairwayHit")
                            self.roundData.setValue(self.fairwayMissValue, forKey: "fairwayMiss")
                            self.roundData.setValue(self.fairwayLeftValue, forKey: "fairwayLeftValue")
                            self.roundData.setValue(self.fairwayRightValue, forKey: "fairwayRightValue")
                            self.roundData.setValue(self.chippingValue, forKey: "chipping")
                            self.roundData.setValue(self.approachValue, forKey: "approach")
                            self.roundData.setValue(self.sandValue, forKey: "sand")
                            self.roundData.setValue(self.girValue, forKey: "gir")
                            self.roundData.setValue(self.girMissValue, forKey: "girMiss")
                            self.roundData.setValue(self.girWithFairwayValue, forKey: "girWithFairway")
                            self.roundData.setValue(self.girWoFairwayValue, forKey: "girWoFairway")
                            self.roundData.setValue(self.penaltyValue, forKey: "penalty")
                            
                            let chipVal = NSMutableDictionary()
                            chipVal.setValue(self.chipUnDAttemptsValue, forKey: "attempts")
                            chipVal.setValue(self.chipUnDAchievedValue, forKey: "achieved")
                            self.roundData.setValue(chipVal, forKey: "chipUnD")
                            
                            let sandVal = NSMutableDictionary()
                            sandVal.setValue(self.sandUnDAttemptsValue, forKey: "attempts")
                            sandVal.setValue(self.sandUnDAchievedValue, forKey: "achieved")
                            self.roundData.setValue(sandVal, forKey: "sandUnD")
                            
                            let puttValues = NSMutableArray()
                            puttValues.add(self.zeroPuttValue)
                            puttValues.add(self.onePuttValue)
                            puttValues.add(self.twoPuttValue)
                            puttValues.add(self.threePuttValue)
                            puttValues.add(self.fourPuttValue)
                            self.roundData.setValue(puttValues, forKey: "putts")
                            
                            let scoringVal = NSMutableDictionary()
                            scoringVal.setValue(self.threeUnder, forKey: "-3")
                            scoringVal.setValue(self.twoUnder, forKey: "-2")
                            scoringVal.setValue(self.oneUnder, forKey: "-1")
                            scoringVal.setValue(self.zeroUnder, forKey: "0")
                            scoringVal.setValue(self.oneOver, forKey: "1")
                            scoringVal.setValue(self.twoOver, forKey: "2")
                            scoringVal.setValue(self.threeOver, forKey: "3")
                            
                            let parwise = NSMutableDictionary()
                            parwise.setValue(self.threeValue, forKey: "three")
                            parwise.setValue(self.fourValue, forKey: "four")
                            parwise.setValue(self.fiveValue, forKey: "five")
                            
                            self.roundData.setValue(self.teesValue, forKey: "tees")
                            self.roundData.setValue(parwise, forKey: "parWise")
                            self.roundData.setValue(scoringVal, forKey: "scoring")
                            self.roundData.setValue(self.smartCaddieValue, forKey: "smartCaddie")
                            
                            if (self.strokesGainedClub.count>0){
                                self.maxValue = (self.strokesGainedClub.first?.key)!
                                self.maxClub = self.strokesGainedClub[(self.strokesGainedClub.first?.key)!]!
                                debugPrint("strokesGainedClub== ",self.strokesGainedClub.count)
                            }
                            
                            for (key,value) in self.strokesGainedClubCount{
                                if value == self.maxClub{
                                    if (key > 0){
                                        
                                        for (key1,value1) in self.strokesGainedClubDistance{
                                            if value1 == value{
                                                self.avgDis = key1/key
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            debugPrint("avgDis== ",self.avgDis)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.getStatisticsDataFromFirebase()
                    })
                }
            }
        }
        func getStatisticsDataFromFirebase() {
            
            let statisticsValue = NSMutableDictionary()
            
            FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "statistics") { (snapshot) in
                var dataDic = NSDictionary()
                if(snapshot.childrenCount > 0){
                    dataDic = (snapshot.value as? NSDictionary)!
                }
                
                DispatchQueue.main.async( execute: {
                    if let card6 = dataDic["card6"] as? NSMutableDictionary{
                        if card6["driveCount"] != nil && card6["driveDistance"] != nil{
                            
                            let tempCount : Int = (card6["driveCount"] as? Int)!
                            let tempDistance: Double = (card6["driveDistance"] as? Double)!
                            
                            card6.setValue(tempCount+self.driveCountValue, forKey: "driveCount")
                            card6.setValue(tempDistance+self.driveDistanceValue, forKey: "driveDistance")
                            
                            statisticsValue.setValue(card6, forKey: "card6")
                        }
                        else{
                            card6.setValue(self.driveCountValue, forKey: "driveCount")
                            card6.setValue(self.driveDistanceValue, forKey: "driveDistance")
                            
                            statisticsValue.setValue(card6, forKey: "card6")
                        }
                    }
                    else{
                        let card6 = NSMutableDictionary()
                        card6.setValue(self.driveCountValue, forKey: "driveCount")
                        card6.setValue(self.driveDistanceValue, forKey: "driveDistance")
                        
                        statisticsValue.setValue(card6, forKey: "card6")
                    }
                    if let card7 = dataDic["card7"] as? NSMutableDictionary{
                        if card7["holeCount"] != nil && card7["puttCount"] != nil{
                            
                            let tempCount : Int = (card7["holeCount"] as? Int)!
                            let tempHole : Int = (card7["puttCount"] as? Int)!
                            
                            card7.setValue(tempCount+self.holeCountValue, forKey: "holeCount")
                            card7.setValue(tempHole+self.puttCountValue, forKey: "puttCount")
                            
                            statisticsValue.setValue(card7, forKey: "card7")
                        }
                        else {
                            card7.setValue(self.holeCountValue, forKey: "holeCount")
                            card7.setValue(self.puttCountValue, forKey: "puttCount")
                            
                            statisticsValue.setValue(card7, forKey: "card7")
                        }
                    }
                    else {
                        let card7 = NSMutableDictionary()
                        card7.setValue(self.holeCountValue, forKey: "holeCount")
                        card7.setValue(self.puttCountValue, forKey: "puttCount")
                        
                        statisticsValue.setValue(card7, forKey: "card7")
                    }
                    
                    if let card35 = dataDic["card3,5"] as? NSMutableDictionary{
                        if card35["strokesCount"] != nil && card35["strokesGainedData"] != nil{
                            let tempCount : Int = (card35["strokesCount"] as? Int)!
                            let tempHole : Double = (card35["strokesGainedData"] as? Double)!
                            
                            card35.setValue(tempCount+self.scoreValue, forKey: "strokesCount")
                            card35.setValue(tempHole+self.strokesGainedDataValue, forKey: "strokesGainedData")
                            
                            statisticsValue.setValue(card35, forKey: "card3,5")
                        }
                        else {
                            card35.setValue(self.scoreValue, forKey: "strokesCount")
                            card35.setValue(self.strokesGainedDataValue, forKey: "strokesGainedData")
                            
                            statisticsValue.setValue(card35, forKey: "card3,5")
                        }
                    }
                    else {
                        let card35 = NSMutableDictionary()
                        card35.setValue(self.scoreValue, forKey: "strokesCount")
                        card35.setValue(self.strokesGainedDataValue, forKey: "strokesGainedData")
                        
                        statisticsValue.setValue(card35, forKey: "card3,5")
                    }
                    
                    if let card3 = dataDic["card3"] as? NSMutableDictionary{
                        
                        if card3["doubleBogey"] != nil{
                            let tempCount = card3["doubleBogey"] as? Int
                            card3.setValue(tempCount!+(self.threeOver+self.twoOver), forKey: "doubleBogey")
                        }
                        else {
                            card3.setValue((self.threeOver+self.twoOver), forKey: "doubleBogey")
                        }
                        if card3["bogey"] != nil{
                            let tempCount : Int = (card3["bogey"] as? Int)!
                            card3.setValue(tempCount+(self.oneOver), forKey: "bogey")
                        }
                        else {
                            card3.setValue((self.oneOver), forKey: "bogey")
                        }
                        if card3["par"] != nil{
                            let tempCount : Int = (card3["par"] as? Int)!
                            card3.setValue(tempCount+(self.zeroUnder), forKey: "par")
                        }
                        else {
                            card3.setValue((self.zeroUnder), forKey: "par")
                        }
                        if card3["birdie"] != nil{
                            let tempCount : Int = (card3["birdie"] as? Int)!
                            card3.setValue(tempCount+(self.oneUnder), forKey: "birdie")
                        }
                        else {
                            card3.setValue((self.oneUnder), forKey: "birdie")
                        }
                        if card3["eagle"] != nil{
                            let tempCount : Int = (card3["eagle"] as? Int)!
                            card3.setValue(tempCount+(self.twoUnder), forKey: "eagle")
                        }
                        else {
                            card3.setValue((self.twoUnder), forKey: "eagle")
                        }
                        statisticsValue.setValue(card3, forKey: "card3")
                    }
                    else{
                        let card3 = NSMutableDictionary()
                        card3.setValue((self.twoUnder), forKey: "eagle")
                        card3.setValue((self.threeOver+self.twoOver), forKey: "doubleBogey")
                        card3.setValue((self.oneOver), forKey: "bogey")
                        card3.setValue((self.oneUnder), forKey: "birdie")
                        card3.setValue((self.zeroUnder), forKey: "par")
                        
                        statisticsValue.setValue(card3, forKey: "card3")
                    }
                    
                    let card1 = NSMutableDictionary()
                    card1.setValue(self.maxClub, forKey: "club")
                    card1.setValue(self.avgDis, forKey: "distance")
                    card1.setValue(self.maxValue, forKey: "strokesGained")
                    
                    statisticsValue.setValue(card1, forKey: "card1")
                    
                    // ------------------------------------------------------------------
                    let card4 = NSMutableDictionary()
                    
                    if let card4Array = dataDic["card4"] as? NSMutableDictionary{
                        
                        for (key,value) in card4Array{
                            let card4Val = value as! NSMutableDictionary
                            card4Val.setValue(card4Val.value(forKey: "score"), forKey: "score")
                            card4Val.setValue(card4Val.value(forKey: "par"), forKey: "par")
                            card4Val.setValue(card4Val.value(forKey: "timestamp"), forKey: "timestamp")
                            card4.setValue(card4Val, forKey: key as! String)
                        }
                    }
                    let card4Val = NSMutableDictionary()
                    card4Val.setValue(self.scoreValue, forKey: "score")
                    card4Val.setValue(self.holeOutTrueParVal, forKey: "par")
                    card4Val.setValue(self.timestampVal, forKey: "timestamp")
                    
                    card4.setValue(card4Val, forKey: self.matchKey)
                    statisticsValue.setValue(card4, forKey: "card4")
                    //--------------------------------------------------------------------
                    
                    // if (self.generateStatsInt > 8) {
                    
                    let roundVal = NSMutableDictionary()
                    roundVal.setValue(self.roundData, forKey: self.matchKey)
                    
                    let statistics = ["statistics":statisticsValue]
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(statistics)
                    ref.child("userData/\(Auth.auth().currentUser!.uid)/scoring/\(self.matchKey!)").setValue(self.roundData)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StatsCompleted"), object: nil)
                    //}
                })
            }
        }
    }
