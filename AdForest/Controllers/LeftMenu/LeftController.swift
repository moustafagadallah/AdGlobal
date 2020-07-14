//
//  LeftController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView
import Firebase
import FirebaseMessaging

enum leftMenues : Int {
    case main
}

enum pageMenu: Int {
    case detailPage
}

enum GuestMenu: Int {
    case main = 1
    case advancedSearch
    case packages
    case login
    case register
}
//Guest Package Hide
enum HideGuestPackage: Int {
    case main = 1
    case advancedSearch
    case login
    case register
}

enum OtherGuestMenues: Int {
    case blog = 1
    case settings
}

enum OtherMenues: Int {
    case blog
    case settings
    case logout
}

enum leftMenuLangSetting : Int {
    case language
}

protocol leftMenuProtocol {
    func changeViewController(_ menu : leftMenues)
}

protocol guestMenuProtocol {
    func changeGuestController(_ menu : GuestMenu)
}

//Pages Protocol
protocol changePagesProtocol {
    func changePage(_ menu : pageMenu)
}

protocol changeOtherMenuesProtocol {
    func changeMenu(_ other: OtherMenues )
}

protocol changeOtherGuestProtocol {
    func changeGuestMenu(_ other: OtherGuestMenues)
}

protocol leftMenuLangProtocol : class {
    func changeViewControllerLang(_ menu: leftMenuLangSetting)
}

class LeftController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable , changeOtherMenuesProtocol , guestMenuProtocol, changeOtherGuestProtocol, changePagesProtocol, leftMenuProtocol,leftMenuLangProtocol {
   

    //MARK:- Outlets
    @IBOutlet weak var imgProfilePicture: UIImageView! {
        didSet {
            imgProfilePicture.round()
        }
    }
    
    @IBOutlet weak var containerViewImage: UIView! 
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorColor = UIColor.darkGray
            tableView.separatorStyle = .singleLineEtched
        }
    }
    
    //MARK:- Properties
    
    var menuLangText = UserDefaults.standard.string(forKey: "meuText")
    var defaults = UserDefaults.standard
    var guestImagesArray = [UIImage(named: "home"), UIImage(named: "search-magnifier"), UIImage(named: "packages"), UIImage(named: "logout")]
    var othersArrayImages = [#imageLiteral(resourceName: "blog"),#imageLiteral(resourceName: "settings") , #imageLiteral(resourceName: "logout")]
    var guestOtherArray = [#imageLiteral(resourceName: "blog"), #imageLiteral(resourceName: "settings")]
    var msgPkgArray = [#imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "profile"), #imageLiteral(resourceName: "search-magnifier"), #imageLiteral(resourceName: "myads"), #imageLiteral(resourceName: "inactiveads"), #imageLiteral(resourceName: "featuredAds"), #imageLiteral(resourceName: "favourite")]
    var guestHideImagesArray = [#imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "search-magnifier"), #imageLiteral(resourceName: "logout")]
    
    var viewHome: UIViewController!
    var viewProfile: UIViewController!
    var viewAdvancedSearch: UIViewController!
    var viewMessages: UIViewController!
    var viewPackages: UIViewController!
    var viewMyAds: UIViewController!
    var viewInactiveAds: UIViewController!
    var viewFeaturedAds: UIViewController!
    var viewFavAds: UIViewController!
    var viewShop: UIViewController!
    var viewSeller: UIViewController!
    
    var viewLogin: UIViewController!
    var viewRegister: UIViewController!
    
    // Pages Controller
    var viewPages: UIViewController!
    
    //Other Menues
    var viewBlog : UIViewController!
    var viewSettings: UIViewController!
    var viewlogout: UIViewController!
    var langController: UIViewController!
    
    //MARK:- Application Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleAnalytics(controllerName: "Left Controller")
        if defaults.bool(forKey: "isLogin") == false {
            self.initializeGuestViews()
            self.initializeOtherGuestViews()
        } else {
            self.initializeViews()
            self.initializeOtherViews()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateUserProfile), object: nil, queue: nil) { (notification) in
            self.adForest_populateData()
        }
        
        self.langView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adForest_populateData()
    }

    //MARK:- custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if let mainColor = defaults.string(forKey: "mainColor") {
            self.containerViewImage.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        if defaults.bool(forKey: "isLogin") == false {
            if let settingsInfo = defaults.object(forKey: "settings") {
               let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
                let model = SettingsRoot(fromDictionary: settingObject)
                if let imgUrl = URL(string: model.data.guestImage) {
                    self.imgProfilePicture.sd_setImage(with: imgUrl, completed: nil)
                    self.imgProfilePicture.sd_setShowActivityIndicatorView(true)
                    self.imgProfilePicture.sd_setIndicatorStyle(.gray)
                }
                if let name = model.data.guestName {
                    self.lblName.text = name
                }
            }
        }
        else {
            if let userInfo = defaults.object(forKey: "userData") {
                let objUser = NSKeyedUnarchiver.unarchiveObject(with: userInfo as! Data) as! [String: Any]
                let userModel = UserRegisterRoot(fromDictionary: objUser)
               
                if userModel.data.profileImg != nil{
                    if let imgUrl = URL(string: userModel.data.profileImg) {
                        self.imgProfilePicture.sd_setShowActivityIndicatorView(true)
                        self.imgProfilePicture.sd_setIndicatorStyle(.gray)
                        self.imgProfilePicture.sd_setImage(with: imgUrl, completed: nil)
                    }
                }
                if let name = userModel.data.displayName {
                    self.lblName.text = name
                }
                if let email = userModel.data.userEmail {
                    self.lblEmail.text = email
                }
            }
        }
    }
    
    //MARK:- Change Controller When click on side menu
    func changeViewController(controllerName: String) {
        switch controllerName.lowercased() {
        case "home":
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        case "profile":
            self.slideMenuController()?.changeMainViewController(self.viewProfile, close: true)
        case "search":
            self.slideMenuController()?.changeMainViewController(self.viewAdvancedSearch, close: true)
        case "messages" :
            self.slideMenuController()?.changeMainViewController(self.viewMessages, close: true)
        case "my_ads":
            self.slideMenuController()?.changeMainViewController(self.viewMyAds, close: true)
        case "inactive_ads":
            self.slideMenuController()?.changeMainViewController(self.viewInactiveAds, close: true)
        case "featured_ads":
            self.slideMenuController()?.changeMainViewController(self.viewFeaturedAds, close: true)
        case    "fav_ads":
            self.slideMenuController()?.changeMainViewController(self.viewFavAds, close: true)
        case    "packages":
            self.slideMenuController()?.changeMainViewController(self.viewPackages, close: true)
        case    "shop":
            self.slideMenuController()?.changeMainViewController(self.viewShop, close: true)
        case   "sellers":
            self.slideMenuController()?.changeMainViewController(self.viewSeller, close: true)
        default:
            break
        }
    }
    
    func changeViewController(_ menu: leftMenues) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        }
    }
 
    func changePage(_ menu: pageMenu) {
        switch menu {
        case .detailPage:
            self.slideMenuController()?.changeMainViewController(self.viewPages, close: true)
        }
    }
    
    func changeGuestController(_ menu: GuestMenu) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        case .advancedSearch:
            self.slideMenuController()?.changeMainViewController(self.viewAdvancedSearch, close: true)
        case .packages:
            self.slideMenuController()?.changeMainViewController(self.viewPackages, close: true)
        case .login:
            self.slideMenuController()?.changeMainViewController(self.viewLogin, close: true)
        case .register:
            self.slideMenuController()?.changeMainViewController(self.viewRegister, close: true)
        }
    }
    
    func changeViewControllerLang(_ menu: leftMenuLangSetting) {
        switch menu {
        case .language:
            self.slideMenuController()?.changeMainViewController(self.langController, close: true)
            
        }
    }
    
    
    
    //MARK:- Hide Guest Package
    func hideGuestController(_ menu: HideGuestPackage) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        case .advancedSearch:
            self.slideMenuController()?.changeMainViewController(self.viewAdvancedSearch, close: true)
        case .login:
            self.slideMenuController()?.changeMainViewController(self.viewLogin, close: true)
        case .register:
            self.slideMenuController()?.changeMainViewController(self.viewRegister, close: true)
        }
    }

    //MARK:- For Side Menu Pages
    func initializePagesView(pageID: Int, type: String, pageUrl: String) {
        let pagesView = storyboard?.instantiateViewController(withIdentifier: "PagesController") as! PagesController
        pagesView.delegate = self
        pagesView.page_id = pageID
        pagesView.type = type
        pagesView.pageUrl = pageUrl
        self.viewPages = UINavigationController(rootViewController: pagesView)
    }
    
    fileprivate func initializeViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let profileView = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
        self.viewProfile = UINavigationController(rootViewController: profileView)
        
        let searchView = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchController") as! AdvancedSearchController
        searchView.delegate = self
        self.viewAdvancedSearch = UINavigationController(rootViewController: searchView)
        
        let messagesView = storyboard?.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
        messagesView.menuDelegate = self
        self.viewMessages = UINavigationController(rootViewController: messagesView)
        
        let packageView = storyboard?.instantiateViewController(withIdentifier: "PackagesController") as! PackagesController
        self.viewPackages = UINavigationController(rootViewController: packageView)

        let myAdsView = storyboard?.instantiateViewController(withIdentifier: "MyAdsController") as! MyAdsController
        self.viewMyAds = UINavigationController(rootViewController: myAdsView)
        
        let inactiveAdsView = storyboard?.instantiateViewController(withIdentifier: "InactiveAdsController") as! InactiveAdsController
        self.viewInactiveAds = UINavigationController(rootViewController: inactiveAdsView)
        
        let featuredAdsView = storyboard?.instantiateViewController(withIdentifier: "FeaturedAdsController") as! FeaturedAdsController
        self.viewFeaturedAds = UINavigationController(rootViewController: featuredAdsView)
        
        let favAdsView = storyboard?.instantiateViewController(withIdentifier: "FavouriteAdsController") as! FavouriteAdsController
        self.viewFavAds = UINavigationController(rootViewController: favAdsView)
        
        let shopView = storyboard?.instantiateViewController(withIdentifier: "ShopController") as! ShopController
        shopView.delegate = self
        self.viewShop = UINavigationController(rootViewController: shopView)
        
        let sellerView = storyboard?.instantiateViewController(withIdentifier: "SellersController") as! SellersController
        self.viewSeller = UINavigationController(rootViewController: sellerView)
    }

    //MARK:- For Guest Pages
    func initializeGuestViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let searchView = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchController") as! AdvancedSearchController
        searchView.delegate = self
        self.viewAdvancedSearch = UINavigationController(rootViewController: searchView)
        
        let packageView = storyboard?.instantiateViewController(withIdentifier: "PackagesController") as! PackagesController
        self.viewPackages = UINavigationController(rootViewController: packageView)
        
        let loginView = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.viewLogin = UINavigationController(rootViewController: loginView)
        
        let registerView = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.viewRegister = UINavigationController(rootViewController: registerView)
    }
    
    func initializeGuestHiddenViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let searchView = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchController") as! AdvancedSearchController
        searchView.delegate = self
        self.viewAdvancedSearch = UINavigationController(rootViewController: searchView)

        let loginView = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.viewLogin = UINavigationController(rootViewController: loginView)
        
        let registerView = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.viewRegister = UINavigationController(rootViewController: registerView)
    }
    
    func initializeOtherViews() {
        let blogView = self.storyboard?.instantiateViewController(withIdentifier: "BlogController") as! BlogController
        self.viewBlog = UINavigationController(rootViewController: blogView)
        
        let settingsView = self.storyboard?.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
        settingsView.delegate = self
        self.viewSettings = UINavigationController(rootViewController: settingsView)
    }
    
    func initializeOtherGuestViews() {
        let blogView = self.storyboard?.instantiateViewController(withIdentifier: "BlogController") as! BlogController
        self.viewBlog = UINavigationController(rootViewController: blogView)
        
        let settingsView = self.storyboard?.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
        settingsView.delegate = self
        self.viewSettings = UINavigationController(rootViewController: settingsView)
    }
    
    func initializeOthersettingLangViewa() {
        let langView = self.storyboard?.instantiateViewController(withIdentifier: "LangViewController") as! LangViewController
        self.langController = UINavigationController(rootViewController: langView)
    }
    
    func langView(){
        let langView = self.storyboard?.instantiateViewController(withIdentifier: "LangViewController") as! LangViewController
        self.langController = UINavigationController(rootViewController: langView)
    }
    
    //Change Other Views
    func changeMenu(_ other: OtherMenues) {
        switch other {
        case .blog :
            self.slideMenuController()?.changeMainViewController(self.viewBlog, close: true)
        case .settings:
            self.slideMenuController()?.changeMainViewController(self.viewSettings, close: true)
        case .logout :
            self.logoutUser()
        }
    }
    
    // change others guest menu
    func changeGuestMenu(_ other: OtherGuestMenues) {
        switch other {
        case .blog:
             self.slideMenuController()?.changeMainViewController(self.viewBlog, close: true)
        case .settings:
             self.slideMenuController()?.changeMainViewController(self.viewSettings, close: true)
        }
    }
    
    //MARK-: Logout user
    func logoutUser() {
        let param: [String: Any] = ["firebase_id": ""]
        self.showLoader()
        AddsHandler.sendFirebaseToken(parameter: param as NSDictionary, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Messaging.messaging().shouldEstablishDirectChannel = false
                    Messaging.messaging().unsubscribe(fromTopic: "global")
                    self.defaults.set(false, forKey: "isLogin")
                    self.defaults.set(false, forKey: "isGuest")
                    self.defaults.set(false, forKey: "isSocial")
                    FacebookAuthentication.signOut()
                    GoogleAuthenctication.signOut()
                    self.appDelegate.moveToLogin()
                    //self.appDelegate.moveToHome()()
                    self.stopAnimating()
                }
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
    //MARK:- Table View Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        let settingArr = UserDefaults.standard.array(forKey: "setArr")
        if section == 0 {
            if defaults.bool(forKey: "isLogin") == false {
                if (UserHandler.sharedInstance.objSettings?.menu.isShowMenu.packageField)! == false {
                    value = 3
                } else {
                    value = 4
                }
            } else {
                return  UserHandler.sharedInstance.menuValuesArray.count
            }
        }
        else if section == 1 {
            if UserHandler.sharedInstance.objSettingsMenu.isEmpty {
                value = 0
            }
            value = UserHandler.sharedInstance.objSettingsMenu.count
        }
        else if section == 2 {
            if defaults.bool(forKey: "isLogin") == false {
                print(settingArr!.count)
                return (settingArr?.count)!
            }
            if (UserHandler.sharedInstance.objSettings?.menu.isShowMenu.blog)! {
                value = 3
            }
            else {
                value = 2
            }
        }
        else if section == 3{
            value = 1
        }
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LeftMenuCell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell", for: indexPath) as! LeftMenuCell
        let section = indexPath.section
        let row = indexPath.row
        let objData = UserHandler.sharedInstance.objSettings
        
        if section == 0 {
            if defaults.bool(forKey: "isLogin") == false {
                var isShowPackage = false
                if let isPackage = objData?.menu.isShowMenu.packageField {
                    isShowPackage = isPackage
                }
                if isShowPackage {
                    cell.imgPicture.image = guestImagesArray[indexPath.row]
                    if row == 0 {
                        cell.lblName.text = objData?.menu.home
                    }
                    else if row == 1 {
                        cell.lblName.text = objData?.menu.search
                    }
                    else if row == 2 {
                        cell.lblName.text = objData?.menu.packages
                    }
                    else if row == 3 {
                        cell.lblName.text = objData?.menu.login
                    }
                }
                else {
                    cell.imgPicture.image = guestHideImagesArray[indexPath.row]
                    if row == 0 {
                        cell.lblName.text = objData?.menu.home
                    }
                    else if row == 1 {
                        cell.lblName.text = objData?.menu.search
                    }
                    else if row == 2 {
                        cell.lblName.text = objData?.menu.login
                    }
                }
            }
            else {
                let objData =  UserHandler.sharedInstance.menuValuesArray[indexPath.row]
                let img = UserHandler.sharedInstance.menuKeysArray[indexPath.row]
                cell.lblName.text = objData
                print(objData)
                
                switch img.lowercased() {
                case "home" :
                    cell.imgPicture.image = #imageLiteral(resourceName: "home")
                case "profile":
                    cell.imgPicture.image = #imageLiteral(resourceName: "profile")
                case   "search":
                    cell.imgPicture.image = #imageLiteral(resourceName: "search-magnifier")
                case   "messages":
                    cell.imgPicture.image = #imageLiteral(resourceName: "msg")
                case   "my_ads":
                    cell.imgPicture.image = #imageLiteral(resourceName: "myads")
                case   "inactive_ads":
                    cell.imgPicture.image = #imageLiteral(resourceName: "inactiveads")
                case   "featured_ads":
                    cell.imgPicture.image = #imageLiteral(resourceName: "featuredAds")
                case "fav_ads":
                    cell.imgPicture.image = #imageLiteral(resourceName: "favourite")
                case "packages":
                    cell.imgPicture.image = #imageLiteral(resourceName: "packages")
                case   "shop":
                    cell.imgPicture.image = #imageLiteral(resourceName: "shopping")
                case   "sellers":
                    cell.imgPicture.image = #imageLiteral(resourceName: "seller")
                default:
                    break
                }
            }
        }
        else if section == 1 {
            let objPages = UserHandler.sharedInstance.objSettingsMenu[indexPath.row]
            cell.lblName.text = objPages.pageTitle
            if let imgUrl = URL(string: objPages.url) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
        }
            
        else if section == 2 {
            let settingArr = UserDefaults.standard.array(forKey: "setArr")
            let images = UserDefaults.standard.imageArray(forKey: "setArrImg")
           
            if defaults.bool(forKey: "isLogin") == false {
               // let isSet = UserDefaults.standard.bool(forKey: "isSet")
               // let isBlog = UserDefaults.standard.bool(forKey: "isBlog")
              
                cell.lblName.text = settingArr![indexPath.row] as? String
                cell.imgPicture.image = images![indexPath.row]
                
//                    if isBlog == true{
//                        cell.lblName.text = settingArr![indexPath.row] as? String
//                        cell.imgPicture.image = UIImage(named: "blog")
//                    }
//
//
//                    if isBlog == true{
//                        cell.lblName.text = settingArr![0] as? String
//                        cell.imgPicture.image = UIImage(named: "blog")
//                    }
                
//                if row == 0{
//                    if isSet == true{
//                        cell.lblName.text = settingArr![1] as? String
//                        cell.imgPicture.image = UIImage(named: "settings")
//                    }
//                }
//
//                 if row == 1{
//                    if isSet == true{
//                        cell.lblName.text = settingArr![1] as? String
//                        cell.imgPicture.image = UIImage(named: "settings")
//                    }
//                }
                
                //cell.imgPicture.image = guestOtherArray[indexPath.row]
//                if (objData?.menu.isShowMenu.blog)! {
//                    if row == 0 {
//                        cell.lblName.text = objData?.menu.blog
//                        cell.imgPicture.image = UIImage(named: "blog")
//                    }
//                    else if row == 1 {
//                        cell.lblName.text = objData?.menu.appSettings
//                        cell.imgPicture.image = UIImage(named: "settings")
//                    }
//                }
            }
                
            else {
                var isShowBlog = false
                if let isBlog = objData?.menu.isShowMenu.blog {
                    isShowBlog = isBlog
                }
                if isShowBlog {
                    if row == 0 {
                        cell.lblName.text = objData?.menu.blog
                        cell.imgPicture.image = UIImage(named: "blog")
                    }
                    else if row == 1 {
                        cell.lblName.text = objData?.menu.appSettings
                        cell.imgPicture.image = UIImage(named: "settings")
                    }
                    else if row == 2 {
                        cell.lblName.text = objData?.menu.logout
                        cell.imgPicture.image = UIImage(named: "logout")
                    }
                }
                else {
                     if row == 0 {
                        cell.lblName.text = objData?.menu.appSettings
                        cell.imgPicture.image = UIImage(named: "settings")
                    }
                    else if row == 1 {
                        cell.lblName.text = objData?.menu.logout
                        cell.imgPicture.image = UIImage(named: "logout")
                    }
                }
            }
        }
        else if section == 3{
            
            let isWpOn = UserDefaults.standard.bool(forKey: "isWpOn")
            if isWpOn == true{
            cell.lblName.text = menuLangText //"Language"
            cell.imgPicture.image = UIImage(named: "language")
            }else{
                //-->>>
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       let isWpOn = UserDefaults.standard.bool(forKey: "isWpOn")
        if indexPath.section == 3 {
            if isWpOn == true{
                 return 40
            }else{
                return 0
            }
        }else{
             return 40
        }
       
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        let objData = UserHandler.sharedInstance.objSettings
        if defaults.bool(forKey: "isLogin") == false {
            if section == 0 {
                title = ""
            } else if section == 1 {
                if UserHandler.sharedInstance.objSettingsMenu.isEmpty {
                    title = ""
                } else {
                    title = (objData?.menu.submenu.title)!
                }
            }
            else if section == 2 {
                let settingArr = UserDefaults.standard.array(forKey: "setArr")
                if settingArr?.count != 0{
                    title = (objData?.menu.others)!
                }
            }
        }
        else {
            if section == 0 {
                title = ""
            }
            else if section == 1 {
                if UserHandler.sharedInstance.objSettingsMenu.isEmpty {
                    title = ""
                }
                else {
                     title = (objData?.menu.submenu.title)!
                }
            }
            else if section == 2 {
                title = (objData?.menu.others)!
            }
        }
        return title
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let objData = UserHandler.sharedInstance.objSettings
        if section == 0 {
            if defaults.bool(forKey: "isLogin") == false {
                var isShowPackage = false
                if let isShow = objData?.menu.isShowMenu.packageField {
                    isShowPackage = isShow
                }
                if isShowPackage {
                    if let menu = GuestMenu(rawValue: indexPath.row+1) {
                        self.changeGuestController(menu)
                    }
                } else {
                    if let menu = HideGuestPackage(rawValue: indexPath.row+1) {
                        self.hideGuestController(menu)
                    }
                }
            } else {
                let obj = UserHandler.sharedInstance.menuKeysArray[indexPath.row]
                self.changeViewController(controllerName: obj)
            }
        }
        else if section == 1 {
            let objData = UserHandler.sharedInstance.objSettingsMenu[indexPath.row]
            let data = UserHandler.sharedInstance.objSettings
            var isShowPage = false
            if let pages = data?.menu.submenu.hasPage {
                isShowPage = pages
            }
            if isShowPage {
                if let menu = pageMenu(rawValue: 0) {
                    initializePagesView(pageID: objData.pageId, type: objData.type, pageUrl: objData.pageUrl)
                    self.changePage(menu)
                }
            }
        }
        else if section == 2 {
          
            var isShowBlog = false
            var isShowSetting = false
            
            if let isBlog = objData?.menu.isShowMenu.blog {
                isShowBlog = isBlog
            }
            if let isSetting = objData?.menu.isShowMenu.settings {
                isShowSetting = isSetting
            }
            
            if defaults.bool(forKey: "isLogin") == false {
                if let menu = OtherGuestMenues(rawValue: indexPath.row+1) {
                    self.changeGuestMenu(menu)
                }
            }
            
            if isShowBlog {
                if let menu = OtherMenues(rawValue: indexPath.row) {
                    self.changeMenu(menu)
                }
            }
            
            else {
                if let menu = OtherMenues(rawValue: indexPath.row+1) {
                    
                    self.changeMenu(menu)
                }
            }
        }
        else if section == 3{
            if let menu = leftMenuLangSetting(rawValue: indexPath.row) {
                 appDelegate.moveToLanguageCtrl()  // self.changeViewController(menu)
            }
        }
        
        
    }
}
