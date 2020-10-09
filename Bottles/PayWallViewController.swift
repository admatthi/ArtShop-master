//
//  PayWallViewController.swift
//  Bottles
//
//  Created by Alek Matthiessen on 10/6/20.
//  Copyright © 2020 The Matthiessen Group, LLC. All rights reserved.
//

import UIKit
import Firebase
import Purchases
import FBSDKCoreKit
import MBProgressHUD
import AppsFlyerLib
import AVKit
import AVFoundation
import Kingfisher
import FirebaseDatabase

@objc protocol SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PayWallViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
    @objc optional func purchaseFailed(paywall: PayWallViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
    @objc optional func purchaseRestored(paywall: PayWallViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}
class PayWallViewController: UIViewController {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return books.count
        
    }
    
    
    var books: [Book] = [] {
        didSet {
            
            //            titleCollectionView.alpha = 1
            
            //            self.titleCollectionView.reloadData()
            
            
        }
    }
    
    var delegate : SwiftPaywallDelegate?
    
    private var offering : Purchases.Offering?
    
    private var offeringId : String?
    
    @IBOutlet weak var termstext: UILabel!
    @IBOutlet weak var disclaimertext: UIButton!
    var purchases = Purchases.configure(withAPIKey: "iwmKCkKDKtJKbrYKdDAumktwIbKqLVJm", appUserID: nil)
    
    func configAutoscrollTimer()
    {
        
    }
    func deconfigAutoscrollTimer()
    {
        timr.invalidate()
        
    }
    func onTimer()
    {
        autoScrollView()
    }
    
    var timr=Timer()
    var w:CGFloat=0.0
    
    @objc func autoScrollView()
    {
        
        let initailPoint = CGPoint(x: w,y :0)
        
        if __CGPointEqualToPoint(initailPoint, titleCollectionView.contentOffset)
        {
            if w<titleCollectionView.contentSize.width
            {
                w += 0.5
            }
            else
            {
                w = -self.view.frame.size.width
            }
            
            let offsetPoint = CGPoint(x: w,y :0)
            
            titleCollectionView.contentOffset=offsetPoint
            
        }
        else
        {
            w=titleCollectionView.contentOffset.x
        }
    }
    
    @IBAction func tapRestore(_ sender: Any) {
        
        
        
        ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
        
        didpurchase = true
        
        
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            //... check purchaserInfo to see if entitlement is now active
            
            if let error = error {
                
                
            } else {
                
                self.logPurchaseSuccessEvent(referrer : referrer)
                //
                ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                
                didpurchase = true
                
                
                self.dismiss(animated: true, completion: nil)
                
                
            }
            
        }
    }
    @IBAction func tapBack(_ sender: Any) {
        
        
        
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    func logNotificationsSettingsTrue(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "notifications enabled"), parameters: ["value" : "true"])
    }
    
    
    func logNotificationsSettingsFalse(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "notifications enabled"), parameters: ["value" : "false"])
    }
    
    
    @IBOutlet weak var backimage: UIImageView!
    
    @IBOutlet weak var titleCollectionView: UICollectionView!
    
    @IBAction func tapWeekly(_ sender: Any) {
        
        
        
        logTapSubscribeEvent(referrer : referrer)
        
          AppsFlyerLib.shared().logEvent(AFEventInitiatedCheckout, withValues: [AFEventParam1 : referrer])
        
        //            AppsFlyerTracker.shared().trackEvent(AFEventInitiatedCheckout, withValues: [
        //                AFEventParamContentId: referrer,
        //
        //            ]);
        
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        
        
        guard let package = offering?.availablePackages[1] else {
            print("No available package")
            MBProgressHUD.hide(for: view, animated: true)
            
            return
        }
        
        
        Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let purchaseFailedHandler = self.delegate?.purchaseFailed {
                    purchaseFailedHandler(self, info, error, cancelled)
                } else {
                    if !cancelled {
                        
                    }
                }
            } else  {
                if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
                    purchaseCompletedHandler(self, trans!, info!)
                    
                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    didpurchase = true
                    
                    AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [AFEventParam1 : referrer])
                    
//                                            AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
//                                                AFEventParamContentId: referrer,
//
//                                            ]);
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                } else {
                    
                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    //                        AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
                    //                            AFEventParamContentId: referrer,
                    //
                    //                        ]);
                    didpurchase = true
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                }
            }
        }
        
    }
    @IBAction func tapContinue(_ sender: Any) {
        
        
        logTapSubscribeEvent(referrer : referrer)
        
        //            AppsFlyerTracker.shared().trackEvent(AFEventInitiatedCheckout, withValues: [
        //                AFEventParamContentId: referrer,
        //
        //            ]);
        //
        //
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        
        AppsFlyerLib.shared().logEvent(AFEventInitiatedCheckout, withValues: [AFEventParam1 : referrer])

        guard let package = offering?.availablePackages[0] else {
            print("No available package")
            MBProgressHUD.hide(for: view, animated: true)
            
            return
        }
        
        
        Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let purchaseFailedHandler = self.delegate?.purchaseFailed {
                    purchaseFailedHandler(self, info, error, cancelled)
                } else {
                    if !cancelled {
                        
                    }
                }
            } else  {
                if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
                    purchaseCompletedHandler(self, trans!, info!)
                    
                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    didpurchase = true
                    
                    //
                    //                        AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
                    //                            AFEventParamContentId: referrer,
                    //
                    //                        ]);
                    
                    AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [AFEventParam1 : referrer])

                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                } else {
                    
                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [AFEventParam1 : referrer])

                    
                    //                        AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
                    //                            AFEventParamContentId: referrer,
                    //
                    //                        ]);
                    didpurchase = true
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                }
            }
        }
    }
    
    @IBAction func tapTerms(_ sender: Any) {
        
        if let url = NSURL(string: "https://www.aktechnology.info/terms.html"
            ) {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    
    @IBOutlet weak var leadingtext: UILabel!
    
    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var videoview: UIView!
    @IBOutlet weak var headlinelabel: UILabel!
    @IBOutlet weak var tapcontinue: UIButton!
    var playerLayer = AVPlayerLayer()
    
    func playVideo(from file:String) {
        let file = file.components(separatedBy: ".")
        
        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.myimage.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        //        self.view.sendSubviewToBack(playerLayer)
        
        player.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //        configAutoscrollTimer()
        
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        super.viewDidAppear(true)
    //
    //        deconfigAutoscrollTimer()
    //    }
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //        tapcontinue2.layer.borderWidth  = 3.0
        //        tapcontinue2.layer.borderColor  = UIColor.lightGray.cgColor
        //
        ref = Database.database().reference()
        
        
        selectedgenre = "New"
        
        Purchases.shared.offerings { (offerings, error) in
            
            if error != nil {
            }
            if let offeringId = self.offeringId {
                
                self.offering = offerings?.offering(identifier: "weekly")
            } else {
                self.offering = offerings?.current
            }
            
        }
        
        
        //               playVideo(from: "myv3.mp4")
        
        
        
        //
        //           let pulsator = Pulsator()
        //            pulsator.radius = 240.0
        //
        //        pulsator.numPulse = 30
        //
        //        pulsator.backgroundColor = UIColor.red.cgColor
        //
        //           view.layer.addSublayer(pulsator)
        //           pulsator.start()
        
        //        tapcontinue.layer.cornerRadius = 25.0
        //
        //        tapcontinue.clipsToBounds = true
        
        
        logPaywallShownEvent(referrer : referrer)
        
        //        var screenSize = titleCollectionView.bounds
        //        var screenWidth = screenSize.width
        //        var screenHeight = screenSize.height
        //
        //        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        //        layout.itemSize = CGSize(width: screenWidth/1.1, height: screenWidth/1.1)
        //        layout.minimumInteritemSpacing = 0
        //        layout.minimumLineSpacing = 0
        //
        //        layout.scrollDirection = .horizontal
        //        titleCollectionView!.collectionViewLayout = layout
        //
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backimage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backimage.addSubview(blurEffectView)
        //
        if slimeybool {
            
            //                slimeybool = true
            //
            
            self.toptext.text = "3 Day FREE Trial"
            self.termstext.alpha = 0
            self.disclaimertext.alpha = 0
            self.tapcontinue.setTitle("Try for FREE", for: .normal)
            
            
            pricingtwo.alpha = 1
            pricingthree.alpha = 1
            
        } else {
            //
            //                slimeybool = false
            //            self.leadingtext.text = "139.99/year. Cancel anytime within 3 days and you won't be charged anything."
            
            self.toptext.text = "World Class Presets"
            //
            self.termstext.alpha = 1
            self.disclaimertext.alpha = 1
            self.tapcontinue.setTitle("Continue", for: .normal)
            self.tapcontinue.setTitle("Continue", for: .normal)
            
            //            pricingone.alpha = 0
            pricingtwo.alpha = 0
            pricingthree.alpha = 0
            
        }
        
        queryforids { () -> Void in
            
        }
        
        queryforpaywall()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func queryforids(completed: @escaping (() -> Void) ) {
        
        //        titleCollectionView.alpha = 0
        
        var functioncounter = 0
        
        
        ref?.child("fb-ads-filter").child(selectedgenre).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var value = snapshot.value as? NSDictionary
            
            print (value)
            
            if let snapDict = snapshot.value as? [String: AnyObject] {
                
                let genre = Genre(withJSON: snapDict)
                
                if let newbooks = genre.books {
                    
                    self.books = newbooks
                    
                    self.books = self.books.sorted(by: { $0.popularity ?? 0  > $1.popularity ?? 0 })
                    
                }
                
            }
            
        })
    }
    @IBOutlet weak var tapcontinue2: UIButton!
    @IBOutlet weak var toptext: UILabel!
    @IBOutlet weak var pricingone: UILabel!
    @IBOutlet weak var pricingthree: UILabel!
    @IBOutlet weak var pricingtwo: UILabel!
    @IBOutlet weak var value1: UILabel!
    func queryforpaywall() {
        
        ref?.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            
            
            if let slimey = value?["Slimey"] as? String {
                
                slimeybool = true
                //
                
                self.toptext.alpha = 1
                self.termstext.alpha = 0
                self.disclaimertext.alpha = 0
                self.tapcontinue.setTitle("Try for FREE!", for: .normal)
                self.toptext.text = slimey
                
                
                self.pricingtwo.alpha = 1
                self.pricingthree.alpha = 1
                
            } else {
                //
                slimeybool = false
                
                
                self.toptext.alpha = 0
                self.termstext.alpha = 1
                self.disclaimertext.alpha = 1
                self.tapcontinue.setTitle("$139.99/year", for: .normal)
                
                
                self.pricingtwo.alpha = 0
                self.pricingthree.alpha = 0
                //
                
            }
            
            if let discountcode = value?["DiscountCode"] as? String {
                
                
            } else {
                
                
            }
        })
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func logPaywallShownEvent(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "paywall shown"), parameters: ["referrer" : referrer, "bookID" : selectedbookid, "genre" : selectedgenre])
    }
    
    func logTapSubscribeEvent(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "tap subscribe"), parameters: ["referrer" : referrer, "bookID" : selectedbookid, "genre" : selectedgenre])
    }
    
    func logPurchaseSuccessEvent(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "purchase success"), parameters: ["referrer" : referrer, "bookID" : selectedbookid, "genre" : selectedgenre])
    }
    
}

    extension PayWallViewController {
         func book(atIndex index: Int) -> Book? {
             if index > books.count - 1 {
                 return nil
             }

             return books[index]
         }

         func book(atIndexPath indexPath: IndexPath) -> Book? {
             return self.book(atIndex: indexPath.row)
         }
     }
