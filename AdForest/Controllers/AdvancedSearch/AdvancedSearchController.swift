//
//  AdvancedSearchController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView
import DropDown
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import Alamofire
import RangeSeekSlider

class AdvancedSearchController: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
            tableView.register(UINib(nibName: "SearchNowButtonCell", bundle: nil), forCellReuseIdentifier: "SearchNowButtonCell")
        }
    }
    
    //MARK:- Properties
    var delegate :leftMenuProtocol?
    var dataArray = [SearchData]()
    
    var data = [SearchData]()
    var addInfoDictionary = [String: Any]()
    var customDictionary = [String: Any]()
    var newArray = [SearchData]()
    var dynamicArray = [SearchData]()
    
    var searchTitle = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshButton()
        self.addBackButtonToNavigationBar()
        self.adForest_getSearchData()
        self.adMob()
        self.googleAnalytics(controllerName: "Advanced Search Controller")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.searchDynamicData), object: nil, queue: nil) { (notification) in
            self.dataArray = self.newArray
            self.dynamicArray = AddsHandler.sharedInstance.objSearchArray
            self.dataArray.insert(contentsOf: AddsHandler.sharedInstance.objSearchArray, at: 2)
            self.tableView.reloadData()
        }
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
    
    func adMob() {
        if UserHandler.sharedInstance.objAdMob != nil {
            let objData = UserHandler.sharedInstance.objAdMob
            var isShowAd = false
            if let adShow = objData?.show {
                isShowAd = adShow
            }
            if isShowAd {
                var isShowBanner = false
                var isShowInterstital = false
                if let banner = objData?.isShowBanner {
                    isShowBanner = banner
                }
                if let intersitial = objData?.isShowInitial {
                    isShowInterstital = intersitial
                }
                if isShowBanner {
                    SwiftyAd.shared.setup(withBannerID: (objData?.bannerId)!, interstitialID: "", rewardedVideoID: "")
                    self.tableView.translatesAutoresizingMaskIntoConstraints = false
                    if objData?.position == "top" {
                        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .top)
                    }
                    else {
                        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 60).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .bottom)
                    }
                }
                if isShowInterstital {
                    SwiftyAd.shared.setup(withBannerID: "", interstitialID: (objData?.interstitalId)!, rewardedVideoID: "")
                    SwiftyAd.shared.showInterstitial(from: self)
                }
            }
        }
    }
    
    
    func refreshButton() {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        if #available(iOS 11, *) {
            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        else {
            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        }
        button.addTarget(self, action: #selector(onClickRefreshButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func onClickRefreshButton() {
        self.adForest_getSearchData()
    }
    
    //Set Up parameters to Sent to Server
    func setUpData() {
        let dataToSend = data
        for (_, value) in dataToSend.enumerated() {
            if value.fieldVal == "" {
                continue
            }
            if newArray.contains(where: { $0.fieldTypeName == value.fieldTypeName}) {
                addInfoDictionary[value.fieldTypeName] = value.fieldVal
                print(addInfoDictionary)
            } else {
                customDictionary[value.fieldTypeName] = value.fieldVal
                print(customDictionary)
            }
        }

        let custom = Constants.json(from: customDictionary)
        var param: [String: Any] = ["custom_fields": custom ?? ""]
        param.merge(with: addInfoDictionary)
      
        self.adForest_postData(parameter: param as NSDictionary)
    }
    
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let objData = dataArray[indexPath.row]
            if objData.fieldType == "select" {
                let cell: SearchDropDown = tableView.dequeueReusableCell(withIdentifier: "SearchDropDown", for: indexPath) as! SearchDropDown
                
                if let title = objData.title {
                    cell.lblName.text = title
                }
                
                var i = 1
                for item in objData.values {
                    if item.id == "" {
                        continue
                    }
                    if i == 1 {
                        cell.oltPopup.setTitle(item.name, for: .normal)
                    }
                    i = i + 1
                }
                cell.btnPopupAction = { () in
                    cell.dropDownKeysArray = []
                    cell.dropDownValuesArray = []
                    cell.fieldTypeName = []
                    cell.hasSubArray = []
                    cell.hasTemplateArray = []
                    cell.hasCategoryTempelateArray = []
                    
                    for item in objData.values {
                        if item.id == "" {
                            continue
                        }
                        cell.dropDownKeysArray.append(item.id)
                        cell.dropDownValuesArray.append(item.name)
                        cell.fieldTypeName.append(objData.fieldTypeName)
                        cell.hasSubArray.append(item.hasSub)
                        cell.hasTemplateArray.append(item.hasTemplate)
                        cell.hasCategoryTempelateArray.append(objData.hasCatTemplate)
                    }
                    cell.accountDropDown()
                    cell.valueDropDown.show()
                }
                return cell
            }
            else if objData.fieldType == "radio" {
                let cell: RadioButtonCell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonCell", for: indexPath) as! RadioButtonCell
                
                if let title = objData.title {
                    cell.lblTitle.text = title
                }
                cell.dataArray = objData.values
                cell.tableView.reloadData()
                return cell
            }
                
            else if objData.fieldType == "textfield" {
                let cell: SearchTextField = tableView.dequeueReusableCell(withIdentifier: "SearchTextField", for: indexPath) as! SearchTextField
                
                if let txtTitle = objData.title {
                    cell.txtType.placeholder = txtTitle
                }
                if let fieldValue = objData.fieldVal {
                    cell.txtType.text = fieldValue
                }
                cell.fieldName = objData.fieldTypeName
                return cell
            }
                
            else if objData.fieldType == "range_textfield" {
                let cell : SearchTwoTextField = tableView.dequeueReusableCell(withIdentifier: "SearchTwoTextField", for: indexPath) as! SearchTwoTextField
                
                if let title = objData.title {
                    cell.lblMin.text = title
                }
                if let minTitle = objData.data[0].title {
                    cell.txtMinPrice.placeholder = minTitle
                }
                if let maxTitle = objData.data[1].title {
                    cell.txtmaxPrice.placeholder = maxTitle
                }
                cell.fieldName = objData.fieldTypeName
                return cell
            }
                
            else if objData.fieldType == "glocation_textfield" {
                let cell: SearchAutoCompleteTextField = tableView.dequeueReusableCell(withIdentifier: "SearchAutoCompleteTextField", for: indexPath) as! SearchAutoCompleteTextField
                
                if let txtTitle = objData.title {
                    cell.txtAutoComplete.placeholder = txtTitle
                }
                
                if let fieldValue = objData.fieldVal {
                    cell.txtAutoComplete.text = fieldValue
                }
                cell.fieldName = objData.fieldTypeName
                return cell
            }
            else if objData.fieldType == "seekbar" {
                let cell: SeekBar = tableView.dequeueReusableCell(withIdentifier: "SeekBar", for: indexPath) as! SeekBar
                if let title = objData.title {
                    cell.lblTitle.text = title
                }
                cell.fieldName = objData.fieldTypeName
                
                return cell
            }
            else if objData.fieldType == "textfield_date" {
                let cell: CalendarCell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
                if let title = objData.title {
                    cell.oltDate.setTitle(title, for: .normal)
                }
                return cell
            }
            
        case 1:
            let cell: SearchNowButtonCell = tableView.dequeueReusableCell(withIdentifier: "SearchNowButtonCell", for: indexPath) as! SearchNowButtonCell
            
            cell.oltSearchNow.isHidden = false
            cell.oltSearchNow.setTitle(self.searchTitle, for: .normal)
            
            cell.btnSearchNow = { () in
                for index in 0..<self.dataArray.count {
                    if let objData = self.dataArray[index] as? SearchData {
                        if objData.fieldType == "select" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchDropDown {
                                var obj = SearchData()
                                
                                obj.fieldTypeName = cell.param
                                obj.fieldVal = cell.selectedKey
                                obj.fieldType = "select"
                                self.data.append(obj)
                            }
                        }
                        if objData.fieldType == "textfield" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchTextField {
                                var obj = SearchData()
                                
                                obj.fieldType = "textfield"
                                obj.fieldVal = cell.txtType.text
                                obj.fieldTypeName = cell.fieldName
                                self.data.append(obj)
                            }
                        }
                        
                        if objData.fieldType == "range_textfield" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchTwoTextField {
                                var obj = SearchData()
                                
                                obj.fieldType = "range_textfield"
                                obj.fieldTypeName = cell.fieldName
                                guard let minTF = cell.txtMinPrice.text else {
                                    return
                                }
                                guard let maxTF = cell.txtmaxPrice.text else {
                                    return
                                }
                                let rangeTF = minTF + "-" + maxTF
                                obj.fieldVal = rangeTF
                                self.data.append(obj)
                            }
                        }
                        
                        if objData.fieldType == "glocation_textfield" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchAutoCompleteTextField {
                                var obj = SearchData()
                                
                                obj.fieldType = "glocation_textfield"
                                obj.fieldTypeName = cell.fieldName
                                obj.fieldVal = cell.txtAutoComplete.text
                                self.data.append(obj)
                            }
                        }
                        
                        if objData.fieldType == "seekbar" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SeekBar {
                                var obj = SearchData()
                                
                                obj.fieldType = "seekbar"
                                obj.fieldTypeName = cell.fieldName
                                obj.fieldVal = String(cell.maximumValue)
                                self.data.append(obj)
                            }
                        }
                        if objData.fieldType == "textfield_date" {
                            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CalendarCell {
                                var obj = SearchData()
                                obj.fieldType = "textfield_date"
                                obj.fieldTypeName = cell.fieldName
                                obj.fieldVal = cell.currentDate
                                self.data.append(obj)
                            }
                        }
                    }
                }
                self.setUpData()
            }
            
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let objData = dataArray[indexPath.row]
            if objData.fieldType == "radio" {
                return 120
            }
            return 80
        case 1:
            return 50
        default:
            return 50
        }
    }
    //MARK:- API Calls
    
    func adForest_getSearchData() {
        self.showLoader()
        AddsHandler.advanceSearch(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.extra.title
                self.dataArray = successResponse.data
                self.newArray = successResponse.data
                self.searchTitle = successResponse.extra.searchBtn
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
    
    //post data to search
    func adForest_postData(parameter : NSDictionary) {
        self.showLoader()
        AddsHandler.searchData(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                AddsHandler.sharedInstance.objCategoryArray = successResponse.data.ads
                AddsHandler.sharedInstance.objCategotyAdArray = successResponse.data.featuredAds.ads
                categoryVC.isFromAdvanceSearch = true
                categoryVC.featureAddTitle = successResponse.data.featuredAds.text
                categoryVC.addcategoryTitle = successResponse.topbar.countAds
                categoryVC.currentPage = successResponse.pagination.currentPage
                categoryVC.maximumPage = successResponse.pagination.maxNumPages
                categoryVC.title = successResponse.extra.title
                self.navigationController?.pushViewController(categoryVC, animated: true)
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
