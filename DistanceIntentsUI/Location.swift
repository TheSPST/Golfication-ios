//
//  Location.swift
//  MapViewClustering
//
//  Created by seyedamirhossein hashemi on 2018-02-15.
//  Copyright © 2018 seyedamirhossein hashemi. All rights reserved.
//
//https://medium.com/@hashemi.eng1985/map-view-does-not-show-all-annotations-at-first-9789d77f6a3a

import Foundation
import MapKit

/**
 * Model class for a Location
 *
 */
class Location : NSObject {
    /// fields
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    class func locations(fromDictionaries dictionaries: [[String: String]]) -> [Location] {
        let locations = dictionaries.map { (dict) -> Location in
            let loc = Location(name: dict["name"]!, latitude: Double(dict["lat"]!)!, longitude: Double(dict["log"]!)!)
            return loc
        }
        return locations
    }

}
extension Location: MKAnnotation {
    
    var title: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
}
