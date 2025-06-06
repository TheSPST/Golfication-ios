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
  import FacebookCore
  import iAd
  var sharedSecret = "79d35d5b3b684c84ba4302a33d498a47"
  var referedBy : String!
  var tempararyUserKey : String!
  @UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate{
    var window: UIWindow?
    var locationManager = CLLocationManager()
    let notificationDelegate = UYLNotificationDelegate()
    var isInternet = true
    var fromNewUserProfile = false
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
            Notification.sendLocalNotificationForNonProNewUser()
            if ADClient.shared().responds(to: #selector(ADClient.requestAttributionDetails(_:))) {
                debugPrint("iOS 10 call exists")
                ADClient.shared().requestAttributionDetails({ attributionDetails, error in
                    // Look inside of the returned dictionary for all attribution details
                    if let attributionDetails = attributionDetails{
                        print("Attribution Dictionary: \(attributionDetails)")
                        let cookieHeader = ((attributionDetails as NSDictionary).compactMap({ (key, value) -> String in
                            return "\(key)=\(value)"
                        }) as Array).joined(separator: ";")
                        print(cookieHeader)
                        tempararyUserKey = ref!.child("iosAdsUser").childByAutoId().key
                        let ddddict = NSMutableDictionary()
                        ddddict.addEntries(from: ["data" : cookieHeader])
                        ref.child("iosAdsUser/").updateChildValues(["\(tempararyUserKey!)" : ddddict], withCompletionBlock: { (error, ref) in
                            debugPrint("Success fulll write")
                        })
                    }
                })
            }
        }

        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = false
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "dlscheme"
        GMSServices.provideAPIKey("AIzaSyBiBmJwKydauA_8VfDlaYAg4C1FZImkAI8")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
        self.logUser()
        DynamicLinks.performDiagnostics(completion: nil)
        Database.database().isPersistenceEnabled = true
        
        Messaging.messaging().delegate = self
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            // Enable or disable features based on authorization
            
        }
        application.registerForRemoteNotifications()
        
        
        //------------------- Local Notification ----------------------
//        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        // ------------------------------------------------------------
        
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
//                                    let v = value as? NSArray
//                                    debugPrint("latest_receipt_info",v?.lastObject)
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
                        debugPrint("the upload task returned an error: \(String(describing: error))")
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
            self.isInternet = false
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            self.isInternet = true
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
//        finishBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        if Auth.auth().currentUser != nil{
            
            let homeIcon = UIApplicationShortcutIcon(templateImageName: "homeTab")
            let homeItem = UIApplicationShortcutItem(type: "OpenHomeTab", localizedTitle: "Home".localized(), localizedSubtitle: nil, icon: homeIcon, userInfo: nil)
            
            let friendsIcon = UIApplicationShortcutIcon(templateImageName: "together_0")
            let friendsItem = UIApplicationShortcutItem(type: "OpenFriendsTab", localizedTitle: "Together".localized(), localizedSubtitle: nil, icon: friendsIcon, userInfo: nil)
            
            let profileIcon = UIApplicationShortcutIcon(templateImageName: "avatar_0")
            let profileItem = UIApplicationShortcutItem(type: "OpenProfileTab", localizedTitle: "Profile".localized(), localizedSubtitle: nil, icon: profileIcon, userInfo: nil)
            
            let addScoreIcon = UIApplicationShortcutIcon(templateImageName: "addScore")
            let addScoreItem = UIApplicationShortcutItem(type: "OpenAddScoreTab", localizedTitle: "Play Game".localized(), localizedSubtitle: nil, icon: addScoreIcon, userInfo: nil)
            
            UIApplication.shared.shortcutItems = [homeItem, friendsItem, profileItem, addScoreItem]
        }
    }
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void){
        
        let tabBarCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarCtrl") as! CustomTabBarCtrl
        window?.rootViewController = tabBarCtrl
        
        if (shortcutItem.type == "OpenHomeTab") {
            tabBarCtrl.selectedIndex = 0
        }
        else if (shortcutItem.type == "OpenFriendsTab") {
            tabBarCtrl.selectedIndex = 1
        }
        else if (shortcutItem.type == "OpenProfileTab") {
            tabBarCtrl.selectedIndex = 2
        }
        else if (shortcutItem.type == "OpenAddScoreTab") {
            
            let gameController = UIStoryboard(name: "Game", bundle:nil).instantiateViewController(withIdentifier: "NewGameVC") as! NewGameVC
            var playNavCtrl = UINavigationController()
            playNavCtrl = (tabBarCtrl.selectedViewController as? UINavigationController)!
            playNavCtrl.pushViewController(gameController, animated: true)
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url, sourceApplication: nil,annotation: [:])

    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink =   DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            // Handle the deep link here.
            // Show promotional offer.
//            debugPrint("Dynamic link : \(dynamicLink.url)")
            return handleDynamicLink(dynamicLink)
        }
        return false
    }
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else { return false }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL ?? URL(fileURLWithPath: "")) { (dynamicLink, error) in
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
            var isMembership : Int!
            if let member = snapshot.value as? Int{
                isMembership = member
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
