//
//  StartViewController.swift
//  PhotoApp
//
//  Created by wflower on 06/02/2020.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit
import Photos
import DKImagePickerController


class StartViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   

    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    
    let pickerController = DKImagePickerController()
    
    @IBOutlet weak var cameraButtonLabel: UILabel!
    @IBOutlet weak var galleryButtonLabel: UILabel!
    @IBOutlet weak var lastphtoButtonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraButtonLabel.text = NSLocalizedString("camera_button", comment: "")
        self.galleryButtonLabel.text = NSLocalizedString("gallery_button", comment: "")
        self.lastphtoButtonLabel.text = NSLocalizedString("last_photo_button", comment: "")
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        print(dateString)
    
        pickerController.assetType = .allPhotos
        pickerController.showsCancelButton = true
        
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            if(assets.count > 0) {
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                for asset in assets {
                    asset.fetchOriginalImage(options: option, completeBlock: { image, info in
                        self.photoArray.append(image!)
                    })
                }
                self.pickerController.deselectAll()
                self.performSegue(withIdentifier: "starttoprocessingsegue", sender: self)
            }
            
//
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let processingimageVC = mainStoryboard.instantiateViewController(withIdentifier: "ImageProcessingViewController") as! ImageProcessingViewController
//            processingimageVC.source_images = self.photoArray
//            self.navigationController?.pushViewController(processingimageVC, animated: true)
        }
        
        pickerController.didCancel = {() in
            self.pickerController.deselectAll()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.photoArray.removeAll()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let progressVC = segue.destination as! ImageProcessingViewController
        progressVC.source_images = self.photoArray
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
    
     
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let oritentationFiexImage = image?.fixOrientation()
        self.photoArray.append(oritentationFiexImage!)
        picker.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "starttoprocessingsegue", sender: self)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("camera is not available")
        }
    }
    
    @IBAction func galleryButtonAction(_ sender: Any) {
        
        self.present(pickerController, animated: true) {}
        
    }
    
    @IBAction func lastphotoButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lastphotoVC = mainStoryboard.instantiateViewController(withIdentifier: "LastPhotoViewController") as! LastPhotoViewController
        self.navigationController?.pushViewController(lastphotoVC, animated: true)
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }


}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
