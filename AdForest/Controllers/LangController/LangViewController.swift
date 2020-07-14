//
//  LangViewController.swift
//  AdForest
//
//  Created by Furqan Nadeem on 13/06/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SDWebImage

class LangViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    //-->> IBOutlets
    
    @IBOutlet weak var lblPick: UILabel!
    @IBOutlet weak var lblLang: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //-->> Proporties
    
    var delegate :leftMenuProtocol?
    let defaults = UserDefaults.standard
    var imagesAr = [LangData]()
    var langArr =  [LangData]()
    
    var isAppOpen = false
    var settingBlogArr = [String]()
    var isBlogImg:Bool = false
    var isSettingImg:Bool = false
    var imagesArr = [UIImage]()
    var languageStyle = "2"
    
    //-->> View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        settingsdata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let isLang = UserDefaults.standard.string(forKey: "langFirst")
        if isLang != "1"{
            self.navigationController?.isNavigationBarHidden = true
        }else{
            self.navigationController?.isNavigationBarHidden = false
            self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
            //addBackButtonToNavigationBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
       // self.navigationController?.isNavigationBarHidden = false
        
        let isLang = UserDefaults.standard.string(forKey: "langFirst")
        if isLang != "1"{
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    //-->> Custome Functions
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
        self.navigationController?.popViewController(animated: true)
        self.dismissVC(completion: nil)
    }
    
    //MARK:- CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesAr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LangCollectionViewCell", for: indexPath) as! LangCollectionViewCell
        
        let url = imagesAr[indexPath.row].flag_url
        cell.imgCountry.sd_setShowActivityIndicatorView(true)
        cell.imgCountry.sd_setIndicatorStyle(.gray)
        cell.imgCountry.sd_setImage(with:URL(string: url!) , completed: nil)
        cell.lblLanguage.text = langArr[indexPath.row].native_name
        cell.btnCode.setTitle(langArr[indexPath.row].code, for: .normal)
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LangCollectionViewCell {
            print("\(String(describing: cell.btnCode.titleLabel?.text))")
            UserDefaults.standard.set(cell.btnCode.titleLabel?.text, forKey: "langCode")
            UserDefaults.standard.setValue("1", forKey: "langFirst")
        }
        self.perform(#selector(self.showHome), with: nil, afterDelay: 2)
    }
    
    @objc func showHome(){
         //appDelegate.moveToLanguageCtrl()
        let ctrl = storyboard?.instantiateViewController(withIdentifier: "Splash")
        self.navigationController?.pushViewController(ctrl!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  0
        let collectionViewSize = collectionView.frame.size.width - padding
        if Constants.isiPadDevice{
            if languageStyle == "1"{
                 return CGSize(width: collectionViewSize, height:65)
            }else{
                 return CGSize(width: collectionViewSize, height:65)
            }
        }
        else{
            if languageStyle == "1"{
                return CGSize(width: collectionViewSize, height:65)
            }else{
                return CGSize(width: collectionViewSize, height:65)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        UIView.animate(withDuration: 0.4,
                       animations: {
                        if let cell = collectionView.cellForItem(at: indexPath) as? LangCollectionViewCell {
                            cell.viewBg.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                            if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
                                cell.viewBg.backgroundColor = UIColor(hex: mainColor)
                            }

                        }
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.4) {
                            if let cell = collectionView.cellForItem(at: indexPath) as? LangCollectionViewCell {
                                cell.viewBg.transform = CGAffineTransform.identity
                                cell.viewBg.backgroundColor = UIColor.white
                            }

                        }
        })
    }
    
    //-->> Api Calls
    
    func settingsdata() {
       // self.showLoader()
        UserHandler.settingsdata(success: { (successResponse) in
           // self.stopAnimating()
            if successResponse.success {
                self.defaults.set(successResponse.data.mainColor, forKey: "mainColor")
                self.appDelegate.customizeNavigationBar(barTintColor: Constants.hexStringToUIColor(hex: successResponse.data.mainColor))
                self.defaults.set(successResponse.data.isRtl, forKey: "isRtl")
                self.defaults.set(successResponse.data.notLoginMsg, forKey: "notLogin")
                self.defaults.set(successResponse.data.isAppOpen, forKey: "isAppOpen")
                self.defaults.set(successResponse.data.showNearby, forKey: "showNearBy")
                self.defaults.set(successResponse.data.appPageTestUrl, forKey: "shopUrl")
                //Save Shop title to show in Shop Navigation Title
                self.defaults.set(successResponse.data.menu.shop, forKey: "shopTitle")
                self.isAppOpen = successResponse.data.isAppOpen
                //Offers title
                self.defaults.set(successResponse.data.messagesScreen.mainTitle, forKey: "message")
                self.defaults.set(successResponse.data.messagesScreen.sent, forKey: "sentOffers")
                self.defaults.set(successResponse.data.messagesScreen.receive, forKey: "receiveOffers")
                self.defaults.synchronize()
                UserHandler.sharedInstance.objSettings = successResponse.data
                UserHandler.sharedInstance.objSettingsMenu = successResponse.data.menu.submenu.pages
                UserHandler.sharedInstance.menuKeysArray = successResponse.data.menu.dynamicMenu.keys
                UserHandler.sharedInstance.menuValuesArray = successResponse.data.menu.dynamicMenu.array
                if successResponse.data.menu.isShowMenu.blog == true{
                    self.settingBlogArr.append(successResponse.data.menu.blog)
                    UserDefaults.standard.set(true, forKey: "isBlog")
                    self.imagesArr.append(UIImage(named: "blog")!)
                }
                if successResponse.data.menu.isShowMenu.settings == true{
                    UserDefaults.standard.set(true, forKey: "isSet")
                    self.imagesArr.append(UIImage(named: "settings")!)
                    self.settingBlogArr.append(successResponse.data.menu.appSettings)
                }
                
                UserDefaults.standard.set(self.settingBlogArr, forKey: "setArr")
                UserDefaults.standard.set(self.imagesArr, forKey: "setArrImg")
                print(self.imagesArr)
            
                self.imagesAr = successResponse.data.langData
                self.langArr = successResponse.data.langData
                self.lblPick.text = successResponse.data.wpml_header_title_1
                self.lblLang.text = successResponse.data.wpml_header_title_2
                self.imgLogo.sd_setImage(with: URL(string: successResponse.data.wpml_logo), completed: nil)
               // self.languageStyle = successResponse.data.language_style
                self.title = successResponse.data.wpml_menu_text
                self.collectionView.reloadData()
            
            } else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
           // self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }

}
