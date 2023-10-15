//
//  WebBrowserView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import Foundation
import WebKit
import SwiftUI

struct WebBrowserView: View {
    @Binding var url: String
    
    var body: some View {
        VStack {
            MyWebView(url: URL(string: url)!)
        }
    }
}

struct MyWebView: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> some WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        var request = URLRequest(url: url)
        uiView.load(request)
    }
}
