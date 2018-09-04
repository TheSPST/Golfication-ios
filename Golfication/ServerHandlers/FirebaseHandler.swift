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
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseGolf(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            let route = golfPathStr + "/" + addedPath
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseMatch(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            makeFirebaseRequest(route: addedPath, onCompletion: {snapshot, err in
            onCompletion(snapshot)
            })
        }
        func getResponseFromFirebaseUserData(addedPath:String,onCompletion: @escaping (DataSnapshot) -> Void) {
            let route = userStr + "/" + addedPath
            makeFirebaseRequest(route: route, onCompletion: {snapshot, err in
                onCompletion(snapshot)
            })
        }
        private func makeFirebaseRequest(route: String, onCompletion: @escaping ServiceResponse) {
            
            let error  = NSError()
            
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
