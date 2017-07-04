//
//  AppDelegate.swift
//  EPIC today
//
//  Created by Mialin Valentin on 21.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit
import Onboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
     //   let defaults = UserDefaults.standard
      //  let userHasOnboarded =  defaults.bool(forKey: "userHasOnboarded")
       
         self.setupNormalRootViewController()
        /*
        if userHasOnboarded == true {
            self.setupNormalRootViewController()
        }
        else {
            
            self.window?.rootViewController = self.generateStandardOnboardingVC()
            
        }
 */
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func generateStandardOnboardingVC () -> OnboardingViewController {
        
        // Initialize onboarding view controller
        var onboardingVC = OnboardingViewController()
        
        // Create slides
        let firstPage = OnboardingContentViewController.content(withTitle: "Welcome To The App!", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut.", image: UIImage(named: "1"), buttonText: nil, action: nil)
        
        firstPage.iconHeight = 25.0
        firstPage.iconWidth = 25.0
        
        let secondPage = OnboardingContentViewController.content(withTitle: "Step 1", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut.", image: UIImage(named: "image2"), buttonText: nil, actionBlock: nil)
        
        let thirdPage = OnboardingContentViewController.content(withTitle: "Step 2:", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut.", image: UIImage(named: "image3"), buttonText: nil, action: nil)
        
        let fourthPage = OnboardingContentViewController.content(withTitle: "Step 3", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut.", image: UIImage(named: "image4"), buttonText: nil, action: nil)
        
        // Define onboarding view controller properties
        onboardingVC = OnboardingViewController.onboard(withBackgroundImage: UIImage(named: "5"), contents: [firstPage, secondPage, thirdPage, fourthPage])
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.shouldMaskBackground = false
        onboardingVC.shouldBlurBackground = false
      //  onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.pageControl.pageIndicatorTintColor = UIColor.darkGray
        onboardingVC.pageControl.currentPageIndicatorTintColor = UIColor.white
        onboardingVC.skipButton.setTitleColor(UIColor.white, for: .normal)
        onboardingVC.allowSkipping = true
        //onboardingVC.fadeSkipButtonOnLastPage = true
        
        onboardingVC.skipHandler = {
            self.skip()
        }

        return onboardingVC
        
    }
    
    func handleOnboardingCompletion (){
        self.setupNormalRootViewController()
    }
    func setupNormalRootViewController (){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "mainVC") 
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "userHasOnboarded")
        
    }
    func skip (){
        self.setupNormalRootViewController()
        
    }


}

