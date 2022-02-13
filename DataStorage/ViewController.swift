//
//  ViewController.swift
//  DataStorage
//
//  Created by Кристина Максимова on 16.09.2021.
//

import UIKit

let truePhone = "+79818747596"
let truePassword = "Swift5"
let authKey = "authKey"
let segueId = "fileController"
let fileControllerId = "fileController"
let navKey = "navigationController"

let validColor = UIColor.clear.cgColor
let invalidColor = UIColor.red.cgColor

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var sexControl: UISegmentedControl!
    @IBOutlet weak var notificationsStack: UIStackView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparationOfView()
        addKeyboardGestures()
        switchToAuthorizationMode()
    }
    
    // MARK: Actions
    
    @IBAction func ageSliderAction(_ sender: UISlider) {
        ageLabel.text = "Возраст: \(Int(sender.value))"
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        guard let phone = phoneField.text,
              let password = passwordField.text
        else { return }

        
        let isPhoneValid1 =
            phone.count == 11 &&
            phone.first == "8" &&
            !phone.containsOtherThan(.nums)
            
        let isPhoneValid2 =
            phone.count == 12 &&
            phone.prefix(2) == "+7" &&
            !String(phone.suffix(10)).containsOtherThan(.nums)
        
        let isPhoneValid = isPhoneValid1 || isPhoneValid2
        
        let isPasswordValid =
            password.count > 5 &&
            password.containsUppercase() &&
            password.containsLowercase() &&
            password.containsOtherThan(.letters) &&
            password.containsOtherThan(.nums)
        
        phoneField.layer.borderColor = isPhoneValid ? validColor : invalidColor
        passwordField.layer.borderColor = isPasswordValid ? validColor : invalidColor
    
        
        if isPhoneValid && isPasswordValid {
            if phone == truePhone && password == truePassword {
                UserDefaults.standard.set(true, forKey: authKey)
                performSegue(withIdentifier: segueId, sender: nil)
            } else {
                presentAlert(withTitle: "Ошибка",
                             message: "Неверный логин или пароль")
            }
        }
    }
    
    // MARK: Service
    
    func preparationOfView() {
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .blue
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        ageSlider.value = 34
        
        phoneField.setValidBorder()
        passwordField.setValidBorder()
    }
    
    func switchToAuthorizationMode() {
        ageLabel.isHidden = false
        ageSlider.isHidden = false
        sexControl.isHidden = false
        notificationsStack.isHidden = false

        titleLabel.text = "Регистрация"
        loginButton.setTitle("Зарегистрироваться", for: .normal)
        passwordField.isHidden = false
    }
    
    // MARK: Keyboard
    
    func addKeyboardGestures() {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -(keyboardHeight / 3)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
}

extension String {
    
    enum Chars: String {
        case letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        case nums = "0123456789"
    }
    
    func containsOtherThan(_ chars: Chars) -> Bool {
        let set = CharacterSet(charactersIn: chars.rawValue)
        return self.rangeOfCharacter(from: set.inverted) != nil
    }
    
    func isCapitalized() -> Bool {
        return self == self.capitalized
    }
    
    func containsUppercase() -> Bool {
        return self != self.lowercased()
    }
    
    func containsLowercase() -> Bool {
        return self != self.uppercased()
    }
}

extension UITextField {
    func setValidBorder() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.layer.borderColor = validColor
    }
}

extension UIViewController {
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

