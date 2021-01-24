//
//  WebView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 21/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//  Based on https://stackoverflow.com/questions/59382225/how-to-implement-wkuidelegate-into-swiftui-wkwebview
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let request: URLRequest
    var webView: WKWebView?

    init(req: URLRequest) {
        self.webView = WKWebView()
        self.webView?.configuration.preferences.minimumFontSize = 24.0
        self.request = req
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Delegate methods go here

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            switch navigationAction.navigationType {

            case .linkActivated:
                let url = navigationAction.request.url
                if url != nil {
                    UIApplication.shared.open(url!)
                }
                decisionHandler(.cancel)

            default:
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            // alert functionality goes here
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView  {
        return webView!
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        uiView.navigationDelegate = context.coordinator
        uiView.load(request)
    }

    func goBack(){
        webView?.goBack()
    }

    func goForward(){
        webView?.goForward()
    }

    func reload(){
        webView?.reload()
    }
}


// MARK:  -

struct ASALocalHTMLView: View {
    var fileName: String

    var body: some View {
        let fileURL = Bundle.main.url(forResource: fileName, withExtension: "html")

        if fileURL == nil {
            EmptyView()
        } else {
            WebView(req: URLRequest(url: fileURL!))
                .padding(8.0)
        }
    }
}


// MARK:  -

struct ASALinkToLocalHTMLView:  View {
    var text:  String
    var fileName: String

    var body: some View {
        NavigationLink(destination:
                        ASALocalHTMLView(fileName:  fileName)
        ) {
            Text(NSLocalizedString(text, comment: ""))
        }
    }
}
