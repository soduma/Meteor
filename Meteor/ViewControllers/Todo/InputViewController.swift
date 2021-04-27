//
//  InputViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/16.
//

import UIKit
import GoogleMobileAds

class InputViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let todoViewModel = TodoViewModel()
    
    var bannerView: GADBannerView! // 구글광고!!!!!!!!!!!!!!!!!!!!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.text = ""
                
        // 구글광고!!!!!!!!!!!!!!!!!!!!!!
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        // --------------------------------
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextView.becomeFirstResponder()
    }
    
    // 구글광고!!!!!!!!!!!!!!!!!!!!!!
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Add banner to view and add constraints as above.
        addBannerViewToView(bannerView)
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    // --------------------------------
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        inputTextView.resignFirstResponder()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
        guard let detail = inputTextView.text, detail.isEmpty == false else { return }
        let todo = TodoManager.shared.createTodo(detail: detail)
        todoViewModel.addTodo(todo)
        inputTextView.text = ""
        TodoViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromInput", sender: self)
    }
}
