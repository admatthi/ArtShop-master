//
//  PostDealTableViewController.swift
//  Bottles
//
//  Created by talal ahmad on 02/12/2020.
//  Copyright © 2020 The Matthiessen Group, LLC. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
class PostDealTableViewController: UITableViewController {
    @IBOutlet weak var dealUrlTF: UITextField!
    @IBOutlet weak var brandTF: UITextField!
    @IBOutlet weak var itemTF: UITextField!
    @IBOutlet weak var currentPriceTF: UITextField!
    @IBOutlet weak var originalPriceTF: UITextField!
    @IBOutlet weak var brandImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func clearAll(){
        dealUrlTF.text = ""
        brandTF.text = ""
        itemTF.text = ""
        currentPriceTF.text = ""
        originalPriceTF.text = ""
        brandImageView.image = nil
    }
    @IBAction func submitButtonAction(_ sender: Any) {
        self.postData(dealurl: dealUrlTF.text ?? "", brandName: brandTF.text ?? "", ItemName: itemTF.text ?? "", originalPrice: originalPriceTF.text ?? "", currentPrice: currentPriceTF.text ?? "", imageUrl: "https://images.pexels.com/photos/19090/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260")
        
    }
    func postData(dealurl:String,brandName:String,ItemName:String,originalPrice:String,currentPrice:String,imageUrl:String){
        MBProgressHUD.showAdded(to: view, animated: true)
        // Add a second document with a generated ID.
        var ref: DocumentReference? = nil

        ref = db.collection("latest_deals").addDocument(data: [
            "brand": brandName,
            "image": imageUrl,
            "name": ItemName,
            "new_price": Int(currentPrice) ?? 0,
            "orignal_price": Int(originalPrice) ?? 0,
            "url": dealurl,
            "website":dealurl,
            "created_at":Date()
        ]) { err in
            if let err = err {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Error adding document: \(err)")
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.clearAll()
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
}
