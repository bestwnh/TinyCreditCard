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
    
    @IBOutlet weak var cardBgView: UIView!
    @IBOutlet weak var scrollView: FixInputScrollView!
    
    @IBOutlet weak var cardLogoImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    
    @IBOutlet weak var cardNumberInputView: TinyCreditCardInputView!
    @IBOutlet weak var cardHolderInputView: TinyCreditCardInputView!
    @IBOutlet weak var expDateInputView: TinyCreditCardInputView!
    @IBOutlet weak var cscNumberInputView: TinyCreditCardInputView!
    
    var currentPage: Int = 0 {
        didSet {
            guard currentPage != oldValue else { return }
            print("page: \(currentPage)")

            _ = [cardNumberInputView,
             cardHolderInputView,
             expDateInputView,
             cscNumberInputView,][currentPage].becomeFirstResponder()

        }
    }

    @IBOutlet weak var cardNumberButton: UIButton!
    @IBOutlet weak var cardHolderButton: UIButton!
    @IBOutlet weak var expDateButton: UIButton!
    
    let focusArea = UIView()
    
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

        cardBgView.layer.cornerRadius = 8
        cardBgView.layer.masksToBounds = true
        
        scrollView.delegate = self
        cardNumberInputView.type = .cardNumber
        cardHolderInputView.type = .cardHolder
        expDateInputView.type = .expDate
        cscNumberInputView.type = .cscNumder
        
        focusArea.layer.borderColor = UIColor.orange.cgColor
        focusArea.layer.borderWidth = 1
        focusArea.layer.cornerRadius = 6
        addSubview(focusArea)
        DispatchQueue.main.async {
            self.focusArea.frame = self.cardNumberButton.frame
        }
        
        cardNumberInputView.didChangeText = { [unowned self] text in
            self.cardNumberLabel.text = text
            if text.hasPrefix("4") { // visa
                self.cardLogoImageView.image = #imageLiteral(resourceName: "visa")
            } else if text.hasPrefix("5") || text.hasPrefix("2") { // mastercard
                self.cardLogoImageView.image = #imageLiteral(resourceName: "mastercard")
            } else if text.hasPrefix("3") { // amex
                self.cardLogoImageView.image = #imageLiteral(resourceName: "amex")
            } else {
                self.cardLogoImageView.image = nil
            }
            if text.count == 19 {
                self.cardNumberInputView.didTapNextButton()
            }
        }
        cardHolderInputView.didChangeText = { [unowned self] text in
            self.cardHolderLabel.isHidden = text.count <= 0
            self.cardHolderLabel.text = text
        }
        expDateInputView.didChangeText = { [unowned self] text in
            self.expDateLabel.isHidden = text.count <= 0
            self.expDateLabel.text = text
        }
        cardNumberInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cardHolder.rawValue)
        }
        cardHolderInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.expDate.rawValue)
        }
        expDateInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cscNumder.rawValue)
        }
        cscNumberInputView.didTapNextButton = { [unowned self] in
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
            let inset = UIEdgeInsets(top: offset,
                                     left: offset,
                                     bottom: offset,
                                     right: offset)
            focusArea.frame = cardNumberButton.frame.inset(by: inset)

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
            let leftFrame = expDateButton.frame

            focusArea.frame = leftFrame
        } else {
            
        }
    }

}
