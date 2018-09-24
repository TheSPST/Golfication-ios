//
//  ServerHandler.swift
//  Golfication
//
//  Created by Rishabh Sood on 24/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class ServerHandler: NSObject {
//https://www.khelfie.com/mysql/
    let pathStr = "http://www.khelfie.com/mysql/"

    let defaultSession = URLSession(configuration: .default)
    var errorMessage = String()
    var state = uint()
    
    var dataTask: URLSessionDataTask?
    func getLocations(urlString: String, dataString: String, onCompletion: @escaping ([String:SelectCourseStruct]?, String?)-> Void ){
        
        if self.state == 1{
            dataTask?.cancel()
        }
        
        if var urlComponents = URLComponents(string: pathStr + urlString) {
            urlComponents.query = dataString
        
            guard let url = urlComponents.url else { return }
            //print("ServerUrl= ",url)
            
            dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                defer { self.dataTask = nil }
        
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                    onCompletion(error as? [String : SelectCourseStruct], error.localizedDescription.debugDescription)
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse, response.statusCode == 200{

                    do{
                        
                    let courses = try JSONDecoder().decode([String:SelectCourseStruct].self, from: data)
                    
                    DispatchQueue.main.async {
                        onCompletion(courses, error as? String)
                    }
                    }
                    catch let jsonErr {
                        //print("Error serializing json:", jsonErr.localizedDescription.debugDescription)
                        onCompletion(jsonErr as? [String : SelectCourseStruct], jsonErr.localizedDescription.debugDescription)
                    }
                }
            }
            dataTask?.resume()
        }
   }
    
    func sendMailingRequest(urlString: String, dataString: String, onCompletion: @escaping (String?, String?)-> Void ){
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = dataString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {  // check for fundamental networking error
                debugPrint("error=\(error ?? "" as! Error)")
                onCompletion(nil, error as? String)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                debugPrint("statusCode should be 200, but is \(httpStatus.statusCode)")
                debugPrint("response = \(response as Any)")
                onCompletion("\(response as Any)", error as? String)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            debugPrint("responseString = \(responseString ?? "")")  // in case of success
            onCompletion(responseString, error as? String)
        }
        task.resume()
    }
}
