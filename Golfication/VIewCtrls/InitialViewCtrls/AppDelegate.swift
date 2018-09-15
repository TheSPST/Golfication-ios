  //
  //  AppDelegate.swift
  //  Golfication
  //
  //  Created by IndiRenters on 10/16/17.
  //  Copyright © 2017 Khelfie. All rights reserved.
  //
  
  //fb App ID: 1572174146212337
  import UIKit
  import Firebase
  import GoogleMaps
  import UserNotifications
  import FBSDKCoreKit
  import FBSDKLoginKit
  import UserNotificationsUI
  import Fabric
  import Crashlytics
  import AdSupport
  import FirebaseAuth
  import SwiftyStoreKit
  import StoreKit
  import UserNotifications
  import Google
  var sharedSecret = "79d35d5b3b684c84ba4302a33d498a47"
  var referedBy : String!
  var locationBackgroundTask: UIBackgroundTaskIdentifier!
  
  @UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate{
    var window: UIWindow?
    var locationManager = CLLocationManager()
    let notificationDelegate = UYLNotificationDelegate()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        // ------------------------ Check Fresh install ---------------------------
        let freshInstall = UserDefaults.standard.bool(forKey: "alreadyInstalled")
        if !freshInstall{
            UserDefaults.standard.set(true, forKey: "alreadyInstalled")
            FBSDKLoginManager().logOut()
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            }
            catch let signOutError as NSError {
                debugPrint("error== ",signOutError.localizedDescription)
            }
        }
        //-------------------------------------------------------------------------

        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = false
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "dlscheme"
        GMSServices.provideAPIKey("AIzaSyBiBmJwKydauA_8VfDlaYAg4C1FZImkAI8")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
        self.logUser()
        DynamicLinks.performDiagnostics(completion: nil)
        // for bluetooth
        /*
        if let launchOptions = launchOptions {
            // 2
            if let centralManagerUUIDs = launchOptions[UIApplicationLaunchOptionsKey.bluetoothCentrals] as? Array<String> {
                for id in centralManagerUUIDs {
                    if id == "DEVICE_GOLFICATION_X" {
                        // Restore the CBCentralManager here
                    }
                }
            }
        }*/
        
        
        
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        
        //debugPrint("IDFA",ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        
        // -------------------------- Google Analytics --------------------------------r
        let gai: GAI = GAI.sharedInstance()
        gai.tracker(withTrackingId: "UA-115156894-1")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        //gai.logger.logLevel = .verbose;
        
        
        //------------------- Local Notification ----------------------
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        // ------------------------------------------------------------
        //pendingTransactions()
        
        //----------------- Check Internet Connection ---------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        // ------------------------------------------------------------
//         receiptValidation()
//        verifyReceipt { result in
//            debugPrint(result)
//        }
        return true
    }
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "79d35d5b3b684c84ba4302a33d498a47")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }

    func receiptValidation() {
        var expireDate = Date()
        let SUBSCRIPTION_SECRET = "79d35d5b3b684c84ba4302a33d498a47"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path

        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            print(base64encodedReceipt!)
            
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"
//                let validationURLString = "https://buy.itunes.apple.com/verifyReceipt"
                // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                            for (key,value) in appReceiptJSON{
                                debugPrint(key)
                                if (key == "latest_receipt_info"){
                                    let v = value as? NSArray
                                    debugPrint("latest_receipt_info",v?.lastObject)
                                } else if (key == "pending_renewal_info"){
                                    debugPrint("pending_renewal_info",value)
                                }else if (key == "latest_receipt"){
                                    debugPrint("latest_receipt",value)
                                }else if (key == "receipt"){
                                    debugPrint("receipt",value)
                                }else if (key == "status"){
                                    debugPrint("status",value)
                                }else if (key == "latest_expired_receipt_info"){
                                    debugPrint("latest_expired_receipt_info",value)
                                }
                            }
                        // if you are using your server this will be a json representation of whatever your server provided
                        } catch let error as NSError {
                            debugPrint("json serialization failed with error: \(error)")
                        }
                    } else {
                        debugPrint("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                debugPrint("json serialization failed with error: \(error)")
            }
        }
    }
    
    
    
    
    // MARK: - networkStatusChanged
    @objc func networkStatusChanged(_ notification: NSNotification) {
        let userInfo = (notification as NSNotification).userInfo
        if userInfo!["Status"] as? String == "Offline" {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//            self.window?.makeToast("No internet connection..", duration: 1.0, position: .bottom)
        }
    }
    
    func pendingTransactions() {
        var isPurchased : Purchase!
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        isPurchased = purchase
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        if(isPurchased != nil){
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    let productId = isPurchased.productId
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        type: .autoRenewable, // or .nonRenewing (see below)
                        productId: productId,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate, let receiptItems):
                        debugPrint("Product is valid until \(expiryDate)\(receiptItems)")
                        if(Auth.auth().currentUser!.uid.count > 1){
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(["proMode" :true] as [AnyHashable:Any])
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let myString = formatter.string(from: expiryDate)
                            let yourDate = formatter.date(from: myString)
                            formatter.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
                            let myStringafd = formatter.string(from: yourDate!)
                            
                            let formatter2 = DateFormatter()
                            formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let myString2 = formatter2.string(from: isPurchased.transaction.transactionDate!)
                            let yourDate2 = formatter2.date(from: myString2)
                            formatter2.dateFormat = "dd-MMM-yyyy  HH:mm:ss"
                            let myStringafd1 = formatter2.string(from: yourDate2!)
                            
                            let membershipDict = NSMutableDictionary()
                            membershipDict.setObject(1, forKey: "isMembershipActive" as NSCopying)
                            membershipDict.setObject(Int(NSDate().timeIntervalSince1970), forKey: "timestamp" as NSCopying)
                            membershipDict.setObject(myStringafd, forKey: "expiryDate" as NSCopying)
                            membershipDict.setObject(myStringafd1, forKey: "transactionDate" as NSCopying)
                            membershipDict.setObject(isPurchased.transaction.transactionIdentifier!, forKey: "transactionId" as NSCopying)
                            membershipDict.setObject("ios", forKey: "device" as NSCopying)

                            let proMembership = ["proMembership":membershipDict]
                            ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(proMembership)
                        }
                        
                    case .expired(let expiryDate, let receiptItems):
                        print("Product is expired since \(expiryDate)\(receiptItems)")
                    case .notPurchased:
                        print("This product has never been purchased")
                    }
                    
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
        }
    }
    
    func logUser() {
        // TODO: Use the current user’s information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail(Auth.auth().currentUser?.email)
        Crashlytics.sharedInstance().setUserIdentifier(Auth.auth().currentUser?.uid)
        Crashlytics.sharedInstance().setUserName(Auth.auth().currentUser?.displayName)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //print("Received data message: \(remoteMessage.appData)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        //print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        //print("didRecieve: \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        //print("didRecieveWithComplition: \(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        // Print full message.
        //        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    //1
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        var userInfo = response.notification.request.content.userInfo
        debugPrint("userInfo", userInfo)
        
        
        if userInfo["type"] as? String == "5" {
            // Opens app tutorial
        }
        else if userInfo["type"] as? String == "6" {
            // Default Home Screen
        }
        else if userInfo["type"] as? String == "7" {
            //Opens new game invite screen
        }
        else if userInfo["type"] as? String == "8" {
            // Opens post match summary screen
        }
        else if userInfo["type"] as? String == "9" {
            // Opens the particular feed item
            let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
            window?.rootViewController = tabBarCtrl
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let viewCtrl = storyboard.instantiateViewController(withIdentifier: "MySwingWebViewVC") as! MySwingWebViewVC
            viewCtrl.linkStr = "https://www.indiegogo.com/projects/golfication-x-ai-powered-golf-super-wearable/x/17803765#/"
            viewCtrl.fromIndiegogo = true
            viewCtrl.fromNotification = true
            var navCtrl = UINavigationController()
            navCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            navCtrl.pushViewController(viewCtrl, animated: true)
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if Auth.auth().currentUser == nil{
            
            UIApplication.shared.shortcutItems = []
        }
        finishBackgroundTask()
    }
    
    func finishBackgroundTask(){
        //https://developer.apple.com/documentation/uikit/core_app/managing_your_app_s_life_cycle/preparing_your_app_to_run_in_the_background/extending_your_app_s_background_execution_time
        
        DispatchQueue.global().async {
            
            locationBackgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Finish Network Tasks", expirationHandler: {
                self.endBackgroundTask()
            })
            
            if let currentLocation: CLLocation = self.locationManager.location{
                
                //Background user location when app is terminated/suspended ios
                //http://mobileoop.com/getting-location-updates-for-ios-7-and-8-when-the-app-is-killedterminatedsuspended
                
                var currentCoord = CLLocationCoordinate2D()
                
                currentCoord = currentLocation.coordinate
                
                var homeLat = String()
                var homeLng = String()
                var golfName = String()
                
                if let lat = UserDefaults.standard.object(forKey: "HomeLat") as? String{
                    homeLat = lat
                }
                if let lng = UserDefaults.standard.object(forKey: "HomeLng") as? String{
                    homeLng = lng
                }
                if let courseName = UserDefaults.standard.object(forKey: "HomeCourseName") as? String{
                    golfName = courseName
                }
                if !(homeLat == "") || !(homeLng == ""){
                    let location1 = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
                    let location2 = CLLocation(latitude: Double(homeLat)!, longitude: Double(homeLng)!)
                    let distance : CLLocationDistance = location1.distance(from: location2)
                    debugPrint("distance = \(distance) m")
                    
                    if(distance <= 3000.0) && (golfName != ""){
                        self.sendLocalNotificationToUSer()
                    }
                    else if(distance > 20000.0){
                        self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
                    }
                    else{
                        self.endBackgroundTask()
                    }
                }
                else
                {
                    self.getNearByData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, currentLocation: currentLocation)
                    
                    // ------------ For testing at Saket Metro --------------
                    /*let lat = Double("28.523329")!
                     let lng = Double("77.195157")!
                     currentLocation =  CLLocation(latitude: lat,  longitude: lng)
                     self.getNearByData(latitude: lat, longitude: lng, currentLocation: currentLocation)*/
                }
            }
            else
            {
                self.endBackgroundTask()
            }
        }
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(locationBackgroundTask)
        locationBackgroundTask = UIBackgroundTaskInvalid
    }
    
    // MARK: getNearByData
    func getNearByData(latitude: Double, longitude: Double, currentLocation: CLLocation){
        
        let serverHandler = ServerHandler()
        serverHandler.state = 0
        let urlStr = "nearBy.php?"
        let dataStr =  "lat=" + "\(latitude)&" + "lng=" + "\(longitude)"
        
        serverHandler.getLocations(urlString: urlStr, dataString: dataStr){(arg0, error)  in
            if (arg0 == nil) && (error != nil){
                
                DispatchQueue.main.async(execute: {
                    // In case of -1 response
                })
            }
            else{
                var dataArr =  NSMutableArray()
                
                let (courses) = arg0
                let group = DispatchGroup()
                
                courses?.forEach {
                    group.enter()
                    
                    let dataDic = NSMutableDictionary()
                    dataDic.setObject($0.key, forKey:"Id"  as NSCopying)
                    dataDic.setObject($0.value.Name, forKey : "Name" as NSCopying)
                    dataDic.setObject($0.value.City, forKey : "City" as NSCopying)
                    dataDic.setObject($0.value.Country, forKey : "Country" as NSCopying)
                    dataDic.setObject($0.value.Latitude, forKey : "Latitude" as NSCopying)
                    dataDic.setObject($0.value.Longitude, forKey : "Longitude" as NSCopying)
                    
                    dataArr.add(dataDic)
                    group.leave()
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    
                    if dataArr.count>0{
                        let tempArray = NSMutableArray()
                        
                        for i in 0..<dataArr.count {
                            let distancesDic = NSMutableDictionary()
                            
                            let pinLatitude = Double((dataArr[i] as AnyObject).value(forKey: "Latitude") as! String)!
                            let pinLongitude = Double((dataArr[i] as AnyObject).value(forKey: "Longitude") as! String)!
                            
                            let pinLoc = CLLocation(latitude: pinLatitude, longitude: pinLongitude)
                            
                            let distance: CLLocationDistance = pinLoc.distance(from: currentLocation)
                            
                            distancesDic["Distance"] = distance.toString()
                            distancesDic["Id"] = (dataArr[i] as AnyObject).value(forKey: "Id")
                            distancesDic["Name"] = (dataArr[i] as AnyObject).value(forKey: "Name")
                            distancesDic["City"] = (dataArr[i] as AnyObject).value(forKey: "City")
                            distancesDic["Country"] = (dataArr[i] as AnyObject).value(forKey: "Country")
                            distancesDic["Latitude"] = (dataArr[i] as AnyObject).value(forKey: "Latitude")
                            distancesDic["Longitude"] = (dataArr[i] as AnyObject).value(forKey: "Longitude")
                            
                            tempArray.insert(distancesDic, at: i)
                        }
                        
                        dataArr.removeAllObjects()
                        dataArr = NSMutableArray()
                        dataArr.addObjects(from: tempArray as! [Any])
                        
                        let descriptor = NSSortDescriptor(key: "Distance", ascending: false)
                        dataArr.sort(using: [descriptor])
                        
                        let golfName = ((dataArr[0] as AnyObject).value(forKey: "Name") as? String) ?? ""
                        let golfDistance = ((dataArr[0] as AnyObject).value(forKey: "Distance") as? String) ?? "0.0"
                        
                        let distance: Double  = Double(golfDistance)!
                        if distance < 1000.0 && golfName != ""{
                            UserDefaults.standard.set(golfName, forKey: "NearByGolfClub")
                            UserDefaults.standard.synchronize()
                            self.sendLocalNotificationToUSer()
                        }
                        else{
                            self.endBackgroundTask()
                        }
                    }
                })
            }
        }
    }
    
    func sendLocalNotificationToUSer() {
        
        if let savedTodayDate = UserDefaults.standard.object(forKey: "Today_Date") as? String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            
            let tomorrow = Date()
            let tomorrowDF = DateFormatter()
            tomorrowDF.dateFormat = "dd-MMM-yyyy"
            let tomorrowDateStr = tomorrowDF.string(from: tomorrow)
            
            switch savedTodayDate.compare(tomorrowDateStr) {
                
            case .orderedAscending     :   debugPrint("currentDate is earlier than expDate")
            
            Notification.sendLocaNotificatonNearByGolf()
            let timeNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let currentDateStr = formatter.string(from: timeNow as Date)
            UserDefaults.standard.set(currentDateStr, forKey: "Today_Date")
            UserDefaults.standard.synchronize()
                
            case .orderedDescending    :   debugPrint("currentDate is later than expDate")
                
            case .orderedSame          :   debugPrint("Both dates are same")
                
            }
        }
        else{
            Notification.sendLocaNotificatonNearByGolf()
            
            let timeNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let currentDateStr = formatter.string(from: timeNow as Date)
            UserDefaults.standard.set(currentDateStr, forKey: "Today_Date")
            UserDefaults.standard.synchronize()
        }
        self.endBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        if Auth.auth().currentUser != nil{
            
            let youIcon = UIApplicationShortcutIcon(templateImageName: "avatar_0")
            let youItem = UIApplicationShortcutItem(type: "OpenYouTab", localizedTitle: "You", localizedSubtitle: nil, icon: youIcon, userInfo: nil)
            
            let friendsIcon = UIApplicationShortcutIcon(templateImageName: "together_0")
            let friendsItem = UIApplicationShortcutItem(type: "OpenFriendsTab", localizedTitle: "Friends", localizedSubtitle: nil, icon: friendsIcon, userInfo: nil)
            
            let exploreIcon = UIApplicationShortcutIcon(templateImageName: "explore_0")
            let exploreItem = UIApplicationShortcutItem(type: "OpenExploreTab", localizedTitle: "Explore", localizedSubtitle: nil, icon: exploreIcon, userInfo: nil)
            
            let addScoreIcon = UIApplicationShortcutIcon(templateImageName: "addScore")
            let addScoreItem = UIApplicationShortcutItem(type: "OpenAddScoreTab", localizedTitle: "Play Game", localizedSubtitle: nil, icon: addScoreIcon, userInfo: nil)
            
            UIApplication.shared.shortcutItems = [youItem, friendsItem, exploreItem, addScoreItem]
        }
    }
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void){
        
        let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
        window?.rootViewController = tabBarCtrl
        
        if (shortcutItem.type == "OpenYouTab") {
            tabBarCtrl.selectedIndex = 0
        }
        else if (shortcutItem.type == "OpenFriendsTab") {
            tabBarCtrl.selectedIndex = 1
        }
        else if (shortcutItem.type == "OpenExploreTab") {
            tabBarCtrl.selectedIndex = 2
        }
        else if (shortcutItem.type == "OpenAddScoreTab") {
            
            let gameController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            var playNavCtrl = UINavigationController()
            playNavCtrl.automaticallyAdjustsScrollViewInsets = false
            playNavCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            playNavCtrl.pushViewController(gameController, animated: true)
            playButton.contentView.isHidden = true
            playButton.floatButton.isHidden = true
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url, sourceApplication: nil,annotation: [:])
//        if let isDynamicLink = DynamicLinks.dynamicLinks()?.shouldHandleDynamicLink(fromCustomSchemeURL: url),
//            isDynamicLink {
//            let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
//            if let url = dynamicLink?.url{
//                debugPrint(dynamicLink!)
//            }else{
//                debugPrint(dynamicLink!)
//            }
//
//            return handleDynamicLink(dynamicLink)
//        }
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink =   DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            // Handle the deep link here.
            // Show promotional offer.
            print("Dynamic link : \(dynamicLink.url)")
            return handleDynamicLink(dynamicLink)
        }
        return false
    }
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else { return false }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
            if (dynamicLink != nil) && !(error != nil) {
                let _ = self.handleDynamicLink(dynamicLink)
            }
        }
        if !handled {
            // Handle incoming URL with other methods as necessary
            // ...
        }
        return handled
    }
    func checkAlreadyMember(promocode:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "proMembership/isMembershipActive") { (snapshot) in
            var isMembership = Int()
            if(snapshot.value != nil){
                isMembership = snapshot.value as! Int
            }
            DispatchQueue.main.async(execute: {
                let oneYear = OneYearMembership()
                
                oneYear.giveMemberShip(promocode: promocode)
            })
        }
    }
    func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink else { return false }
        guard let deepLink = dynamicLink.url else { return false }
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let invitedBy = queryItems?.filter({(item) in item.name == "invitedby"}).first?.value
        let user = Auth.auth().currentUser
        if(invitedBy != nil){
            referedBy = "\(invitedBy!)"
            if(invitedBy?.contains("//"))!{
                let userStr = invitedBy?.split(separator: "/")
                referedBy = "\((userStr?.first)!)"
            }
        }
        else if((Auth.auth().currentUser?.uid) != nil){
            let promocode = queryItems?.filter({(item) in item.name == "promocode"}).first?.value
            let isIndigogoBackers = "\(promocode!)"
            debugPrint(isIndigogoBackers)
            self.checkAlreadyMember(promocode:isIndigogoBackers)
        }else{
            let alert = UIAlertController(title: "Alert", message: "Your 1 year membership can not be applied, Please open the link after login.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }

        if user == nil && invitedBy != nil {
            Auth.auth().signInAnonymously() { (user, error) in
                if let user = user {
                    let userRecord = Database.database().reference().child("dataMatch").child(user.uid)
                    userRecord.child("referred_by").setValue(invitedBy)
                    if dynamicLink.matchType == .weak {
                        // If the Dynamic Link has a weak match confidence, it is possible
                        // that the current device isn't the same device on which the invitation
                        // link was originally opened. The way you handle this situation
                        // depends on your app, but in general, you should avoid exposing
                        // personal information, such as the referrer's email address, to
                        // the user.
                    }
                }
            }
        }
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  }
 /*
"latest_receipt_info" =     (
    {
        "expires_date" = "2018-03-08 09:29:38 Etc/GMT";
        "expires_date_ms" = 1520501378000;
        "expires_date_pst" = "2018-03-08 01:29:38 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 09:24:38 Etc/GMT";
        "purchase_date_ms" = 1520501078000;
        "purchase_date_pst" = "2018-03-08 01:24:38 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356069;
        "web_order_line_item_id" = 1000000038050303;
  },
    {
        "expires_date" = "2018-03-14 14:33:55 Etc/GMT";
        "expires_date_ms" = 1521038035000;
        "expires_date_pst" = "2018-03-14 07:33:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:28:55 Etc/GMT";
        "purchase_date_ms" = 1521037735000;
        "purchase_date_pst" = "2018-03-14 07:28:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356070;
        "web_order_line_item_id" = 1000000038110053;
  },
    {
        "expires_date" = "2018-03-08 12:39:06 Etc/GMT";
        "expires_date_ms" = 1520512746000;
        "expires_date_pst" = "2018-03-08 04:39:06 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:34:06 Etc/GMT";
        "purchase_date_ms" = 1520512446000;
        "purchase_date_pst" = "2018-03-08 04:34:06 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356071;
        "web_order_line_item_id" = 1000000038052270;
  },
    {
        "expires_date" = "2018-03-08 09:00:36 Etc/GMT";
        "expires_date_ms" = 1520499636000;
        "expires_date_pst" = "2018-03-08 01:00:36 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = true;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 08:55:36 Etc/GMT";
        "purchase_date_ms" = 1520499336000;
        "purchase_date_pst" = "2018-03-08 00:55:36 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356114;
        "web_order_line_item_id" = 1000000038050081;
  },
    {
        "expires_date" = "2018-03-14 11:04:58 Etc/GMT";
        "expires_date_ms" = 1521025498000;
        "expires_date_pst" = "2018-03-14 04:04:58 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:59:58 Etc/GMT";
        "purchase_date_ms" = 1521025198000;
        "purchase_date_pst" = "2018-03-14 03:59:58 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356082;
        "web_order_line_item_id" = 1000000038107527;
  },
    {
        "expires_date" = "2018-03-08 09:05:36 Etc/GMT";
        "expires_date_ms" = 1520499936000;
        "expires_date_pst" = "2018-03-08 01:05:36 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 09:00:36 Etc/GMT";
        "purchase_date_ms" = 1520499636000;
        "purchase_date_pst" = "2018-03-08 01:00:36 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356088;
        "web_order_line_item_id" = 1000000038050082;
  },
    {
        "expires_date" = "2018-03-14 10:08:49 Etc/GMT";
        "expires_date_ms" = 1521022129000;
        "expires_date_pst" = "2018-03-14 03:08:49 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:03:49 Etc/GMT";
        "purchase_date_ms" = 1521021829000;
        "purchase_date_pst" = "2018-03-14 03:03:49 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356092;
        "web_order_line_item_id" = 1000000038105091;
  },
    {
        "expires_date" = "2018-03-14 10:35:31 Etc/GMT";
        "expires_date_ms" = 1521023731000;
        "expires_date_pst" = "2018-03-14 03:35:31 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:30:31 Etc/GMT";
        "purchase_date_ms" = 1521023431000;
        "purchase_date_pst" = "2018-03-14 03:30:31 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356097;
        "web_order_line_item_id" = 1000000038107139;
  },
    {
        
        "expires_date" = "2018-03-08 15:15:51 Etc/GMT";
        "expires_date_ms" = 1520522151000;
        "expires_date_pst" = "2018-03-08 07:15:51 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-03-08 14:15:51 Etc/GMT";
        "purchase_date_ms" = 1520518551000;
        "purchase_date_pst" = "2018-03-08 06:15:51 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356101;
        "web_order_line_item_id" = 1000000038052951;
  },
    {
        "expires_date" = "2018-03-16 08:59:08 Etc/GMT";
        "expires_date_ms" = 1521190748000;
        "expires_date_pst" = "2018-03-16 01:59:08 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195777000;
        "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 08:54:08 Etc/GMT";
        "purchase_date_ms" = 1521190448000;
        "purchase_date_pst" = "2018-03-16 01:54:08 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383356104;
        "web_order_line_item_id" = 1000000038132112;
  },
    {
        "expires_date" = "2018-03-16 10:26:25 Etc/GMT";
        "expires_date_ms" = 1521195985000;
        "expires_date_pst" = "2018-03-16 03:26:25 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:24:28 Etc/GMT";
        "original_purchase_date_ms" = 1521195868000;
        "original_purchase_date_pst" = "2018-03-16 03:24:28 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 10:21:25 Etc/GMT";
        "purchase_date_ms" = 1521195685000;
        "purchase_date_pst" = "2018-03-16 03:21:25 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383357120;
        "web_order_line_item_id" = 1000000038133299;
  },
    {
        "expires_date" = "2018-03-16 10:31:25 Etc/GMT";
        "expires_date_ms" = 1521196285000;
        "expires_date_pst" = "2018-03-16 03:31:25 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:25:57 Etc/GMT";
        "original_purchase_date_ms" = 1521195957000;
        "original_purchase_date_pst" = "2018-03-16 03:25:57 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 10:26:25 Etc/GMT";
        "purchase_date_ms" = 1521195985000;
        "purchase_date_pst" = "2018-03-16 03:26:25 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383357547;
        "web_order_line_item_id" = 1000000038133798;
  },
    {
        "expires_date" = "2018-03-16 10:48:45 Etc/GMT";
        "expires_date_ms" = 1521197325000;
        "expires_date_pst" = "2018-03-16 03:48:45 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:43:47 Etc/GMT";
        "original_purchase_date_ms" = 1521197027000;
        "original_purchase_date_pst" = "2018-03-16 03:43:47 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 10:43:45 Etc/GMT";
        "purchase_date_ms" = 1521197025000;
        "purchase_date_pst" = "2018-03-16 03:43:45 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383362112;
        "web_order_line_item_id" = 1000000038133861;
  },
    {
        "expires_date" = "2018-03-16 10:56:35 Etc/GMT";
        "expires_date_ms" = 1521197795000;
        "expires_date_pst" = "2018-03-16 03:56:35 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 10:51:37 Etc/GMT";
        "original_purchase_date_ms" = 1521197497000;
        "original_purchase_date_pst" = "2018-03-16 03:51:37 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 10:51:35 Etc/GMT";
        "purchase_date_ms" = 1521197495000;
        "purchase_date_pst" = "2018-03-16 03:51:35 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383364166;
        "web_order_line_item_id" = 1000000038134093;
  },
    {
        "expires_date" = "2018-03-16 11:25:37 Etc/GMT";
        "expires_date_ms" = 1521199537000;
        "expires_date_pst" = "2018-03-16 04:25:37 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:20:39 Etc/GMT";
        "original_purchase_date_ms" = 1521199239000;
        "original_purchase_date_pst" = "2018-03-16 04:20:39 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 11:20:37 Etc/GMT";
        "purchase_date_ms" = 1521199237000;
        "purchase_date_pst" = "2018-03-16 04:20:37 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383370351;
        "web_order_line_item_id" = 1000000038134213;
  },
    {
        "expires_date" = "2018-03-16 11:51:31 Etc/GMT";
        "expires_date_ms" = 1521201091000;
        "expires_date_pst" = "2018-03-16 04:51:31 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:46:33 Etc/GMT";
        "original_purchase_date_ms" = 1521200793000;
        "original_purchase_date_pst" = "2018-03-16 04:46:33 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 11:46:31 Etc/GMT";
        "purchase_date_ms" = 1521200791000;
        "purchase_date_pst" = "2018-03-16 04:46:31 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376184;
        "web_order_line_item_id" = 1000000038134492;
  },
    {
        "expires_date" = "2018-03-14 07:39:52 Etc/GMT";
        "expires_date_ms" = 1521013192000;
        "expires_date_pst" = "2018-03-14 00:39:52 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 07:34:52 Etc/GMT";
        "purchase_date_ms" = 1521012892000;
        "purchase_date_pst" = "2018-03-14 00:34:52 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376497;
        "web_order_line_item_id" = 1000000038053479;
  },
    {
        "expires_date" = "2018-03-08 13:15:52 Etc/GMT";
        "expires_date_ms" = 1520514952000;
        "expires_date_pst" = "2018-03-08 05:15:52 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 13:10:52 Etc/GMT";
        "purchase_date_ms" = 1520514652000;
        "purchase_date_pst" = "2018-03-08 05:10:52 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376498;
        "web_order_line_item_id" = 1000000038052630;
  },
    {
        "expires_date" = "2018-03-14 07:50:59 Etc/GMT";
        "expires_date_ms" = 1521013859000;
        "expires_date_pst" = "2018-03-14 00:50:59 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 07:45:59 Etc/GMT";
        "purchase_date_ms" = 1521013559000;
        "purchase_date_pst" = "2018-03-14 00:45:59 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376499;
        "web_order_line_item_id" = 1000000038104654;
  },
    {
        "expires_date" = "2018-03-16 09:48:23 Etc/GMT";
        "expires_date_ms" = 1521193703000;
        "expires_date_pst" = "2018-03-16 02:48:23 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 09:43:23 Etc/GMT";
        "purchase_date_ms" = 1521193403000;
        "purchase_date_pst" = "2018-03-16 02:43:23 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376500;
        "web_order_line_item_id" = 1000000038133071;
  },
    {
        "expires_date" = "2018-03-08 13:01:27 Etc/GMT";
        "expires_date_ms" = 1520514087000;
        "expires_date_pst" = "2018-03-08 05:01:27 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:56:27 Etc/GMT";
        "purchase_date_ms" = 1520513787000;
        "purchase_date_pst" = "2018-03-08 04:56:27 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376504;
        "web_order_line_item_id" = 1000000038052472;
  },
    {
        "expires_date" = "2018-03-08 12:31:26 Etc/GMT";
        "expires_date_ms" = 1520512286000;
        "expires_date_pst" = "2018-03-08 04:31:26 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:26:26 Etc/GMT";
        "purchase_date_ms" = 1520511986000;
        "purchase_date_pst" = "2018-03-08 04:26:26 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376506;
        "web_order_line_item_id" = 1000000038052242;
  },
    {
        "expires_date" = "2018-03-14 10:18:49 Etc/GMT";
        "expires_date_ms" = 1521022729000;
        "expires_date_pst" = "2018-03-14 03:18:49 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:13:49 Etc/GMT";
        "purchase_date_ms" = 1521022429000;
        "purchase_date_pst" = "2018-03-14 03:13:49 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376507;
        "web_order_line_item_id" = 1000000038106868;
  },
    {
        "expires_date" = "2018-03-14 11:10:45 Etc/GMT";
        "expires_date_ms" = 1521025845000;
        "expires_date_pst" = "2018-03-14 04:10:45 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 11:05:45 Etc/GMT";
        "purchase_date_ms" = 1521025545000;
        "purchase_date_pst" = "2018-03-14 04:05:45 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376508;
        "web_order_line_item_id" = 1000000038107671;
  },
    {
        "expires_date" = "2018-03-08 09:10:36 Etc/GMT";
        "expires_date_ms" = 1520500236000;
        "expires_date_pst" = "2018-03-08 01:10:36 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 09:05:36 Etc/GMT";
        "purchase_date_ms" = 1520499936000;
        "purchase_date_pst" = "2018-03-08 01:05:36 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376509;
        "web_order_line_item_id" = 1000000038050125;
  },
    {
        "expires_date" = "2018-03-16 07:48:24 Etc/GMT";
        "expires_date_ms" = 1521186504000;
        "expires_date_pst" = "2018-03-16 00:48:24 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 07:43:24 Etc/GMT";
        "purchase_date_ms" = 1521186204000;
        "purchase_date_pst" = "2018-03-16 00:43:24 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376465;
        "web_order_line_item_id" = 1000000038110344;
  },
    {
        "expires_date" = "2018-03-08 09:22:31 Etc/GMT";
        "expires_date_ms" = 1520500951000;
        "expires_date_pst" = "2018-03-08 01:22:31 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 09:17:31 Etc/GMT";
        "purchase_date_ms" = 1520500651000;
        "purchase_date_pst" = "2018-03-08 01:17:31 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376468;
        "web_order_line_item_id" = 1000000038050260;
  },
    {
        "expires_date" = "2018-03-14 08:00:59 Etc/GMT";
        "expires_date_ms" = 1521014459000;
        "expires_date_pst" = "2018-03-14 01:00:59 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 07:55:59 Etc/GMT";
        "purchase_date_ms" = 1521014159000;
        "purchase_date_pst" = "2018-03-14 00:55:59 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376472;
        "web_order_line_item_id" = 1000000038104756;
  },
    {
        "expires_date" = "2018-03-14 14:53:55 Etc/GMT";
        "expires_date_ms" = 1521039235000;
        "expires_date_pst" = "2018-03-14 07:53:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:48:55 Etc/GMT";
        "purchase_date_ms" = 1521038935000;
        "purchase_date_pst" = "2018-03-14 07:48:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376473;
        "web_order_line_item_id" = 1000000038110294;
  },
    {
        "expires_date" = "2018-03-14 10:56:16 Etc/GMT";
        "expires_date_ms" = 1521024976000;
        "expires_date_pst" = "2018-03-14 03:56:16 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:51:16 Etc/GMT";
        "purchase_date_ms" = 1521024676000;
        "purchase_date_pst" = "2018-03-14 03:51:16 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376476;
        "web_order_line_item_id" = 1000000038107236;
  },
    {
        "expires_date" = "2018-03-16 07:58:51 Etc/GMT";
        "expires_date_ms" = 1521187131000;
        "expires_date_pst" = "2018-03-16 00:58:51 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 07:53:51 Etc/GMT";
        "purchase_date_ms" = 1521186831000;
        "purchase_date_pst" = "2018-03-16 00:53:51 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376477;
        "web_order_line_item_id" = 1000000038131858;
  },
    {
        "expires_date" = "2018-03-08 12:49:14 Etc/GMT";
        "expires_date_ms" = 1520513354000;
        "expires_date_pst" = "2018-03-08 04:49:14 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:44:14 Etc/GMT";
        "purchase_date_ms" = 1520513054000;
        "purchase_date_pst" = "2018-03-08 04:44:14 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376478;
        "web_order_line_item_id" = 1000000038052420;
  },
    {
        "expires_date" = "2018-03-14 10:13:49 Etc/GMT";
        "expires_date_ms" = 1521022429000;
        "expires_date_pst" = "2018-03-14 03:13:49 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:08:49 Etc/GMT";
        "purchase_date_ms" = 1521022129000;
        "purchase_date_pst" = "2018-03-14 03:08:49 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376479;
        "web_order_line_item_id" = 1000000038106809;
  },
    {
        "expires_date" = "2018-03-14 07:55:59 Etc/GMT";
        "expires_date_ms" = 1521014159000;
        "expires_date_pst" = "2018-03-14 00:55:59 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 07:50:59 Etc/GMT";
        "purchase_date_ms" = 1521013859000;
        "purchase_date_pst" = "2018-03-14 00:50:59 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376480;
        "web_order_line_item_id" = 1000000038104713;
  },
    {
        "expires_date" = "2018-03-14 14:48:55 Etc/GMT";
        
        "expires_date_ms" = 1521038935000;
        "expires_date_pst" = "2018-03-14 07:48:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:43:55 Etc/GMT";
        "purchase_date_ms" = 1521038635000;
        "purchase_date_pst" = "2018-03-14 07:43:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376482;
        "web_order_line_item_id" = 1000000038110240;
  },
    {
        "expires_date" = "2018-03-14 07:45:33 Etc/GMT";
        "expires_date_ms" = 1521013533000;
        "expires_date_pst" = "2018-03-14 00:45:33 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 07:40:33 Etc/GMT";
        "purchase_date_ms" = 1521013233000;
        "purchase_date_pst" = "2018-03-14 00:40:33 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376484;
        "web_order_line_item_id" = 1000000038104600;
  },
    {
        "expires_date" = "2018-03-08 12:20:06 Etc/GMT";
        "expires_date_ms" = 1520511606000;
        "expires_date_pst" = "2018-03-08 04:20:06 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:15:06 Etc/GMT";
        "purchase_date_ms" = 1520511306000;
        "purchase_date_pst" = "2018-03-08 04:15:06 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376485;
        "web_order_line_item_id" = 1000000038050365;
  },
    {
        "expires_date" = "2018-03-16 09:31:28 Etc/GMT";
        "expires_date_ms" = 1521192688000;
        "expires_date_pst" = "2018-03-16 02:31:28 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 09:26:28 Etc/GMT";
        "purchase_date_ms" = 1521192388000;
        "purchase_date_pst" = "2018-03-16 02:26:28 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376486;
        "web_order_line_item_id" = 1000000038132762;
  },
    {
        "expires_date" = "2018-03-08 12:26:26 Etc/GMT";
        "expires_date_ms" = 1520511986000;
        "expires_date_pst" = "2018-03-08 04:26:26 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:21:26 Etc/GMT";
        "purchase_date_ms" = 1520511686000;
        "purchase_date_pst" = "2018-03-08 04:21:26 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376488;
        "web_order_line_item_id" = 1000000038052175;
  },
    {
        "expires_date" = "2018-03-08 13:26:28 Etc/GMT";
        "expires_date_ms" = 1520515588000;
        "expires_date_pst" = "2018-03-08 05:26:28 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 13:21:28 Etc/GMT";
        "purchase_date_ms" = 1520515288000;
        "purchase_date_pst" = "2018-03-08 05:21:28 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376489;
        "web_order_line_item_id" = 1000000038052815;
  },
    {
        "expires_date" = "2018-03-14 08:21:11 Etc/GMT";
        "expires_date_ms" = 1521015671000;
        "expires_date_pst" = "2018-03-14 01:21:11 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 08:16:11 Etc/GMT";
        "purchase_date_ms" = 1521015371000;
        "purchase_date_pst" = "2018-03-14 01:16:11 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376490;
        "web_order_line_item_id" = 1000000038104885;
  },
    {
        "expires_date" = "2018-03-16 08:03:56 Etc/GMT";
        "expires_date_ms" = 1521187436000;
        "expires_date_pst" = "2018-03-16 01:03:56 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 07:58:56 Etc/GMT";
        "purchase_date_ms" = 1521187136000;
        "purchase_date_pst" = "2018-03-16 00:58:56 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376492;
        "web_order_line_item_id" = 1000000038131926;
  },
    {
        "expires_date" = "2018-03-08 09:17:27 Etc/GMT";
        "expires_date_ms" = 1520500647000;
        "expires_date_pst" = "2018-03-08 01:17:27 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 09:12:27 Etc/GMT";
        "purchase_date_ms" = 1520500347000;
        "purchase_date_pst" = "2018-03-08 01:12:27 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376493;
        "web_order_line_item_id" = 1000000038050170;
  },
    {
        "expires_date" = "2018-03-14 14:28:55 Etc/GMT";
        "expires_date_ms" = 1521037735000;
        "expires_date_pst" = "2018-03-14 07:28:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:23:55 Etc/GMT";
        "purchase_date_ms" = 1521037435000;
        "purchase_date_pst" = "2018-03-14 07:23:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376495;
        "web_order_line_item_id" = 1000000038107962;
  },
    {
        "expires_date" = "2018-03-14 14:43:55 Etc/GMT";
        "expires_date_ms" = 1521038635000;
        "expires_date_pst" = "2018-03-14 07:43:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:38:55 Etc/GMT";
        "purchase_date_ms" = 1521038335000;
        "purchase_date_pst" = "2018-03-14 07:38:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376496;
        "web_order_line_item_id" = 1000000038110170;
  },
    {
        "expires_date" = "2018-03-14 10:29:33 Etc/GMT";
        "expires_date_ms" = 1521023373000;
        "expires_date_pst" = "2018-03-14 03:29:33 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:24:33 Etc/GMT";
        "purchase_date_ms" = 1521023073000;
        "purchase_date_pst" = "2018-03-14 03:24:33 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376456;
        "web_order_line_item_id" = 1000000038107067;
  },
    {
        "expires_date" = "2018-03-14 12:20:50 Etc/GMT";
        "expires_date_ms" = 1521030050000;
        "expires_date_pst" = "2018-03-14 05:20:50 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-03-14 11:20:50 Etc/GMT";
        "purchase_date_ms" = 1521026450000;
        "purchase_date_pst" = "2018-03-14 04:20:50 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376457;
        "web_order_line_item_id" = 1000000038107745;
  },
    {
        "expires_date" = "2018-03-16 09:06:42 Etc/GMT";
        "expires_date_ms" = 1521191202000;
        "expires_date_pst" = "2018-03-16 02:06:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 09:01:42 Etc/GMT";
        "purchase_date_ms" = 1521190902000;
        "purchase_date_pst" = "2018-03-16 02:01:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376458;
        "web_order_line_item_id" = 1000000038132664;
  },
    {
        "expires_date" = "2018-03-08 12:44:14 Etc/GMT";
        "expires_date_ms" = 1520513054000;
        "expires_date_pst" = "2018-03-08 04:44:14 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-08 12:39:14 Etc/GMT";
        "purchase_date_ms" = 1520512754000;
        "purchase_date_pst" = "2018-03-08 04:39:14 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376459;
        "web_order_line_item_id" = 1000000038052348;
  },
    {
        "expires_date" = "2018-03-16 08:08:56 Etc/GMT";
        "expires_date_ms" = 1521187736000;
        "expires_date_pst" = "2018-03-16 01:08:56 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 08:03:56 Etc/GMT";
        "purchase_date_ms" = 1521187436000;
        "purchase_date_pst" = "2018-03-16 01:03:56 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376460;
        "web_order_line_item_id" = 1000000038131996;
  },
    {
        "expires_date" = "2018-03-14 14:38:55 Etc/GMT";
        "expires_date_ms" = 1521038335000;
        "expires_date_pst" = "2018-03-14 07:38:55 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 14:33:55 Etc/GMT";
        "purchase_date_ms" = 1521038035000;
        "purchase_date_pst" = "2018-03-14 07:33:55 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376461;
        "web_order_line_item_id" = 1000000038110115;
  },
    {
        "expires_date" = "2018-03-14 10:24:30 Etc/GMT";
        "expires_date_ms" = 1521023070000;
        "expires_date_pst" = "2018-03-14 03:24:30 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 10:19:30 Etc/GMT";
        "purchase_date_ms" = 1521022770000;
        "purchase_date_pst" = "2018-03-14 03:19:30 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376462;
        "web_order_line_item_id" = 1000000038106964;
  },
    {
        "expires_date" = "2018-03-16 08:13:56 Etc/GMT";
        "expires_date_ms" = 1521188036000;
        "expires_date_pst" = "2018-03-16 01:13:56 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 08:08:56 Etc/GMT";
        "purchase_date_ms" = 1521187736000;
        "purchase_date_pst" = "2018-03-16 01:08:56 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376463;
        "web_order_line_item_id" = 1000000038132062;
  },
    {
        "expires_date" = "2018-03-14 08:06:14 Etc/GMT";
        "expires_date_ms" = 1521014774000;
        "expires_date_pst" = "2018-03-14 01:06:14 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
        "original_purchase_date_ms" = 1521200914000;
        "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-14 08:01:14 Etc/GMT";
        "purchase_date_ms" = 1521014474000;
        "purchase_date_pst" = "2018-03-14 01:01:14 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383376464;
        "web_order_line_item_id" = 1000000038104816;
  },
    {
        "expires_date" = "2018-03-16 12:42:44 Etc/GMT";
        "expires_date_ms" = 1521204164000;
        "expires_date_pst" = "2018-03-16 05:42:44 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 12:37:46 Etc/GMT";
        "original_purchase_date_ms" = 1521203866000;
        "original_purchase_date_pst" = "2018-03-16 05:37:46 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 12:37:44 Etc/GMT";
        
        "purchase_date_ms" = 1521203864000;
        "purchase_date_pst" = "2018-03-16 05:37:44 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383388251;
        "web_order_line_item_id" = 1000000038134740;
  },
    {
        "expires_date" = "2018-03-16 12:47:44 Etc/GMT";
        "expires_date_ms" = 1521204464000;
        "expires_date_pst" = "2018-03-16 05:47:44 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 12:42:03 Etc/GMT";
        "original_purchase_date_ms" = 1521204123000;
        "original_purchase_date_pst" = "2018-03-16 05:42:03 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 12:42:44 Etc/GMT";
        "purchase_date_ms" = 1521204164000;
        "purchase_date_pst" = "2018-03-16 05:42:44 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383389000;
        "web_order_line_item_id" = 1000000038135242;
  },
    {
        "expires_date" = "2018-03-16 12:53:08 Etc/GMT";
        "expires_date_ms" = 1521204788000;
        "expires_date_pst" = "2018-03-16 05:53:08 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 12:48:10 Etc/GMT";
        "original_purchase_date_ms" = 1521204490000;
        "original_purchase_date_pst" = "2018-03-16 05:48:10 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 12:48:08 Etc/GMT";
        "purchase_date_ms" = 1521204488000;
        "purchase_date_pst" = "2018-03-16 05:48:08 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383389396;
        "web_order_line_item_id" = 1000000038135279;
  },
    {
        "expires_date" = "2018-03-16 12:59:19 Etc/GMT";
        "expires_date_ms" = 1521205159000;
        "expires_date_pst" = "2018-03-16 05:59:19 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 12:54:20 Etc/GMT";
        "original_purchase_date_ms" = 1521204860000;
        "original_purchase_date_pst" = "2018-03-16 05:54:20 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 12:54:19 Etc/GMT";
        "purchase_date_ms" = 1521204859000;
        "purchase_date_pst" = "2018-03-16 05:54:19 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383389516;
        "web_order_line_item_id" = 1000000038135324;
  },
    {
        "expires_date" = "2018-03-16 14:17:00 Etc/GMT";
        "expires_date_ms" = 1521209820000;
        "expires_date_pst" = "2018-03-16 07:17:00 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 14:12:02 Etc/GMT";
        "original_purchase_date_ms" = 1521209522000;
        "original_purchase_date_pst" = "2018-03-16 07:12:02 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 14:12:00 Etc/GMT";
        "purchase_date_ms" = 1521209520000;
        "purchase_date_pst" = "2018-03-16 07:12:00 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383402210;
        "web_order_line_item_id" = 1000000038135368;
  },
    {
        "expires_date" = "2018-03-16 14:22:00 Etc/GMT";
        "expires_date_ms" = 1521210120000;
        "expires_date_pst" = "2018-03-16 07:22:00 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 14:16:25 Etc/GMT";
        "original_purchase_date_ms" = 1521209785000;
        "original_purchase_date_pst" = "2018-03-16 07:16:25 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-03-16 14:17:00 Etc/GMT";
        "purchase_date_ms" = 1521209820000;
        "purchase_date_pst" = "2018-03-16 07:17:00 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383403575;
        "web_order_line_item_id" = 1000000038135956;
  },
    {
        "expires_date" = "2018-03-16 15:24:16 Etc/GMT";
        "expires_date_ms" = 1521213856000;
        "expires_date_pst" = "2018-03-16 08:24:16 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-03-16 14:24:18 Etc/GMT";
        "original_purchase_date_ms" = 1521210258000;
        "original_purchase_date_pst" = "2018-03-16 07:24:18 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-03-16 14:24:16 Etc/GMT";
        "purchase_date_ms" = 1521210256000;
        "purchase_date_pst" = "2018-03-16 07:24:16 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000383404230;
        "web_order_line_item_id" = 1000000038136013;
  },
    {
        "expires_date" = "2018-09-11 09:15:42 Etc/GMT";
        "expires_date_ms" = 1536657342000;
        "expires_date_pst" = "2018-09-11 02:15:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 08:15:43 Etc/GMT";
        "original_purchase_date_ms" = 1536653743000;
        "original_purchase_date_pst" = "2018-09-11 01:15:43 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-09-11 08:15:42 Etc/GMT";
        "purchase_date_ms" = 1536653742000;
        "purchase_date_pst" = "2018-09-11 01:15:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442308206;
        "web_order_line_item_id" = 1000000038136117;
  },
    {
        "expires_date" = "2018-09-11 10:15:42 Etc/GMT";
        "expires_date_ms" = 1536660942000;
        "expires_date_pst" = "2018-09-11 03:15:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 09:15:08 Etc/GMT";
        "original_purchase_date_ms" = 1536657308000;
        "original_purchase_date_pst" = "2018-09-11 02:15:08 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-09-11 09:15:42 Etc/GMT";
        "purchase_date_ms" = 1536657342000;
        "purchase_date_pst" = "2018-09-11 02:15:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442351192;
        "web_order_line_item_id" = 1000000040302770;
  },
    {
        "expires_date" = "2018-09-11 11:15:42 Etc/GMT";
        "expires_date_ms" = 1536664542000;
        "expires_date_pst" = "2018-09-11 04:15:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 10:15:28 Etc/GMT";
        "original_purchase_date_ms" = 1536660928000;
        "original_purchase_date_pst" = "2018-09-11 03:15:28 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_yearly";
        "purchase_date" = "2018-09-11 10:15:42 Etc/GMT";
        "purchase_date_ms" = 1536660942000;
        "purchase_date_pst" = "2018-09-11 03:15:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442407061;
        "web_order_line_item_id" = 1000000040304041;
  },
    {
        "expires_date" = "2018-09-11 11:20:42 Etc/GMT";
        "expires_date_ms" = 1536664842000;
        "expires_date_pst" = "2018-09-11 04:20:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 11:15:22 Etc/GMT";
        "original_purchase_date_ms" = 1536664522000;
        "original_purchase_date_pst" = "2018-09-11 04:15:22 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-09-11 11:15:42 Etc/GMT";
        "purchase_date_ms" = 1536664542000;
        "purchase_date_pst" = "2018-09-11 04:15:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442457371;
        "web_order_line_item_id" = 1000000040305337;
  },
    {
        "expires_date" = "2018-09-11 11:25:42 Etc/GMT";
        "expires_date_ms" = 1536665142000;
        "expires_date_pst" = "2018-09-11 04:25:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 11:19:47 Etc/GMT";
        "original_purchase_date_ms" = 1536664787000;
        "original_purchase_date_pst" = "2018-09-11 04:19:47 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-09-11 11:20:42 Etc/GMT";
        "purchase_date_ms" = 1536664842000;
        "purchase_date_pst" = "2018-09-11 04:20:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442460517;
        "web_order_line_item_id" = 1000000040306497;
  },
    {
        "expires_date" = "2018-09-11 11:30:42 Etc/GMT";
        "expires_date_ms" = 1536665442000;
        "expires_date_pst" = "2018-09-11 04:30:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 11:24:44 Etc/GMT";
        "original_purchase_date_ms" = 1536665084000;
        "original_purchase_date_pst" = "2018-09-11 04:24:44 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-09-11 11:25:42 Etc/GMT";
        "purchase_date_ms" = 1536665142000;
        "purchase_date_pst" = "2018-09-11 04:25:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442465155;
        "web_order_line_item_id" = 1000000040306601;
  },
    {
        "expires_date" = "2018-09-11 11:35:42 Etc/GMT";
        "expires_date_ms" = 1536665742000;
        "expires_date_pst" = "2018-09-11 04:35:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 11:30:29 Etc/GMT";
        "original_purchase_date_ms" = 1536665429000;
        "original_purchase_date_pst" = "2018-09-11 04:30:29 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-09-11 11:30:42 Etc/GMT";
        "purchase_date_ms" = 1536665442000;
        "purchase_date_pst" = "2018-09-11 04:30:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442468568;
        "web_order_line_item_id" = 1000000040306692;
  },
    {
        "expires_date" = "2018-09-11 11:40:42 Etc/GMT";
        "expires_date_ms" = 1536666042000;
        "expires_date_pst" = "2018-09-11 04:40:42 America/Los_Angeles";
        "is_in_intro_offer_period" = false;
        "is_trial_period" = false;
        "original_purchase_date" = "2018-09-11 11:34:56 Etc/GMT";
        "original_purchase_date_ms" = 1536665696000;
        "original_purchase_date_pst" = "2018-09-11 04:34:56 America/Los_Angeles";
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
        "purchase_date" = "2018-09-11 11:35:42 Etc/GMT";
        "purchase_date_ms" = 1536665742000;
        "purchase_date_pst" = "2018-09-11 04:35:42 America/Los_Angeles";
        quantity = 1;
        "transaction_id" = 1000000442472642;
        "web_order_line_item_id" = 1000000040306804;
  }
  );
  "pending_renewal_info" =     (
    {
        "auto_renew_product_id" = "pro_subscription_monthly";
        "auto_renew_status" = 0;
        "expiration_intent" = 1;
        "is_in_billing_retry_period" = 0;
        "original_transaction_id" = 1000000381484598;
        "product_id" = "pro_subscription_monthly";
    }
  );
  receipt =     {
    "adam_id" = 0;
    "app_item_id" = 0;
    "application_version" = 1;
    "bundle_id" = "com.khelfie.Khelfie";
    "download_id" = 0;
    "in_app" =         (
        {
            "expires_date" = "2018-03-08 15:15:51 Etc/GMT";
            "expires_date_ms" = 1520522151000;
            "expires_date_pst" = "2018-03-08 07:15:51 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-03-08 14:15:51 Etc/GMT";
            "purchase_date_ms" = 1520518551000;
            "purchase_date_pst" = "2018-03-08 06:15:51 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356101;
            "web_order_line_item_id" = 1000000038052951;
    },
        {
            "expires_date" = "2018-03-14 12:20:50 Etc/GMT";
            "expires_date_ms" = 1521030050000;
            "expires_date_pst" = "2018-03-14 05:20:50 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-03-14 11:20:50 Etc/GMT";
            "purchase_date_ms" = 1521026450000;
            "purchase_date_pst" = "2018-03-14 04:20:50 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376457;
            "web_order_line_item_id" = 1000000038107745;
    },
        {
            "expires_date" = "2018-03-16 15:24:16 Etc/GMT";
            "expires_date_ms" = 1521213856000;
            "expires_date_pst" = "2018-03-16 08:24:16 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 14:24:18 Etc/GMT";
            "original_purchase_date_ms" = 1521210258000;
            "original_purchase_date_pst" = "2018-03-16 07:24:18 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-03-16 14:24:16 Etc/GMT";
            "purchase_date_ms" = 1521210256000;
            "purchase_date_pst" = "2018-03-16 07:24:16 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383404230;
            "web_order_line_item_id" = 1000000038136013;
    },
        {
            "expires_date" = "2018-09-11 09:15:42 Etc/GMT";
            "expires_date_ms" = 1536657342000;
            "expires_date_pst" = "2018-09-11 02:15:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 08:15:43 Etc/GMT";
            "original_purchase_date_ms" = 1536653743000;
            "original_purchase_date_pst" = "2018-09-11 01:15:43 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-09-11 08:15:42 Etc/GMT";
            "purchase_date_ms" = 1536653742000;
            "purchase_date_pst" = "2018-09-11 01:15:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442308206;
            "web_order_line_item_id" = 1000000038136117;
    },
        {
            "expires_date" = "2018-09-11 10:15:42 Etc/GMT";
            "expires_date_ms" = 1536660942000;
            "expires_date_pst" = "2018-09-11 03:15:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 09:15:08 Etc/GMT";
            "original_purchase_date_ms" = 1536657308000;
            "original_purchase_date_pst" = "2018-09-11 02:15:08 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-09-11 09:15:42 Etc/GMT";
            "purchase_date_ms" = 1536657342000;
            "purchase_date_pst" = "2018-09-11 02:15:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442351192;
            "web_order_line_item_id" = 1000000040302770;
    },
        {
            "expires_date" = "2018-09-11 11:15:42 Etc/GMT";
            "expires_date_ms" = 1536664542000;
            "expires_date_pst" = "2018-09-11 04:15:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 10:15:28 Etc/GMT";
            "original_purchase_date_ms" = 1536660928000;
            "original_purchase_date_pst" = "2018-09-11 03:15:28 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_yearly";
            "purchase_date" = "2018-09-11 10:15:42 Etc/GMT";
            "purchase_date_ms" = 1536660942000;
            "purchase_date_pst" = "2018-09-11 03:15:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442407061;
            "web_order_line_item_id" = 1000000040304041;
    },
        {
            "expires_date" = "2018-03-08 09:05:36 Etc/GMT";
            "expires_date_ms" = 1520499936000;
            "expires_date_pst" = "2018-03-08 01:05:36 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 09:00:36 Etc/GMT";
            "purchase_date_ms" = 1520499636000;
            "purchase_date_pst" = "2018-03-08 01:00:36 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356088;
            "web_order_line_item_id" = 1000000038050082;
    },
        {
            "expires_date" = "2018-03-08 09:10:36 Etc/GMT";
            "expires_date_ms" = 1520500236000;
            "expires_date_pst" = "2018-03-08 01:10:36 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 09:05:36 Etc/GMT";
            "purchase_date_ms" = 1520499936000;
            "purchase_date_pst" = "2018-03-08 01:05:36 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376509;
            "web_order_line_item_id" = 1000000038050125;
    },
        {
            "expires_date" = "2018-03-08 09:17:27 Etc/GMT";
            "expires_date_ms" = 1520500647000;
            "expires_date_pst" = "2018-03-08 01:17:27 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 09:12:27 Etc/GMT";
            "purchase_date_ms" = 1520500347000;
            "purchase_date_pst" = "2018-03-08 01:12:27 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376493;
            "web_order_line_item_id" = 1000000038050170;
    },
        {
            "expires_date" = "2018-03-08 09:22:31 Etc/GMT";
            "expires_date_ms" = 1520500951000;
            "expires_date_pst" = "2018-03-08 01:22:31 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 09:17:31 Etc/GMT";
            "purchase_date_ms" = 1520500651000;
            "purchase_date_pst" = "2018-03-08 01:17:31 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376468;
            "web_order_line_item_id" = 1000000038050260;
    },
        {
            "expires_date" = "2018-03-08 09:29:38 Etc/GMT";
            "expires_date_ms" = 1520501378000;
            "expires_date_pst" = "2018-03-08 01:29:38 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 09:24:38 Etc/GMT";
            "purchase_date_ms" = 1520501078000;
            "purchase_date_pst" = "2018-03-08 01:24:38 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356069;
            "web_order_line_item_id" = 1000000038050303;
    },
        {
            "expires_date" = "2018-03-08 12:20:06 Etc/GMT";
            "expires_date_ms" = 1520511606000;
            "expires_date_pst" = "2018-03-08 04:20:06 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:15:06 Etc/GMT";
            "purchase_date_ms" = 1520511306000;
            "purchase_date_pst" = "2018-03-08 04:15:06 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376485;
            "web_order_line_item_id" = 1000000038050365;
    },
        {
            "expires_date" = "2018-03-08 12:26:26 Etc/GMT";
            "expires_date_ms" = 1520511986000;
            "expires_date_pst" = "2018-03-08 04:26:26 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:21:26 Etc/GMT";
            "purchase_date_ms" = 1520511686000;
            "purchase_date_pst" = "2018-03-08 04:21:26 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376488;
            "web_order_line_item_id" = 1000000038052175;
    },
        {
            "expires_date" = "2018-03-08 12:31:26 Etc/GMT";
            "expires_date_ms" = 1520512286000;
            "expires_date_pst" = "2018-03-08 04:31:26 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:26:26 Etc/GMT";
            "purchase_date_ms" = 1520511986000;
            "purchase_date_pst" = "2018-03-08 04:26:26 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376506;
            "web_order_line_item_id" = 1000000038052242;
    },
        {
            "expires_date" = "2018-03-08 12:39:06 Etc/GMT";
            "expires_date_ms" = 1520512746000;
            "expires_date_pst" = "2018-03-08 04:39:06 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:34:06 Etc/GMT";
            "purchase_date_ms" = 1520512446000;
            "purchase_date_pst" = "2018-03-08 04:34:06 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356071;
            "web_order_line_item_id" = 1000000038052270;
    },
        {
            "expires_date" = "2018-03-08 12:44:14 Etc/GMT";
            "expires_date_ms" = 1520513054000;
            "expires_date_pst" = "2018-03-08 04:44:14 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:39:14 Etc/GMT";
            "purchase_date_ms" = 1520512754000;
            "purchase_date_pst" = "2018-03-08 04:39:14 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376459;
            "web_order_line_item_id" = 1000000038052348;
    },
        {
            "expires_date" = "2018-03-08 12:49:14 Etc/GMT";
            "expires_date_ms" = 1520513354000;
            "expires_date_pst" = "2018-03-08 04:49:14 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:44:14 Etc/GMT";
            "purchase_date_ms" = 1520513054000;
            "purchase_date_pst" = "2018-03-08 04:44:14 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376478;
            "web_order_line_item_id" = 1000000038052420;
    },
        {
            "expires_date" = "2018-03-08 13:01:27 Etc/GMT";
            "expires_date_ms" = 1520514087000;
            "expires_date_pst" = "2018-03-08 05:01:27 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 12:56:27 Etc/GMT";
            "purchase_date_ms" = 1520513787000;
            "purchase_date_pst" = "2018-03-08 04:56:27 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376504;
            "web_order_line_item_id" = 1000000038052472;
    },
        {
            "expires_date" = "2018-03-08 13:15:52 Etc/GMT";
            "expires_date_ms" = 1520514952000;
            "expires_date_pst" = "2018-03-08 05:15:52 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 13:10:52 Etc/GMT";
            "purchase_date_ms" = 1520514652000;
            "purchase_date_pst" = "2018-03-08 05:10:52 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376498;
            "web_order_line_item_id" = 1000000038052630;
    },
        {
            "expires_date" = "2018-03-08 13:26:28 Etc/GMT";
            "expires_date_ms" = 1520515588000;
            "expires_date_pst" = "2018-03-08 05:26:28 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 13:21:28 Etc/GMT";
            "purchase_date_ms" = 1520515288000;
            "purchase_date_pst" = "2018-03-08 05:21:28 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376489;
            "web_order_line_item_id" = 1000000038052815;
    },
        {
            "expires_date" = "2018-03-14 07:39:52 Etc/GMT";
            "expires_date_ms" = 1521013192000;
            "expires_date_pst" = "2018-03-14 00:39:52 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 07:34:52 Etc/GMT";
            "purchase_date_ms" = 1521012892000;
            "purchase_date_pst" = "2018-03-14 00:34:52 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376497;
            "web_order_line_item_id" = 1000000038053479;
    },
        {
            "expires_date" = "2018-03-14 07:45:33 Etc/GMT";
            "expires_date_ms" = 1521013533000;
            "expires_date_pst" = "2018-03-14 00:45:33 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 07:40:33 Etc/GMT";
            "purchase_date_ms" = 1521013233000;
            "purchase_date_pst" = "2018-03-14 00:40:33 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376484;
            "web_order_line_item_id" = 1000000038104600;
    },
        {
            "expires_date" = "2018-03-14 07:50:59 Etc/GMT";
            "expires_date_ms" = 1521013859000;
            "expires_date_pst" = "2018-03-14 00:50:59 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 07:45:59 Etc/GMT";
            "purchase_date_ms" = 1521013559000;
            "purchase_date_pst" = "2018-03-14 00:45:59 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376499;
            "web_order_line_item_id" = 1000000038104654;
    },
        {
            "expires_date" = "2018-03-14 07:55:59 Etc/GMT";
            "expires_date_ms" = 1521014159000;
            "expires_date_pst" = "2018-03-14 00:55:59 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 07:50:59 Etc/GMT";
            "purchase_date_ms" = 1521013859000;
            "purchase_date_pst" = "2018-03-14 00:50:59 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376480;
            "web_order_line_item_id" = 1000000038104713;
    },
        {
            "expires_date" = "2018-03-14 08:00:59 Etc/GMT";
            "expires_date_ms" = 1521014459000;
            "expires_date_pst" = "2018-03-14 01:00:59 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 07:55:59 Etc/GMT";
            "purchase_date_ms" = 1521014159000;
            "purchase_date_pst" = "2018-03-14 00:55:59 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376472;
            "web_order_line_item_id" = 1000000038104756;
    },
        {
            "expires_date" = "2018-03-14 08:06:14 Etc/GMT";
            "expires_date_ms" = 1521014774000;
            "expires_date_pst" = "2018-03-14 01:06:14 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 08:01:14 Etc/GMT";
            "purchase_date_ms" = 1521014474000;
            "purchase_date_pst" = "2018-03-14 01:01:14 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376464;
            "web_order_line_item_id" = 1000000038104816;
    },
        {
            "expires_date" = "2018-03-14 08:21:11 Etc/GMT";
            "expires_date_ms" = 1521015671000;
            "expires_date_pst" = "2018-03-14 01:21:11 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 08:16:11 Etc/GMT";
            "purchase_date_ms" = 1521015371000;
            "purchase_date_pst" = "2018-03-14 01:16:11 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376490;
            "web_order_line_item_id" = 1000000038104885;
    },
        {
            "expires_date" = "2018-03-14 10:08:49 Etc/GMT";
            "expires_date_ms" = 1521022129000;
            "expires_date_pst" = "2018-03-14 03:08:49 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:03:49 Etc/GMT";
            "purchase_date_ms" = 1521021829000;
            "purchase_date_pst" = "2018-03-14 03:03:49 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356092;
            "web_order_line_item_id" = 1000000038105091;
    },
        {
            "expires_date" = "2018-03-14 10:13:49 Etc/GMT";
            "expires_date_ms" = 1521022429000;
            "expires_date_pst" = "2018-03-14 03:13:49 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:08:49 Etc/GMT";
            "purchase_date_ms" = 1521022129000;
            "purchase_date_pst" = "2018-03-14 03:08:49 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376479;
            "web_order_line_item_id" = 1000000038106809;
    },
        {
            "expires_date" = "2018-03-14 10:18:49 Etc/GMT";
            "expires_date_ms" = 1521022729000;
            "expires_date_pst" = "2018-03-14 03:18:49 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:13:49 Etc/GMT";
            "purchase_date_ms" = 1521022429000;
            "purchase_date_pst" = "2018-03-14 03:13:49 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376507;
            "web_order_line_item_id" = 1000000038106868;
    },
        {
            "expires_date" = "2018-03-14 10:24:30 Etc/GMT";
            "expires_date_ms" = 1521023070000;
            "expires_date_pst" = "2018-03-14 03:24:30 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:19:30 Etc/GMT";
            "purchase_date_ms" = 1521022770000;
            "purchase_date_pst" = "2018-03-14 03:19:30 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376462;
            "web_order_line_item_id" = 1000000038106964;
    },
        {
            "expires_date" = "2018-03-14 10:29:33 Etc/GMT";
            "expires_date_ms" = 1521023373000;
            "expires_date_pst" = "2018-03-14 03:29:33 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:24:33 Etc/GMT";
            "purchase_date_ms" = 1521023073000;
            "purchase_date_pst" = "2018-03-14 03:24:33 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376456;
            "web_order_line_item_id" = 1000000038107067;
    },
        {
            "expires_date" = "2018-03-14 10:35:31 Etc/GMT";
            "expires_date_ms" = 1521023731000;
            "expires_date_pst" = "2018-03-14 03:35:31 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:30:31 Etc/GMT";
            "purchase_date_ms" = 1521023431000;
            "purchase_date_pst" = "2018-03-14 03:30:31 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356097;
            "web_order_line_item_id" = 1000000038107139;
    },
        {
            "expires_date" = "2018-03-14 10:56:16 Etc/GMT";
            "expires_date_ms" = 1521024976000;
            "expires_date_pst" = "2018-03-14 03:56:16 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:51:16 Etc/GMT";
            "purchase_date_ms" = 1521024676000;
            "purchase_date_pst" = "2018-03-14 03:51:16 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376476;
            "web_order_line_item_id" = 1000000038107236;
    },
        {
            "expires_date" = "2018-03-14 11:04:58 Etc/GMT";
            "expires_date_ms" = 1521025498000;
            "expires_date_pst" = "2018-03-14 04:04:58 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 10:59:58 Etc/GMT";
            "purchase_date_ms" = 1521025198000;
            "purchase_date_pst" = "2018-03-14 03:59:58 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356082;
            "web_order_line_item_id" = 1000000038107527;
    },
        {
            "expires_date" = "2018-03-14 11:10:45 Etc/GMT";
            "expires_date_ms" = 1521025845000;
            "expires_date_pst" = "2018-03-14 04:10:45 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 11:05:45 Etc/GMT";
            "purchase_date_ms" = 1521025545000;
            "purchase_date_pst" = "2018-03-14 04:05:45 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376508;
            "web_order_line_item_id" = 1000000038107671;
    },
        {
            "expires_date" = "2018-03-14 14:28:55 Etc/GMT";
            "expires_date_ms" = 1521037735000;
            "expires_date_pst" = "2018-03-14 07:28:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:23:55 Etc/GMT";
            "purchase_date_ms" = 1521037435000;
            "purchase_date_pst" = "2018-03-14 07:23:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376495;
            "web_order_line_item_id" = 1000000038107962;
    },
        {
            "expires_date" = "2018-03-14 14:33:55 Etc/GMT";
            "expires_date_ms" = 1521038035000;
            "expires_date_pst" = "2018-03-14 07:33:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:28:55 Etc/GMT";
            "purchase_date_ms" = 1521037735000;
            "purchase_date_pst" = "2018-03-14 07:28:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356070;
            "web_order_line_item_id" = 1000000038110053;
    },
        {
            "expires_date" = "2018-03-14 14:38:55 Etc/GMT";
            "expires_date_ms" = 1521038335000;
            "expires_date_pst" = "2018-03-14 07:38:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:33:55 Etc/GMT";
            "purchase_date_ms" = 1521038035000;
            "purchase_date_pst" = "2018-03-14 07:33:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376461;
            "web_order_line_item_id" = 1000000038110115;
    },
        {
            "expires_date" = "2018-03-14 14:43:55 Etc/GMT";
            "expires_date_ms" = 1521038635000;
            "expires_date_pst" = "2018-03-14 07:43:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:38:55 Etc/GMT";
            "purchase_date_ms" = 1521038335000;
            "purchase_date_pst" = "2018-03-14 07:38:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376496;
            "web_order_line_item_id" = 1000000038110170;
    },
        {
            "expires_date" = "2018-03-14 14:48:55 Etc/GMT";
            "expires_date_ms" = 1521038935000;
            "expires_date_pst" = "2018-03-14 07:48:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:43:55 Etc/GMT";
            "purchase_date_ms" = 1521038635000;
            "purchase_date_pst" = "2018-03-14 07:43:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376482;
            "web_order_line_item_id" = 1000000038110240;
    },
        {
            "expires_date" = "2018-03-14 14:53:55 Etc/GMT";
            "expires_date_ms" = 1521039235000;
            "expires_date_pst" = "2018-03-14 07:53:55 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-14 14:48:55 Etc/GMT";
            "purchase_date_ms" = 1521038935000;
            "purchase_date_pst" = "2018-03-14 07:48:55 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376473;
            "web_order_line_item_id" = 1000000038110294;
    },
        {
            "expires_date" = "2018-03-16 07:48:24 Etc/GMT";
            "expires_date_ms" = 1521186504000;
            "expires_date_pst" = "2018-03-16 00:48:24 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 07:43:24 Etc/GMT";
            "purchase_date_ms" = 1521186204000;
            "purchase_date_pst" = "2018-03-16 00:43:24 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376465;
            "web_order_line_item_id" = 1000000038110344;
    },
        {
            "expires_date" = "2018-03-16 07:58:51 Etc/GMT";
            "expires_date_ms" = 1521187131000;
            "expires_date_pst" = "2018-03-16 00:58:51 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 07:53:51 Etc/GMT";
            "purchase_date_ms" = 1521186831000;
            "purchase_date_pst" = "2018-03-16 00:53:51 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376477;
            "web_order_line_item_id" = 1000000038131858;
    },
        {
            "expires_date" = "2018-03-16 08:03:56 Etc/GMT";
            "expires_date_ms" = 1521187436000;
            "expires_date_pst" = "2018-03-16 01:03:56 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 07:58:56 Etc/GMT";
            "purchase_date_ms" = 1521187136000;
            "purchase_date_pst" = "2018-03-16 00:58:56 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376492;
            "web_order_line_item_id" = 1000000038131926;
    },
        {
            "expires_date" = "2018-03-16 08:08:56 Etc/GMT";
            "expires_date_ms" = 1521187736000;
            "expires_date_pst" = "2018-03-16 01:08:56 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 08:03:56 Etc/GMT";
            "purchase_date_ms" = 1521187436000;
            "purchase_date_pst" = "2018-03-16 01:03:56 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376460;
            "web_order_line_item_id" = 1000000038131996;
    },
        {
            "expires_date" = "2018-03-16 08:13:56 Etc/GMT";
            "expires_date_ms" = 1521188036000;
            "expires_date_pst" = "2018-03-16 01:13:56 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 08:08:56 Etc/GMT";
            "purchase_date_ms" = 1521187736000;
            "purchase_date_pst" = "2018-03-16 01:08:56 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376463;
            "web_order_line_item_id" = 1000000038132062;
    },
        {
            "expires_date" = "2018-03-16 08:59:08 Etc/GMT";
            "expires_date_ms" = 1521190748000;
            "expires_date_pst" = "2018-03-16 01:59:08 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 08:54:08 Etc/GMT";
            "purchase_date_ms" = 1521190448000;
            "purchase_date_pst" = "2018-03-16 01:54:08 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356104;
            "web_order_line_item_id" = 1000000038132112;
    },
        {
            "expires_date" = "2018-03-16 09:06:42 Etc/GMT";
            "expires_date_ms" = 1521191202000;
            "expires_date_pst" = "2018-03-16 02:06:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 09:01:42 Etc/GMT";
            "purchase_date_ms" = 1521190902000;
            "purchase_date_pst" = "2018-03-16 02:01:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376458;
            "web_order_line_item_id" = 1000000038132664;
    },
        {
            "expires_date" = "2018-03-16 09:31:28 Etc/GMT";
            "expires_date_ms" = 1521192688000;
            "expires_date_pst" = "2018-03-16 02:31:28 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 09:26:28 Etc/GMT";
            "purchase_date_ms" = 1521192388000;
            "purchase_date_pst" = "2018-03-16 02:26:28 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376486;
            "web_order_line_item_id" = 1000000038132762;
    },
        {
            "expires_date" = "2018-03-16 09:48:23 Etc/GMT";
            "expires_date_ms" = 1521193703000;
            "expires_date_pst" = "2018-03-16 02:48:23 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:48:34 Etc/GMT";
            "original_purchase_date_ms" = 1521200914000;
            "original_purchase_date_pst" = "2018-03-16 04:48:34 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 09:43:23 Etc/GMT";
            "purchase_date_ms" = 1521193403000;
            "purchase_date_pst" = "2018-03-16 02:43:23 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376500;
            "web_order_line_item_id" = 1000000038133071;
    },
        {
            "expires_date" = "2018-03-16 10:26:25 Etc/GMT";
            "expires_date_ms" = 1521195985000;
            "expires_date_pst" = "2018-03-16 03:26:25 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:24:28 Etc/GMT";
            "original_purchase_date_ms" = 1521195868000;
            "original_purchase_date_pst" = "2018-03-16 03:24:28 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 10:21:25 Etc/GMT";
            "purchase_date_ms" = 1521195685000;
            "purchase_date_pst" = "2018-03-16 03:21:25 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383357120;
            "web_order_line_item_id" = 1000000038133299;
    },
        {
            "expires_date" = "2018-03-16 10:31:25 Etc/GMT";
            "expires_date_ms" = 1521196285000;
            "expires_date_pst" = "2018-03-16 03:31:25 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:25:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195957000;
            "original_purchase_date_pst" = "2018-03-16 03:25:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 10:26:25 Etc/GMT";
            "purchase_date_ms" = 1521195985000;
            "purchase_date_pst" = "2018-03-16 03:26:25 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383357547;
            "web_order_line_item_id" = 1000000038133798;
    },
        {
            "expires_date" = "2018-03-16 10:48:45 Etc/GMT";
            "expires_date_ms" = 1521197325000;
            "expires_date_pst" = "2018-03-16 03:48:45 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:43:47 Etc/GMT";
            "original_purchase_date_ms" = 1521197027000;
            "original_purchase_date_pst" = "2018-03-16 03:43:47 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 10:43:45 Etc/GMT";
            "purchase_date_ms" = 1521197025000;
            "purchase_date_pst" = "2018-03-16 03:43:45 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383362112;
            "web_order_line_item_id" = 1000000038133861;
    },
        {
            "expires_date" = "2018-03-16 10:56:35 Etc/GMT";
            "expires_date_ms" = 1521197795000;
            "expires_date_pst" = "2018-03-16 03:56:35 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 10:51:37 Etc/GMT";
            "original_purchase_date_ms" = 1521197497000;
            "original_purchase_date_pst" = "2018-03-16 03:51:37 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 10:51:35 Etc/GMT";
            "purchase_date_ms" = 1521197495000;
            "purchase_date_pst" = "2018-03-16 03:51:35 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383364166;
            "web_order_line_item_id" = 1000000038134093;
    },
        {
            "expires_date" = "2018-03-16 11:25:37 Etc/GMT";
            "expires_date_ms" = 1521199537000;
            "expires_date_pst" = "2018-03-16 04:25:37 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:20:39 Etc/GMT";
            "original_purchase_date_ms" = 1521199239000;
            "original_purchase_date_pst" = "2018-03-16 04:20:39 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 11:20:37 Etc/GMT";
            "purchase_date_ms" = 1521199237000;
            "purchase_date_pst" = "2018-03-16 04:20:37 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383370351;
            "web_order_line_item_id" = 1000000038134213;
    },
        {
            "expires_date" = "2018-03-16 11:51:31 Etc/GMT";
            "expires_date_ms" = 1521201091000;
            "expires_date_pst" = "2018-03-16 04:51:31 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 11:46:33 Etc/GMT";
            "original_purchase_date_ms" = 1521200793000;
            "original_purchase_date_pst" = "2018-03-16 04:46:33 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 11:46:31 Etc/GMT";
            "purchase_date_ms" = 1521200791000;
            "purchase_date_pst" = "2018-03-16 04:46:31 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383376184;
            "web_order_line_item_id" = 1000000038134492;
    },
        {
            "expires_date" = "2018-03-16 12:42:44 Etc/GMT";
            "expires_date_ms" = 1521204164000;
            "expires_date_pst" = "2018-03-16 05:42:44 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 12:37:46 Etc/GMT";
            "original_purchase_date_ms" = 1521203866000;
            "original_purchase_date_pst" = "2018-03-16 05:37:46 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 12:37:44 Etc/GMT";
            "purchase_date_ms" = 1521203864000;
            "purchase_date_pst" = "2018-03-16 05:37:44 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383388251;
            "web_order_line_item_id" = 1000000038134740;
    },
        {
            "expires_date" = "2018-03-16 12:47:44 Etc/GMT";
            "expires_date_ms" = 1521204464000;
            "expires_date_pst" = "2018-03-16 05:47:44 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 12:42:03 Etc/GMT";
            "original_purchase_date_ms" = 1521204123000;
            "original_purchase_date_pst" = "2018-03-16 05:42:03 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 12:42:44 Etc/GMT";
            "purchase_date_ms" = 1521204164000;
            "purchase_date_pst" = "2018-03-16 05:42:44 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383389000;
            "web_order_line_item_id" = 1000000038135242;
    },
        {
            "expires_date" = "2018-03-16 12:53:08 Etc/GMT";
            "expires_date_ms" = 1521204788000;
            "expires_date_pst" = "2018-03-16 05:53:08 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 12:48:10 Etc/GMT";
            "original_purchase_date_ms" = 1521204490000;
            "original_purchase_date_pst" = "2018-03-16 05:48:10 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 12:48:08 Etc/GMT";
            "purchase_date_ms" = 1521204488000;
            "purchase_date_pst" = "2018-03-16 05:48:08 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383389396;
            "web_order_line_item_id" = 1000000038135279;
    },
        {
            "expires_date" = "2018-03-16 12:59:19 Etc/GMT";
            "expires_date_ms" = 1521205159000;
            "expires_date_pst" = "2018-03-16 05:59:19 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 12:54:20 Etc/GMT";
            "original_purchase_date_ms" = 1521204860000;
            "original_purchase_date_pst" = "2018-03-16 05:54:20 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 12:54:19 Etc/GMT";
            "purchase_date_ms" = 1521204859000;
            "purchase_date_pst" = "2018-03-16 05:54:19 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383389516;
            "web_order_line_item_id" = 1000000038135324;
    },
        {
            "expires_date" = "2018-03-16 14:17:00 Etc/GMT";
            "expires_date_ms" = 1521209820000;
            "expires_date_pst" = "2018-03-16 07:17:00 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 14:12:02 Etc/GMT";
            "original_purchase_date_ms" = 1521209522000;
            "original_purchase_date_pst" = "2018-03-16 07:12:02 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 14:12:00 Etc/GMT";
            "purchase_date_ms" = 1521209520000;
            "purchase_date_pst" = "2018-03-16 07:12:00 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383402210;
            "web_order_line_item_id" = 1000000038135368;
    },
        {
            "expires_date" = "2018-03-16 14:22:00 Etc/GMT";
            "expires_date_ms" = 1521210120000;
            "expires_date_pst" = "2018-03-16 07:22:00 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-03-16 14:16:25 Etc/GMT";
            "original_purchase_date_ms" = 1521209785000;
            "original_purchase_date_pst" = "2018-03-16 07:16:25 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-16 14:17:00 Etc/GMT";
            "purchase_date_ms" = 1521209820000;
            "purchase_date_pst" = "2018-03-16 07:17:00 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383403575;
            "web_order_line_item_id" = 1000000038135956;
    },
        {
            "expires_date" = "2018-09-11 11:20:42 Etc/GMT";
            "expires_date_ms" = 1536664842000;
            "expires_date_pst" = "2018-09-11 04:20:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 11:15:22 Etc/GMT";
            "original_purchase_date_ms" = 1536664522000;
            "original_purchase_date_pst" = "2018-09-11 04:15:22 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-09-11 11:15:42 Etc/GMT";
            "purchase_date_ms" = 1536664542000;
            "purchase_date_pst" = "2018-09-11 04:15:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442457371;
            "web_order_line_item_id" = 1000000040305337;
    },
        {
            "expires_date" = "2018-09-11 11:25:42 Etc/GMT";
            "expires_date_ms" = 1536665142000;
            "expires_date_pst" = "2018-09-11 04:25:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 11:19:47 Etc/GMT";
            "original_purchase_date_ms" = 1536664787000;
            "original_purchase_date_pst" = "2018-09-11 04:19:47 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-09-11 11:20:42 Etc/GMT";
            "purchase_date_ms" = 1536664842000;
            "purchase_date_pst" = "2018-09-11 04:20:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442460517;
            "web_order_line_item_id" = 1000000040306497;
    },
        {
            "expires_date" = "2018-09-11 11:30:42 Etc/GMT";
            "expires_date_ms" = 1536665442000;
            "expires_date_pst" = "2018-09-11 04:30:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 11:24:44 Etc/GMT";
            "original_purchase_date_ms" = 1536665084000;
            "original_purchase_date_pst" = "2018-09-11 04:24:44 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-09-11 11:25:42 Etc/GMT";
            "purchase_date_ms" = 1536665142000;
            "purchase_date_pst" = "2018-09-11 04:25:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442465155;
            "web_order_line_item_id" = 1000000040306601;
    },
        {
            "expires_date" = "2018-09-11 11:35:42 Etc/GMT";
            "expires_date_ms" = 1536665742000;
            "expires_date_pst" = "2018-09-11 04:35:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 11:30:29 Etc/GMT";
            "original_purchase_date_ms" = 1536665429000;
            "original_purchase_date_pst" = "2018-09-11 04:30:29 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-09-11 11:30:42 Etc/GMT";
            "purchase_date_ms" = 1536665442000;
            "purchase_date_pst" = "2018-09-11 04:30:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442468568;
            "web_order_line_item_id" = 1000000040306692;
    },
        {
            "expires_date" = "2018-09-11 11:40:42 Etc/GMT";
            "expires_date_ms" = 1536666042000;
            "expires_date_pst" = "2018-09-11 04:40:42 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = false;
            "original_purchase_date" = "2018-09-11 11:34:56 Etc/GMT";
            "original_purchase_date_ms" = 1536665696000;
            "original_purchase_date_pst" = "2018-09-11 04:34:56 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-09-11 11:35:42 Etc/GMT";
            "purchase_date_ms" = 1536665742000;
            "purchase_date_pst" = "2018-09-11 04:35:42 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000442472642;
            "web_order_line_item_id" = 1000000040306804;
    },
        {
            "expires_date" = "2018-03-08 09:00:36 Etc/GMT";
            "expires_date_ms" = 1520499636000;
            "expires_date_pst" = "2018-03-08 01:00:36 America/Los_Angeles";
            "is_in_intro_offer_period" = false;
            "is_trial_period" = true;
            "original_purchase_date" = "2018-03-16 10:22:57 Etc/GMT";
            "original_purchase_date_ms" = 1521195777000;
            "original_purchase_date_pst" = "2018-03-16 03:22:57 America/Los_Angeles";
            "original_transaction_id" = 1000000381484598;
            "product_id" = "pro_subscription_monthly";
            "purchase_date" = "2018-03-08 08:55:36 Etc/GMT";
            "purchase_date_ms" = 1520499336000;
            "purchase_date_pst" = "2018-03-08 00:55:36 America/Los_Angeles";
            quantity = 1;
            "transaction_id" = 1000000383356114;
            "web_order_line_item_id" = 1000000038050081;
    }
    );
    "original_application_version" = "1.0";
    "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
    "original_purchase_date_ms" = 1375340400000;
    "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
    "receipt_creation_date" = "2018-09-11 12:34:16 Etc/GMT";
    "receipt_creation_date_ms" = 1536669256000;
    "receipt_creation_date_pst" = "2018-09-11 05:34:16 America/Los_Angeles";
    "receipt_type" = ProductionSandbox;
    "request_date" = "2018-09-11 12:36:12 Etc/GMT";
    "request_date_ms" = 1536669372668;
    "request_date_pst" = "2018-09-11 05:36:12 America/Los_Angeles";
    "version_external_identifier" = 0;
  };
  status = 0;
  }

  */
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
