//
//  SelectCourseStructData.swift
//  Golfication
//
//  Created by Rishabh Sood on 24/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

    struct SelectCourseStruct: Decodable {
        
//    func unkeyedContainer() throws -> UnkeyedDecodingContainer
//    enum CodingKeys: String
    let Name: String
    let City: String
    let Country: String
    let Latitude: String
    let Longitude: String
    let Mapped: String

}

//struct CourseTypeData: SelectCourseStruct {
////    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
////        return NSNumber.self as! UnkeyedDecodingContainer
////    }
//        let Name: String
//        let City: String
//        let Country: String
//        let Latitude: String
//        let Longitude: String
//   }

//{"8914":{"Name":"Mini Golf Course \u0096 DDA, Siri Fort","City":"New Delhi","Country":"India","Latitude":"28.552273","Longitude":"77.220749"}

