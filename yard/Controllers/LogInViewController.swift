//
//  LogInViewController.swift
//  yard
//
//  Created by Dara Ladjevardian on 5/5/19.
//  Copyright © 2019 Dara Ladjevardian. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    
    // MARK: Constants
    let loginToList = "LoginToList"
    
    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Actions
    @IBAction func loginDidTouch(_ sender: Any) {
        performSegue(withIdentifier: loginToList, sender: nil)
    }
    @IBAction func signUpDidTouch(_ sender: Any) {
        performSegue(withIdentifier: "signUp", sender: nil)
    }

}
extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
