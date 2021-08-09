//
//  ViewController.swift
//  Foodticket
//
//  Created by Niels Marsman on 22/07/2021.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])
        webView.uiDelegate = self
        
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
        
        if let wrapperUrl = Bundle.main.url(forResource: "foodticketWrapper", withExtension: "js") {
            if let source = try? String(contentsOf: wrapperUrl, encoding: .utf8) {
                let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                contentController.addUserScript(script)
            }
            
            // Note: Normally it would be sufficient to do something like: webView.load(URLRequest(url: URL(string: "https://foodticket.nl/")))
            if let indexUrl = Bundle.main.url(forResource: "index", withExtension: "html") {
                if let source = try? String(contentsOf: indexUrl, encoding: .utf8) {
                    webView.loadHTMLString(source, baseURL: indexUrl)
                }
            }
        }
    }
    
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let controller = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in completionHandler() })
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let toggled = message.body as? Bool else {
            return
        }
        
        let message = toggled ? "Toggle Switch could be on" : "Toggle Switch is off";
        webView.evaluateJavaScript("window.nativeAPI.checkBoxCallback(\"\(message)\")")
    }
}
