//
//  SettingsViewController.swift
//  PhotoApp
//
//  Created by wflower on 10/02/2020.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import AVKit
import AVFoundation

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsLabel.text = NSLocalizedString("settings_label", comment: "")
        self.helpButton.setTitle(NSLocalizedString("help_button", comment: ""), for: .normal)
        self.contactButton.setTitle(NSLocalizedString("contact_developer_button", comment: ""), for: .normal)
        self.shareButton.setTitle(NSLocalizedString("share_app_button", comment: ""), for: .normal)
        self.rateButton.setTitle(NSLocalizedString("rate_app_button", comment: ""), for: .normal)
        self.privacyButton.setTitle(NSLocalizedString("privacy_button", comment: ""), for: .normal)
        self.termsButton.setTitle(NSLocalizedString("terms_button", comment: ""), for: .normal)
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "help_video", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func contactButtonAction(_ sender: Any) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([])
        mailVC.setSubject("")
        mailVC.setMessageBody("", isHTML: false)

        present(mailVC, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
        let activityController = UIActivityViewController(activityItems: ["https://itunes.apple.com/us/app/myapp/id1302071480?ls=1&mt=8"], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func rateButtonAction(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func privacyButtonAction(_ sender: Any) {
        guard let url = URL(string: "https://www.google.com") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func termsButtonAction(_ sender: Any) {
        guard let url = URL(string: "https://www.google.com") else { return }
        UIApplication.shared.open(url)
    }

}
