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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
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
            _ = self.cardHolderInputView.becomeFirstResponder()
        }
        cardHolderInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.expDate.rawValue)
            _ = self.expDateInputView.becomeFirstResponder()
        }
        expDateInputView.didTapNextButton = { [unowned self] in
            self.scrollView.scrollTo(page: TinyCreditCardInputView.InputType.cscNumder.rawValue)
            _ = self.cscNumberInputView.becomeFirstResponder()
        }
        cscNumberInputView.didTapNextButton = { [unowned self] in
            print("Done")
        }
    }
    
}

extension TinyCreditCardView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}
