//
//  PagesController.swift
//  AdForest
//
//  Created by apple on 6/1/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import WebKit
import NVActivityIndicatorView
import WebKit

class PagesController: UIViewController, NVActivityIndicatorViewable, WKUIDelegate , WKNavigationDelegate {

    //MARK:- Outlets
    
    
@IBOutlet weak var webView: WKWebView! {
    didSet{
        
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.clear
    }
    }
    
    //MARK:- Properties
    var delegate :leftMenuProtocol?
    var page_id = 0
    var type = ""
    var pageUrl = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"
        self.addBackButtonToNavigationBar()
        self.googleAnalytics(controllerName: "Pages Controller")
        if type == "simple" {
            let param:[String: Any] = ["page_id": page_id]
            print(param)
            self.adForest_pagesData(param: param as NSDictionary)
        } else if type == "simple" || type != "simple" {
           // guard let userEmail = UserDefaults.standard.string(forKey: "email") else {return}
            //guard let userPassword = UserDefaults.standard.string(forKey: "password") else {return}

            let userEmail = UserDefaults.standard.string(forKey: "email")
            let userPassword = UserDefaults.standard.string(forKey: "password")
            
            let emailPass = "\(userEmail):\(userPassword)"
            let encodedString = emailPass.data(using: String.Encoding.utf8)!
            let base64String = encodedString.base64EncodedString(options: [])
            print(base64String)
            let url = URL(string: pageUrl)
            var request = URLRequest(url: url!)
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            request.setValue("body", forHTTPHeaderField: "Adforest-Shop-Request")
            if UserDefaults.standard.bool(forKey: "isSocial") {
                request.setValue("social", forHTTPHeaderField: "AdForest-Login-Type")
            }
            self.webView.load(request)
        }
    }
    
    //MARK:- Custom
   
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
    //MARK:- API Call
    func adForest_pagesData(param: NSDictionary) {
        self.showLoader()
        UserHandler.termsConditions(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
               
                
                if let htmlString = successResponse.data.pageContent {
                     self.title = successResponse.data.pageTitle
                    self.webView.loadHTMLString(htmlString, baseURL: nil)
                }
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
}
