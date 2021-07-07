//
//  ModifyViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/30.
//

import UIKit
import GoogleMobileAds

class ModifyViewController: UIViewController/*, GADBannerViewDelegate*/ {
    
    @IBOutlet weak var modifyTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let modifyViewModel = ModifyViewModel()
    let todoViewModel = TodoViewModel()
//    var bannerView: GADBannerView! // 구글광고!!!!!!!!!!!!!!!!!!!!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        /*// 구글광고!!!!!!!!!!!!!!!!!!!!!!
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        
        addBannerViewToView(bannerView)
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // 테스트
        bannerView.adUnitID = "ca-app-pub-1960781437106390/9678128363" // modify
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        // --------------------------------*/
    }
    
    /*// 구글광고!!!!!!!!!!!!!!!!!!!!!!
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
    // --------------------------------*/
    
    func updateUI() {
        if let todo = modifyViewModel.todo {
            modifyTextView.text = todo.detail
        }
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        modifyTextView.resignFirstResponder()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
        guard let detail = modifyTextView.text, detail.isEmpty == false else { return }
        if var todo = modifyViewModel.todo {
            todo.detail = modifyTextView.text
            todoViewModel.updateTodo(todo)
        }
        TodoViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromModify", sender: self)
    }
}

class ModifyViewModel {
    
    var todo: Todo?
    func update(model: Todo?) {
        todo = model
        //        print(todo)
    }
}
