//
//  AttendanceController.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 16/10/23.
//

import Foundation
import UIKit
import SwiftUI
/*
"id": 181,
"place": "khalil test nearby location ",
"latitude": "19.46479333786486",
"longitude": "72.80544431203187",
"radius": "290.1751158168647",
"zoom": "16",
"created_at": "2023-10-04 20:06:01.188971",
"modified_at": "2023-10-04 20:06:01.188971"
 */

struct GeoFence {
    let id: Int
    let place: String
    let latitude: String
    let longitude: String
    let radius: String
    let zoom: String
    let created_at: String
    let modified_at: String
}

class GeofenceSiteName: ObservableObject  {
    @Published var siteName: String
    init(siteName: String) {
        self.siteName = siteName
    }
}


class AttendanceController {
    
    public static var selectedImage :UIImage? = UIImage()
    public static var longitude :String = ""
    public static var latitude :String = ""
    public static var currentDate: String = ""
    public static var currentTime: String = ""
    public static var allGeoFences: [Dictionary<String,Any>] = Globals.allGeoFences
    public static var currentLocationName :String = "Loading..."
    public static var geoFenceSiteName = GeofenceSiteName(siteName: "Outside premises...")
    
    public static func getCurrentCheckValue() async -> String {
        
        if await Globals.isCheckedIn() {
            return "Check out"
        }
        
        return "Check In"
    }
    
    public static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public static func loadGeofencing1() -> Int {
        
        guard let url = URL(string: Globals.API_URL) else {
            
            return -1
        }
        
        // http request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "action": "geofences"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                
                return
            }
            do {
                print("received login response")
                // handling response
                let response = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                guard let result = response as? [String:Any] else {
                    
                    return
                }
                
                
                // is response ok?
                if let status_code = result["status_code"] {
                    if status_code as! Int != 200 {
                        return
                    }
                }
                
                // response is okay
                // loading geofences
                if let json_data = result["json_data"] {
                    
                    let geofences_raw = json_data as! String
                    
                    
                    let geofences_data = geofences_raw.data(using: .utf8)!
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(
                            with: geofences_data, options : .allowFragments) as? [Dictionary<String,Any>]
                        {
                            allGeoFences = jsonArray
                            getCurrentSiteName()
                            
                            
                        } else {
                            print("bad json")
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
                
                
                
            } catch {
                print(error)
                
            }
            
        }
        
        task.resume()
        
        return -1
    }
    
    public static func getCurrentSiteName() -> String {
    
        
        if allGeoFences.count < 2 {
            print("geo fence is empty")
        }
        else {
            print("geo fence is size: " + String(allGeoFences.count))
        }
        
        for fence in allGeoFences {
            var lat1 :Float = 0.0
            var long1 :Float = 0.0
            var r1 :Float = 0.0
            
            if let lat2 = fence["latitude"] as? String {
                lat1 = Float(lat2) ?? 0.0
            }
            
            if let long2 = fence["longitude"] as? String {
                long1 = Float(long2) ?? 0.0
            }
            
            if let r2 = fence["radius"] as? String {
                r1 = Float(r2) ?? 0.0
            }
            
            if isInsideFence(homelatitude: lat1, homelongitude: long1, radius: r1) {
                let siteName = fence["place"] as! String
                currentLocationName = siteName
                geoFenceSiteName.siteName = siteName
                print("found current location: \(siteName)")
                return fence["place"] as! String
            }
            
        }
        
        currentLocationName = "Outside Premises"
        geoFenceSiteName.siteName = "Outside Premises"
        return "Outside Premises"
    }
    
    public static func isInsideFence(homelatitude: Float, homelongitude: Float, radius: Float) -> Bool {
        
        // (lat-center_lat)^2 + (lon - center_lon)^2 < radius^2: inside fence
        //print("is inside fence params", "\(homelatitude)", "\(homelongitude)")
        //print("is inside fence long tat", "\(latitude)", "\(longitude)")
        //print("current location", "\(latitude)", "\(longitude)" )
        //print("current geofence test", "\(homelatitude)", "\(homelongitude)" )
        let difflongitude = (Float(longitude) ?? 0.0) - homelongitude;
        let difflatitude  = (Float(latitude) ??  0.0) - homelatitude;
        
        let squareDiffLongitude = pow(difflongitude, 2)
        let squareDiffLatitude = pow(difflatitude, 2)
        let squareRadius = pow(radius / 10, 2)
        
        let sumOfDiff = squareDiffLongitude + squareDiffLatitude
        
        if sumOfDiff < squareRadius {
            return true
        } else {
            return false
        }
        /*
        
        let a = pow(sin(difflatitude/2),2) + cos(homelatitude)
        * cos((Float(latitude) ??  0.0)) * pow(sin(difflongitude/2),2);
        let circuit = 2 * asin(sqrt(a));
        //print("insidefence circuit", "\(circuit)")
        let eradius = 6731;
        
        let mradius = circuit * Float(eradius)
        //print("mradius", "\(mradius)")
        //print("radius", "\(radius)")
        if(circuit*Float(eradius)<radius){
            return true;
        }
        return false;
         */
        
    }
    
    public static func getAttendanceType() -> String {
        let status = Globals.getCheckInStatus()
        if status.isEmpty {
            return "1"
        }
        
        if status == "1" {
            
            return "2"
        }
        
        if Int(status) == 1 {
            return "2"
        }
        return "1"
    }
    
    public static func getBase64Image() -> String {
        // Safely unwrap both the image and the PNG data
        guard let image = selectedImage,
              let imageData = image.pngData() else {
            print("Warning: No image found or failed to convert to PNG data.")
            return "" // Gracefully return an empty string instead of crashing
        }
        
        // Convert directly from Data to base64 string
        return imageData.base64EncodedString()
    }
    
    public static func markAttendance() {
        guard let url = URL(string: Globals.API_URL) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let mydata: [String: AnyHashable] = [
            "id": 0,
            "token": Globals.getUserToken(),
            "type": getAttendanceType(),
            "date": currentDate,
            "time": currentTime,
            "location_name": currentLocationName,
            "latitude": latitude,
            "longitude": longitude,
            "image": getBase64Image()
        ]
        
        print("markattendance start")
        print(mydata)
        
        
        
        let body: [String: AnyHashable] = [
            "data": mydata,
            "action": "mark_attendance"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                
                // handling response
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(response)
                guard let result = response as? [String:Any] else {
                
                    return
                }
                
                
                // is response ok?
                if let status_code = result["status_code"] {
                    if status_code as! Int != 200 {
                        return
                        
                    }
                }
                
                // response is okay
                selectedImage = UIImage()
                
            } catch  {
                
                print(error)
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    print(str)
                }
                
            }
            
        }
        
        task.resume()
        print("mark attendance end")
    }
}
