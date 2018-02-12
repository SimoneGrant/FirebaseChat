//
//  UsersTableViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/10/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MessagesTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var pickerButton: UIBarButtonItem!
    let profileImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isUserLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isUserLoggedIn()
    }
    
    // MARK: - Setup and Action
    
    func logOutUser() {
        SVProgressHUD.show()
        do {
            try Auth.auth().signOut()
        } catch {
            print("Could not log user out", error)
        }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    private func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            logOutUser()
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                //                print(snapshot)
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dict["name"] as? String
                    
                    if let profilePicURL = dict["profileImageUrl"] as? String {
                        let url = URL(string: profilePicURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                                self.profileImageView.image = UIImage(data: data!)
                            }
                        }).resume()
                    }
                    
                }
            })
        }
    }
    
    @IBAction func logOutTriggered(_ sender: UIBarButtonItem) {
        logOutUser()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createNewMessage(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Create") as! CreateMessageTableViewController
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func changeUserImageTriggered(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Nav Bar Image
    //https://stackoverflow.com/questions/47062176/image-for-navigation-bar-with-large-title-ios-11
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //        title = "Large Title"
        
        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(profileImageView)
        profileImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor,
                                                    constant: -Const.ImageRightMargin),
            profileImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor,
                                                     constant: -Const.ImageBottomMarginForLargeState),
            profileImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
            ])
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        profileImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
        
    }
    
    // MARK: - Storage
    
        private func updateNewProfilePic() {
            //create unique image id for users
            let uniqueUserImage = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueUserImage).png")
            let databaseRef = Database.database().reference()
            guard let userID = Auth.auth().currentUser?.uid else { return }
            if let uploadData = UIImagePNGRepresentation(profileImageView.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
//                    print(metadata)
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        //save image here
                        databaseRef.child("users").child(userID).child("profileImageUrl").setValue(imageURL, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            print("successful image upload")
                        })
                    }
                })
            }
        }
    
}

extension MessagesTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("pressed cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //        print(info)
        var userSelectedImage: UIImage?
        if let pickerEditedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            userSelectedImage = pickerEditedImg
        } else if let pickerOriginalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            userSelectedImage = pickerOriginalImg
        }
        
        if let image = userSelectedImage {
            //navigationImageView.image = image
            profileImageView.image = image
            
        }
        updateNewProfilePic()
        self.dismiss(animated: true, completion: nil)
    }
}
