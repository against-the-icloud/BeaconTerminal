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
import Material

class WebViewController: UIViewController,  WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?
    var src: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create WKWebView in code, because IB cannot add a WKWebView directly
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame:self.view.frame, configuration: configuration)
        view.addSubview(webView!)
      
        webView?.bindFrameToSuperviewBounds()
        
        // 2 ways to load webpage: `loadHTML()` or `loadURL()`   
        
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        
        
        let addButton = FabButton()
        addButton.image = #imageLiteral(resourceName: "refresh")
        addButton.tintColor = Color.white
        addButton.backgroundColor = Color.blue.base
        
        
        /// Menu bottom inset.
        
        let rightInset = UIScreen.main.bounds.width - (24 + 75)
        
     
        addButton.frame = CGRect(x: rightInset, y: 15, width: 65, height: 65)
        addButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)
        webView?.addSubview(addButton)
    }
    
    internal func reloadPage(button: Any?) {
        loadAddress()
    }
    
    func loadAddress() {
        if self.src != nil {
            guard let url = URL(string: src!) else {return}
            let request = NSMutableURLRequest(url:url)
            webView?.load(request as URLRequest)
        }
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LOG.debug("Did fail \(error)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LOG.debug("Did did finish")

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.webView?.setNeedsLayout()
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.modalPresentationStyle = .formSheet
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.modalPresentationStyle = .formSheet
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }}
