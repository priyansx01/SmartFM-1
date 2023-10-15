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
    
    var body: some View {
        if(!isLoggedIn) {
            LoginView()
        } else {
            
            NavigationView {
                
                ScrollView {
                    VStack(alignment: .leading) {
                        DashboardLink(title: "Employee Details", page: "user_details.php")
                        DashboardLink(title: "Employee Self Service", page: "payslip.php")
                        DashboardLink(title: "Uniform Size", page: "uniform_size.php")
                        // Induction and training
                        // Attendance
                        NavigationLink {
                            AttendanceView()
                        } label: {
                            DashboardLinkTitle(title: "Attendance")
                        }
                        DashboardLink(title: "Attendance Report", page: "attendance_report.php")
                        DashboardLink(title: "Assets", page: "add_asset.php")
                        DashboardLink(title: "ESIC Form", page: "esic.php")
                        DashboardLink(title: "Compliance and Audit", page: "compliance.php")
                        DashboardLink(title: "Apply Leave", page: "add_leave.php")
                        DashboardLink(title: "Conveyance", page: "add_conveyance.php")
                        DashboardLink(title: "Approvals", page: "approvals.php")
                        
                        
                        // Logout
                        NavigationLink {
                            LogoutView()
                        } label: {
                            DashboardLinkTitle(title: "Logout")
                        }
                        Spacer()
                    } //Vstack
                    .navigationTitle("Dashboard")
                }// Scrollview
                
            }// navigation view
        }// else
    } // body
    
}

struct DashboardLinkTitle: View {
    var title :String
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "arrowshape.right.fill")
                .foregroundColor(Color.black)
            Text(title.uppercased())
                .foregroundColor(Color.black)
                .bold()
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
        .shadow(radius:40)    }
}

struct DashboardLink: View {
    
    var title :String
    var page :String
    
    var body: some View {
        NavigationLink {
            WebBrowserView(url: .constant(Globals.getWebViewURL(page: page)))
        } label: {
            DashboardLinkTitle(title: title)
        }
    }
    
}

struct LogoutView: View {
    @State private var isLoggedIn = Globals.isLoggedIn()
    var body: some View {
        if !isLoggedIn {
            ContentView()
        } else {
            VStack {
                Text("Confirm Logout?")
                Button("Yes") {
                    Globals.resetData()
                    isLoggedIn = Globals.isLoggedIn()
                }
                
            }
        }
    }
}

/**
NavigationLink {
    if !isLoggedIn {
        ContentView()
    }
} label: {
    DashboardLinkTitle(title: "Logout")
}
.onTapGesture {
    Globals.resetData()
    isLoggedIn.toggle()
}
**/
