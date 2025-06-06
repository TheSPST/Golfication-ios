//
//  IntentHandler.swift
//  DistanceIntents
//
//  Created by Rishabh Sood on 26/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is DistanceOfGreenIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return DistanceOfGreenIntentHandler()
//        return self
    }
}
