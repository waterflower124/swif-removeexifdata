//
//  ImageProcessingViewController.swift
//  PhotoApp
//
//  Created by wflower on 08/02/2020.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class ImageProcessingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var imageTableVIew: UITableView!
    var source_images = [UIImage]()
    var dest_images = [URL]()
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressContainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    var progressStage = 1
    var progress = Progress()
    
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareButton.layer.cornerRadius = 20
        self.shareButton.setTitle(NSLocalizedString("share_button", comment: ""), for: .normal)
        
        progressStage = 0
        
        self.imageTableVIew.separatorStyle = .none
        self.progressView.progress = 0
        self.progress = Progress(totalUnitCount: Int64(self.source_images.count))

    }
    
    func updateProgress(progress: Int) {
        
        DispatchQueue.main.async {
                        
            print(self.progressStage)
            
            self.progressLabel.text = "\(self.progressStage * 100 / (self.source_images.count))% ... "
            self.progress.completedUnitCount += 1
            let progressFlot = Float(self.progress.fractionCompleted)
            self.progressView.setProgress(progressFlot, animated: true)
            if(self.progressStage == self.source_images.count) {
                self.progressContainViewHeight.constant = 0
                self.progressContainerView.isHidden = true
            }
            
            print("\(progress * 100 / self.source_images.count)")
        }

    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        for i in 0..<self.source_images.count {
            
            DispatchQueue.global(qos: .background).async {
                let exifremovedImageData = self.removeExifData(data: self.source_images[i].pngData()! as NSData)
                if(exifremovedImageData != nil) {
                    let orientation = self.DetectOrientation(img: UIImage(data: exifremovedImageData! as Data)!)
                    DispatchQueue.main.async {
                        self.dest_images.append(self.saveImageToDocumentDirectory(image: UIImage(data: exifremovedImageData! as Data)!))

                        self.progressStage = self.progressStage+1
                        
                        self.imageTableVIew.reloadData()
                        self.updateProgress(progress: i + 1)

                    }
                }
            }
        }
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        var shareImages = [UIImage]()
        for i in 0..<self.dest_images.count {
            do {
                let imageData = try Data(contentsOf: self.dest_images[i])
                shareImages.append(UIImage(data: imageData)!)
            } catch {
            
            }
        }
        let activityController = UIActivityViewController(activityItems: shareImages, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func DetectOrientation(img : UIImage) -> UIImage.Orientation{
        var newOrientation = UIImage.Orientation.up
        switch (img.imageOrientation)
        {
        case .up:
            newOrientation = UIImage.Orientation.up;
            break;
        case .down:
            newOrientation = UIImage.Orientation.down;
            break;
        case .left:
            newOrientation = UIImage.Orientation.left;
            break;
        case .right:
            newOrientation = UIImage.Orientation.right;
            break;
        case .upMirrored:
            newOrientation = UIImage.Orientation.upMirrored;
            break;
        case .downMirrored:
            newOrientation = UIImage.Orientation.downMirrored;
            break;
        case .leftMirrored:
            newOrientation = UIImage.Orientation.leftMirrored;
            break;
        case .rightMirrored:
            newOrientation = UIImage.Orientation.rightMirrored;
            break;
        @unknown default: break
            
        }
        return newOrientation;
    }
    
    func removeExifData(data: NSData) -> NSData? {
      guard let source = CGImageSourceCreateWithData(data, nil) else {
          return nil
      }
      guard let type = CGImageSourceGetType(source) else {
          return nil
      }
      let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData(data: data as Data)
      guard let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else {
          return nil
      }
      // Check the keys for what you need to remove
      // As per documentation, if you need a key removed, assign it kCFNull
      let removeExifProperties: Dictionary = [String(kCGImagePropertyExifDictionary): kCFNull,
                                                String(kCGImagePropertyGPSDictionary): kCFNull]

      for i in 0..<count {
        CGImageDestinationAddImageFromSource(destination, source, i, removeExifProperties as CFDictionary)
      }

      guard CGImageDestinationFinalize(destination) else {
          return nil
      }

      return mutableData;
    }
    
    func saveImageToDocumentDirectory(image: UIImage) -> URL {
        var objCBool: ObjCBool = true
//        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        let mainPath = paths.first
        
        let folderPath = mainPath! + "/photoapp/"

        let isExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &objCBool)
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDate = Date()
        let currentDateMillisecond = Int(currentDate.timeIntervalSince1970 * 1000)
        let imageName = "\(currentDateMillisecond).png"
        let imageUrl = documentDirectory.appendingPathComponent("photoapp/\(imageName)")
        if let data = image.pngData(){
            do {
                try data.write(to: imageUrl)
            } catch {
                print("error saving", error)
            }
        }
        
        return imageUrl
    }
    
    func loadImagesFromAlbum(folderName:String) -> [String]{

        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var theItems = [String]()
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)

            do {
                theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
                return theItems
            } catch let error as NSError {
                print(error.localizedDescription)
                return theItems
            }
        }
        return theItems
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dest_images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "processtableviewcell") as! ProcessingTableViewCell

        cell.processImageView.kf.setImage(with: self.dest_images[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func startActivityIndicator() {
        
        overlayView = UIView(frame:view.frame);
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.6;
        view.addSubview(overlayView);
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = .large;
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        self.view.isUserInteractionEnabled = false
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating();
        self.overlayView.removeFromSuperview();
        if !self.view.isUserInteractionEnabled {
            self.view.isUserInteractionEnabled = true
        }
    }

}
