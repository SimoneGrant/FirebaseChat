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
import GoogleSignIn
import FBSDKLoginKit

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
        setupDelegates()
    }
    
    func setupDelegates() {
        //        facebookLoginButton.delegate = self
        let google: GIDSignIn? = GIDSignIn.sharedInstance()
        google?.uiDelegate = self
        google?.delegate = self
        google?.shouldFetchBasicProfile = true
        
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
    
    @IBAction func twitterPressed(_ sender: UIButton) {
        signUpWithTwitter()
    }
    
    @IBAction func facebookPressed(_ sender: UIButton) {
        signUpWithFacebook()
    }
    
    @IBAction func googlePressed(_ sender: UIButton) {
        signUpWithGoogle()
    }
}

//  MARK: - 3rd party authentication

extension SignUpViewController: FBSDKLoginButtonDelegate {
    // MARK: - Facebook Auth
    func signUpWithFacebook() {
        let fbManager = FBSDKLoginManager()
        fbManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if error != nil {
                print("Login failed: ", error!)
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            //call to firebase
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    print("Login error: ", error!)
                    let alertController = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainView") as! LoginViewController
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("login")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
}

extension SignUpViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    // MARK: - Google Auth
    func signUpWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Could not sign in user: ", error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            //TODO: Refactor
            guard let uid = user?.uid else { return }
            guard let gName = GIDSignIn.sharedInstance().currentUser.profile.name else { return }
            guard let gEmail = user?.email else { return }
            let uniqueUserImage = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueUserImage).png")
            if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
                print("user has image")
                let imageURL = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 2)
                do {
                    let uploadData = try Data(contentsOf: imageURL!)
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            let values = ["name": gName, "email": gEmail, "profileImageUrl": profileImageUrl]
                            self.registerUserInfo(with: uid, values: values as [String : AnyObject])
                        }
                    })
                } catch {
                    print(error)
                }
            }
        }
    }

    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//
//    }
}

extension SignUpViewController {
    
    // MARK - Twitter Auth
    func signUpWithTwitter() {
        
    }
    
}
