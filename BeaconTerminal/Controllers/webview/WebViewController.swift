//
//  WebViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 10/7/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController,  WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create WKWebView in code, because IB cannot add a WKWebView directly
        webView = WKWebView()
        view.addSubview(webView!)
      
        webView?.bindFrameToSuperviewBounds()
        
        // 2 ways to load webpage: `loadHTML()` or `loadURL()`   
        
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        loadURL()
    }
    
    func loadURL() {
        let urlString = "http://cnn.com"
        guard let url = URL(string: urlString) else {return}
        let request = NSMutableURLRequest(url:url)
        webView?.load(request as URLRequest)
    }
}
