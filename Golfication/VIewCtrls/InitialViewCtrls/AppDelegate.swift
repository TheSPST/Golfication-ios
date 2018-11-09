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
                debugPrint("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            debugPrint(base64encodedReceipt!)
            
            
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
                        debugPrint("Product is expired since \(expiryDate)\(receiptItems)")
                    case .notPurchased:
                        debugPrint("This product has never been purchased")
                    }
                    
                case .error(let error):
                    debugPrint("Receipt verification failed: \(error)")
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
        
        /*let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        debugPrint("Device Token: \(token)")*/
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
                var dataArr =  [NSMutableDictionary]()
                
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
                    if($0.key != "99999999"){
                        dataArr.append(dataDic)
                    }
                    group.leave()
                    group.notify(queue: .main) {
                    }
                }
                DispatchQueue.main.async(execute: {
                    if !dataArr.isEmpty{
                        dataArr = BackgroundMapStats.sortAndShow(searchDataArr: dataArr, myLocation: currentLocation)
                        let golfName = (dataArr[0].value(forKey: "Name") as? String) ?? ""
                        let golfDistance = (dataArr[0].value(forKey: "Distance") as? Double) ?? 0.0
                        
//                        let distance: Double  = Double(golfDistance)!
                        if golfDistance < 1000.0 && golfName != ""{
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
            let friendsItem = UIApplicationShortcutItem(type: "OpenFriendsTab", localizedTitle: "Together", localizedSubtitle: nil, icon: friendsIcon, userInfo: nil)
            
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
            debugPrint("Dynamic link : \(dynamicLink.url)")
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
