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
        
        // Used to load index.html and javascript.
        let base = URL(fileURLWithPath: #file).deletingLastPathComponent()
        
        // Note: Normally this would be packaged into this project and it would be sufficient
        // to do something like: if let url = Bundle.main.url(forResource: "foodticket-ios", withExtension: "js") {
        let javascript = URL(fileURLWithPath: "../../foodticket-web/foodticket.js", relativeTo: base)
        if let source = try? String(contentsOf: javascript, encoding: .utf8) {
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            contentController.addUserScript(script)
        }
        
        // Note: Normally it would be sufficient to do something like: webView.load(URLRequest(url: URL(string: "https://foodticket.nl/")))
        // This is used to load the index.html used for both Android and iOS
        let html = URL(fileURLWithPath: "../../foodticket-web/index.html", relativeTo: base)
        if let source = try? String(contentsOf: html, encoding: .utf8) {
            webView.loadHTMLString(source, baseURL: html)
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
        guard let message = message.body as? String else {
            return
        }
        
        webView.evaluateJavaScript("document.getElementById('value').innerText = \"\(message)\"") { (result, error) in
            if let result = result {
                print("Label is updated with message: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }
    }
}
