//
//  MeteorInputViewController.swift
//  Meteor
//
//  Created by 장기화 on 2023/09/07.
//

import UIKit
import SnapKit

protocol MeteorInputDelegate: AnyObject {
    func setInputtedText(text: String)
}

class MeteorInputViewController: UIViewController {
    weak var delegate: MeteorInputDelegate?
    var gesture = UIPanGestureRecognizer()
    var rectangleViewOriginalX: CGFloat = 0
    var rectangleViewOriginalY: CGFloat = 0
    var absoluteY: CGFloat = 0
    
    let meteorText: String
    let labelPositionY: CGFloat
    
    init(meteorText: String, labelPositionY: CGFloat) {
        self.meteorText = meteorText
        self.labelPositionY = labelPositionY
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private lazy var rectangleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.6)
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(rectangleViewDragged))
        self.gesture = gesture
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 25, weight: .medium)
        view.backgroundColor = .clear
        view.tintColor = .red
        view.delegate = self
        return view
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        button.setImage(UIImage(systemName: "xmark.bin.circle.fill", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .systemGray2
        button.alpha = 0
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        openingAnimation()
    }
    
    private func setInitialLayout() {
        view.alpha = 0
        textView.text = meteorText
        
        [visualEffectView, rectangleView].forEach {
            view.addSubview($0)
        }
        
        visualEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rectangleView.snp.makeConstraints {
            $0.centerY.equalTo(view.snp.top).offset(labelPositionY)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        [textView, clearButton, enterButton, grabberView].forEach {
            rectangleView.addSubview($0)
        }
        
        clearButton.snp.makeConstraints {
            $0.centerX.equalTo(enterButton)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
    }
    
    private func openingAnimation() {
        rectangleView.snp.remakeConstraints {
            $0.centerY.equalTo(view.snp.top).offset(labelPositionY - 40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(220)
        }
        
        textView.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(enterButton.snp.leading)
            $0.bottom.equalTo(grabberView).inset(20)
        }
        
        enterButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        grabberView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(100)
            $0.height.equalTo(4)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) { [weak self] in
            guard let self else { return }
            view.alpha = 1
            view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self else { return }
            rectangleViewOriginalX = gesture.view!.center.x
            rectangleViewOriginalY = gesture.view!.center.y
            textView.becomeFirstResponder()
            makeVibration(type: .rigid)
        }
    }
    
    @objc private func rectangleViewDragged(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        sender.view!.center = CGPoint(x: sender.view!.center.x + (translation.x / 10),
                                      y: sender.view!.center.y + (translation.y / 10)) // 나누기 10해서 속도 늦춤
        absoluteY += translation.y
        print("🙏🏻 \(absoluteY)")
        
        sender.setTranslation(.zero, in: view)
        print("🌈 \(translation.y)")
        
        switch sender.state {
        case .ended:
            if abs(velocity.y) > 500 || absoluteY > 300 { // 빠르게 할 때만 디스미스
                textView.resignFirstResponder()
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self else { return }
                    view.alpha = 0
                    sender.view!.center = CGPoint(x: rectangleViewOriginalX, y: 1000)
                    view.layoutIfNeeded()
                } completion: { _ in
                    self.dismiss(animated: false)
                }
                
            } else {
                absoluteY = 0
                UIView.animate(withDuration: 0.2) { [weak self] in
                    guard let self else { return }
                    sender.view!.center = CGPoint(x: rectangleViewOriginalX, y: rectangleViewOriginalY)
                    view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
    
    @objc private func clearButtonTapped() {
        textView.text = ""
        clearButton.alpha = 0
    }
    
    @objc private func enterButtonTapped() {
        makeVibration(type: .rigid)
        textView.resignFirstResponder()
        
        rectangleView.snp.remakeConstraints {
            $0.centerY.equalTo(view.snp.top).offset(labelPositionY)
            $0.width.equalTo(0)
            $0.height.equalTo(0)
        }
        
        textView.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(enterButton.snp.leading)
            $0.bottom.equalTo(grabberView).inset(20)
        }
        
        enterButton.snp.remakeConstraints {
            $0.width.height.equalTo(0)
        }
        
        grabberView.snp.remakeConstraints {
            $0.width.equalTo(0)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            guard let self else { return }
            view.alpha = 0
            view.layoutIfNeeded()
            delegate?.setInputtedText(text: textView.text)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

extension MeteorInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        clearButtonAnimation(textView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        clearButtonAnimation(textView: textView)
        textView.textColor = .label // 텍스트뷰 크기조정 트릭
    }
    
    private func clearButtonAnimation(textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            if textView.hasText {
                self.clearButton.alpha = 1
            } else {
                self.clearButton.alpha = 0
            }
        }
    }
}
