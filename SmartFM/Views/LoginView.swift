import Foundation
import SwiftUI

struct LoginView: View {
    @State private var mobile: String = ""
    @State private var loginPassword: String = ""
    @State private var showCreateAccountPage: Bool = false
    @State private var showPasswordResetPage: Bool = false
    @State private var isLogging: Bool = false
    @State private var errorMessage: String = ""
    
    @AppStorage(Globals.IS_LOGGED_IN_KEY) private var isLoggedIn: String = ""

    var body: some View {
        if(isLoggedIn != "1") {
            NavigationView {
                ZStack {
                    // Background
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 25) {
                        Spacer()
                        
                        // Logo Header
                        Image("ismart_logo2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 10)
                        
                        // Input Fields
                        VStack(spacing: 16) {
                            // Mobile Field
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                TextField("Enter Mobile Number", text: $mobile)
                                    .keyboardType(.decimalPad)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .frame(height: 55)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Password Field
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                SecureField("Enter password", text: $loginPassword)
                            }
                            .padding()
                            .frame(height: 55)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(Font.footnote.weight(.semibold)) // iOS 14 Compatible
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Login Button
                        Button(action: {
                            doLogin()
                        }) {
                            HStack {
                                if isLogging {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Please wait...")
                                        .padding(.leading, 5)
                                } else {
                                    Text("LOGIN")
                                        .font(Font.headline.weight(.semibold)) // iOS 14 Compatible
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                isLogging ? Color.gray : Color.blue
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .disabled(isLogging)
                        
                        Spacer()
                        
                        // Footer Links
                        HStack {
                            Button("Create Account") {
                                showCreateAccountPage = true
                            }
                            .font(Font.subheadline.weight(.semibold)) // iOS 14 Compatible
                            .foregroundColor(.blue)
                            .sheet(isPresented: $showCreateAccountPage, content: {
                                WebBrowserView(url: .constant(Globals.getWebViewURL(page: "onboard.php")))
                            })
                            
                            Spacer()
                            
                            Button("Password reset") {
                                showPasswordResetPage = true
                            }
                            .font(Font.subheadline.weight(.semibold)) // iOS 14 Compatible
                            .foregroundColor(.gray)
                            .sheet(isPresented: $showPasswordResetPage, content: {
                                WebBrowserView(url: .constant(Globals.getWebViewURL(page: "password_reset.php")))
                            })
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                    .padding()
                }
                .navigationBarHidden(true)
            }
        } else {
            DashboardView()
        }
    }
    
    // MARK: - Functions
    
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
            isLogging = false
            errorMessage = "Cannot connect to server"
            return
        }
        
        let request = createRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLogging = false
                
                guard let data = data, error == nil else {
                    self.errorMessage = "No response"
                    return
                }
                
                do {
                    print("received login response")
                    let response = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    
                    guard let result = response as? [String:Any] else {
                        self.errorMessage = "Response parsing failed"
                        return
                    }
                    
                    if let status_code = result["status_code"] as? Int, status_code != 200 {
                        if let response_message = result["response_message"] as? String {
                            self.errorMessage = response_message
                            return
                        }
                    }
                    
                    if let id = result["id"] as? Int {
                        Globals.saveData(key: Globals.USER_ID_KEY, value: String(id))
                    } else {
                        print("Error: id is not an Int")
                    }
                    
                    if let user_token = result["user_token"] as? String {
                        Globals.saveData(key: Globals.USER_TOKEN_KEY, value: user_token)
                    }
                    
                    if let name = result["name"] as? String {
                        Globals.saveData(key: Globals.USER_NAME_KEY, value: name)
                    }
                    
                    if let is_approved = result["is_approved"] as? Int {
                        Globals.saveData(key: Globals.IS_APPROVED_KEY, value: String(is_approved))
                    }
                    
                    if let is_reporting_manager = result["is_reporting_manager"] as? Int {
                        Globals.saveData(key: Globals.IS_REPORTING_MANAGER_KEY, value: String(is_reporting_manager))
                    }
                    
                    Globals.saveData(key: Globals.IS_LOGGED_IN_KEY, value: "1")
                    print("saving logged in data")
                    
                    // Silences the "unused result" warning
                    _ = Globals.printAllKeyData()
                    
                    self.isLoggedIn = "1"
                    
                } catch {
                    print(error)
                    self.errorMessage = "Network error"
                }
            }
        }
        
        task.resume()
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
