//
//  LastPhotoViewController.swift
//  PhotoApp
//
//  Created by wflower on 08/02/2020.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit
import Kingfisher

class LastPhotoViewController: UIViewController {
   
    struct TableItem {
        let title: String
        let creationDate: NSDate
    }
    
    var sections = Dictionary<String, Array<ImageM>>()
    var sortedSections = [String]()
    
    var source_images = [UIImage]()
    var dest_images = [URL]()
    var selectedImgArr = [String]()
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressContainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIButton!
    
    var progressStage = 1
    var progress = Progress()
    var imgBasePath = ""
    var isSelected = false
    var images = [ImageM]()
    
    let spacing:CGFloat = 0.0
    let numberOfItemsPerRow:CGFloat = 4
    let spacingBetweenCells:CGFloat = 0
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        
        self.shareButton.layer.cornerRadius = 20
        self.shareButton.setTitle(NSLocalizedString("share_button", comment: ""), for: .normal)
        
        self.selectButton.setTitle(NSLocalizedString("select_button", comment: ""), for: .normal)
        
        let hview = UINib.init(nibName: "HeaderView", bundle: nil)
        
        collectionView.register(hview, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:"HeaderView")
        
        print("wew");
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.loadAllImages()
    }


    func loadAllImages(){
        DispatchQueue.global(qos: .background).async {
            
            let imgs = self.loadImagesFromAlbum()
            
            let df = DateFormatter()
            df.dateFormat = "MMM dd yyyy"
            //            let currentDateMillisecond = Int(currentDate.timeIntervalSince1970 * 1000)
            for (_, element) in imgs.enumerated(){
                
                if element.contains(".png") {
                    let nsStr = (element as NSString).substring(to: element.count-7)
                    
                    let timeStamp = Double(nsStr)
                    
                    let dateD = Date(timeIntervalSince1970: timeStamp!)
                    
                    let date:String = df.string(from: dateD)
                    
                    //                        let date = dateD.timeAgoDisplay()
                    
                    //if we don't have section for particular date, create new one, otherwise we'll just add item to existing section
                    if self.sections.index(forKey: date) == nil {
                        let imgM = ImageM.init(imgUrl: element, isSelected: false)
                        self.sections[date] = [imgM]
                    }
                    else {
                        let imgM = ImageM.init(imgUrl: element, isSelected: false)
                        self.sections[date]!.append(imgM)
                    }
                    
                    //we are storing our sections in dictionary, so we need to sort it
                    self.sortedSections = Array(self.sections.keys).sorted(by: >)
                    
                    //                let imgM = ImageM.init(imgUrl: element, isSelected: false)
                    //                self.images.append(imgM)
                }
                
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stopActivityIndicator()
                
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSelect(_ sender: UIButton) {
        isSelected = !isSelected
        if isSelected {
            sender.setTitle(NSLocalizedString("selected_button", comment: ""), for: .normal)
        } else {
            sender.setTitle(NSLocalizedString("select_button", comment: ""), for: .normal)
        }
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        if self.selectedImgArr.count == 0 {
            return
        }
        var shareImages = [UIImage]()
        for i in 0..<self.selectedImgArr.count {
            let imageURL = URL(fileURLWithPath: self.imgBasePath).appendingPathComponent(self.selectedImgArr[i])
            let image    = UIImage(contentsOfFile: imageURL.path)
            
//                let imageData = try Data(contentsOf: self.dest_images[i])
            shareImages.append(image!)

        }
        let activityController = UIActivityViewController(activityItems: shareImages, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    func loadImagesFromAlbum() -> [String]{
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        let mainPath = paths.first
        
        let folderPath = mainPath! + "/photoapp/"
        
        var theItems = [String]()
        
        imgBasePath = folderPath
        
        print("Bae url \(imgBasePath)")
        
        //            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
        let imageURL = URL(fileURLWithPath: folderPath)
        
        do {
            theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
            return theItems
        } catch let error as NSError {
            print(error.localizedDescription)
            return theItems
        }
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

extension LastPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if sections.count == 0 {
            return 0
        }
        
        return sections[sortedSections[section]]!.count //images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView

            let df = DateFormatter()
            df.dateFormat = "MMM dd yyyy"
//
            let date = df.date(from: sortedSections[indexPath.section])
            
            let str = date?.timeAgoDisplay()
            
            headerView.backgroundColor = UIColor.white
            headerView.lblTitle.text = sortedSections[indexPath.section]
            return headerView

        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let tbSection = sections[sortedSections[indexPath.section]]
        let img = tbSection![indexPath.row]
        let imageURL = URL(fileURLWithPath: self.imgBasePath).appendingPathComponent(img.imgURL)

        cell.bg.kf.setImage(with: imageURL)
           
        cell.widhtCon.constant = cell.frame.size.width
        cell.heightCon.constant = cell.frame.size.height
        
        if img.isSelected{
            cell.ivSelect.image = UIImage.init(named: "checked")
        } else {
            cell.ivSelect.image = UIImage.init(named: "unchecked")
        }
        return cell
         
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let totalSpacing = (numberOfItemsPerRow * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            
//            cell.widhtCon.constant = width
//            cell.heightCon.constant = width
            
            return CGSize(width: width-10, height: width-10)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let img = images[indexPath.row]
        
        let tbSection = sections[sortedSections[indexPath.section]]
        let img = tbSection![indexPath.row]
        
        if isSelected {
            
            if selectedImgArr.contains(img.imgURL){
                selectedImgArr.firstIndex(of: img.imgURL).map{ selectedImgArr.remove(at: $0) }
            }else{
                selectedImgArr.append(img.imgURL)
            }
            
            img.isSelected = !img.isSelected
                        
//            let indexP = IndexPath.init(row: indexPath.row, section: 1)
////
//            var indexPaths = [IndexPath]()
//            indexPaths.append(indexP)
//
//            self.collectionView.reloadItems(at: indexPaths)
//            self.collectionView.reloadData()
            
//            let indexPath1 = IndexPath(item: 0, section: 0)
            collectionView.reloadItems(at: [indexPath])
            
        } else {
            
            let imageURL = URL(fileURLWithPath: imgBasePath).appendingPathComponent(img.imgURL)
            let image    = UIImage(contentsOfFile: imageURL.path)
            
            let vc = self.storyboard?.instantiateViewController(identifier: "ShowImageVC") as! ShowImageVC
            vc.image = image
            
            self.present(vc, animated: true, completion: nil)
        }
    }
}



extension Date {
    func timeAgoDisplay() -> String {

        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let monthAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
//        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
//            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
//            return "\(diff) sec ago"
            return "Today"
        } else if hourAgo < self {
//            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
//            return "\(diff) min ago"
            return "Today"
        } else if dayAgo < self {
//            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
//            return "\(diff) hrs ago"
            return "Today"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            
            if diff < 3 {
                return "\(diff) days ago"
            }
            return "1 week ago"
            
        }
//        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
//
//        if diff > 1 {
            
            let df = DateFormatter()
            df.dateFormat = "MMM yyyy"
            
            
            return df.string(from: self)
//        }else{
//
//            return "\(diff) week ago"
//        }
    }
}
