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
import ReadabilityKit
import Kingfisher
class PostDealTableViewController: UITableViewController,UITextFieldDelegate {
    @IBOutlet weak var dealUrlTF: UITextField!
    @IBOutlet weak var brandTF: UITextField!
    @IBOutlet weak var itemTF: UITextField!
    @IBOutlet weak var currentPriceTF: UITextField!
    @IBOutlet weak var originalPriceTF: UITextField!
    @IBOutlet weak var brandImageView: UIImageView!
    var imageUrl :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        dealUrlTF.delegate = self
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.imageUrl = nil
        self.brandImageView.image = nil
        guard let articleUrl = URL(string: textField.text ?? "") else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        Readability.parse(url: articleUrl, completion: { data in
            MBProgressHUD.hide(for: self.view, animated: true)
            let title = data?.title
            let description = data?.description
            let keywords = data?.keywords
            let imageUrl = data?.topImage
           
            let videoUrl = data?.topVideo
            let datePublished = data?.datePublished
            
            self.imageUrl = data?.topImage
            if let url = URL(string: data?.topImage ?? ""){
                self.brandImageView.kf.setImage(with: url)
            }
            
           
            
        })
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
        if dealUrlTF.text == nil || dealUrlTF.text == "" {
            showAlert(withTile: "Validation Error", andMessage: "Please Enter DealUrl")
        }else if URL(string: dealUrlTF.text!) == nil {
            showAlert(withTile: "Validation Error", andMessage: "Please Enter Valid DealUrl")
        }else if brandTF.text == nil || brandTF.text == "" {
            showAlert(withTile: "Validation Error", andMessage: "Please Enter brand")
        }else  if itemTF.text == nil || itemTF.text == "" {
            showAlert(withTile: "Validation Error", andMessage: "Please Enter Item")
        }else  if currentPriceTF.text == nil || currentPriceTF.text == "" {
            showAlert(withTile: "Validation Error", andMessage: "Please add Current Price")
        }else  if originalPriceTF.text == nil || originalPriceTF.text == "" {
            showAlert(withTile: "Validation Error", andMessage: "Please add Original Price")
        }else  if brandImageView.image == nil {
            showAlert(withTile: "Validation Error" , andMessage: "brand Url Did't able to get brand image please try other Rich url")
        }else{
        self.postData(dealurl: dealUrlTF.text ?? "", brandName: brandTF.text ?? "", ItemName: itemTF.text ?? "", originalPrice: originalPriceTF.text ?? "", currentPrice: currentPriceTF.text ?? "", imageUrl: self.imageUrl ?? "")
        }
    }
    func showAlert(withTile title:String,andMessage message:String)
     {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
         self.present(alert, animated: true, completion: nil)
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
