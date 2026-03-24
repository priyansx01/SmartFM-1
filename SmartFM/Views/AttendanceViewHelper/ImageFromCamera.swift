//
//  ImageFromCamera.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 16/10/23.
//

import Foundation
import SwiftUI

struct ImageFromCamera: View {
    @State private var imageSelected = UIImage()
    @State private var showSheet = false
    @State public var changeProfileImage = false
    @State var openCameraRoll = false
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            Button(action: {
                openCameraRoll = true
                changeProfileImage = true
            }, label: {
                if changeProfileImage {
                    Image(uiImage: imageSelected)
                        .profileImageMod()
                } else {
                    Image("user")
                        .profileImageMod()
                }
            })
            
            Image(systemName: "plus")
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .background(Color.gray)
            
        }.sheet(isPresented: $openCameraRoll) {
            ImagePicker(selectedImage: $imageSelected, sourceType: .camera)
            
        }
    }
}

extension Image {
    
    func profileImageMod() -> some View {
        self
            .resizable()
            .frame(width: 120, height: 120)
    }
    
}
