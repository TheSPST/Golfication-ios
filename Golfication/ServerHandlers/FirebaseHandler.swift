    //
    //  FirebaseHandler.swift
    //  Golfication
    //
    //  Created by Rishabh Sood on 26/10/17.
    //  Copyright © 2017 Khelfie. All rights reserved.
    //
    
    import UIKit
    import FirebaseDatabase
    import FirebaseAuth
    typealias ServiceResponse = (DataSnapshot, NSError?) -> Void
        
    var ref: DatabaseReference! = Database.database().reference()

    class FirebaseHandler: NSObject {
        
        static let fireSharedInstance = FirebaseHandler()
        
        let golfPathStr = "golfCourses"
        let userStr = "userData/"
        
        // read User Data
        func getResponseFromFirebase(addedPath:String, onCompletion: @escaping (DataSnapshot) -> Void) {
            let route: String!
            route = "userData/\(Auth.auth().currentUser?.uid ?? "user1")" + "/" + addedPath
            debugPrint("getResponseFromFirebase",route)
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseGolf(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            let route = golfPathStr + "/" + addedPath
            debugPrint("getResponseFromFirebaseGolf",route)
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseMatch(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            debugPrint("getResponseFromFirebaseMatch",addedPath)
            makeFirebaseRequest(route: addedPath, onCompletion: {snapshot, err in
            onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseUserData(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            let route = userStr + "/" + addedPath
            debugPrint("getResponseFromFirebaseUserData",route)
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        private func makeFirebaseRequest(route: String, onCompletion: @escaping ServiceResponse) {
            debugPrint("route",route)

            let error  = NSError()
//            if route.contains("swingSession"){
//                debugPrint(route)
                ref?.child(route).keepSynced(true)
//            }
            ref?.child(route).observeSingleEvent(of: .value, with: { snapshot in
                
                let nullFlag = DataSnapshot()
                
                if !snapshot.exists() || snapshot.value == nil {
                    onCompletion(nullFlag, error)
                    //print("myError :\(snapshot)")
                }
                else {
                    onCompletion(snapshot, error)
                    //print("myData :\(snapshot)")
                }
            })
        }
//        private func makeFirebaseRequestOrderByTimeStamp(route: String, onCompletion: @escaping ServiceResponse) {
//
//            let error  = NSError()
//
//            ref?.child(route).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { snapshot in
//
//                let nullFlag = DataSnapshot()
//
//                if !snapshot.exists() || snapshot.value == nil {
//                    onCompletion(nullFlag, error)
//                    print("myError :\(snapshot)")
//                }
//                else {
//                    onCompletion(snapshot, error)
//                    print("myData :\(snapshot)")
//                }
//            })
//        }

}
