//
//  LoginViewController.swift
//  
//
//  Created by Jerry Ding on 2018-05-07.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                
                print(error!)
                
                var errorMessage = ""
                
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .userNotFound:
                        errorMessage = "User Not Found"
                    case .wrongPassword:
                        errorMessage = "Incorrect Password"
                    case .userDisabled:
                        errorMessage = "Account Disabled"
                    default:
                        errorMessage = "Login Failed"
                    }
                }
                
                SVProgressHUD.showError(withStatus: errorMessage)
                
            }
            else {
                print("Login Successful")
                SVProgressHUD.showSuccess(withStatus: "Login Successful")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
            
        }
        
    }
    
}
