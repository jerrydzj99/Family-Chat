//
//  ChatViewController.swift
//  Family Chat
//
//  Created by Jerry Ding on 2018-05-07.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messageArray : [Message] = [Message]()
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var borderConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        var avatarImageName = ""
        
        switch messageArray[indexPath.row].senderProfilePicture {
        case 1:
            avatarImageName = "chicken"
        case 2:
            avatarImageName = "turtle"
        case 3:
            avatarImageName = "tiger"
        case 4:
            avatarImageName = "bird"
        case 5:
            avatarImageName = "fish"
        default:
            avatarImageName = "egg"
        }
        
        cell.avatarImageView.image = UIImage(named: avatarImageName)
        cell.senderNicknameLabel.text = messageArray[indexPath.row].senderNickname
        cell.messageBodyLabel.text = messageArray[indexPath.row].messageBody
        
        if messageArray[indexPath.row].senderID == Auth.auth().currentUser?.uid as String? {
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            heightConstraint.constant = keyboardSize.height + 50
            borderConstraint.constant = heightConstraint.constant
            view.layoutIfNeeded()
            if messageArray.count != 0 {
                messageTableView.scrollToRow(at: IndexPath(item: messageArray.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        heightConstraint.constant = 50
        borderConstraint.constant = heightConstraint.constant
        view.layoutIfNeeded()
        if messageArray.count != 0 {
            messageTableView.scrollToRow(at: IndexPath(item: messageArray.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 100.0
    }
    
    func retrieveMessages() {
        
        let DB = Database.database().reference()
        
        DB.child("Messages").observe(.childAdded) { (messageSnapshot) in
            
            DB.child("Users").observeSingleEvent(of: .value, with: { (userSnapshot) in
                
                let messageSnapshotValue = messageSnapshot.value as! Dictionary<String,String>
                let userSnapshotValue = userSnapshot.value as! Dictionary<String,Dictionary<String,String>>
                
                let message = Message()
                
                message.senderID = messageSnapshotValue["SenderID"]!
                message.messageBody = messageSnapshotValue["MessageBody"]!
                message.senderNickname = userSnapshotValue[message.senderID]!["Nickname"]!
                message.senderProfilePicture = Int(userSnapshotValue[message.senderID]!["ProfilePicture"]!)!
                
                self.messageArray.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: IndexPath(item: self.messageArray.count - 1, section: 0), at: .bottom, animated: false)
                
            })
            
        }
        
    }
    
//    func retrieveMessages() {
//
//        let DB = Database.database().reference()
//
//        DB.child("Messages").observe(.childAdded) { (messageSnapshot) in
//
//            let messageSnapshotValue = messageSnapshot.value as! Dictionary<String,String>
//            let message = Message()
//            message.senderID = messageSnapshotValue["SenderID"]!
//            message.messageBody = messageSnapshotValue["MessageBody"]!
//
//            DB.child("Users").child(message.senderID).observeSingleEvent(of: .value, with: { (userSnapshot) in
//
//                let userSnapshotValue = userSnapshot.value as! Dictionary<String,String>
//                message.senderNickname = userSnapshotValue["Nickname"]!
//                message.senderProfilePicture = Int(userSnapshotValue["ProfilePicture"]!)!
//                self.messageArray.append(message)
//                print("message appended! messageBody: \(message.messageBody); senderNickname: \(message.senderNickname)")
//                self.configureTableView()
//                self.messageTableView.reloadData()
//                self.messageTableView.scrollToRow(at: IndexPath(item: self.messageArray.count - 1, section: 0), at: .bottom, animated: false)
//
//            })
//
//        }
//
//    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        if messageTextField.text == "" {
            return
        }
        
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let senderID = Auth.auth().currentUser?.uid
        let messageBody = messageTextField.text!
        
        let messageDictionary = ["SenderID" : senderID, "MessageBody" : messageBody]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message Saved")
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            SVProgressHUD.showError(withStatus: "There's a problem signing out.")
        }
        
    }
    
}
