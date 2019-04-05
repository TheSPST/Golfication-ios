//
//  BackgroundMapStats.swift
//  Golfication
//
//  Created by Khelfie on 12/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import Intents
import CoreData
import FacebookCore
class BackgroundMapStats: NSObject {
    static var blockRecursionIssue = 0
    static let clubsFullForm = ["Dr":"Driver","w":"Wood","h":"Hybrid","i":"Iron","Pw":"P Wedge","Gw":"Gap Wedge","Sw":"Sand Wedge","Lw":"Lob Wedge","Pu":"Putter"]
    static func getClubName(club:String)->String{
        var clubToShow = String()
        if(club.count > 0){
            if let fullName = clubsFullForm[club]{
                clubToShow =  fullName
            }
            else if let fullName = clubsFullForm["\(club.last!)"]{
                clubToShow =  "\(club.first!) \(fullName)"
            }
        }
        return clubToShow
    }
    static func nearByPoint(newPoint:CLLocationCoordinate2D, array:[CLLocationCoordinate2D])->Int{
        var distance = [Double]()
        for coord in array{
            distance.append(GMSGeometryDistance(newPoint, coord))
        }
        return (distance.index(of: distance.min()!)!)
    }

    static func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
        var x = 0.0 as CGFloat
        var y = 0.0 as CGFloat
        var z = 0.0 as CGFloat
        
        for coordinate in listCoords{
            let lat:CGFloat = ((CGFloat(coordinate.latitude)) / 180.0 * CGFloat(Double.pi))
            let lon:CGFloat = ((CGFloat(coordinate.longitude)) / 180.0 * CGFloat(Double.pi))
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon);
            z = z + sin(lat);
        }
        x = x/CGFloat(listCoords.count)
        y = y/CGFloat(listCoords.count)
        z = z/CGFloat(listCoords.count)
        
        let resultLon: CGFloat = atan2(y, x)
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        let resultLat:CGFloat = atan2(z, resultHyp)
        let newLat = CLLocationDegrees(resultLat * CGFloat(180.0 / .pi))
        let newLon = CLLocationDegrees(resultLon * CGFloat(180.0 / .pi))
        let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        return result
    }
    static func setStartingEndingChar(str:String)->String{
        let typeArray = ["F","G","R","S","T"]
        var returnedStr = String()
        if(!typeArray.contains(str)){
            if(str == "GB" || str == "FB"){
                returnedStr = "S"
            }
            else{
                returnedStr = "R"
            }
        }
        else{
            returnedStr = str
        }
        return returnedStr
    }
    static func findPositionOfPointInside(position:CLLocationCoordinate2D,whichFeature:[CLLocationCoordinate2D])->Bool{
        let path = GMSMutablePath()
        for j in 0..<whichFeature.count{
            path.add(whichFeature[j])
        }
        if(GMSGeometryContainsLocation(position, path, true)){
            return true
        }
        return false
    }
    static func getDataFromJson(lattitude:Double,longitude:Double, onCompletion: @escaping ([String:AnyObject]?, String?) -> Void) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lattitude)&lon=\(longitude)&APPID=a261cc920ea8ff18f5c941b4675f1b8a")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            guard let data = Data, error == nil else {  // check for fundamental networking error
                debugPrint("error=\(error ?? "some error Comes" as! Error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                return
            }
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            onCompletion(responseString, nil)
        }
        task.resume()
    }
    static func isPositionAvailable(latLng:CLLocationCoordinate2D, latLngArray:[CLLocationCoordinate2D]) ->Int{
        var availableAtIndex = -1
        for i in 0..<latLngArray.count{
            if(latLng.latitude == latLngArray[i].latitude && latLng.longitude == latLngArray[i].longitude ){
                availableAtIndex = i
                break
            }
        }
        return availableAtIndex
    }
    static func getNearbymarkers(position:CLLocationCoordinate2D,markers:[GMSMarker])->Int{
        var distanceArray = [Double]()
        for markers in markers{
            let distance = GMSGeometryDistance(markers.position, position)
            distanceArray.append(distance)
            debugPrint(markers.title!)
        }
        return distanceArray.index(of: distanceArray.min()!) ?? 0
    }
    
    static func setHoleShotDetails(par:Int,shots:Int)->(String,UIColor){
        var holeFinishStatus = String()
        var color = UIColor()
        if (shots > par) {
            if (shots - par > 1) {
                holeFinishStatus = " \(shots-par) "+"Bogey".localized()
                color = UIColor.glfRosyPink
            } else {
                holeFinishStatus = " "+"Bogey".localized()
                color = UIColor.glfRosyPink
            }
        } else if (shots < par) {
            if (par == 3) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 2) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                    color = UIColor.glfFlatBlue
                }
            } else if (par == 4) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 2) {
                    holeFinishStatus = "  "+"Eagle".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 3) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                    color = UIColor.glfFlatBlue
                }
            } else if (par == 5) {
                if (par - shots == 1) {
                    holeFinishStatus = "  "+"Birdie".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 2) {
                    holeFinishStatus = "  "+"Eagle".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 3) {
                    holeFinishStatus = "  "+"Albatross".localized()+"  "
                    color = UIColor.glfFlatBlue
                } else if (par - shots == 4) {
                    holeFinishStatus = " "+"Hole In One".localized()+" "
                    color = UIColor.glfFlatBlue
                }
            }
        } else if (shots == par) {
            holeFinishStatus = "  "+"Par".localized()+"  "
            color = UIColor.glfFlatBlue
        }
        return (holeFinishStatus,color)
    }
    static func returnLandedOnFullName(data:String)->(String,UIColor){
        var fullName = "Rough"
        var color = UIColor.glfRough
        if data == "G"{
            color = UIColor.glfGreen
            fullName = "Green"
        }else if data == "F" {
            color = UIColor.glfFairway
            fullName = "Fairway"
        }else if data == "GB" || data == "FB"{
            fullName = "Bunker"
            color = UIColor.glfBunker
        }
        else if data == "WH"{
            fullName = "Water H."
            color = UIColor.glfBluegreen
        }
        return (fullName,color)
    }
    static func coordInsideFairway(newPoint:CLLocationCoordinate2D, array:[CLLocationCoordinate2D],path:GMSMutablePath)->CLLocationCoordinate2D{
        
        let coordinate = array[BackgroundMapStats.nearByPoint(newPoint: newPoint, array: array)]
        blockRecursionIssue += 2
        let distance = GMSGeometryDistance(newPoint, coordinate)
        let headingAngle = GMSGeometryHeading(newPoint,coordinate)
        var nextPoint = GMSGeometryOffset(newPoint, distance+8.0, headingAngle)
        if(GMSGeometryContainsLocation(nextPoint, path, true)){
            return nextPoint
        }
        else{
            if(blockRecursionIssue > 200){
                return nextPoint
            }
            nextPoint = coordInsideFairway(newPoint: nextPoint, array: array, path: path)
        }
        return nextPoint
    }
    
    static func getPoints(hole:CLLocationCoordinate2D,greenPath:[CLLocationCoordinate2D],gir:Double,insideDistance:Double)->CLLocationCoordinate2D{
        var latLngArray = greenPath
        var greenHeadingAngle = 0.0
        var distance = 0.0
        var maxDistance = 0.0
        let generatedDistance = 0.0
        var distanceArray = [Double]()
        var offsetLatLong = CLLocationCoordinate2D()
        for i in 0..<latLngArray.count{
            distance = GMSGeometryDistance(hole,latLngArray[i])
            distanceArray.append(distance)
            if(maxDistance < distance){
                maxDistance = distance;
            }
        }
        var dX = 20.0
        if(insideDistance < 5){
            dX = 2.0 * insideDistance
        }
        let maximumDistance = insideDistance-dX > dX ? insideDistance-dX : dX
        let minimumDistance = insideDistance-dX < dX ? insideDistance-dX : dX
        
        let convertInside = Int(maximumDistance-minimumDistance)
        let randomGeneratedDistance = Int(arc4random_uniform(UInt32(convertInside))) + Int(minimumDistance)
        let randomGir = Double(arc4random_uniform(100))
        
        for _ in 0..<latLngArray.count{
            var randomHeading = Int(arc4random_uniform(UInt32(latLngArray.count - 1)))
            randomHeading += 1
            if(randomHeading == latLngArray.count){
                randomHeading = 0
            }
            if(randomGir<gir) {
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                if (insideDistance - maxDistance > 20) {
                    offsetLatLong = GMSGeometryOffset(hole,insideDistance, greenHeadingAngle)
                    break
                }
                
                if(generatedDistance<maxDistance){
                    if(distanceArray[randomHeading] > Double(randomGeneratedDistance)) {
                        greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                        offsetLatLong = GMSGeometryOffset(hole,Double(randomGeneratedDistance), greenHeadingAngle)
                        break
                    }
                }
                
                if (generatedDistance > maxDistance) {
                    greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                    offsetLatLong = GMSGeometryOffset(hole,(maxDistance - Double(arc4random_uniform(5)) > 0 ? 2:maxDistance -  Double(arc4random_uniform(5))), greenHeadingAngle)
                    break
                }
            }else{
                distance = GMSGeometryDistance(hole,latLngArray[randomHeading])
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                offsetLatLong = GMSGeometryOffset(hole,Double(distance) + Double(arc4random_uniform(20)), greenHeadingAngle)
                break
            }
        }
        if(offsetLatLong.latitude == 0){
            offsetLatLong = GMSGeometryOffset(hole,insideDistance, Double(arc4random_uniform(360)))
        }
        return offsetLatLong
    }
    static func removeRepetedElement(curvedArray : [CLLocationCoordinate2D] )->[CLLocationCoordinate2D]{
        var uniqueArray = [CLLocationCoordinate2D]()
        if(!curvedArray.isEmpty){
            var lat = [CLLocationDegrees]()
            var lng = [CLLocationDegrees]()
            for i in 0..<curvedArray.count{
                lat.append(curvedArray[i].latitude)
                lng.append(curvedArray[i].longitude)
            }
            lat = lat.removeDuplicates()
            lng = lng.removeDuplicates()
            if lng.count == lat.count{
                for i in 0..<lng.count{
                    uniqueArray.append(CLLocationCoordinate2D(latitude: lat[i], longitude: lng[i]))
                }
            }else{
                uniqueArray = curvedArray
            }

        }
        return uniqueArray
    }
    static func imageOfButton(endingPoint: String)->UIImage{
        let btn = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 16)
        btn.setTitleColor(UIColor.glfWhite, for: .normal)
        btn.layer.cornerRadius = 15
        
        if endingPoint == "G"{
            btn.backgroundColor = UIColor.glfGreen
            btn.setTitle("Green", for: .normal)
        }else if endingPoint == "F" {
            btn.backgroundColor = UIColor.glfFairway
            btn.setTitle("Fairway".localized(), for: .normal)
        }else if endingPoint == "GB" || endingPoint == "FB"{
            btn.setTitle("Bunker", for: .normal)
            btn.backgroundColor = UIColor.glfBunker
        }else{
            btn.setTitle("Rough", for: .normal)
            btn.backgroundColor = UIColor.glfRough
        }
        return btn.screenshot()
    }

    static func getDistanceWithZoom(zoom:Float)->Double{
        var checkDistance:Double = 20
        if (zoom > 20) {
            checkDistance = 1
        } else if (zoom > 19.8 && zoom < 20) {
            checkDistance = 2
        } else if (zoom > 19.6 && zoom < 19.8) {
            checkDistance = 2
        } else if (zoom > 19.4 && zoom < 19.6) {
            checkDistance = 3
        } else if (zoom > 19.2 && zoom < 19.4) {
            checkDistance = 4
        } else if (zoom > 19 && zoom < 19.2) {
            checkDistance = 5
        } else if (zoom > 18.8 && zoom < 19) {
            checkDistance = 6
        } else if (zoom > 18.6 && zoom < 18.8) {
            checkDistance = 7
        } else if (zoom > 18.4 && zoom < 18.6) {
            checkDistance = 8
        } else if (zoom > 18.2 && zoom < 18.4) {
            checkDistance = 9
        } else if (zoom > 17 && zoom < 18.2) {
            checkDistance = 10
        } else if (zoom > 17.8 && zoom < 18) {
            checkDistance = 11
        } else if (zoom > 17.6 && zoom < 17.8) {
            checkDistance = 12
        } else if (zoom > 17.4 && zoom < 17.6) {
            checkDistance = 13
        } else if (zoom > 17.2 && zoom < 17.4) {
            checkDistance = 14
        } else if (zoom > 17 && zoom < 17.2) {
            checkDistance = 15
        } else if (zoom > 16.8 && zoom < 17) {
            checkDistance = 16
        } else if (zoom > 16.6 && zoom < 16.8) {
            checkDistance = 17
        } else if (zoom > 16.4 && zoom < 16.6) {
            checkDistance = 18
        } else if (zoom > 16.2 && zoom < 16.4) {
            checkDistance = 19
        } else if (zoom > 16 && zoom < 16.2) {
            checkDistance = 20
        }
        return checkDistance*3
    }
    //------------getZoomLevel------------------//
    static func getTheZoomLevel(positionsOfDotLine:[CLLocationCoordinate2D])->(CLLocationCoordinate2D,Float){
        var distance = 200.0
        var midPoint = CLLocationCoordinate2D()
        var lat = Int()
        distance  = GMSGeometryDistance(positionsOfDotLine.first!, positionsOfDotLine.last!)
        midPoint = BackgroundMapStats.middlePointOfListMarkers(listCoords: [positionsOfDotLine.first!, positionsOfDotLine.last!])
        lat = Int(midPoint.latitude)
        var zoom = 16.0
        if(lat < 90 && lat > 60){
            if (distance<100){
                zoom = 17.2;
            }else if (distance>100&&distance<150){
                zoom = 17;
            }else if (distance>150&&distance<200){
                zoom = 16.8;
            }else if (distance>200&&distance<250){
                zoom = 16.5;
            }else if (distance>250&&distance<300){
                zoom = 16.1;
            }else if (distance>300&&distance<350){
                zoom = 16.0;
            }else if (distance>350&&distance<400){
                zoom = 15.7;
            }else if (distance>400&&distance<450){
                zoom = 15.6;
            }else if (distance>450&&distance<500){
                zoom = 15.5;
            }else if (distance>500&&distance<550){
                zoom = 15.4;
            }else if (distance>550&&distance<600){
                zoom = 15.3;
            }
        }else{
            if (distance<100){
                zoom = 18.7;
            }else if (distance>100&&distance<150){
                zoom = 18.5;
            }else if (distance>150&&distance<200){
                zoom = 18.3;
            }else if (distance>200&&distance<250){
                zoom = 18;
            }else if (distance>250&&distance<300){
                zoom = 17.6;
            }else if (distance>300&&distance<350){
                zoom = 17.5;
            }else if (distance>350&&distance<400){
                zoom = 17.2;
            }else if (distance>400&&distance<450){
                zoom = 17.1;
            }else if (distance>450&&distance<500){
                zoom = 17;
            }else if (distance>500&&distance<550){
                zoom = 16.8;
            }else if (distance>550&&distance<600){
                zoom = 16.7;
            }
        }
        let middlePointWithZoom = (midPoint,Float(zoom))
        return middlePointWithZoom
    }
    static func sortAndShow(searchDataArr:[NSMutableDictionary],myLocation:CLLocation)->[NSMutableDictionary]{
        var searchArr = searchDataArr
        var indexArr = [Int]()
        var i = 0
        for data in searchArr{
            let latt = data.value(forKey: "Latitude") as! String
            let lng = data.value(forKey: "Longitude") as! String
            if let latti = Double(latt){
                if let lngg = Double(lng){
                    let coord = CLLocation(latitude: latti, longitude: lngg)
                    data.setValue(myLocation.distance(from: coord), forKey: "Distance")
                }else{
                    indexArr.append(i)
                }
            }else{
                indexArr.append(i)
            }
//            if (Double(latt) != nil) && (Double(lng) != nil){
//
//            }else{
//                indexArr.append(i)
//                ref.child("invalidCourses").updateChildValues([data.value(forKey: "Id") as! String:true])
//            }
            i += 1
        }
        for ind in 0..<indexArr.count{
            searchArr.remove(at: indexArr[ind]-ind)
        }
        let sortedArr = searchArr.sorted{
            ($1.value(forKey: "Distance")) as! Double > ($0.value(forKey: "Distance")) as! Double
        }
        return sortedArr
    }
    static func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
        var newPoint = CGPoint(x:view.bounds.size.width * anchorPoint.x, y:view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x:view.bounds.size.width * view.layer.anchorPoint.x, y:view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position : CGPoint = view.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        view.layer.position = position;
        view.layer.anchorPoint = anchorPoint;
    }
    static func getDataInTermOf5(data:Int)->Int{
        var avg = data
        if (avg%10) != 5{
            if (avg%10) % 5 < 3{
                avg -= (avg%10) % 5
            }else{
                avg += (5-((avg%10) % 5))
            }
        }
        return avg
    }
    static func donateInteraction() {
        let intent = DistanceOfGreenIntent()
        intent.suggestedInvocationPhrase = "What’s My Distance"
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    debugPrint("Interaction donation failed:",error)
                } else {
                    debugPrint("Successfully donated interaction")
                }
            }
        }
    }
    static func deleteCoreData(){
        context.performAndWait{ () -> Void in
            let arr = ["CourseDetailsEntity","TeeDistanceEntity","FrontBackDistanceEntity","GreenDistanceEntity","CalledByUserEntity"]
            arr.forEach({ (string) in
                if let counter1 = NSManagedObject.findAllForEntity(string, context: context){
                    counter1.forEach { counter in
                        context.delete(counter as! NSManagedObject)
                    }
                }
            })
        }
    }
    static func setDir(isUp:Bool,label:UILabel){
        label.textColor = !isUp ? UIColor.glfDarkGreen :UIColor.glfRed
        if isUp{
            label.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }else{
            label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        }
    }
    static func getDynamicLinkFromPromocode(code:String){
        let link = URL(string: "https://p5h99.app.goo.gl/mVFa?promocode=\(code)")
        let referralLink = DynamicLinkComponents(link: link!, domain: "p5h99.app.goo.gl")
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.khelfie.Khelfie")
        referralLink.iOSParameters?.minimumAppVersion = "1.0.1"
        referralLink.iOSParameters?.appStoreID = "1216612467"
        referralLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.khelfiegolf")
        referralLink.androidParameters?.minimumVersion = 1
        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let invitationUrl = shortURL
            let invitationStr = invitationUrl?.absoluteString
            debugPrint("URL",invitationUrl!)
//            let shareItems = [invitationStr] as! [String]
//            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
//            activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.message, UIActivityType.mail, UIActivityType.postToFlickr, UIActivityType.postToWeibo, UIActivityType.postToVimeo]
//            // present the view controller
//            //https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
//            //http://www.rockhoppertech.com/blog/uiactivitycontroller-in-swift/
//            activityViewController.completionWithItemsHandler = {
//                (s, ok, items, error) in
//                if ok{
//                    self.sendFriendDataToFirebase(usrName: (textField?.text)!, userId: userId)
//                }
//            }
            
//            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    static func sendMailingRequestToServer(uName: String, uEmail: String) {
        let serverHandler = ServerHandler()
        serverHandler.state = 2
        let fullNameArr = uName.components(separatedBy: " ")
        var fName = uName
        var lName = ""
        if fullNameArr.count > 1{
            fName = fullNameArr[0]
            lName = fullNameArr[1]
        }
        let urlStr = "https://golfication.us15.list-manage.com/subscribe/post?"
        let dataStr =  "u=" + "61aa993cd19d0fb238ab03ae0&amp;" + "id=" + "b8bdae75ef&" + "EMAIL=" + "\(uEmail)&" + "FULLNAME=" + "\(uName)&" + "FNAME=" + "\(fName)&" + "LNAME=" + "\(lName)"
        serverHandler.sendMailingRequest(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            debugPrint("arg0_&_error==", arg0 ?? "", error ?? "")
        }
    }
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    static func getPlaysLike(headingTarget:Double, degree:Double, windSpeed:Double, dist:Double)->Double{
        if (degree == 0 && windSpeed == 0) {
            debugPrint("return Distance:",Constants.distanceFilter == 1 ?dist/Constants.YARD:dist)
            return Constants.distanceFilter == 1 ?dist/Constants.YARD:dist
        }
        let windTarget = windSpeed * cos(((degree-headingTarget)/180)*Double.pi)
        debugPrint("cos:",cos(((degree-headingTarget)/180)*Double.pi))
        var PL1 = dist + (dist * 0.005 * windTarget)
        if (windTarget>0){
            PL1 =  dist + (dist * 0.01 * windTarget)
        }
        let PL2 = (0.58*windTarget*(dist/100)) + dist
        debugPrint("return Distance:",Constants.distanceFilter == 1 ?((PL1 + PL2)/2)/Constants.YARD:(PL1 + PL2)/2)
        debugPrint("__________________________________________")
//
        return Constants.distanceFilter == 1 ?((PL1 + PL2)/2)/Constants.YARD:(PL1 + PL2)/2
        
    }
    static func isDevelopmentProvisioningProfile() -> Bool {
        #if IOS_SIMULATOR
        return true
        #else
        // there will be no provisioning profile in AppStore Apps
        guard let fileName = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            return false
        }
        
        let fileURL = URL(fileURLWithPath: fileName)
        // the documentation says this file is in UTF-8, but that failed
        // on my machine. ASCII encoding worked ¯\_(ツ)_/¯
        guard let data = try? String(contentsOf: fileURL, encoding: .ascii) else {
            return false
        }
        
        let cleared: String = data.components(separatedBy: .whitespacesAndNewlines).joined()
        return cleared.contains("<key>get-task-allow</key><true/>")
        #endif
    }
    static func calculateGoal(scoreData:[(hole:Int,par:Int,players:[NSMutableDictionary])],targetGoal:Goal)->Goal{
        let achievedGoal = Goal()
        for data in scoreData{
            for pla in data.players{
                if let playerData = pla.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSMutableDictionary{
                    let holeOut = playerData.value(forKey: "holeOut") as! Bool
                    if holeOut{
                        var strokes = playerData.value(forKey: "strokes") as? Int ?? 0
                        if let shots = playerData.value(forKey: "strokes") as? NSMutableArray{
                            strokes = shots.count
                        }
                        let gir = playerData.value(forKey: "gir") as? Bool ?? false
                        let fairwayHit = playerData.value(forKey: "fairway") as? String ?? ""
                        if (strokes - data.par) == 0{
                            achievedGoal.par += 1
                        }else if (strokes - data.par) < 0{
                            achievedGoal.par += 1
                            achievedGoal.Birdie += 1
                        }
                        if gir{
                            achievedGoal.gir += 1
                        }
                        if fairwayHit.trim() == "H"{
                            achievedGoal.fairwayHit += 1
                        }
                    }
                }
            }
        }
        let goal = NSMutableDictionary()
        goal.setValue(achievedGoal.Birdie, forKey: "birdie")
        goal.setValue(achievedGoal.par, forKey: "par")
        goal.setValue(achievedGoal.gir, forKey: "gir")
        goal.setValue(achievedGoal.fairwayHit, forKey: "fairway")
        ref.child("matchData/\(Constants.matchId)/player/\(Auth.auth().currentUser!.uid)/goals/achieved").updateChildValues(goal as! [AnyHashable : Any])
        return achievedGoal
    }
}
class Goal{
    var par = Int()
    var gir = Int()
    var Birdie = Int()
    var fairwayHit = Int()
}

