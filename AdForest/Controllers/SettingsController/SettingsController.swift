//
//  SettingsController.swift
//  AdForest
//
//  Created by Apple on 9/24/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import StoreKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .singleLineEtched
            tableView.register(UINib(nibName: "AboutAppCell", bundle: nil), forCellReuseIdentifier: "AboutAppCell")
            tableView.register(UINib(nibName: "AppShareCell", bundle: nil), forCellReuseIdentifier: "AppShareCell")
            tableView.register(UINib(nibName: "CategoryDetailCell", bundle: nil), forCellReuseIdentifier: "CategoryDetailCell")
        }
    }
    
    //MARK:- Properties
    var delegate :leftMenuProtocol?
    var objData : AppSettingData?
    
    var isShowAboutApp = false
    var isShowAppVersion = false
    var isShowAppRating = false
    var isShowAppShare = false
    var isShowFeedback = false
    var isShowFaq = false
    var isShowTerms = false
    var isShowPrivacyPolicy = false
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBackButtonToNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adForest_getAppData()
    }

    //MARK:- Custom
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func appStorerating(appStoreID: String) {
        let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(appStoreID)?mt=8&action=write-review")!
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                print("Open \(url): \(success)")
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK:- Table View Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0 :
            if isShowAboutApp {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutAppCell", for: indexPath) as! AboutAppCell
                if let title = objData?.about.title {
                    cell.lblAbout.text = title
                }
                if let desc = objData?.about.desc {
                    cell.lblDetail.text = desc
                }
                return cell
            }
        case 1:
            if isShowAppVersion {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutAppCell", for: indexPath) as! AboutAppCell
                
                if let title = objData?.appVersion.title {
                    cell.lblAbout.text = title
                }
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    cell.lblDetail.text = version
                }
                return cell
            }
        case 2:
            if isShowAppRating {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppShareCell", for: indexPath) as! AppShareCell
                if let rating = objData?.appRating.title {
                    cell.lblName.text = rating
                }
                cell.imgPicture.image = UIImage(named: "star")
                return cell
            }
        case 3:
            if isShowAppShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppShareCell", for: indexPath) as! AppShareCell
                if let share = objData?.appShare.title {
                    cell.lblName.text = share
                }
                cell.imgPicture.image = UIImage(named: "shareIcon")
                return cell
            }
        case 4:
            if isShowFeedback {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutAppCell", for: indexPath) as! AboutAppCell
                if let faqs = objData?.feedback.title {
                    cell.lblAbout.text = faqs
                }
                if let detail = objData?.feedback.subline {
                    cell.lblDetail.text = detail
                }
                return cell
            }
        case 5:
            if isShowFaq {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryDetailCell", for: indexPath) as! CategoryDetailCell
                if let faqs = objData?.faqs.title {
                    cell.lblName.text = faqs
                }
                return cell
            }
        case 6:
            if isShowTerms {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryDetailCell", for: indexPath) as! CategoryDetailCell
                if let termsConditions = objData?.tandc.title {
                    cell.lblName.text = termsConditions
                }
                return cell
            }
        case 7:
            if isShowPrivacyPolicy {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryDetailCell", for: indexPath) as! CategoryDetailCell
                if let privacyPolicy = objData?.privacyPolicy.title {
                    cell.lblName.text = privacyPolicy
                }
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section {
        case 2:
            guard let appID = objData?.appRating.url else {return}
            self.appStorerating(appStoreID: appID)
        case 3:
            guard let shareText = objData?.appShare.text else {return}
            guard let shareUrl = objData?.appShare.url else {return}
            
            let shareVC = UIActivityViewController(activityItems: [shareText, shareUrl], applicationActivities: nil)
            shareVC.popoverPresentationController?.sourceView = self.view
            self.presentVC(shareVC)
        case 4:
           let feedbackVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackController") as! FeedbackController
           feedbackVC.formData = objData?.feedback.form
           feedbackVC.modalPresentationStyle = .overCurrentContext
           if let feedbackTitle = objData?.feedback.title {
            feedbackVC.feedbackTitle = feedbackTitle
           }
           view.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
           UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.view.transform = .identity
           }) { (success) in
              self.presentVC(feedbackVC)
           }
        case 5:
            if let url = URL(string: (objData?.faqs.url)!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 6:
            if let url = URL(string: (objData?.tandc.url)!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 7:
            if let url = URL(string: (objData?.privacyPolicy.url)!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch  section {
        case 0:
            if isShowAboutApp {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        case 1:
            if isShowAppVersion {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        case 2:
            if isShowAppRating {
                return 50
            } else {
                return 0
            }
        case 3:
            if isShowAppShare {
                return 50
            } else {
                return 0
            }
        case 4:
            if isShowFeedback {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        case 5:
            if isShowFaq {
                return 45
            } else {
                return 0
            }
        case 6:
            if isShowTerms {
                return 45
            } else {
                return 0
            }
        case 7:
            if isShowPrivacyPolicy {
                return 45
            } else {
                return 0
            }
        default:
            return 0
        }
    }
  
    
    //MARK:- API Calls
    func adForest_getAppData() {
        self.showLoader()
        UserHandler.appSettings(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                self.isShowAboutApp = successResponse.data.about.isShow
                self.isShowAppVersion = successResponse.data.appVersion.isShow
                self.isShowAppRating = successResponse.data.appRating.isShow
                self.isShowAppShare = successResponse.data.appShare.isShow
                self.isShowFeedback = successResponse.data.feedback.isShow
                self.isShowFaq = successResponse.data.faqs.isShow
                self.isShowTerms = successResponse.data.tandc.isShow
                self.isShowPrivacyPolicy = successResponse.data.privacyPolicy.isShow
                self.objData = successResponse.data
                self.tableView.reloadData()
            } else {
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
