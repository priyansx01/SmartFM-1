//
//  DashboardView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @State private var isLoggedIn : Bool = Globals.isLoggedIn()
    
    // Grabs the user's name from the saved login data to display a greeting
    @AppStorage(Globals.USER_NAME_KEY) private var userName: String = ""
    
    var body: some View {
        if(!isLoggedIn) {
            LoginView()
        } else {
            NavigationView {
                ZStack {
                    // Modern iOS Dashboard Background
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Welcome Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back,")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(userName.isEmpty ? "Employee" : userName)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Dashboard Cards
                            VStack(spacing: 12) {
                                
                                // Native Views
                                NavigationLink { InductionAndTrainingView() } label: {
                                    DashboardRowCard(title: "Induction and Training", iconName: "graduationcap.fill", iconColor: .orange)
                                }
                                
                                NavigationLink { AttendanceView() } label: {
                                    DashboardRowCard(title: "Attendance", iconName: "clock.fill", iconColor: .green)
                                }
                                
                                // Web Views
                                DashboardLink(title: "Employee Details", page: "user_details.php", iconName: "person.crop.rectangle.fill", iconColor: .blue)

                                DashboardLink(title: "Employee Self Service", page: "payslip.php", iconName: "dollarsign.circle.fill", iconColor: Color(UIColor.systemTeal))

                                DashboardLink(title: "Uniform Size", page: "uniform_size.php", iconName: "tshirt.fill", iconColor: .purple)

                                DashboardLink(title: "Attendance Report", page: "attendance_report.php", iconName: "doc.text.magnifyingglass", iconColor: .green)

                                DashboardLink(title: "Assets", page: "add_asset.php", iconName: "archivebox.fill", iconColor: Color(UIColor.systemBrown))

                                DashboardLink(title: "ESIC Form", page: "esic.php", iconName: "cross.case.fill", iconColor: .red)

                                DashboardLink(title: "Compliance and Audit", page: "compliance.php", iconName: "checkmark.shield.fill", iconColor: Color(UIColor.systemIndigo))

                                DashboardLink(title: "Apply Leave", page: "add_leave.php", iconName: "calendar.badge.minus", iconColor: .pink)

                                DashboardLink(title: "Conveyance", page: "add_conveyance.php", iconName: "car.fill", iconColor: .blue)

                                DashboardLink(title: "Approvals", page: "approvals.php", iconName: "checkmark.seal.fill", iconColor: .orange)
                                
                                // Logout
                                NavigationLink { LogoutView() } label: {
                                    DashboardRowCard(title: "Logout", iconName: "arrow.right.circle.fill", iconColor: .red)
                                }
                                
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                }
                .navigationTitle("Dashboard")
            }
        }
    }
}

// MARK: - Reusable UI Components

// 1. The Modernized Card View
struct DashboardRowCard: View {
    var title: String
    var iconName: String
    var iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Tinted Icon Box
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 45, height: 45)
                .background(iconColor.opacity(0.15))
                .cornerRadius(12)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Subtle Chevron indicating it's clickable
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// 2. Updated Dashboard Link Wrapper
struct DashboardLink: View {
    var title: String
    var page: String
    var iconName: String
    var iconColor: Color
    
    var body: some View {
        NavigationLink {
            WebBrowserView(url: .constant(Globals.getWebViewURL(page: page)))
        } label: {
            DashboardRowCard(title: title, iconName: iconName, iconColor: iconColor)
        }
    }
}

// MARK: - Logout View
struct LogoutView: View {
    @State private var isLoggedIn = Globals.isLoggedIn()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if !isLoggedIn {
            ContentView()
        } else {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Confirm Logout?")
                    .font(.title2)
                    .bold()
                
                Text("Are you sure you want to sign out of your account?")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .foregroundColor(.primary)
                    
                    Button("Sign Out") {
                        Globals.resetData()
                        isLoggedIn = Globals.isLoggedIn()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

// Ensure Xcode preview works
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
