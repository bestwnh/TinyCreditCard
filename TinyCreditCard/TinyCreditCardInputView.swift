//
//  TinyCreditCardInputView.swift
//  TinyCreditCard
//
//  Created by Galvin on 2019/2/26.
//  Copyright © 2019 @GalvinLi. All rights reserved.
//

import UIKit

class TinyCreditCardInputView: UIView {
    enum InputType: Int {
        case cardNumber = 0, cardHolder, expDate, cscNumder
    }
    var didChangeText: (String) -> () = { _ in }
    var didTapNextButton: () -> () = {}
    
    private let textField: UITextField = UITextField()
    private let button: UIButton = UIButton(type: .custom)

    var type: InputType = .cardHolder {
        didSet {
            switch type {
            case .cardNumber:
                textField.keyboardType = .numberPad
                textField.returnKeyType = .next
            case .cardHolder:
                textField.keyboardType = .default
                textField.autocorrectionType = .no
                textField.returnKeyType = .next
            case .expDate:
                let pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
                textField.inputView = pickerView
            case .cscNumder:
                textField.keyboardType = .numberPad
                textField.returnKeyType = .done
            }
            let doneToolbar:UIToolbar = UIToolbar()
            doneToolbar.barStyle = .blackTranslucent
            doneToolbar.tintColor = UIColor.white
            doneToolbar.items = [
                UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(resignFirstResponder)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: type == .cscNumder ? "Done" : "Next", style: .plain, target: self, action: #selector(didTapToolbarNext))
            ]
            doneToolbar.sizeToFit()
            textField.inputAccessoryView = doneToolbar
        }
    }
    @IBInspectable var placeHolder: String? {
        set { textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [.foregroundColor : UIColor.gray]) }
        get { return textField.placeholder }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
    }
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc func didTapToolbarNext() {
        didTapNextButton()
    }
}

private extension TinyCreditCardInputView {
    func initView() {
        self.backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        do { // layout
            addSubview(textField)
            addSubview(button)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false

            textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
            textField.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: 5).isActive = true
            
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.addTarget(self, action: #selector(formatTextField), for: .editingChanged)
        textField.addTarget(self, action: #selector(tapTextFieldReturn), for: .editingDidEndOnExit)

        button.isHidden = true
        button.setImage(#imageLiteral(resourceName: "angle-right"), for: .normal)
        button.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(tapNextButton), for: .touchUpInside)
    }
    @objc func tapNextButton() {
        didTapNextButton()
    }
    @objc func tapTextFieldReturn() {
        if !button.isHidden {
            tapNextButton()
        } else {
            textField.resignFirstResponder()
        }
    }
    @objc func formatTextField(_ sender: UITextField) {
        switch type {
        case .cardNumber:
            let rawText = textField.text?.components(separatedBy: " ").joined() ?? ""
            var newText = String(rawText.prefix(16))
            
            let spaceIndex = [12, 8, 4]
            
            for index in spaceIndex {
                guard newText.count >= index + 1 else { continue }
                newText.insert(" ", at: String.Index(encodedOffset: index))
            }
            
            setText(newText)
            
        case .cardHolder:
            setText(textField.text)
        case .expDate:
            break
        case .cscNumder:
            setText(textField.text)
        }
        
        didChangeText(textField.text ?? "")
    }
    func setText(_ text: String?) {
        if textField.text != text {
            textField.text = text
        }
        guard let text = text, text.count != 0 else { return button.isHidden = true }
        switch type {
        case .cardNumber:
            button.isHidden = text.count != 19
        case .cardHolder:
            button.isHidden = false
        case .expDate:
            button.isHidden = false
        case .cscNumder:
            button.isHidden = text.count < 3
        }
    }
}

extension TinyCreditCardInputView: UIPickerViewDataSource, UIPickerViewDelegate {
    enum ExpDate: Int, CaseIterable {
        case month
        case year
        var data: [String] {
            switch self {
            case .month:
                return (1...12).map({ String(format: "%02d", arguments: [$0]) })
            case .year:
                let year = Calendar.current.component(.year, from: Date())
                return (year...year + 20).map(String.init)
            }
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return ExpDate.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ExpDate(rawValue: component)?.data.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ExpDate(rawValue: component)?.data[row] ?? ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = ExpDate.month.data[pickerView.selectedRow(inComponent: ExpDate.month.rawValue)]
        let year = ExpDate.year.data[pickerView.selectedRow(inComponent: ExpDate.year.rawValue)]
        setText("\(month)/\(year)")
        didChangeText("\(month)/\(year.suffix(2))")
    }
}
