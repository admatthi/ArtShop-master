//
//  PostDealTableViewController.swift
//  Bottles
//
//  Created by talal ahmad on 02/12/2020.
//  Copyright © 2020 The Matthiessen Group, LLC. All rights reserved.
//

import UIKit

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
        
    }
    
}
