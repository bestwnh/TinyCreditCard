//
//  TinyCreditCardBackView.swift
//  TinyCreditCard
//
//  Created by Galvin on 2019/2/28.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

import UIKit

class TinyCreditCardBackView: UIView {

    @IBOutlet weak var cardBrandImageView: UIImageView!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var cscNumberLabel: UILabel!
    @IBOutlet weak var cscArea: UIView!
    
    let focusArea = UIView()

    var cscNumber: String? {
        set { cscNumberLabel.text = newValue }
        get { return cscNumberLabel.text }
    }
    var cardHolder: String? {
        set { cardHolderLabel.text = newValue }
        get { return cardHolderLabel.text }
    }
    var cardBrandImage: UIImage? {
        set { cardBrandImageView.image = newValue }
        get { return cardBrandImageView.image }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
}

extension TinyCreditCardBackView {
    func updateFocusArea(progress: CGFloat) {
        let offset: CGFloat = -20 * progress - 6
        focusArea.frame = cscArea.frame.insetBy(dx: offset, dy: offset)
    }
}

private extension TinyCreditCardBackView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    func initNibView() {
        guard let view = TinyCreditCardBackView.nib
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
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        focusArea.layer.borderColor = UIColor.orange.cgColor
        focusArea.layer.borderWidth = 1
        focusArea.layer.cornerRadius = 6
        addSubview(focusArea)
        DispatchQueue.main.async {
            self.focusArea.frame = self.cscArea.frame.insetBy(dx: 6, dy: 6)
        }
    }
    
}
