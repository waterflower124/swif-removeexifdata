//
//  ImageM.swift
//  PhotoApp
//
//  Created by Dharmbir Singh on 12/02/20.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit

class ImageM: NSObject {

    var imgURL: String! = ""
    var isSelected: Bool! = false
    
    
    init(imgUrl: String, isSelected: Bool) {
        
        self.imgURL = imgUrl
        self.isSelected = isSelected
        
    }
}
