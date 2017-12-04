//
//  ViewController.swift
//  FlowReader
//
//  Created by Aydar Mukhametzyanov on 12/3/17.
//  Copyright © 2017 Aydar Mukhametzyanov. All rights reserved.
//

import UIKit
import WebKit

class FlowWebViewController: UIViewController {
    
    private let startUrl = "http://lukoshko.net/storyList/skazki-pushkina.htm"
    private let timeUnit: TimeInterval = 0.1
    private let defaultVelocityKey = "kFRVelocityKey"
    
    private var velocity: Float = 1.0
    private var isScrolling = false
    private var willResignActiveObserver: Any?
    
    @IBOutlet private weak var toggleFlowButton: UIBarButtonItem!
    @IBOutlet private weak var speedUpButton: UIBarButtonItem!
    @IBOutlet private weak var slowDownButton: UIBarButtonItem!
    @IBOutlet private weak var goBackButton: UIBarButtonItem!
    @IBOutlet private weak var goForwardButton: UIBarButtonItem!
    @IBOutlet private weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FlowReader"
        
        willResignActiveObserver = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive,
                                                                          object: nil,
                                                                          queue: nil) { [weak self] _ in
                                                                            self?.stopScrollingIfNeeded()
        }
        
        resetVelocity()
        webView.load(URLRequest(url: URL(string: startUrl)!))
    }
    
    deinit {
        if let willResignActiveObserver = willResignActiveObserver {
            NotificationCenter.default.removeObserver(willResignActiveObserver)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
        stopScrollingIfNeeded()
    }
    
    private func scrollContentIfNeeded() {
        guard isScrolling else {
            return
        }
        
        guard webView.scrollView.contentSize.height > (webView.scrollView.bounds.height + webView.scrollView.contentOffset.y) else {
            toggleScrolling()
            return
        }
        
        var offset = webView.scrollView.contentOffset
        offset.y += CGFloat(velocity)
        UIView.animate(withDuration: timeUnit,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: { [weak self] in
                        self?.webView.scrollView.contentOffset = offset
        }) { [weak self] _ in
            self?.scrollContentIfNeeded()
        }
    }
    
    private func resetVelocity() {
        let defaultVelocity = UserDefaults.standard.float(forKey: defaultVelocityKey)
        if defaultVelocity == 0 {
            velocity = 1
        } else {
            velocity = defaultVelocity
        }
    }
    
    private func toggleScrolling() {
        isScrolling = !isScrolling
        toggleFlowButton.title = isScrolling ? "Stop" : "Start"
        
        scrollContentIfNeeded()
    }
    
    private func stopScrollingIfNeeded() {
        if isScrolling {
            toggleScrolling()
        }
    }
    
    // MARK - Actions
    
    @IBAction func togglePressed(_ sender: Any) {
        toggleScrolling()
    }
    
    @IBAction func speedUpPressed(_ sender: Any) {
        velocity *= 1.1
    }
    
    @IBAction func slowDownPressed(_ sender: Any) {
        velocity /= 1.1
    }
    
    @IBAction func resetVelocityPressed(_ sender: Any) {
        resetVelocity()
    }
    
    @IBAction func saveVelocityPressed(_ sender: Any) {
        UserDefaults.standard.set(velocity, forKey: defaultVelocityKey)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        if webView.canGoBack {
            stopScrollingIfNeeded()
            webView.goBack()
        }
    }
    
    @IBAction func goForwardPressed(_ sender: Any) {
        if webView.canGoForward {
            stopScrollingIfNeeded()
            webView.goForward()
        }
    }
}

