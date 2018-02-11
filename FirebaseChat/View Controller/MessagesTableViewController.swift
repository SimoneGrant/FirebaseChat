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

    override func viewDidLoad() {
        super.viewDidLoad()
//        isUserLoggedIn()
        setupUI()
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
    
    func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            logOutUser()
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot)
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dict["name"] as? String
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
    
    private let imageView = UIImageView(image: UIImage(named: "man"))
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        title = "Large Title"
        
        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor,
                                             constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor,
                                              constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
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
        
        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
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
            imageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
