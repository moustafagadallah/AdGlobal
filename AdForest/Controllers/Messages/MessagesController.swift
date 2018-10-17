//
//  MessagesController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SlideMenuControllerSwift

class MessagesController: UIViewController {

    var delegate: leftMenuProtocol?
    var isFromAdDetail = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleAnalytics(controllerName: "Messages Controller")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateMessageTitle), object: nil, queue: nil) { (notification) in
            self.title = UserHandler.sharedInstance.messagesTitle
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromAdDetail {
            self.showBackButton()
        }
        else {
              self.addBackButtonToNavigationBar()
        }
    }
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
}
