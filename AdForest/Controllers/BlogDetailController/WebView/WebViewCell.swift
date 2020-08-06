//
//  WebViewCell.swift
//  AdForest
//
//  Created by apple on 3/14/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import WebKit

class WebViewCell: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView! {
        didSet {
              webView.isOpaque = false
            webView.navigationDelegate = self
        }
    }
    @IBOutlet weak var heightWebView: NSLayoutConstraint!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //to set webview size with amount of data
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(.zero)
    }
 
    
}
