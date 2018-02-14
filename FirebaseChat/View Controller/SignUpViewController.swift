//
//  SignUpViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/10/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var gmailLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Action
    //TODO: Error handling
    @IBAction func signUpTriggered(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                
            } else {
                print("Successful registration")
                guard let uid = user?.uid else { return }
                
                //Create a default profile picture per user
                let uniqueUserImage = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueUserImage).png")
                if let uploadData = UIImagePNGRepresentation(UIImage(named: "anon")!) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            //save image here
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserInfo(with: uid, values: values as [String : AnyObject])
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func LoginRequested(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    //UPLOAD USER INFO
    private func registerUserInfo(with uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(uid)
        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
            } else {
                self.performSegue(withIdentifier: "signUpToChat", sender: self)
            }
        })
    }

}
