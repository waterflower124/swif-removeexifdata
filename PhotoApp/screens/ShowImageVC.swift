//
//  ShowImageVC.swift
//  PhotoApp
//
//  Created by Dharmbir Singh on 12/02/20.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit

class ShowImageVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    weak var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgView.image = self.image
    }
    
    @IBAction func onClickClose(sender: UIButton){
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
