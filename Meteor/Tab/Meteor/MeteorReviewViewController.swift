//
//  MeteorReviewViewController.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/23.
//

import UIKit
import SnapKit
import Lottie

class MeteorReviewViewController: UIViewController {
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let colorsConfig = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: colorsConfig.applying(sizeConfig))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("rate", comment: "")
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("rate comment", comment: "")
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "lottie_face")
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var moveButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("rate button", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .yellow.withAlphaComponent(0.5)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lottieView.loopMode = .loop
        lottieView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        lottieView.stop()
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        
        [closeButton, headerLabel, descriptionLabel, lottieView, moveButton]
            .forEach { view.addSubview($0) }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(24)
        }
        
        headerLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(headerLabel.snp.bottom).offset(8)
        }
        
        lottieView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(-80)
            $0.leading.equalToSuperview().inset(-200)
            $0.trailing.equalToSuperview().inset(-200)
        }
        
        moveButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(lottieView.snp.centerY).offset(120)
        }
    }
    
    @objc private func closeButtonTapped() {
        UserDefaults.standard.set(0, forKey: customAppReviewCountKey)
        dismiss(animated: true)
    }
    
    @objc private func moveButtonTapped() {
        let url = "https://apps.apple.com/app/id1562989730?action=write-review"
        guard let writeReviewURL = URL(string: url) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
        UserDefaults.standard.set(SettingViewModel().getCurrentVersion(), forKey: lastVersionKey)
        
        dismiss(animated: true)
    }
}
