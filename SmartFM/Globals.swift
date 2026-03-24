//
//  Globals.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import Foundation
class Globals {
    public static let BASE_URL = "https://smartfm.ismartfacitechpl.com/"
    public static let API_URL = BASE_URL + "android.php"
    
    // user data
    public static let USER_ID_KEY = "USER_ID_KEY"
    public static let USER_TOKEN_KEY = "USER_TOKEN_KEY"
    public static let USER_NAME_KEY = "USER_NAME_KEY"
    public static let CHECK_IN_OUT_KEY = "CHECK_IN_OUT_KEY"
    public static let IS_LOGGED_IN_KEY = "IS_LOGGED_IN_KEY"
    public static let IS_APPROVED_KEY = "IS_APPROVED_KEY"
    public static let IS_REPORTING_MANAGER_KEY = "IS_REPORTING_MANAGER_KEY"
    
    // main views
    public static let LOGIN_VIEW = "LOGIN_VIEW"
    public static let DASHBOARD_VIEW = "DASHBOARD_VIEW"
    public static let WEBUI_VIEW = "WEBUI_VIEW"
    public static let ATTENDANCE_VIEW = "ATTENDANCE_VIEW"
    public static let CURRENT_VIEW = LOGIN_VIEW
    public static var allGeoFences: [Dictionary<String,Any>] = []
    
    
    public static func saveData(key: String, value: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    public static func getData(key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    public static func getUserId() -> String {
        return getData(key:USER_ID_KEY)
    }
    
    public static func getUserToken() -> String {
        return getData(key:USER_TOKEN_KEY)
    }
    
    public static func getUserName() -> String {
        return getData(key:USER_NAME_KEY)
    }
    
    public static func getCheckInStatus() -> String {
        return getData(key:CHECK_IN_OUT_KEY)
    }
    
    public static func getLoggedInStatus() -> String {
        return getData(key:IS_LOGGED_IN_KEY)
    }
    
    public static func getIsApproved() -> String {
        return getData(key:IS_APPROVED_KEY)
    }
    
    public static func getIsReportingManager() -> String {
        return getData(key:IS_REPORTING_MANAGER_KEY)
    }
    
    public static func getWebViewURL(page: String) -> String {
        let token = getUserToken()
        let url = BASE_URL + page + "?user_token=" + token
        return url
    }
    
    public static func isLoggedIn() -> Bool {
        let status = getLoggedInStatus()
        print("Globals.isLoggedIn(): " + status)
        if status.isEmpty {
            return false
        }
        
        if status == "0" {
            return false
        }
        
        if status == "1" {
            return true
        }
            
        return false
    }
    
    public static func isCheckedIn() async -> Bool {
        await initailizeCheckInDataFromServer();
        let status = Globals.getCheckInStatus()
        print("isCheckedIn() status " + status)
        if status.isEmpty {
            print("isCheckedIn() returning false because empty")
            return false;
        }
        
        if status == "1" {
            print("isCheckedIn() returning true because '1'")
            return true
        }
        
        if Int(status) == 1 {
            print("isCheckedIn() returning true because int 1")
            return true
        }
        print("isCheckedIn() returning false because reach end")
        return false
    }
    
    public static func resetData() {
        Globals.saveData(key: Globals.USER_ID_KEY, value: "")
        Globals.saveData(key: Globals.USER_TOKEN_KEY, value: "")
        Globals.saveData(key: Globals.USER_NAME_KEY, value: "")
        Globals.saveData(key: Globals.CHECK_IN_OUT_KEY, value: "")
        Globals.saveData(key: Globals.IS_LOGGED_IN_KEY, value: "")
        Globals.saveData(key: Globals.IS_APPROVED_KEY, value: "")
        
    }
    
    public static func printAllKeyData() -> Bool {
        print("USER_ID_KEY: " + Globals.getData(key: Globals.USER_ID_KEY))
        print("USER_TOKEN_KEY: " + Globals.getData(key: Globals.USER_TOKEN_KEY))
        print("USER_NAME_KEY: " + Globals.getData(key: Globals.USER_NAME_KEY))
        print("CHECK_IN_OUT_KEY: " + Globals.getData(key: Globals.CHECK_IN_OUT_KEY))
        print("IS_LOGGED_IN_KEY: " + Globals.getData(key: Globals.IS_LOGGED_IN_KEY))
        print("IS_APPROVED_KEY: " + Globals.getData(key: Globals.IS_APPROVED_KEY))
        return true
    }
    
    public static func initialize() async -> Bool {
        print("initializing global")
        await initailizeCheckInDataFromServer()
        await loadGeofencing()
        print("intialization global end")
        return true
    }
    
    public static func initailizeCheckInDataFromServer() async {
        guard isLoggedIn(),
              let url = URL(string: Globals.API_URL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "user_token": getUserToken(),
            "action": "is_user_checked_in"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let result = json as? [String: Any] else { return }
            print(result)
            if let status_code = result["status_code"] as? Int, status_code != 200 {
                return
            }
            
            if let checked_in = result["checked_in"] as? Int {
                Globals.saveData(key: Globals.CHECK_IN_OUT_KEY, value: checked_in == 1 ? "1" : "0")
            }

            printAllKeyData()
        } catch {
            print("Error:", error)
            if let str = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("Request body: \(str)")
            }
        }
    }

    
    public static func __initailizeCheckInDataFromServer() async {
        if !isLoggedIn() {
            return
        }
        
        guard let url = URL(string: Globals.API_URL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "user_token": getUserToken(),
            "action": "is_user_checked_in"
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
                
                if let checked_in = result["checked_in"] {
                    let is_in = checked_in as! Int
                    
                    if is_in == 1 {
                        Globals.saveData(key: Globals.CHECK_IN_OUT_KEY, value: "1")
                    } else {
                        Globals.saveData(key: Globals.CHECK_IN_OUT_KEY, value: "0")
                    }
                }
                
                printAllKeyData()
                
            } catch {
                
                print(error)
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    print(str)
                }
                
            }
            
        }
        
        task.resume()
    }
    
    public static func loadGeofencing() async -> Int {
        
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

}
