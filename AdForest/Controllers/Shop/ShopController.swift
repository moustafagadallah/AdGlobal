//
//  ShopController.swift
//  AdForest
//
//  Created by Apple on 7/12/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import DropDown

class ShopController: UIViewController, UIWebViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var webView: UIWebView!{
        didSet {
            webView.delegate =  self
            webView.isOpaque = false
            webView.backgroundColor = UIColor.clear
        }
    }
    
    //MARK:- Properties
    let cartButton = UIButton(type: .custom)
    let defaults = UserDefaults.standard
    var delegate :leftMenuProtocol?
    var titleArray = [String]()
    var urlArray = [String]()
    
    var shopDropDown = DropDown()
    lazy var dropDown: [DropDown] = {
        return [
            self.shopDropDown
        ]
    }()
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let shopTitle = defaults.string(forKey: "shopTitle") {
            self.title = shopTitle
        }
        self.populateShopData()
        self.addBackButtonToNavigationBar()
        self.googleAnalytics(controllerName: "ShopController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let userEmail = UserDefaults.standard.string(forKey: "email") else {return}
        guard let userPassword = UserDefaults.standard.string(forKey: "password") else {return}
        guard let shopUrl = defaults.string(forKey: "shopUrl") else {return}
        
        let emailPass = "\(userEmail):\(userPassword)"
        let encodedString = emailPass.data(using: String.Encoding.utf8)!
        let base64String = encodedString.base64EncodedString(options: [])
        print(base64String)
        let url = URL(string: shopUrl)
        var request = URLRequest(url: url!)
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.setValue("body", forHTTPHeaderField: "Adforest-Shop-Request")
        if UserDefaults.standard.bool(forKey: "isSocial") {
            request.setValue("social", forHTTPHeaderField: "AdForest-Login-Type")
        }
        self.webView.loadRequest(request)
    
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            var userEmail = ""
            var userPassword = ""
            if let email = defaults.string(forKey: "email") {
                userEmail = email
            }
            if let password = defaults.string(forKey: "password") {
                userPassword = password
            }
            let emailPass = "\(userEmail):\(userPassword)"
            let encodedString = emailPass.data(using: String.Encoding.utf8)!
            let base64String = encodedString.base64EncodedString(options: [])
            print(base64String)
            var urlRequest = request
            urlRequest.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("body", forHTTPHeaderField: "Adforest-Shop-Request")
            if UserDefaults.standard.bool(forKey: "isSocial") {
                urlRequest.setValue("social", forHTTPHeaderField: "AdForest-Login-Type")
            }
            self.webView.loadRequest(urlRequest)
            return true
        }
        return true
    }
    
    //MARK:- Custom
    func addBackButtonToNavigationBar() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if UserDefaults.standard.bool(forKey: "isRtl") {
            backButton.setBackgroundImage(#imageLiteral(resourceName: "arabicBackButton"), for: .normal)
        } else {
            backButton.setBackgroundImage(#imageLiteral(resourceName: "backbutton"), for: .normal)
        }
        backButton.addTarget(self, action: #selector(moveToParentController), for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
    
    func populateShopData() {
        if let userInfo = defaults.object(forKey: "settings") {
            let objUser = NSKeyedUnarchiver.unarchiveObject(with: userInfo as! Data) as! [String: Any]
            let userModel = SettingsRoot(fromDictionary: objUser)
            for items in userModel.data.shopMenu {
                if items.url == "" {
                    continue
                }
                self.titleArray.append(items.title)
                self.urlArray.append(items.url)
            }
        }
        self.dropDownData()
        self.ShopButton()
    }
    
    func ShopButton() {
        if #available(iOS 11, *) {
            cartButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            cartButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            cartButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        cartButton.addTarget(self, action: #selector(onClickShop), for: .touchUpInside)
        let cartImage = UIImage(named: "arrowDown")
        let tintImage = cartImage?.withRenderingMode(.alwaysTemplate)
        cartButton.setImage(tintImage , for: .normal)
        cartButton.tintColor = UIColor.white
        let barButton = UIBarButtonItem(customView: cartButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func onClickShop() {
       self.shopDropDown.show()
    }
    
    func dropDownData() {
        shopDropDown.anchorView = cartButton
        shopDropDown.dataSource = titleArray
        shopDropDown.selectionAction = { [unowned self] (index, item) in
            self.cartButton.setTitle(item, for: .normal)
            let selectedURL = self.urlArray[index]
            guard let userEmail = UserDefaults.standard.string(forKey: "email") else {return}
            guard let userPassword = UserDefaults.standard.string(forKey: "password") else {return}

            let emailPass = "\(userEmail):\(userPassword)"
            let encodedString = emailPass.data(using: String.Encoding.utf8)!
            let base64String = encodedString.base64EncodedString(options: [])
            print(base64String)
            let url = URL(string: selectedURL)
            var request = URLRequest(url: url!)
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            request.setValue("body", forHTTPHeaderField: "Adforest-Shop-Request")
            if UserDefaults.standard.bool(forKey: "isSocial") {
                request.setValue("social", forHTTPHeaderField: "AdForest-Login-Type")
            }
            self.webView.loadRequest(request)
        }
    }
}
