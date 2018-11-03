//
//  PublicScore.swift
//  Golfication
//
//  Created by Rishabh Sood on 29/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit

class PublicScore: NSObject {


    // Overview Functions
    func getOverviewScoring(absoluteBirdie:Double,absolutePar:Double,absoluteBogey:Double,absoluteDBogey:Double)->NSMutableAttributedString {
        var attributedOverviewScoring = NSMutableAttributedString()
        
        var baselineHandicapPar = 0.0
        var baselineHandicapBirdie = 0.0
        var baselineHandicapBogey = 0.0
        var baselineHandicapDBogey = 0.0
        
        if baselineDict != nil{
            if let baselineHandiPar = baselineDict.value(forKey: "par") as? String{
                baselineHandicapPar = Double(baselineHandiPar) ?? 0.0
            }
            if let baselineHandiBirdie = baselineDict.value(forKey: "birdie") as? String{
                baselineHandicapBirdie = Double(baselineHandiBirdie) ?? 0.0
            }
            if let baselineHandiBogey = baselineDict.value(forKey: "bogey") as? String{
                baselineHandicapBogey = Double(baselineHandiBogey) ?? 0.0
            }
            if let baselineHandiDBogey = baselineDict.value(forKey: "dbogey") as? String{
                baselineHandicapDBogey = Double(baselineHandiDBogey) ?? 0.0
            }
            
            var maxAbsoluteValue = 0.0
            var scoreAbsoluteValue = 0.0
            var setMoreLess = "less"
            var maxAbsoluteValueScore = "less"
            
            if(baselineHandicapPar>0){
                if(abs(absoluteBirdie-baselineHandicapBirdie)>0.5 && maxAbsoluteValue<abs(absoluteBirdie-baselineHandicapBirdie)){
                    maxAbsoluteValue = abs(absoluteBirdie-baselineHandicapBirdie)
                    maxAbsoluteValueScore = "birdies"
                    scoreAbsoluteValue = baselineHandicapBirdie
                    if(absoluteBirdie-baselineHandicapBirdie>0){
                        setMoreLess = "more";
                    }else{
                        setMoreLess = "less";
                    }
                }
                if(abs(absolutePar-baselineHandicapPar)>0.5 && maxAbsoluteValue<abs(absolutePar-baselineHandicapPar)){
                    maxAbsoluteValue = abs(absolutePar-baselineHandicapPar);
                    maxAbsoluteValueScore = "pars";
                    scoreAbsoluteValue = baselineHandicapPar;
                    if(absoluteBirdie-baselineHandicapPar>0){
                        setMoreLess = "more";
                    }else{
                        setMoreLess = "less";
                    }
                }
                if(abs(absoluteBogey-baselineHandicapBogey)>0.5 && maxAbsoluteValue<abs(absoluteBogey-baselineHandicapBogey)){
                    maxAbsoluteValue = abs(absoluteBogey-baselineHandicapBogey);
                    maxAbsoluteValueScore = "bogeys";
                    scoreAbsoluteValue = baselineHandicapBogey;
                    if(absoluteBirdie-baselineHandicapBogey>0){
                        setMoreLess = "more";
                    }else{
                        setMoreLess = "less";
                    }
                }
                if(abs(absoluteDBogey-baselineHandicapDBogey)>0.5 && maxAbsoluteValue<abs(absoluteDBogey-baselineHandicapDBogey)){
                    maxAbsoluteValue = abs(absoluteDBogey-baselineHandicapDBogey);
                    maxAbsoluteValueScore = "dbogeys";
                    scoreAbsoluteValue = baselineHandicapDBogey;
                    if(absoluteBirdie-baselineHandicapDBogey>0){
                        setMoreLess = "more";
                    }else{
                        setMoreLess = "less";
                    }
                }
                
                let spannableString = "You make " + String(format:"%.01f ",(maxAbsoluteValue*100/scoreAbsoluteValue)) + "% " +  "\(setMoreLess) " + maxAbsoluteValueScore + " than other golfers of your HCP"
                attributedOverviewScoring = NSMutableAttributedString(string: spannableString)
                
                let textToHighlight = String(format:"%.01f ",(maxAbsoluteValue*100/scoreAbsoluteValue)) + "% " + "\(setMoreLess) " + maxAbsoluteValueScore
                
                if(setMoreLess.contains("more") && (maxAbsoluteValueScore.contains("birdies") || maxAbsoluteValueScore.contains("pars"))){
                    
                    attributedOverviewScoring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 9, length: textToHighlight.count))
                }
                else if(setMoreLess.contains("less") && (maxAbsoluteValueScore.contains("bogeys") || maxAbsoluteValueScore.contains("dbogeys"))){
                    
                    attributedOverviewScoring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 9, length: textToHighlight.count))
                }
                else if(setMoreLess.contains("less") && (maxAbsoluteValueScore.contains("birdies") || maxAbsoluteValueScore.contains("pars"))){
                    
                    attributedOverviewScoring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 9, length: textToHighlight.count))
                }
                else if(setMoreLess.contains("more") && (maxAbsoluteValueScore.contains("bogeys") || maxAbsoluteValueScore.contains("dbogeys"))){
                    
                    attributedOverviewScoring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 9, length: textToHighlight.count))
                }
                if(abs(absoluteBirdie-baselineHandicapBirdie)<0.5 && abs(absolutePar-baselineHandicapPar)<0.5
                    && abs(absoluteBogey-baselineHandicapBogey)<0.5 && abs(absoluteDBogey-baselineHandicapDBogey)<0.5){
                    
                    let spannableStr = "Your Par-Averages are similar to other golfers of your HCP"
                    attributedOverviewScoring = NSMutableAttributedString(string: spannableStr)
                    
                    attributedOverviewScoring.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfFlatBlue, range: NSRange(location: 0, length: spannableStr.count))
                }
            }
        }
        return attributedOverviewScoring
    }
    
    func getOverviewParAvg(par3s:Double, par4s:Double, par5s:Double)->NSMutableAttributedString{
        var attributedOverviewParAvg = NSMutableAttributedString()
        
        var baselineHandicapPar3 = 0.0
        var baselineHandicapPar4 = 0.0
        var baselineHandicapPar5 = 0.0
        if baselineDict != nil{
            
            if let baselineHandiPar3 = baselineDict.value(forKey: "par3") as? String{
                baselineHandicapPar3 = Double(baselineHandiPar3) ?? 0.0
            }
            if let baselineHandiPar4 = baselineDict.value(forKey: "par4") as? String{
                baselineHandicapPar4 = Double(baselineHandiPar4) ?? 0.0
            }
            if let baselineHandiPar5 = baselineDict.value(forKey: "par5") as? String{
                baselineHandicapPar5 = Double(baselineHandiPar5) ?? 0.0
            }
            
            var maxAbsoluteValue = 0.0
            var setParText = ""
            var setLoseGain = ""
            
            if(abs(par3s-baselineHandicapPar3)>0.2 && maxAbsoluteValue<abs(par3s-baselineHandicapPar3)){
                maxAbsoluteValue = abs(par3s-baselineHandicapPar3)
                setParText = "Par-3"
                if((par3s-baselineHandicapPar3)<0){
                    setLoseGain = "gain"
                }else{
                    setLoseGain = "lose"
                }
            }
            if(abs(par4s-baselineHandicapPar4)>0.2 && maxAbsoluteValue<abs(par4s-baselineHandicapPar4)){
                maxAbsoluteValue = abs(par4s-baselineHandicapPar4)
                setParText = "Par-4"
                if((par4s-baselineHandicapPar4)<0){
                    setLoseGain = "gain"
                }else{
                    setLoseGain = "lose"
                }
            }else{}
            if(abs(par5s-baselineHandicapPar5)>0.2 && maxAbsoluteValue<abs(par5s-baselineHandicapPar5)){
                maxAbsoluteValue = abs(par5s-baselineHandicapPar5);
                setParText = "Par-5"
                if((par5s-baselineHandicapPar5)<0){
                    setLoseGain = "gain"
                }else{
                    setLoseGain = "lose"
                }
            }
            let spannableString = "You " + setLoseGain + " " + String(format:"%.01f",maxAbsoluteValue) + " strokes to other golfers of your HCP on each " + setParText + " Hole."
            attributedOverviewParAvg = NSMutableAttributedString(string: spannableString)
            
            let textToHighlight = setLoseGain + " " + String(format:"%.01f",maxAbsoluteValue) + " strokes"
            
            if(setLoseGain.contains("gain")){
                attributedOverviewParAvg.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 4, length: textToHighlight.count))
            }
            else if(setLoseGain.contains("lose")){
                attributedOverviewParAvg.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 4, length: textToHighlight.count))
            }
            if(abs(par3s-baselineHandicapPar3)<0.2 && abs(par4s-baselineHandicapPar4)<0.2 && abs(par5s-baselineHandicapPar5)<0.2){
                
                let spannableStr = "Your Par-Averages are similar to other golfers of your HCP"
                attributedOverviewParAvg = NSMutableAttributedString(string: spannableStr)
                attributedOverviewParAvg.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfFlatBlue, range: NSRange(location: 0, length: spannableStr.count))
            }
        }
        return attributedOverviewParAvg
    }
    
    func getApproachGIR(p:Double)->NSMutableAttributedString{
        var attributedApproachGIR = NSMutableAttributedString()
        
        if baselineDict != nil{
            
            var girBaseLine = 0.0
            
            if let baselineGIR = baselineDict.value(forKey: "gir") as? String{
                girBaseLine = Double(baselineGIR) ?? 0.0
            }
            
            if(abs(girBaseLine-p)>5){
                var strHitMiss = ""
                
                if(p-girBaseLine>0){
                    strHitMiss = "hit "
                }else{
                    strHitMiss = "miss "
                }
                let finalValueGir:Double = abs(girBaseLine-p);
                let spannableString = "You " + strHitMiss + "\(Int(finalValueGir))" + "% more greens than other golfers like you"
                attributedApproachGIR = NSMutableAttributedString(string: spannableString)
                
                let textToHighlight = strHitMiss + "\(Int(finalValueGir))" + "% more greens"
                
                if(strHitMiss.contains("hit")){
                    attributedApproachGIR.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 4, length: textToHighlight.count))
                }
                else if(strHitMiss.contains("miss")){
                    attributedApproachGIR.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 4, length: textToHighlight.count))
                }
            }
            else{
                let spannableStr = "Your Approach Accuracy is similar to other golfers of your HCP."
                attributedApproachGIR = NSMutableAttributedString(string: spannableStr)
                attributedApproachGIR.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfFlatBlue, range: NSRange(location: 0, length: spannableStr.count))
            }
        }
        return attributedApproachGIR
    }
    func getPuttsBreakup(zeroPutts:Double, onePutts:Double, twoPutts:Double, threePutts:Double, fourPutts:Double)->NSMutableAttributedString{
        
        var attributedPuttsBreakup = NSMutableAttributedString()
        
        let totalNumberOfPutts = zeroPutts + onePutts + twoPutts + threePutts + fourPutts
        var zeroPuttPercentage = 0.0
        var onePuttPercentage = 0.0
        var twoPuttPercentage = 0.0
        var threePuttPercentage = 0.0
        var fourPuttPercentage = 0.0
        if (zeroPutts>0){
            zeroPuttPercentage = zeroPutts * 100 / totalNumberOfPutts
        }
        if (onePutts>0){
            onePuttPercentage = onePutts * 100 / totalNumberOfPutts
        }
        if (twoPutts>0){
            twoPuttPercentage = twoPutts * 100 / totalNumberOfPutts
        }
        if (threePutts>0){
            threePuttPercentage = threePutts * 100 / totalNumberOfPutts
        }
        if (fourPutts>0){
            fourPuttPercentage = fourPutts * 100 / totalNumberOfPutts
        }
        
        if((fourPuttPercentage>10 && threePuttPercentage>10) || (fourPuttPercentage>10 && onePuttPercentage>10)
            || (fourPuttPercentage>10 && zeroPuttPercentage>10) || (threePuttPercentage>10 && onePuttPercentage>10)
            || (threePuttPercentage>10 && zeroPuttPercentage>10) || (onePuttPercentage>10 && zeroPuttPercentage>10)){
            
            var oneTwoThreeFour = ""
            var maxPercentageValue = 0.0
            if(fourPuttPercentage>10){
                oneTwoThreeFour = "four";
                maxPercentageValue = fourPuttPercentage
            }
            if(threePuttPercentage>10){
                oneTwoThreeFour = "three"
                maxPercentageValue = threePuttPercentage
            }
            if(onePuttPercentage>10){
                oneTwoThreeFour = "one"
                maxPercentageValue = onePuttPercentage
            }
            if(zeroPuttPercentage>10){
                oneTwoThreeFour = "zero"
                maxPercentageValue = zeroPuttPercentage
            }
            let spannableString = "You " + oneTwoThreeFour + "-putt " + String(format: "%.01f", maxPercentageValue) + "% of your holes."
            attributedPuttsBreakup = NSMutableAttributedString(string: spannableString)
            
            let textToHighlight = oneTwoThreeFour + "-putt " + String(format:"%.01f", maxPercentageValue) + "%"
            
            if((oneTwoThreeFour.contains("zero") || oneTwoThreeFour.contains("one"))){
                attributedPuttsBreakup.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 4, length: textToHighlight.count))
            }
            else if((oneTwoThreeFour.contains("three") || oneTwoThreeFour.contains("four"))){
                attributedPuttsBreakup.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 4, length: textToHighlight.count))
            }
        }
        else if(fourPuttPercentage>10 || threePuttPercentage>10 || onePuttPercentage>10 || zeroPuttPercentage>10){
            var oneTwoThreeFour = ""
            var maxPercentageValue  = 0.0
            if(fourPuttPercentage>10){
                oneTwoThreeFour = "four"
                maxPercentageValue = fourPuttPercentage
            }
            if(threePuttPercentage>10){
                oneTwoThreeFour = "three"
                maxPercentageValue = threePuttPercentage
            }
            if(onePuttPercentage>10){
                oneTwoThreeFour = "one";
                maxPercentageValue = onePuttPercentage
            }
            if(zeroPuttPercentage>10){
                oneTwoThreeFour = "zero";
                maxPercentageValue = zeroPuttPercentage
            }
            let spannableString = "You " + oneTwoThreeFour + "-putt " + String(format:"%.01f", maxPercentageValue) + "% of your holes."
            attributedPuttsBreakup = NSMutableAttributedString(string: spannableString)
            
            let textToHighlight = oneTwoThreeFour + "-putt " + String(format:"%.01f", maxPercentageValue) + "%"
            
            if((oneTwoThreeFour.contains("zero") || oneTwoThreeFour.contains("one"))){
                attributedPuttsBreakup.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 4, length: textToHighlight.count))
            }
            else if((oneTwoThreeFour.contains("three") || oneTwoThreeFour.contains("four"))){
                attributedPuttsBreakup.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 4, length: textToHighlight.count))
            }
        }
        var zeroMoreThanTenPercentage = true
        var oneMoreThanTenPercentage = true
        let twoMoreThanTenPercentage = true
        var threeMoreThanTenPercentage = true
        var fourMoreThanTenPercentage = true
        if(fourPuttPercentage>0){
            if(fourPuttPercentage<10){
                fourMoreThanTenPercentage = true
            }
            else{
                fourMoreThanTenPercentage = false
            }
        }
        if(threePuttPercentage>0){
            if(threePuttPercentage<10){
                threeMoreThanTenPercentage = true
            }
            else{
                threeMoreThanTenPercentage = false
            }
        }
        if(onePuttPercentage>0){
            if(onePuttPercentage<10){
                oneMoreThanTenPercentage = true
            }
            else{
                oneMoreThanTenPercentage = false
            }
        }
        if(zeroPuttPercentage>0){
            if(zeroPuttPercentage<10){
                zeroMoreThanTenPercentage = true
            }
            else{
                zeroMoreThanTenPercentage = false
            }
        }
        if(zeroMoreThanTenPercentage && oneMoreThanTenPercentage && twoMoreThanTenPercentage && threeMoreThanTenPercentage && fourMoreThanTenPercentage){
            
            let spannableStr = "You two-putt " + String(format:"%.01f", twoPuttPercentage) + " of your holes"
            attributedPuttsBreakup = NSMutableAttributedString(string: spannableStr)
            attributedPuttsBreakup.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfFlatBlue, range: NSRange(location: 0, length: spannableStr.count))
        }
        return attributedPuttsBreakup
    }
    
    func getPuttsHandicap(avergePutts:Double)->NSMutableAttributedString{
        
        var attributedPuttsHandicap = NSMutableAttributedString()
        
        if baselineDict != nil{
            var baselinePuttPerRound = 0.0
            if let puttsPerRound = baselineDict.value(forKey: "puttsPerRound") as? String{
                baselinePuttPerRound = Double(puttsPerRound) ?? 0.0
            }
            
            if(baselinePuttPerRound>avergePutts){
                
                let spannableString = "You gain " + String(format:"%.01f", abs(baselinePuttPerRound-avergePutts)) + " strokes per round to other golfers of your handicap."
                attributedPuttsHandicap = NSMutableAttributedString(string: spannableString)
                
                let textToHighLight = "gain " + String(format:"%.01f", abs(baselinePuttPerRound-avergePutts)) + " strokes"
                
                attributedPuttsHandicap.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.glfBluegreen, range: NSRange(location: 4, length: textToHighLight.count))
            }
            else{
                let spannableString = "You lose " + String(format:"%.01f", abs(baselinePuttPerRound-avergePutts)) + " strokes per round to other golfers of your handicap."
                attributedPuttsHandicap = NSMutableAttributedString(string: spannableString)
                
                let textToHighLight = "lose " + String(format:"%.01f", abs(baselinePuttPerRound-avergePutts)) + " strokes"
                
                attributedPuttsHandicap.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 4, length: textToHighLight.count))
            }
        }
        return attributedPuttsHandicap
    }
    // OTTView Scoring
    let dict1:[NSAttributedStringKey:Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfFlatBlue]
    let dict2:[NSAttributedStringKey:Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfBluegreen]
    let dict3:[NSAttributedStringKey:Any] = [NSAttributedStringKey.foregroundColor : UIColor.glfDustyRed]
    func getDriveAccuracyData(fairHit:Double)->NSAttributedString{
        var attributedText = NSAttributedString()
        let msg = "Your Driving Accuracy is similar to other golfers of your HCP."
        var baselineFHit : Double!
        if let baselineHit = baselineDict.value(forKey: "fairwayHit") as? String{
            baselineFHit = Double(baselineHit)!
        }
        let absHitValue = abs(baselineFHit - fairHit)
        attributedText = NSAttributedString(string: "\(msg)", attributes: self.dict1)
        if absHitValue > 5{
            var hit = "Hit"
            attributedText = (NSAttributedString(string: "\(hit) \(absHitValue.rounded(toPlaces: 1))%", attributes: self.dict2))
            if (fairHit - baselineFHit) < 0{
                hit = "Miss"
                attributedText = (NSAttributedString(string: " \(hit) \(absHitValue.rounded(toPlaces: 1))%", attributes: self.dict3))
            }
        }
        return attributedText
    }
    func getFairwaysHitTrendsData(dataValues:[Double])-> NSMutableDictionary{
        let msg = "Your Driving Accuracy looks consistent."
        var attributedText = NSAttributedString(string: "\(msg)", attributes: self.dict1)
        var firstTwo = Double()
        var lastTwo = Double()
        let dict = NSMutableDictionary()

        if dataValues.count > 2{
            firstTwo = (dataValues[0] + dataValues[1])/2.0
            lastTwo = (dataValues[dataValues.count-1] + dataValues[dataValues.count-2])/2.0
            let percentFairwayTrend = (abs(firstTwo-lastTwo)/firstTwo)*100
            var color = UIColor.glfWarmGrey
            if percentFairwayTrend > 5{
                var setImproveWorse = "improved"
                attributedText = (NSAttributedString(string: "\(setImproveWorse) by", attributes: self.dict2))
                color = UIColor.glfBluegreen
                if (lastTwo < firstTwo) {
                    setImproveWorse = "worsened"
                    attributedText = (NSAttributedString(string: "\(setImproveWorse) by", attributes: self.dict3))
                    color = UIColor.glfDustyRed
                }
            }
            dict.setValue(attributedText, forKey: "text")
            dict.setValue(percentFairwayTrend, forKey: "percentFairwayTrend")
            dict.setValue(color, forKey: "color")
            dict.setValue(firstTwo, forKey: "firstTwo")
        }
        return dict
    }
    func getGIRTrendsData(dataValues:[Double])-> NSMutableDictionary{
        let msg = "Your Approach Accuracy looks consistent."
        var attributedText = NSAttributedString(string: "\(msg)", attributes: self.dict1)
        var firstTwo = Double()
        var lastTwo = Double()
        let dict = NSMutableDictionary()
        
        if dataValues.count > 2{
            firstTwo = (dataValues[0] + dataValues[1])/2.0
            lastTwo = (dataValues[dataValues.count-1] + dataValues[dataValues.count-2])/2.0
            let percentFairwayTrend = (abs(firstTwo-lastTwo)/firstTwo)*100
            var color = UIColor.glfWarmGrey
            if percentFairwayTrend > 5{
                var setImproveWorse = "improved"
                attributedText = (NSAttributedString(string: "\(setImproveWorse) by", attributes: self.dict2))
                color = UIColor.glfBluegreen
                if (lastTwo < firstTwo) {
                    setImproveWorse = "worsened"
                    attributedText = (NSAttributedString(string: "\(setImproveWorse) by", attributes: self.dict3))
                    color = UIColor.glfDustyRed
                }
            }
            dict.setValue(attributedText, forKey: "text")
            dict.setValue(percentFairwayTrend, forKey: "percentGIRTrend")
            dict.setValue(color, forKey: "color")
            dict.setValue(firstTwo, forKey: "firstTwo")
        }
        return dict
    }
    
    // Chipping Data
    func getChipUND(p:Double)->NSAttributedString{
        var attributedText = NSAttributedString()
        let msg = "Your Scrambling Performance is similar to other golfers of your HCP."
        var baselineChipUND : Double!
        if let baselineHit = baselineDict.value(forKey: "chipUpAndDown") as? String{
            baselineChipUND = Double(baselineHit)!
        }
        let absHitValue = abs(p-baselineChipUND)
        attributedText = NSAttributedString(string: "\(msg)", attributes: self.dict1)
        if absHitValue > 5{
            var hit = "more"
            attributedText = (NSAttributedString(string: " \(Int(absHitValue))% \(hit) up & downs", attributes: self.dict2))
            if (p - baselineChipUND) < 0{
                hit = "less"
                attributedText = (NSAttributedString(string: " \(Int(absHitValue))% \(hit) up & downs", attributes: self.dict3))
            }
        }
        return attributedText
    }
    func getSandUND(p:Double)->NSAttributedString{
        var attributedText = NSAttributedString()
        let msg = "Your Sand-Save Performance is similar to other golfers of your HCP."
        var baselineChipUND : Double!
        if let baselineHit = baselineDict.value(forKey: "sandUpAndDown") as? String{
            baselineChipUND = Double(baselineHit)!
        }
        let absHitValue = abs(p-baselineChipUND)
        attributedText = NSAttributedString(string: "\(msg)", attributes: self.dict1)
        if absHitValue > 5{
            var hit = "more"
            attributedText = (NSAttributedString(string: " \(Int(absHitValue))% \(hit) sand saves", attributes: self.dict2))
            if (p - baselineChipUND) < 0{
                hit = "less"
                attributedText = (NSAttributedString(string: " \(Int(absHitValue))% \(hit) sand saves", attributes: self.dict3))
            }
        }
        return attributedText
    }
    
    // Strokes Gained
    func getSGPerClub(gainAvg: Double, gainAvg1:Double, gainAvg2:Double, gainAvg3:Double)-> String{
        
        var sGPerClubStr = String()
        var setStrokesGainedString = ""
        if(skrokesGainedFilter==0){
            setStrokesGainedString = "PGA Tour"
        }
        else if(skrokesGainedFilter==1){
            setStrokesGainedString = "Men's - Scratch"
        }
        else if(skrokesGainedFilter==2){
            setStrokesGainedString = "Men's - 18 Handicap"
        }
        else if(skrokesGainedFilter==3){
            setStrokesGainedString = "Women's - Scratch"
        }
        else if(skrokesGainedFilter==4){
            setStrokesGainedString = "Women's - 18 Handicap"
        }
        if (gainAvg <= 1 && gainAvg1 <= 1 && gainAvg2 <= 1 && gainAvg3 <= 1) {
            sGPerClubStr = "Your Strokes Gained performance is similar to other golfers of the " + setStrokesGainedString + " Category"
        }
        else if (abs(gainAvg) > 1 || abs(gainAvg1) > 1 || abs(gainAvg2) > 1 || abs(gainAvg3) > 1) {
            
            var maxAbsoluteValueOfStrokesGaines = 0.0
            var setOffAproachAroundPutting = ""
            var setLoseGain = ""
            
            if (maxAbsoluteValueOfStrokesGaines < abs(gainAvg)) {
                
                maxAbsoluteValueOfStrokesGaines = abs(gainAvg)
                setOffAproachAroundPutting = "Off the Tee"
                
                if (gainAvg > 0) {
                    setLoseGain = "gain "
                } else {
                    setLoseGain = "lose "
                }
            }
            if (maxAbsoluteValueOfStrokesGaines < abs(gainAvg1)) {
                
                maxAbsoluteValueOfStrokesGaines = abs(gainAvg1)
                setOffAproachAroundPutting = "Approach"
                
                if (gainAvg1 > 0) {
                    setLoseGain = "gain "
                } else {
                    setLoseGain = "lose "
                }
            }
            if (maxAbsoluteValueOfStrokesGaines < abs(gainAvg2)) {
                
                maxAbsoluteValueOfStrokesGaines = abs(gainAvg2)
                setOffAproachAroundPutting = "Around the Green"
                
                if (gainAvg2 > 0) {
                    setLoseGain = "gain "
                } else {
                    setLoseGain = "lose "
                }
            }
            if (maxAbsoluteValueOfStrokesGaines < abs(gainAvg3)) {
                maxAbsoluteValueOfStrokesGaines = abs(gainAvg3)
                setOffAproachAroundPutting = "Putting"
                if (gainAvg3 > 0) {
                    setLoseGain = "gain "
                } else {
                    setLoseGain = "lose "
                }
            }
            sGPerClubStr = "You " + setLoseGain + String(format:"%.01f", maxAbsoluteValueOfStrokesGaines) + " strokes in " + setOffAproachAroundPutting + " per round to " + setStrokesGainedString + " Category golfers."
        }
        return sGPerClubStr
    }
    // smart caddie
    func getSGPerClubForSmartCaddie(setMaxAbsoluteValueStrokesGained: Double,club:String)-> String{
        var sGPerClubStr = String()
        var setStrokesGainedString = ""
        var setLoseGain = ""
        if(skrokesGainedFilter==0){
            setStrokesGainedString = "PGA Tour"
        }
        else if(skrokesGainedFilter==1){
            setStrokesGainedString = "Men's - Scratch"
        }
        else if(skrokesGainedFilter==2){
            setStrokesGainedString = "Men's - 18 Handicap"
        }
        else if(skrokesGainedFilter==3){
            setStrokesGainedString = "Women's - Scratch"
        }
        else if(skrokesGainedFilter==4){
            setStrokesGainedString = "Women's - 18 Handicap"
        }
        if (setMaxAbsoluteValueStrokesGained > 0) {
            setLoseGain = "gain "
        } else {
            setLoseGain = "lose "
        }
        if(abs(setMaxAbsoluteValueStrokesGained)<=0.5) {
            sGPerClubStr = "Your Strokes Gained stats closely resemble other golfers of the "+setStrokesGainedString
        }else if(abs(setMaxAbsoluteValueStrokesGained)>0.5) {
            sGPerClubStr = "You \(setLoseGain) \(abs(setMaxAbsoluteValueStrokesGained.rounded(toPlaces: 1))) strokes per round over \(setStrokesGainedString) golfers, using \(club)"
        }
        return sGPerClubStr
    }
    
    
    /*func getSmartCaddieSGPerClub(setMaxAbsoluteValueStrokesGained:Double, setLoseGainSG:Double){
     var smartCaddieSGPerClubStr = String()
     
     if(setMaxAbsoluteValueStrokesGained>0){
     
     var setStrokesGainedString = ""
     
     if(skrokesGainedFilter==0){
     setStrokesGainedString = "PGA Tour"
     }
     else if(skrokesGainedFilter == 1){
     setStrokesGainedString = "Men's - Scratch"
     }
     else if(skrokesGainedFilter == 2){
     setStrokesGainedString = "Men's - 18 Handicap"
     }
     else if(skrokesGainedFilter == 3){
     setStrokesGainedString = "Women's - Scratch"
     }
     else if(skrokesGainedFilter == 4){
     setStrokesGainedString = "Women's - 18 Handicap"
     }
     
     if(setMaxAbsoluteValueStrokesGained <= 0.5) {
     
     smartCaddieSGPerClubStr = "Your Strokes Gained stats closely resemble other golfers of the " + setStrokesGainedString
     }
     else if(setMaxAbsoluteValueStrokesGained > 0.5) {
     
     smartCaddieSGPerClubStr = "You " + setLoseGainSG + String(format:"%.01f", setMaxAbsoluteValueStrokesGained) + " strokes per round over " + setStrokesGainedString + " golfers, using " + BaseClassContext.getClubFullName(clubNameStrokesGainmed)
     }
     }
     }*/
    //Smart Caddie
    
}
