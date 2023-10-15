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
    
    public func isCheckedIn() -> Bool {
        let status = Globals.getCheckInStatus()
        
        if status.isEmpty {
            return false;
        }
        
        if status == "1" {
            return true
        }
        
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

}
