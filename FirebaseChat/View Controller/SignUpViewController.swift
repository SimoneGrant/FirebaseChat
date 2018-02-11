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
            }
            print("Successful registration")
            
            guard let uid = user?.uid else { return }
            let ref = Database.database().reference(fromURL: "https://fir-chat-912af.firebaseio.com/")
            let userRef = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                }
                self.performSegue(withIdentifier: "signUpToChat", sender: self)
            })
        }
    }
    
    @IBAction func LoginRequested(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
