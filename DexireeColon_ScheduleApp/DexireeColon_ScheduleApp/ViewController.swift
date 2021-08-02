//
//  ViewController.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 7/14/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUpElements()
    }
    
    // MARK: - Setup
    func SetUpElements() {
        
        errorLabel.alpha = 0
    }
    
     // MARK: - Methods
    func TransitionToHome() {
        
        var homePage = storyboard?.instantiateViewController(identifier: "HomeEmployee")
        
        if emailField.text! == "manager@myCompany.com" {
            homePage = storyboard?.instantiateViewController(identifier: "HomeEmployer")
        }
        
        // navigate to home screen
        view.window?.rootViewController = homePage
        view.window?.makeKeyAndVisible()
    }
    
    // MARK: - Buttons
    @IBAction func LoginTapped(_ sender: UIButton) {
        
        // make sure fields arnt blank
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errorLabel.text = "Please fill in all test fields"
        }
        // validate login
        else {
            Auth.auth().signIn(withEmail: emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { result, error in
                
                // couldnt sign in
                if error != nil {
                    self.errorLabel.text = error?.localizedDescription
                    self.errorLabel.alpha = 1
                }
                else {
                    self.TransitionToHome()
                }
            }
        }
    }
    

}

