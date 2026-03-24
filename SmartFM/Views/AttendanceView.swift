//
//  AttendanceView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

//1. Load Geo fencing data
//2. Load google map with current location
//3. Show fencing overlap or "Outside premises"
//4. Show name
//5. get and show date
//6. get and show time
//7. get longdate
//8. Ability to upload picture
//9. Load check in/out status
//10. Validate before check in/out
//11. reset image after check in/out

import Foundation
import SwiftUI
import GoogleMaps

struct AttendanceView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var locationManager = LocationManager()
    //@State var currentCheckValue :String = AttendanceController.getCurrentCheckValue()
    @State var currentCheckValue :String = ""
    @State var status :String = ""
    @State var isMarking :Bool = false
    @State var changeProfilePicture :Bool = false;
    @State var currentSiteName = AttendanceController.geoFenceSiteName.siteName
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    @State var zoomInCenter: Bool = false
    
    var body: some View {
        
        let marker = currentMarker()
        
        VStack {
            
            // google map
            MapViewControllerBridge(
                markers: .constant([marker]),
                selectedMarker: .constant(marker),
                onAnimationEnded: {},
                mapViewWillMove: {_ in }
            )
            
            .onAppear {
                Task {
                    // This is called when navigating back to this view
                    currentCheckValue = await AttendanceController.getCurrentCheckValue()
                    print("AttendanceView appeared. Refreshed currentCheckValue = \(currentCheckValue)")
                }
            }
            .padding()
            
            Text(AttendanceController.geoFenceSiteName.siteName)
                .padding()
            
            Spacer()
            
            
            HStack {
                VStack {
                    Text(Globals.getUserName())
                    
                    Text(currentDate())
                    Text(currentTime())
                    
                }//Vstack
                .padding()
                
                Spacer()
                
                ImageFromCamera(changeProfileImage: changeProfilePicture)
                
            }//Hstack
            .padding()
            
            if !isMarking {
                Button(currentCheckValue) {
                    
                    saveAttendance()
                    Task {
                        await Globals.initailizeCheckInDataFromServer()
                        currentCheckValue = await AttendanceController.getCurrentCheckValue()
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10.0)
                .foregroundColor(Color.white)
                
                Spacer()
            }
            
            if !status.isEmpty {
                Text(status)
                Spacer()
            }
            
        }// vstack
    } // body
        
    
    func currentMarker() -> GMSMarker {
        let latitude = locationManager.lastLocation?.coordinate.latitude ?? 0
        let longitude = locationManager.lastLocation?.coordinate.longitude ?? 0
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print("currentMarker", "\(position)")
        AttendanceController.latitude = "\(latitude)"
        AttendanceController.longitude = "\(longitude)"
        AttendanceController.getCurrentSiteName()
        currentSiteName = AttendanceController.geoFenceSiteName.siteName
        
        return GMSMarker(position: position)
    }
    
    func currentDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy"
        let currentDate = dateFormatter.string(from: date)
        AttendanceController.currentDate = currentDate
        
        return currentDate
    }
    
    func currentTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        let currentTime = dateFormatter.string(from: date)
        AttendanceController.currentTime = currentTime
        return currentTime
    }
    
    func toggleCheckInOutValue() {
        let v = Globals.getData(key: Globals.CHECK_IN_OUT_KEY)
        var newv = "1"
        
        if v.isEmpty {
            newv = "1"
        }
        
        if v == "0" {
            newv = "1"
        }
        
        if v == "1" {
            newv = "0"
        }
        
        Globals.saveData(key: Globals.CHECK_IN_OUT_KEY, value: newv)
        
        //AttendanceController.markAttendance()

    }
    
    func saveAttendance() {
        status = "Saving..."
        isMarking = true;
        if AttendanceController.selectedImage?.size.width ?? 0.0 < 1 {
            status = "Change image"
            isMarking = false
            return
        }
        AttendanceController.markAttendance()
        toggleCheckInOutValue()
        status = "Saved"
        isMarking = false
        changeProfilePicture = false
        
    }
}
