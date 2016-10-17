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
    var src: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create WKWebView in code, because IB cannot add a WKWebView directly
        webView = WKWebView()
        view.addSubview(webView!)
      
        webView?.bindFrameToSuperviewBounds()
        
        // 2 ways to load webpage: `loadHTML()` or `loadURL()`   
        
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        //loadURL()
    }
    
    func loadURL(withUrl src: String = "http://google.com") {
        LOG.debug("TAB AT CREATED \(src)")
        self.src = src
        guard let url = URL(string: src) else {return}
        let request = NSMutableURLRequest(url:url)
        webView?.load(request as URLRequest)
    }
    
    func reload() {
        if let src = self.src {
            LOG.debug("LOADING WEB \(src)")

            guard let url = URL(string: src) else {return}
            let request = NSMutableURLRequest(url:url)
            webView?.load(request as URLRequest)
        }
       
    }
}
