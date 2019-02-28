//
//  LocationView.swift
//  MapViewClustering
//
//  Created by seyedamirhossein hashemi on 2018-02-17.
//  Copyright © 2018 seyedamirhossein hashemi. All rights reserved.
//

import UIKit
import MapKit

/**
 * View of annotations
 *
 */
class LocationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if let _ = newValue as? Location {
                self.displayPriority = .required
            }
        }
    }
}
