//
//  ExploreViewController.swift
//  Bottles
//
//  Created by Alek Matthiessen on 6/24/20.
//  Copyright © 2020 The Matthiessen Group, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import Kingfisher
import Kingfisher
import Photos
import FBSDKCoreKit
import MBProgressHUD
import FirebaseFirestore

var didpurchase = Bool()
var db : Firestore!

let lightg = UIColor(red: 0.90, green: 0.91, blue: 0.91, alpha: 1.00)

var bookindex = Int()
               var selectedauthor = String()
               var selectedtitle = String()
               var selectedurl = String()
               var selectedbookid = String()
               var selectedamazonurl = String()
               var selecteddescription = String()
               var selectedduration = Int()
        

var selectedgenre = String()
var selectedindex = Int()

var wishlistids = [String]()
var counter = Int()
var musictimer : Timer?
var updater : CADisplayLink?
var player : AVPlayer?
var referrer = String()
var selectedauthorimage = String()
var uid = String()
var ref : DatabaseReference?
var refer = String()

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleCollectionView: UICollectionView!
    var counter = 0
    //
    @IBOutlet weak var genreCollectionView: UICollectionView!
    var books: [Book] = [] {
        didSet {
            
            self.titleCollectionView.reloadData()
            
        }
    }
    
    var genres = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.titleCollectionView.reloadData()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        db = Firestore.firestore()

        genres.removeAll()
        genres.append("Latest")
        genres.append("Shirts")
        genres.append("Pants")
        genres.append("Shoes")
        genres.append("Other")
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        
        
        selectedgenre = "Latest"
        
        var screenSize = titleCollectionView.bounds
        var screenWidth = screenSize.width
        var screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: screenWidth/2.21, height: screenWidth/1.3)
        
        titleCollectionView!.collectionViewLayout = layout
        
        
        
        if selectedgenre == "" || selectedgenre == "None" {
            
            selectedgenre = "Selfie"
            
            selectedindex = genres.firstIndex(of: selectedgenre)!
            
            genreCollectionView.reloadData()
            
        } else {
            
            print(selectedindex)
            
            selectedindex = genres.firstIndex(of: selectedgenre)!
            
            genreCollectionView.reloadData()
            
        }
        
        queryforids()
        
        queryforinfo()
        
        // Do any additional setup after loading the view.
    }
    
    func queryforinfo() {
          
          ref?.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
              
              let value = snapshot.value as? NSDictionary
              
              if let purchased = value?["Purchased"] as? String {
                  
                  if purchased == "True" {
                      
                      didpurchase = true
                      
                  } else {
                      
                      didpurchase = false
                      self.performSegue(withIdentifier: "HomeToSales", sender: self)
                      
                  }
                  
              } else {
                  
                  didpurchase = false
                  self.performSegue(withIdentifier: "HomeToSales", sender: self)
              }
              
          })
          
      }
    
    func queryforids() {
        
        titleCollectionView.alpha = 1
        
        var functioncounter = 0
        
        
        db.collection("latest_deals").whereField("brand", isGreaterThan: " ").limit(to: 100)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let para:NSMutableDictionary = NSMutableDictionary()
                    
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let docId = document.documentID
                        let prod: NSMutableDictionary = NSMutableDictionary()
                        for (key, value) in data {
                            prod.setValue(value, forKey: "\(key)")
                        }
                        
                        para.setObject(prod, forKey: docId as NSCopying)
                        
                    }
                    if para.count > 0 {
                        
                        if let snapDict = para as? [String : Any] {
                            
                            let genre = Genre(withJSON: snapDict)
                            
                            if let newbooks = genre.books {
                                
                                self.books = newbooks
                                
                                //
                                //
                                self.books = self.books.sorted(by: { $0.created?.dateValue().timeAgoSinceDate() ?? "0" < $1.created?.dateValue().timeAgoSinceDate() ?? "1" })
                                
                            }
                        }
                    }
                    
                }
                
        }
    }
    
    var genreindex = Int()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        refer = "On Tap Discover"
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        self.view.endEditing(true)
        titleCollectionView.isUserInteractionEnabled = true
        
        
        
        if collectionView.tag == 1 {
            
            selectedindex = indexPath.row
            
            genreCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            
            collectionView.alpha = 0
            
            selectedgenre = genres[indexPath.row]
            
            
            genreindex = indexPath.row
            
            queryforids()
            
            logCategoryPressed(referrer: referrer)
            
            titleCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            //            addstaticbooks()
            
            
            genreCollectionView.reloadData()
            
        } else {
            
            let book = self.book(atIndexPath: indexPath)
            
            //print("CELL ITEM===>", book ?? [])
            
            
//            if didpurchase {
                
                
                bookindex = indexPath.row
                selectedauthor = book?.author ?? ""
                selectedtitle = book?.title ?? ""
                selectedbookid = book?.bookID ?? ""
                selectedgenre = book?.genre ?? ""
                selectedurl = book?.amazonURL as! String
                
                
                logUsePressed(referrer: referrer)
                
                
                guard let url = URL(string: selectedurl) else {
                    return //be safe
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
                
//            } else {
//
//                if indexPath.row < 2 {
//
//                    bookindex = indexPath.row
//                    selectedauthor = book?.author ?? ""
//                    selectedtitle = book?.title ?? ""
//                    selectedbookid = book?.bookID ?? ""
//                    selectedgenre = book?.genre ?? ""
//                    selectedurl = book?.amazonURL as! String
//
//
//                    logUsePressed(referrer: referrer)
//
//
//                    guard let url = URL(string: selectedurl) else {
//                        return //be safe
//                    }
//
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    } else {
//                        UIApplication.shared.openURL(url)
//                    }
//
//                } else {
//
//                    self.performSegue(withIdentifier: "HomeToSales", sender: self)
//
//                }
//
//            }
            
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case self.genreCollectionView:
            return genres.count
        case self.titleCollectionView:
            return books.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        // Genre collection
        case self.genreCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Categories", for: indexPath) as! CategoryCollectionViewCell
            
            collectionView.alpha = 1
            cell.titlelabel.text = genres[indexPath.row]
            
            
            //            cell.titlelabel.sizeToFit()
            
            //            cell.selectedimage.layer.cornerRadius = 5.0
            //            cell.selectedimage.layer.masksToBounds = true
            
            
            MBProgressHUD.hide(for: view, animated: true)
            
            logCategoryPressed(referrer: referrer)
            genreCollectionView.alpha = 1
            
            if selectedindex == 0 {
                
                if indexPath.row == 0 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
            }
            
            if selectedindex == 1 {
                
                if indexPath.row == 1 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 2 {
                
                if indexPath.row == 2 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 3 {
                
                if indexPath.row == 3 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 4 {
                
                if indexPath.row == 4 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
            }
            
            if selectedindex == 5 {
                
                if indexPath.row == 5 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 6 {
                
                if indexPath.row == 6 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 7 {
                
                if indexPath.row == 7 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            if selectedindex == 8 {
                
                if indexPath.row == 8 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 9 {
                
                if indexPath.row == 9 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 10 {
                
                if indexPath.row == 10 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 11 {
                
                if indexPath.row == 11 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 12 {
                
                if indexPath.row == 12 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 13 {
                
                if indexPath.row == 13 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 14 {
                
                if indexPath.row == 14 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 15 {
                
                if indexPath.row == 15 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 16 {
                
                if indexPath.row == 16 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 17 {
                
                if indexPath.row == 17 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 18 {
                
                if indexPath.row == 18 {
                    
                    cell.titlelabel.alpha = 1
                    cell.selectedimage.alpha = 1
                    
                } else {
                    
                    cell.titlelabel.alpha = 0.25
                    cell.selectedimage.alpha = 0
                    
                }
                
            }
            
            
            if selectedindex == 1000 {
                
                cell.titlelabel.alpha = 0.25
                cell.selectedimage.alpha = 0
            }
            
            return cell
            
        case self.titleCollectionView:
            
              let book = self.book(atIndexPath: indexPath)
                     
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Discount", for: indexPath) as! DiscountCollectionViewCell
                     
                     print(book?.brand)
                     
                     if book?.name == "" || book?.brand == " " || book?.brand == "" || book?.brand == nil || book?.brand == "Limited-Time Sale" || book?.brand == "New Markdown" || book?.brand == "Price Matched"  {
                         //
                         //                books.remove(at: indexPath.row)
                         
                         //                cell.alpha = 0
                         
                         
                         cell.removeFromSuperview()
                         
                         
                         //
                         //
                         return cell
                         
                         //
                     } else {
                         
                         
                         let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "$\((book?.originalprice)!)")
                         
                         attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                         
                         cell.strikethrough.attributedText = attributeString
                         
                         if let newprice = book?.newprice {
                             
                             cell.pricelabel.text = "$\(newprice)"
                             
                         }
                         
                         //let mydate = String((book?.date?.prefix(6))!)
                         
                         cell.brandname.text = book?.brand?.lowercased()
                         cell.brandname.text = book?.brand?.capitalized
                         cell.pricelabel.alpha = 1
                         cell.strikethrough.alpha = 1
                         
                         let datemy = book?.created
                         
                         let date2 = datemy!.dateValue()
                         
                         
                         
                         //                let timestamp = datemy
                         
                         //                let converted = NSDate(timeIntervalSince1970: datemy / 1000)
                         ////
                         ////
                         //                let dateFormatter = DateFormatter()
                         //                dateFormatter.timeZone = NSTimeZone.local
                         //                dateFormatter.dateFormat = "hh:mm a"
                         //                let time = dateFormatter.string(from: converted as Date)
                         //
                         //            print("above is \(date2.timeAgoSinceDate())")
                         
                         //
                         cell.datelabel.text = date2.timeAgoSinceDate()
                         cell.titlelabel.text = book?.name?.capitalized
                         
                         cell.imagelabel.alpha = 1
                         cell.datelabel.alpha = 1
                         cell.titlelabel.alpha = 1
                         cell.brandname.alpha = 1
                         
                         logFilterViewed(referrer: referrer)
                         
                         cell.layer.borderWidth = 1
                         cell.layer.borderColor = lightg.cgColor
                         
                         
                         if let imageURLString = book?.imageURL, let imageUrl = URL(string: imageURLString) {
                             
                             MBProgressHUD.hide(for: view, animated: true)
                             
                             cell.imagelabel.kf.setImage(with: imageUrl)
                             
                             //                if didpurchase {
                             //
                             //                    cell.blurimage.alpha = 0
                             //                    cell.titlelabel.alpha = 1
                             //
                             //                } else {
                             //
                             //                    if indexPath.row > 1 {
                             //
                             //
                             //                        cell.titlelabel.alpha = 0
                             //                        cell.blurimage.alpha = 1
                             //
                             //                    } else {
                             
                             
                             cell.titlelabel.alpha = 1
                             cell.blurimage.alpha = 0
                             //                    }
                             //                    //
                             //                }
                             
                         }
                         
                         return cell
                        
            }
            
        default:
            
            return UICollectionViewCell()  
        }
            
        
    }
    
    
    func logUsePressed(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "use pressed"), parameters: ["referrer" : referrer, "bookID" : selectedbookid, "genre" : selectedgenre])
    }
    
    func logCategoryPressed(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "category pressed"), parameters: ["referrer" : referrer, "genre" : selectedgenre])
    }
    
    func logFilterViewed(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "filter viewed"), parameters: ["referrer" : referrer, "bookID" : selectedbookid, "genre" : selectedgenre])
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension ExploreViewController {
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


extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + "" + "y" : "\(interval)" + "" + "y"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + "" + "mo" : "\(interval)" + "" + "mo"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + "" + "d" : "\(interval)" + "" + "d"
        }

//         Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + "" + "h ago" : "\(interval)" + "" + "h ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + "" + "m ago" : "\(interval)" + "" + "m ago"
        }

        return "5s"
    }
}
