//
//  TinyCreditCardView.swift
//  TinyCreditCard
//
//  Created by Galvin on 2019/2/13.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

import UIKit

class FixInputScrollView: UIScrollView {
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        // fix scrollview auto move when input start editting
    }
    func scrollTo(page: Int) {
        var rect = bounds
        rect.origin.x = rect.width * CGFloat(page)
        UIView.animate(withDuration: 0.5) {
            super.scrollRectToVisible(rect, animated: false)
        }
    }
}

class TinyCreditCardView: UIView {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var cardFrontView: UIView!
    @IBOutlet weak var scrollView: FixInputScrollView!
    
    @IBOutlet weak var cardBrandImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    
    @IBOutlet weak var cardNumberInputView: TinyCreditCardInputView!
    @IBOutlet weak var cardHolderInputView: TinyCreditCardInputView!
    @IBOutlet weak var expDateInputView: TinyCreditCardInputView!
    @IBOutlet weak var cscNumberInputView: TinyCreditCardInputView!
    
    @IBOutlet weak var cardNumberButton: UIButton!
    @IBOutlet weak var cardHolderButton: UIButton!
    @IBOutlet weak var expDateButton: UIButton!
    
    let cardBackView = TinyCreditCardBackView()
    let focusArea = UIView()
    
    var currentPage: Int = 0 {
        didSet {
            guard currentPage != oldValue else { return }
            print("page: \(currentPage)")
            
            let inputs: [TinyCreditCardInputView] = [
                cardNumberInputView,
                cardHolderInputView,
                expDateInputView,
                cscNumberInputView,
                ]
            _ = inputs[currentPage].becomeFirstResponder()
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    @IBAction func tapCardNumberButton(_ sender: UIButton) {
        scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cardNumber.rawValue)
    }
    @IBAction func tapCardHolderButton(_ sender: UIButton) {
        scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cardHolder.rawValue)
    }
    @IBAction func tapExpDateButton(_ sender: UIButton) {
        scrollView.scrollTo(page: TinyCreditCardInputView.InputType.expDate.rawValue)
    }
    
}

private extension TinyCreditCardView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    func initNibView() {
        guard let view = TinyCreditCardView.nib
            .instantiate(withOwner: self, options: nil)
            .compactMap({ $0 as? UIView })
            .first else {
                return
        }
        
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    func initView() {
        initNibView()

        backgroundColor = .clear

        cardFrontView.layer.cornerRadius = 8
        cardFrontView.layer.masksToBounds = true
        
        cardContainerView.addSubview(cardBackView)
        cardBackView.translatesAutoresizingMaskIntoConstraints = false
        cardBackView.leadingAnchor.constraint(equalTo: cardFrontView.leadingAnchor).isActive = true
        cardBackView.trailingAnchor.constraint(equalTo: cardFrontView.trailingAnchor).isActive = true
        cardBackView.topAnchor.constraint(equalTo: cardFrontView.topAnchor).isActive = true
        cardBackView.bottomAnchor.constraint(equalTo: cardFrontView.bottomAnchor).isActive = true
        cardBackView.isHidden = true
        
        scrollView.delegate = self
        cardNumberInputView.type = .cardNumber
        cardHolderInputView.type = .cardHolder
        expDateInputView.type = .expDate
        cscNumberInputView.type = .cscNumder
        
        focusArea.layer.borderColor = UIColor.orange.cgColor
        focusArea.layer.borderWidth = 1
        focusArea.layer.cornerRadius = 6
        cardFrontView.addSubview(focusArea)
        DispatchQueue.main.async {
            self.focusArea.frame = self.cardNumberButton.frame
        }
        
        cardNumberInputView.didChangeText = { [unowned self] text in
            self.cardNumberLabel.text = text
            if text.hasPrefix("4") { // visa
                self.cardBrandImageView.image = #imageLiteral(resourceName: "visa")
            } else if text.hasPrefix("5") || text.hasPrefix("2") { // mastercard
                self.cardBrandImageView.image = #imageLiteral(resourceName: "mastercard")
            } else if text.hasPrefix("3") { // amex
                self.cardBrandImageView.image = #imageLiteral(resourceName: "amex")
            } else {
                self.cardBrandImageView.image = nil
            }
            self.cardBackView.cardBrandImage = self.cardBrandImageView.image
            if text.count == 19 {
                self.cardNumberInputView.didTapNextButton()
            }
        }
        cardHolderInputView.didChangeText = { [unowned self] text in
            self.cardHolderLabel.isHidden = text.count <= 0
            self.cardHolderLabel.text = text.uppercased()
            self.cardBackView.cardHolder = text.capitalized
        }
        expDateInputView.didChangeText = { [unowned self] text in
            self.expDateLabel.isHidden = text.count <= 0
            self.expDateLabel.text = text
        }
        cscNumberInputView.didChangeText = { [unowned self] text in
            self.cardBackView.cscNumber = text
        }
        cardNumberInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cardHolder.rawValue)
        }
        cardHolderInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.expDate.rawValue)
        }
        expDateInputView.didTapNextButton = { [unowned self] in
            self.cardBackView.layer.transform = CATransform3DIdentity
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cscNumder.rawValue)
        }
        cscNumberInputView.didTapNextButton = {
            print("Done")
        }
    }
}

extension TinyCreditCardView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageValue = scrollView.contentOffset.x / scrollView.bounds.width
        let page = Int(pageValue)
        if pageValue == CGFloat(page) {
            currentPage = page
        }
        print("pageValue: \(pageValue)")
        if pageValue <= CGFloat(TinyCreditCardInputView.InputType.cardNumber.rawValue) {
            let offset: CGFloat = 20 * pageValue
            focusArea.frame = cardNumberButton.frame.insetBy(dx: offset, dy: offset)

        } else if pageValue < CGFloat(TinyCreditCardInputView.InputType.cardHolder.rawValue) {
            let percent = pageValue.truncatingRemainder(dividingBy: 1)
            let leftFrame = cardNumberButton.frame
            let rightFrame = cardHolderButton.frame
            
            focusArea.frame = CGRect(x: (rightFrame.origin.x - leftFrame.origin.x) * percent + leftFrame.origin.x,
                                           y: (rightFrame.origin.y - leftFrame.origin.y) * percent + leftFrame.origin.y,
                                           width: (rightFrame.width - leftFrame.width) * percent + leftFrame.width,
                                           height: (rightFrame.height - leftFrame.height) * percent + leftFrame.height)
        } else if pageValue < CGFloat(TinyCreditCardInputView.InputType.expDate.rawValue) {
            let percent = pageValue.truncatingRemainder(dividingBy: 1)
            let leftFrame = cardHolderButton.frame
            let rightFrame = expDateButton.frame
            
            focusArea.frame = CGRect(x: (rightFrame.origin.x - leftFrame.origin.x) * percent + leftFrame.origin.x,
                                           y: (rightFrame.origin.y - leftFrame.origin.y) * percent + leftFrame.origin.y,
                                           width: (rightFrame.width - leftFrame.width) * percent + leftFrame.width,
                                           height: (rightFrame.height - leftFrame.height) * percent + leftFrame.height)
        } else if pageValue < CGFloat(TinyCreditCardInputView.InputType.cscNumder.rawValue) {
            let percent = pageValue.truncatingRemainder(dividingBy: 1)
            focusArea.frame = expDateButton.frame
            
            if percent < 0.5 {
                // show cardBgView
                cardFrontView.isHidden = false
                cardBackView.isHidden = true
            } else {
                // show cardBackView
                cardFrontView.isHidden = true
                cardBackView.isHidden = false
            }

            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / -800
            cardFrontView.layer.transform = CATransform3DRotate(transform, -CGFloat.pi * percent, 0, 1, 0)
            cardBackView.layer.transform = CATransform3DRotate(transform, -CGFloat.pi * percent - CGFloat.pi, 0, 1, 0)
            
        } else {
            if pageValue == CGFloat(TinyCreditCardInputView.InputType.cscNumder.rawValue) && cardBackView.isHidden {

                cardFrontView.layer.transform = CATransform3DIdentity
                cardBackView.layer.transform = CATransform3DIdentity
                let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]

                UIView.transition(with: cardContainerView, duration: 0.5, options: transitionOptions, animations: {
                    self.cardFrontView.isHidden = true
                    self.cardBackView.isHidden = false
                })

            }
            let percent = pageValue.truncatingRemainder(dividingBy: 1)
            cardBackView.updateFocusArea(progress: percent)
        }
    }

}
