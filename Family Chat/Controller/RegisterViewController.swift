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

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var chickenBackground: UIView!
    @IBOutlet weak var turtleBackground: UIView!
    @IBOutlet weak var tigerBackground: UIView!
    @IBOutlet weak var birdBackground: UIView!
    @IBOutlet weak var fishBackground: UIView!
    
    var profilePictureSelected : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profilePicturePressed(_ sender: UIButton) {
        profilePictureSelected = sender.tag
        updateUI()
    }
    
    func updateUI() {
        
        chickenBackground.backgroundColor = UIColor.darkGray
        turtleBackground.backgroundColor = UIColor.darkGray
        tigerBackground.backgroundColor = UIColor.darkGray
        birdBackground.backgroundColor = UIColor.darkGray
        fishBackground.backgroundColor = UIColor.darkGray
        
        switch profilePictureSelected {
        case 1:
            chickenBackground.backgroundColor = UIColor.green
        case 2:
            turtleBackground.backgroundColor = UIColor.green
        case 3:
            tigerBackground.backgroundColor = UIColor.green
        case 4:
            birdBackground.backgroundColor = UIColor.green
        case 5:
            fishBackground.backgroundColor = UIColor.green
        default:
            return
        }
        
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if profilePictureSelected == 0 {
            
            let alert = UIAlertController(title: "Error", message: "Please select a profile picture.", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            
            let alert = UIAlertController(title: "Error", message: "You passwords don't match.", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in

            })

            alert.addAction(restartAction)

            present(alert, animated: true, completion: nil)
            
            return
            
        }
        
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
                
                let usersDB = Database.database().reference().child("Users")
                
                let userDictionary = ["Nickname" : self.nicknameTextField.text!, "ProfilePicture" : "\(self.profilePictureSelected)"]
                
                usersDB.child(user!.uid).setValue(userDictionary) {
                    (error, reference) in
                    if error != nil {
                        print(error!)
                        SVProgressHUD.showError(withStatus: "Registration Failed")
                    }
                    else {
                        print("Registration Successful")
                        SVProgressHUD.showSuccess(withStatus: "Registration Successful")
                        self.performSegue(withIdentifier: "goToChat", sender: self)
                    }
                }
                
            }
            
        }
        
    }
    
}
