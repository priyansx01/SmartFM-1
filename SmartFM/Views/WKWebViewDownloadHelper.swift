//
//  WKWebViewDownloadHelper.swift
//  WkWebViewTest
//
//  Created by Gualtiero Frigerio on 03/07/2020.
//  Copyright © 2020 Gualtiero Frigerio. All rights reserved.
//

// OLD implementation
// The helper is now distributed as SPM

import Foundation
import WebKit

struct MimeType {
    var type:String
    var fileExtension:String
}

protocol WKWebViewDownloadHelperDelegate {
    func fileDownloadedAtURL(url:URL)
}

class WKWebviewDownloadHelper:NSObject {
    
    var webView:WKWebView
    var mimeTypes:[MimeType]
    var delegate:WKWebViewDownloadHelperDelegate
    
    init(webView:WKWebView, mimeTypes:[MimeType], delegate:WKWebViewDownloadHelperDelegate) {
        self.webView = webView
        self.mimeTypes = mimeTypes
        self.delegate = delegate
        super.init()
        webView.navigationDelegate = self
    }
    
    private var fileDestinationURL: URL?
    
    private func downloadData(fromURL url:URL,
                              fileName:String,
                              completion:@escaping (Bool, URL?) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
            let session = URLSession.shared
            session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
            let task = session.downloadTask(with: url) { localURL, urlResponse, error in
                if let localURL = localURL {
                    let destinationURL = self.moveDownloadedFile(url: localURL, fileName: fileName)
                    completion(true, destinationURL)
                }
                else {
                    completion(false, nil)
                }
            }

            task.resume()
        }
    }
    
    private func getDefaultFileName(forMimeType mimeType:String) -> String {
        for record in self.mimeTypes {
            if mimeType.contains(record.type) {
                return "default." + record.fileExtension
            }
        }
        return "default"
    }
    
    private func getFileNameFromResponse(_ response:URLResponse) -> String? {
        if let httpResponse = response as? HTTPURLResponse {
            let headers = httpResponse.allHeaderFields
            if let disposition = headers["Content-Disposition"] as? String {
                let components = disposition.components(separatedBy: " ")
                if components.count > 1 {
                    let innerComponents = components[1].components(separatedBy: "=")
                    if innerComponents.count > 1 {
                        if innerComponents[0].contains("filename") {
                            return innerComponents[1]
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func isMimeTypeConfigured(_ mimeType:String) -> Bool {
        for record in self.mimeTypes {
            if mimeType.contains(record.type) {
                return true
            }
        }
        return false
    }
    
    private func moveDownloadedFile(url:URL, fileName:String) -> URL {
        let tempDir = NSTemporaryDirectory()
        let destinationPath = tempDir + fileName
        let destinationURL = URL(fileURLWithPath: destinationPath)
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.moveItem(at: url, to: destinationURL)
        return destinationURL
    }
}

extension WKWebviewDownloadHelper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let mimeType = navigationResponse.response.mimeType {
            if isMimeTypeConfigured(mimeType) {
                if let url = navigationResponse.response.url {
                    if #available(iOS 14.5, *) {
                        decisionHandler(.download)
                    } else {
                        var fileName = getDefaultFileName(forMimeType: mimeType)
                        if let name = getFileNameFromResponse(navigationResponse.response) {
                            fileName = name
                        }
                        downloadData(fromURL: url, fileName: fileName) { success, destinationURL in
                            if success, let destinationURL = destinationURL {
                                self.delegate.fileDownloadedAtURL(url: destinationURL)
                            }
                        }
                        decisionHandler(.cancel)
                    }
                    return
                }
            }
        }
        decisionHandler(.allow)
    }

    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        print(" navigationresponse didbecome download ")
        download.delegate = self
    }
}

@available(iOS 14.5, *)
extension WKWebviewDownloadHelper: WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let temporaryDir = NSTemporaryDirectory()
        let fileName = temporaryDir + "/" + suggestedFilename
        let url = URL(fileURLWithPath: fileName)
        fileDestinationURL = url
        completionHandler(url)
    }
    
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("download failed \(error)")
    }
    
    func downloadDidFinish(_ download: WKDownload) {
        print("download finish")
        if let url = fileDestinationURL {
            self.delegate.fileDownloadedAtURL(url: url)
        }
    }
}


/// Delegate object for ``WKDownloadHelper``
///
/// The delegate receives information about file downloaded by the helper
/// as long as errors during a download. It is also possible to prevent an URL to be opened by implementing ``canNavigate(toUrl:)``. The default implementation always return true
public protocol WKDownloadHelperDelegate {
    /// Optional funtion that is called whenever a new URL is about to be opened
    ///
    /// Implement this function if you want more control over the link opened in the WKWebView
    /// Since the helper become the WKNavigationDelegate you lose control of that aspect and this method
    /// allow you to at least prevent some URL to be opened in your WKWebView
    /// - Parameter toUrl: the URL about to be opened by the web view
    /// - Returns: true if the URL can be opened
    func canNavigate(toUrl: URL) -> Bool
    
    /// Mandatory function, called when a file has been successfully downloaded at the given local URL
    /// - Parameter atUrl: local URL of the downloaded file
    func didDownloadFile(atUrl: URL)
    
    /// Called in case of error while downloading a file
    /// - Parameter error: the Error occurred while downloading the file
    func didFailDownloadingFile(error: Error)
    
    
    /// Provide a local url path where the file will be downloaded
    /// - Returns: An optional url of the file
    func localURLForFile(withName: String) -> URL?
}

/// default implementation of optional methods
extension WKDownloadHelperDelegate {
    public func canNavigate(toUrl: URL) -> Bool {
        true
    }
    
    public func didFailDownloadingFile(error: Error) {
        
    }
    
    /// The default implementation saves the file in the temporary directory
    /// inside a rando UUID directory to avoid conflicts of file names
    public func localURLForFile(withName name: String) -> URL? {
        let temporaryDir = NSTemporaryDirectory()
        var url = URL(fileURLWithPath: temporaryDir)
        url = url.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        }
        catch {
            return nil
        }
        url = url.appendingPathComponent(name)
        return url
    }
}
