//
//  RegisterViewController.swift
//  Family Chat
//
//  Created by Jerry Ding on 2018-05-07.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if passwordTextField.text == confirmPasswordTextField.text {
            
            SVProgressHUD.show()
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                SVProgressHUD.dismiss()
                
                if error != nil {
                    
                    print(error!)
                    
                    var errorMessage = ""
                    
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .invalidEmail:
                            errorMessage = "Invalid Email"
                        case .emailAlreadyInUse:
                            errorMessage = "Email Already In Use"
                        default:
                            errorMessage = "Registration Failed"
                        }
                    }
                    
                    SVProgressHUD.showError(withStatus: errorMessage)
                    
                }
                else {
                    print("Registration Successful")
                    SVProgressHUD.showSuccess(withStatus: "Registration Successful")
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
                
            }
            
        }
        else {
            
            let alert = UIAlertController(title: "Error", message: "You passwords don't match.", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
}
