//
//  GolfBagEditPopUpData.swift
//  Golfication
//
//  Created by Rishabh Sood on 05/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit

class GolfBagEditPopUpData: NSObject {

    var selectedLoft = String()
    var selectedLength = String()
    var selectedBrand = String()

    func getLoftAngleArray(clubName: String) -> [String]{
        var dataArray = [String]()

        switch clubName {
        case "Dr":
            //6-16 (interval: 0.5)
            selectedLoft = "9.5"
            for i in 6..<16{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("16.0")
            break
        case "3w":
            //11.5 - 17
            selectedLoft = "15.0"
            dataArray.append("11.5")
            for i in 12..<17{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("17.0")
            break
        case "4w":
            //14.5-18.5
            selectedLoft = "16.0"
            dataArray.append("14.5")
            for i in 15..<19{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "5w":
            //16.5-21.5
            selectedLoft = "19.0"
            dataArray.append("16.5")
            for i in 17..<22{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "7w":
            //19.5-23.5
            selectedLoft = "21.0"
            dataArray.append("19.5")
            for i in 20..<24{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "1h":
            //12.5-17.5
            selectedLoft = "15.0"
            dataArray.append("12.5")
            for i in 13..<18{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "2h":
            //14.5-19.5
            selectedLoft = "17.0"
            dataArray.append("14.5")
            for i in 15..<20{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "3h":
            //16.5-21.5
            selectedLoft = "19.0"
            dataArray.append("16.5")
            for i in 17..<22{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "4h":
            //19.5-24.5
            selectedLoft = "22.0"
            dataArray.append("19.5")
            for i in 20..<25{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "5h":
            //21.5-26.5
            selectedLoft = "25.0"
            dataArray.append("21.5")
            for i in 22..<27{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "6h":
            //24.5-29.5
            selectedLoft = "28.0"
            dataArray.append("24.5")
            for i in 25..<30{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "7h":
            //27.5-34.5
            selectedLoft = "31.0"
            dataArray.append("27.5")
            for i in 28..<35{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            break
        case "1i":
            //13-21
            selectedLoft = "17.0"
            for i in 13..<21{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("21.0")
            break
        case "2i":
            //15-23
            selectedLoft = "19.0"
            for i in 15..<23{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("23.0")
            break
        case "3i":
            //16-26
            selectedLoft = "21.0"
            for i in 16..<26{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("26.0")
            break
        case "4i":
            //19-29
            selectedLoft = "24.0"
            for i in 19..<29{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("29.0")
            break
        case "5i":
            //23-33
            selectedLoft = "28.0"
            for i in 23..<33{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("33.0")
            break
        case "6i":
            //27-37
            selectedLoft = "32.0"
            for i in 27..<37{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("37.0")
            break
        case "7i":
            //31-41
            selectedLoft = "36.0"
            for i in 31..<41{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("41.0")
            break
        case "8i":
            //35-45
            selectedLoft = "40.0"
            for i in 35..<45{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("45.0")
            break
        case "9i":
            //39-49
            selectedLoft = "44.0"
            for i in 39..<49{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("49.0")
            break
        case "Pw":
            //43-53
            selectedLoft = "48.0"
            for i in 43..<53{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("53.0")
            break
        case "Sw":
            //51-61
            selectedLoft = "56.0"
            for i in 51..<61{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("61.0")
            break
        case "Gw":
            //47-57
            selectedLoft = "52.0"
            for i in 47..<57{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("57.0")
            break
        case "Lw":
            //55-67
            selectedLoft = "60.0"
            for i in 55..<67{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.5))
            }
            dataArray.append("67.0")
            break
        case "Pu":
            break

        default: break
            //
        }
        return dataArray
    }
    
    func getClubLengthArray(clubName: String) -> [String]{
        var dataArray = [String]()
        
        //22 - 47.75 (interval: 0.25. In case centimeter is selected the range is 55 cm to 121 cm with gaps of 1 cm)
        if Constants.distanceFilter == 1{
            for i in 55..<122{
                dataArray.append(String(Double(i)))
            }
            let inchToCM = 2.54
            switch clubName {
            case "Dr":
                //6-16 (interval: 0.5)
                selectedLength = "\((45.0*inchToCM).rounded())"
                break
            case "3w":
                //11.5 - 17
                selectedLength = "\((43.0*inchToCM).rounded())"
                break
            case "4w":
                //14.5-18.5
                selectedLength = "\((42.5*inchToCM).rounded())"
                break
            case "5w":
                //16.5-21.5
                selectedLength = "\((42.0*inchToCM).rounded())"
                break
            case "7w":
                //19.5-23.5
                selectedLength = "\((41.5*inchToCM).rounded())"
                break
            case "1h":
                //12.5-17.5
                selectedLength = "\((41.5*inchToCM).rounded())"
                break
            case "2h":
                //14.5-19.5
                selectedLength = "\((41.0*inchToCM).rounded())"
                break
            case "3h":
                //16.5-21.5
                selectedLength = "\((40.5*inchToCM).rounded())"
                break
            case "4h":
                //19.5-24.5
                selectedLength = "\((40.0*inchToCM).rounded())"
                break
            case "5h":
                //21.5-26.5
                selectedLength = "\((39.5*inchToCM).rounded())"
                break
            case "6h":
                //24.5-29.5
                selectedLength = "\((39.0*inchToCM).rounded())"
                break
            case "7h":
                //27.5-34.5
                selectedLength = "\((38.5*inchToCM).rounded())"
                break
            case "1i":
                //13-21
                selectedLength = "\((40.0*inchToCM).rounded())"
                break
            case "2i":
                //15-23
                selectedLength = "\((39.5*inchToCM).rounded())"
                break
            case "3i":
                //16-26
                selectedLength = "\((39.0*inchToCM).rounded())"
                break
            case "4i":
                //19-29
                selectedLength = "\((38.5*inchToCM).rounded())"
                break
            case "5i":
                //23-33
                selectedLength = "\((38.0*inchToCM).rounded())"
                break
            case "6i":
                //27-37
                selectedLength = "\((37.5*inchToCM).rounded())"
                break
            case "7i":
                //31-41
                selectedLength = "\((37.0*inchToCM).rounded())"
                break
            case "8i":
                //35-45
                selectedLength = "\((36.5*inchToCM).rounded())"
                break
            case "9i":
                //39-49
                selectedLength = "\((36.0*inchToCM).rounded())"
                break
            case "Pw":
                //43-53
                selectedLength = "\((35.5*inchToCM).rounded())"
                break
            case "Sw":
                //51-61
                selectedLength = "\((35.0*inchToCM).rounded())"
                break
            case "Gw":
                //47-57
                selectedLength = "\((35.0*inchToCM).rounded())"
                break
            case "Lw":
                //55-67
                selectedLength = "\((35.0*inchToCM).rounded())"
                break
            case "Pu":
                break
                
            default: break
                //
            }
        }
        else{
            for i in 22..<48{
                dataArray.append(String(Double(i)))
                dataArray.append(String(Double(i)+0.25))
                dataArray.append(String(Double(i)+0.50))
                dataArray.append(String(Double(i)+0.75))
            }
            switch clubName {
            case "Dr":
                //6-16 (interval: 0.5)
                selectedLength = "45.0"
                break
            case "3w":
                //11.5 - 17
                selectedLength = "43.0"
                break
            case "4w":
                //14.5-18.5
                selectedLength = "42.5"
                break
            case "5w":
                //16.5-21.5
                selectedLength = "42.0"
                break
            case "7w":
                //19.5-23.5
                selectedLength = "41.5"
                break
            case "1h":
                //12.5-17.5
                selectedLength = "41.5"
                break
            case "2h":
                //14.5-19.5
                selectedLength = "41.0"
                break
            case "3h":
                //16.5-21.5
                selectedLength = "40.5"
                break
            case "4h":
                //19.5-24.5
                selectedLength = "40.0"
                break
            case "5h":
                //21.5-26.5
                selectedLength = "39.5"
                break
            case "6h":
                //24.5-29.5
                selectedLength = "39.0"
                break
            case "7h":
                //27.5-34.5
                selectedLength = "38.5"
                break
            case "1i":
                //13-21
                selectedLength = "40.0"
                break
            case "2i":
                //15-23
                selectedLength = "39.5"
                break
            case "3i":
                //16-26
                selectedLength = "39.0"
                break
            case "4i":
                //19-29
                selectedLength = "38.5"
                break
            case "5i":
                //23-33
                selectedLength = "38.0"
                break
            case "6i":
                //27-37
                selectedLength = "37.5"
                break
            case "7i":
                //31-41
                selectedLength = "37.0"
                break
            case "8i":
                //35-45
                selectedLength = "36.5"
                break
            case "9i":
                //39-49
                selectedLength = "36.0"
                break
            case "Pw":
                //43-53
                selectedLength = "35.5"
                break
            case "Sw":
                //51-61
                selectedLength = "35.0"
                break
            case "Gw":
                //47-57
                selectedLength = "35.0"
                break
            case "Lw":
                //55-67
                selectedLength = "35.0"
                break
            case "Pu":
                break
                
            default: break
                //
            }
        }
        return dataArray
    }
    
    func getBrandArray(clubName: String) -> [String]{

        var dataArray = [String]()
        
        let lastChar = clubName.last!
        let fullName = getFullClubName(clubName: clubName).dropFirst(2)
        
        var genericFullName = "Generic " + getFullClubName(clubName: clubName)
        selectedBrand = genericFullName

        if clubName == "Pw"{
            genericFullName = "Generic " + "P Wedge"
            selectedBrand = genericFullName
        }
        else if clubName == "Sw"{
            genericFullName = "Generic " + "S Wedge"
            selectedBrand = genericFullName
        }
        else if clubName == "Gw"{
            genericFullName = "Generic " + "G Wedge"
            selectedBrand = genericFullName
        }
        else if clubName == "Lw"{
            genericFullName = "Generic " + "L Wedge"
            selectedBrand = genericFullName
        }
        if (clubName == "Dr") || (String(fullName) == "Wood"){
            dataArray = [genericFullName, "Acer", "Adams", "Ben Hogan", "Benross", "Billy Club", "Bob Toski", "Bobby Jones", "Bombtech", "Bridgestone", "Brosnan", "Callaway", "Cleveland", "Coates", "Cobra", "Dunlop", "Fourteen", "Golfsmith", "GX-7 Golf", "Hogan", "Honma", "Inesis", "Intech", "Knuth Golf", "Krank", "Lynx", "Majek", "Maxfli", "Miura", "Mizuno", "Nakashima", "Nickent", "Nicklaus", "Nike", "Nomad", "Odyssey", "Onoff", "Orlimar", "Perfect Club", "Pinemeadow", "Ping", "Powell", "Power Bilt", "PRGR", "PGX", "Revolution Golf", "Royal Collection", "Slazenger", "Sonartec", "Srixon", "Taylormade", "Titleist", "Tommy Armour", "Top Flite", "Tour Edge", "Turin", "Walter Hagen", "Warrior", "Wilson", "Wishon Golf", "XXIO", "Yamaha", "Yonex"]
        }
        else if (lastChar == "i") || ((clubName == "Pw") || (clubName == "Sw") || (clubName == "Gw") || (clubName == "Lw")){

            dataArray = [genericFullName, "Acer", "Adams", "Ben Hogan", "Benross", "Bombtech", "Bridgestone", "Brosnan", "Callaway", "Cleveland", "Coates", "Cobra", "Dunlop", "Edel", "Epon", "Forgan", "Fourteen", "Golfsmith", "Honma", "Inesis", "Infinity", "Intech", "Izzo", "John Letters", "KZG", "Lynx", "Macgregor", "Majek", "Maltby", "Maxfli", "Miura", "Mizuno", "Nakashima", "Nickent", "Nicklaus", "Nike", "Nomad", "Onoff", "Orlimar", "Pinemeadow", "Ping", "Powell", "Power Bilt", "PRGR", "PGX", "RAM", "Royal Collection", "Scratch", "Slazenger", "Sota", "Srixon", "Sub 70", "Taylormade", "Thomas Golf", "Titleist", "Tommy Armour", "Top Flite", "Tour Edge", "TP Mills", "Vega", "Walter Hagen", "Warrior", "Wilson", "Wishon Golf", "XXIO", "Yamaha", "Yonex"]
        }
        else if (lastChar == "h"){
            
            dataArray = [genericFullName, "Adams", "Affinity", "Ben Hogan", "Benross", "Bettinardi", "Bobby Jones", "Bombtech", "Bridgestone", "Brosnan", "C3I", "Callaway", "Cleveland", "Club Nut", "Coates", "Cobra", "Cooper", "Dunlop", "Edel", "Epon", "Forgan", "Fourteen", "Golf Customs", "Golf Gods", "Heavy Putter", "Honma", "Hopkins", "Indi Golf", "Inesis", "Intech", "KZG", "MacGregor", "Majek", "Maltby", "Maxfli", "Miura", "Mizuno", "Nakashima", "Nickent", "Nike", "Nomad", "Odyssey", "Onoff", "Orlimar", "Pinemeadow", "PnP", "Power Bilt", "PRGR", "PGX", "Ray Cook", "Royal Collection", "Scor", "Scratch", "Slazenger", "Slotline", "Smashfactor", "Snake Eyes", "Sonartec", "Spalding", "Srixon", "Strokes Gained Customs", "Sub 70", "Taylormade", "Thomas Golf", "Titleist", "Tommy Armour", "Top Flite", "Tour Edge", "Vega", "Walter Hagen", "Warrior", "Wilson", "Wishon Golf", "XE1", "XXIO", "Yamaha", "Yonex", "Zevo"]
        }
        return dataArray
    }
    
    func getFullClubName(clubName: String) -> String{
        var fullClubName = String()
        
        let lastChar = clubName.last!
        let firstChar = clubName.first!
        
        if lastChar == "i"{
            fullClubName = String(firstChar) + " Iron"
        }
        else if lastChar == "h"{
            fullClubName = String(firstChar) + " Hybrid"
        }
        else if lastChar == "r"{
            fullClubName = "Driver"
        }
        else if lastChar == "u"{
            fullClubName = "Putter"
        }
        else if lastChar == "w"{
            if clubName == "Pw"{
                fullClubName =  "Pitching Wedge"
            }
            else if clubName == "Sw"{
                fullClubName =  "Sand Wedge"
            }
            else if clubName == "Gw"{
                fullClubName =  "Gap Wedge"
            }
            else if clubName == "Lw"{
                fullClubName =  "Lob Wedge"
            }
            else{
                fullClubName = String(firstChar) + " Wood"
            }
        }
        return fullClubName
    }
}
