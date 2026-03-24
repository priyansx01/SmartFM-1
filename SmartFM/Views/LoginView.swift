//
//  LoginView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var mobile: String = ""
    @State private var loginPassword: String = ""
    @State private var showCreateAccountPage: Bool = false
    @State private var showPasswordResetPage: Bool = false
    @State private var isLogging: Bool = false
    @State private var errorMessage: String = ""
    
    //@State private var isLoggedIn: Bool = false
    @AppStorage(Globals.IS_LOGGED_IN_KEY) private var isLoggedIn: String = ""

    
    var body: some View {
        
        if(isLoggedIn != "1") {
            VStack(alignment: .leading, spacing: 0.0) {
                Spacer()
                Image("ismart_logo2")
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 15.0)
                Spacer()
                
                Text("Mobile number")
                    .padding(.horizontal)
                TextField("Enter Mobile Number", text: $mobile)
                    .keyboardType(.decimalPad)
                    .frame(height: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                    .padding()
                
                Text("Password")
                    .padding([.top, .leading, .trailing])
                SecureField("Enter password", text: $loginPassword)
                    .frame(height: 55)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                    .padding()
                
                if !errorMessage.isEmpty {
                    HStack {
                        Spacer()
                        Text(_: errorMessage)
                            .foregroundColor(Color.red)
                        Spacer()
                    }
                    .padding()
                }
                
                if isLogging {
                    HStack {
                        Spacer()
                        Text("Please wait...")
                        Spacer()
                    }
                    .padding()
                }
                
                if !isLogging {
                    HStack {
                        Spacer()
                        Button("LOGIN") {
                            doLogin()
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10.0)
                        .foregroundColor(Color.white)
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Button("Create Account") {
                            showCreateAccountPage = true
                        }.sheet(isPresented: $showCreateAccountPage, content: {
                            WebBrowserView(url: .constant(
                                Globals.getWebViewURL(page: "onboard.php"))
                            )
                        })
                        Spacer()
                        Button("Password reset") {
                            showPasswordResetPage = true
                        }.sheet(isPresented: $showPasswordResetPage, content: {
                            WebBrowserView(
                                url: .constant(
                                    Globals.getWebViewURL(page: "password_reset.php"))
                            )
                        })
                    }
                    .padding()
                }
                
                Spacer()
            }
        } else {
            DashboardView()
        }
    }
    
    func doLogin() {
        print("inside do login")
        isLogging = true
        errorMessage = ""
        
        let validate = validateInputs()
        if validate != "ok" {
            errorMessage = validate
            isLogging = false
            return
        }
        
        print("login validation is correct")
        
        guard let url = URL(string: Globals.API_URL) else {
            isLogging = false;
            errorMessage = "Cannot connect to server"
            return
        }
        
        print("url is created")
        
        let request = createRequest(url: url)
        
        print("request is created")
        
        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                isLogging = false;
                errorMessage = "No response"
                return
            }
            do {
                print("received login response")
                // handling response
                let response = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                guard let result = response as? [String:Any] else {
                    isLogging = false;
                    errorMessage = "Response parsing failed"
                    return
                }
                
                
                // is response ok?
                if let status_code = result["status_code"] {
                    if status_code as! Int != 200 {
                        if let response_message = result["response_message"] {
                            isLogging = false;
                            errorMessage = response_message as! String
                            return
                        }
                    }
                }
                
                // response is okay
                // saving user data
                //if let id = result["id"] {
                  //  Globals.saveData(key: Globals.USER_ID_KEY, value: String(id as! Int))
                //}
                
                if let id = result["id"] as? Int {
                    Globals.saveData(key: Globals.USER_ID_KEY, value: String(id))
                } else {
                    print("Error: id is not an Int")
                }

                
                if let user_token = result["user_token"] {
                    Globals.saveData(key: Globals.USER_TOKEN_KEY, value: user_token as! String)
                }
                
                if let name = result["name"] {
                    Globals.saveData(key: Globals.USER_NAME_KEY, value: name as! String)
                }
                
                if let is_approved = result["is_approved"] {
                    Globals.saveData(key: Globals.IS_APPROVED_KEY, value: String(is_approved as! Int))
                }
                
                if let is_reporting_manager = result["is_reporting_manager"] {
                    Globals.saveData(
                        key: Globals.IS_REPORTING_MANAGER_KEY,
                        value: String(is_reporting_manager as! Int))
                }
                
                Globals.saveData(key: Globals.IS_LOGGED_IN_KEY, value: "1")
                print("saving logged in data")
                Globals.printAllKeyData()
                
                isLoggedIn = "1"
            } catch {
                print(error)
                isLogging = false
                errorMessage = "Network error"
            }
            
        }
        
        task.resume()
        
        isLogging = false
        
    }
    
    func validateInputs() -> String {
        if mobile.isEmpty {
            return "Enter mobile number"
        }
        
        if loginPassword.isEmpty {
            return "Enter password"
        }
        
        if mobile.count != 10 {
            return "Enter valid 10 digit mobile number"
        }
        
        if loginPassword.count < 3 {
            return "Invalid password"
        }
        
        return "ok"
    }
    
    func createRequest(url: URL) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "mobile": mobile,
            "password": loginPassword,
            "action": "login"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        return request
    }
}

#Preview {
    LoginView()
}
