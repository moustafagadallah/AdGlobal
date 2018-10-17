//
//  AppDelegate.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import Firebase
import FirebaseMessaging
import UserNotifications
import FBSDKCoreKit
import SlideMenuControllerSwift
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlacePicker
import StoreKit
import SwiftyStoreKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  

    var window: UIWindow?

    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let keyboardManager = IQKeyboardManager.sharedManager()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let defaults = UserDefaults.standard
    var deviceFcmToken = "0"
    
    var gViewController: UIViewController?
    var mInterstitial: GADInterstitial!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        keyboardManager.enable = true
        self.setUpGoogleMaps()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if #available(iOS 11, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
                  print("Granted \(granted)")
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
        else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in}
            UIApplication.shared.registerForRemoteNotifications()
            application.registerForRemoteNotifications()
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        // For Facebook and Google SignIn
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        defaults.removeObject(forKey: "isGuest")
        defaults.synchronize()
        
        //For in App Purchase
        SwiftyStoreKit.completeTransactions(atomically: true) { (purchases) in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction{
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6905547279452514/6461881125")
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let willHandleByFacebook = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])

      let willHandleByGoogle =  GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return willHandleByGoogle || willHandleByFacebook
    }
    
    //MARK:- For Google Places Search
    func setUpGoogleMaps() {
        let googleMapsApiKey = Constants.googlePlacesAPIKey.placesKey
        GMSServices.provideAPIKey(googleMapsApiKey)
        GMSPlacesClient.provideAPIKey(googleMapsApiKey)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("App Resign Active")
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App in Background")
    
         Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App in Foreground")
         Messaging.messaging().shouldEstablishDirectChannel = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("App Become Active")
        Messaging.messaging().shouldEstablishDirectChannel = true
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AdForest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    func customizeNavigationBar(barTintColor: UIColor) {
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .default)
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
        appearance.barTintColor = barTintColor
        appearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        appearance.barStyle = .blackTranslucent
    }
    
    func moveToHome() {
        let HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        if defaults.bool(forKey: "isRtl") {
            let rightViewController = storyboard.instantiateViewController(withIdentifier: "LeftController") as! LeftController
            let navi: UINavigationController = UINavigationController(rootViewController: HomeVC)
            let slideMenuController = SlideMenuController(mainViewController: navi, rightMenuViewController: rightViewController)
            self.window?.rootViewController = slideMenuController
        } else {
            let leftVC = storyboard.instantiateViewController(withIdentifier: "LeftController") as! LeftController
            let navi : UINavigationController = UINavigationController(rootViewController: HomeVC)
            let slideMenuController = SlideMenuController(mainViewController: navi, leftMenuViewController: leftVC)
            self.window?.rootViewController = slideMenuController
        }        
        self.window?.makeKeyAndVisible()
    }
    
    func moveToLogin() {
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let nav: UINavigationController = UINavigationController(rootViewController: loginVC)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func presentController(ShowVC: UIViewController) {
        self.window?.rootViewController?.presentVC(ShowVC)
    }
    
    func dissmissController() {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func popController() {
        self.window?.rootViewController?.navigationController?.popViewController(animated: true)
    }
    
    func pushController(controller: UIViewController) {
        self.window?.rootViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}

extension AppDelegate  {
    
    // MARK: UNUserNotificationCenter Delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        print("Data is \(content)")
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("This method is called")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if PROD_BUILD
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        #else
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        #endif
        
        Messaging.messaging().apnsToken = deviceToken
        
        if let refreshedToken = InstanceID.instanceID().token() {
            print("Firebase: InstanceID token: \(refreshedToken)")
            self.deviceFcmToken = refreshedToken
            let defaults =  UserDefaults.standard
            defaults.setValue(deviceToken, forKey: "fcmToken")
            defaults.synchronize()
        }else{
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications with with error: \(error)")
    }
    
    
    func application(_ application: UIApplication, didrequestAuthorizationRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        #if PROD_BUILD
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        #else
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        #endif
        
        Messaging.messaging().apnsToken = deviceToken
        
        let token = deviceToken.base64EncodedString()
        
        let fcmToken = Messaging.messaging().fcmToken
        print("Firebase: FCM token: \(fcmToken ?? "")")
        
        print("Firebase: found token \(token)")
        
        print("Firebase: found token \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Firebase: user info \(userInfo)")
        switch application.applicationState {
        case .active:
            break
        case .background, .inactive:
            break
        }
        let gcmMessageIDKey = "gcm.message_id"
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("mtech Message ID: \(messageID)")
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let fcmToken = Messaging.messaging().fcmToken
        let defaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: "fcmToken")
        defaults.synchronize()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
        guard let adID = remoteMessage.appData[AnyHashable("adId")]as? String else  {
            return
        }
        guard let textFrom = remoteMessage.appData[AnyHashable("from")] as? String else {
            return
        }
        guard let textTitle = remoteMessage.appData[AnyHashable("title")] as? String else  {
            return
        }
        guard let userMessage = remoteMessage.appData[AnyHashable("message")] as? String else {
            return
        }
        guard let senderID = remoteMessage.appData[AnyHashable("senderId")] as? String else {
            return
        }
        guard let receiverID = remoteMessage.appData[AnyHashable("recieverId")] as? String else {
            return
        }
        guard let type = remoteMessage.appData[AnyHashable("type")] as? String else {
            return
        }
        guard let topic = remoteMessage.appData[AnyHashable("topic")] as? String else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = textTitle
        content.body = userMessage
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "AdForest", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error)
        }
    }
}
