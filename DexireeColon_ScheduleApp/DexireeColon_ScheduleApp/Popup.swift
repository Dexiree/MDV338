//
//  Popup.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 7/29/21.
//

import UIKit
import Firebase
import FirebaseAuth

class Popup: UIView {

    let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 24
        return view
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        label.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        label.text = "New Employee"
        label.textAlignment = .center
        return label
    }()
    
    let firstName: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "First Name"
        text.textAlignment = .center
        return text
    }()
    
    let lastName: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "Last Name"
        text.textAlignment = .center
        return text
    }()
    
    let email: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "Email"
        text.textAlignment = .center
        return text
    }()
    
    let employeeTitle: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "Title"
        text.textAlignment = .center
        return text
    }()
    
    let wages: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "Wages"
        text.textAlignment = .center
        return text
    }()
    
    let time: UITextField = {
       let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "Arial Rounded MT Bold", size: 15)
        text.textColor = #colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.4156862745, alpha: 1)
        text.placeholder = "Time"
        text.textAlignment = .center
        return text
    }()
    
    let buttons: UISegmentedControl = {
       let segments = UISegmentedControl(items: ["Add","Cancel"])
        segments.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.8156862745, blue: 0.5058823529, alpha: 1)
        segments.addTarget(self, action: #selector(Selected(_:)), for: .valueChanged)
        return segments
    }()
    
    lazy var stack: UIStackView = {
       let stack = UIStackView(arrangedSubviews:[title,firstName,lastName,email,employeeTitle,wages,time,buttons])
        stack.subviews[0].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[1].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[2].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[3].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[4].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[5].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[6].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.1)
        stack.subviews[7].frame.size = CGSize(width: stack.frame.width, height: stack.frame.height * 0.3)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    //var mainView = ViewController()
    
    // MARK: - Animations
    @objc func AnimateOut() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
            self.alpha = 0
        } completion: { complete in
            if complete {
                self.removeFromSuperview()
            } }
    }
    @objc func AnimateIn() {
        // bring from top with opacity at 0
        self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        self.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            // bring back to it's default with full opacity
            self.container.transform = .identity
            self.alpha = 1
        })
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        // setting background frame
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.frame = UIScreen.main.bounds
        
        // constraints for container
        self.addSubview(container)
        self.addConstraint(NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: container, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.7, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.45, constant: 0))
        
        // constraints for stack
        container.addSubview(stack)
        container.addConstraint(NSLayoutConstraint(item: stack, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stack, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stack, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: stack, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: 0))
        
        // animation
        AnimateIn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    @IBAction func Selected(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            // add new employee
            Auth.auth().createUser(withEmail: email.text!, password: "password") { result, err in
                
                // check for errors
                if err != nil {
                    print(err.debugDescription)
                }
                else {
                    let db = Firestore.firestore()
                    
                    db.collection("employees").document(result!.user.uid).setData([
                                                            "firstname":self.firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                            "lastname": self.lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                            "title": self.employeeTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                            "wages": self.wages.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                            "time": self.time.text!.trimmingCharacters(in: .whitespacesAndNewlines)]) { error in
                        if error != nil {
                            print("Error saving user data") } }
                }
            }
            
            AnimateOut()
            //mainView.TransitionToHome()
            
        case 1:
            // cancels
            AnimateOut()
        default:
            break
        }
    }

}
