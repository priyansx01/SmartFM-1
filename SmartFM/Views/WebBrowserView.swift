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
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> some WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        func fileDownloadedAtURL(url: URL) {
            
        }
        
        let parent: MyWebView
        
        
        init(parent: MyWebView) {
            self.parent = parent
        }
        
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
                print(navigationResponse.response.mimeType!)
                print("allowing from nav response canShowMIMEType")
            } else {
                if #available(iOS 14.5, *) {
                    decisionHandler(.download)
                    print("downloading from nav response canShowMIMEType")
                } else {
                    print("download decision not supported canShowMIMEType")
                }
            }
        }
        
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if #available(iOS 14.5, *) {
                if navigationAction.shouldPerformDownload {
                    print("navigation action perform download")
                    decisionHandler(.download)
                    //print("fetching download url")
                    //let downloadUrl = navigationAction.request.url
                    //UIApplication.shared.open(downloadUrl ?? parent.url)
                    //print("downloadUrl", "\(String(describing: downloadUrl))", "shouldPerformDownload")

                } else {
                    
                    print("cannot download so going nav from navaction. allowing form nav action shouldPerformDownload")
                    let pdfurl = navigationAction.request.url!
                    let pathExtention = pdfurl.pathExtension
                    if(pathExtention == "pdf") {
                        UIApplication.shared.open(pdfurl)
                        print("trying to dowload file")
                        decisionHandler(.cancel)
                    }
                    else {
                        decisionHandler(.allow)
                    }
                    
                    
                }
            } else {
                print("download not supported shouldPerformDownload")
            }
            
        }
         
        
        
    }
}
 
