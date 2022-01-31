//
//  ProjectsViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/22/22.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import PencilKit

class ProjectsViewController: UIViewController, UITextFieldDelegate {
    
    // OUTLETS
    @IBOutlet weak var projectsCollection: UICollectionView!
    
    @IBOutlet weak var loginSignup: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginCreateBtnName: UIButton!
    @IBOutlet weak var loginSignupView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet var newProjectView: UIView!
    @IBOutlet weak var projectNameField: UITextField!
    
    // VARIABLES
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    var images = [UIImage(systemName: "scribble")]
    var projIDs = [String]()
    var projects = [Projects]()
    
    let animation = Animations()
    var willLogin = true
    var newUser = false
    
    var email = "test@gmail.com"
    var password = "password"
    var user = User(email: "test@gmail.com", uid: "1234")
    var uid = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // register the cell
        projectsCollection.register(ProjectsCollectionViewCell.nib(), forCellWithReuseIdentifier: ProjectsCollectionViewCell.identifier)
        
        // delegate
        emailField.delegate = self
        passwordField.delegate = self
        
        // set layout for cells
        var layout: UICollectionViewFlowLayout {
            let flow = UICollectionViewFlowLayout()
            flow.itemSize = CGSize(width: self.view.bounds.width / 4, height: self.view.bounds.height / 4)
            flow.minimumInteritemSpacing = 1
            flow.minimumLineSpacing = 1
            flow.scrollDirection = .vertical
            return flow
        }
        projectsCollection.collectionViewLayout = layout
        
         //set self as delegate and datasource
        projectsCollection.delegate = self
        projectsCollection.dataSource = self
        
        // Login popup
        loginSignupView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.height * 0.5)
        loginSignupView.layer.cornerRadius = 20
        
        // New Project popup
        newProjectView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.75, height: self.view.bounds.height * 0.25)
        newProjectView.layer.cornerRadius = 20
        
        // load data from database
        loadProjects()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func loadProjects() {
        
        db.collection("emails/\(user.email)/\(user.uid)").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Document not found")
                return
            }
            // save docIds
            self.projIDs = snapshot.documents.map{$0.documentID}
            
            // load info on app
            self.images.removeAll()
            snapshot.documents.forEach { document in
                do {
                    let project = try Projects(snapshot: document.data())
                    self.projects.append(project)
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            self.projects.forEach { project in
                guard let image = project.image else {return}
                self.loadImage(file: image)
            }
            
        }
    }
    func loadImage(file: String){
        
        guard let url = URL(string: file) else {return}
        
        do {
            let data = try Data(contentsOf: url)
            
            guard let image = UIImage(data: data) else {
                print("NO IMAGE")
                return
            }
            
            images.append(image)
            projectsCollection.reloadData()
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - Add New Project
    @IBAction func addNewProject(_ sender: UIBarButtonItem) {
        
        // open popup
        animation.animateIn(desiredView: newProjectView, on: self.view)
        
    }
    
    @IBAction func createNewProjectBtn(_ sender: UIButton) {
        
        //         Project Name
                var newName = "Untitled"
        if !(projectNameField.text!.isEmpty) || !(projectNameField.text == "") {
            newName = projectNameField.text!
        }
        
        //         create new sketch.drawing
                let newSketch = PKCanvasView().drawing.dataRepresentation()
        //         create new image.png
                let newImage = UIImage(systemName: "scribble")?.pngData()
                
        //         palette.txt
        //        let paletteString = ""
        //        let newPalette = paletteString.data(using: .utf16)!
        
        // create new project
        let userRef = "emails/\(user.email)/\(user.uid)"
        let newProjectRef = db.collection(userRef).addDocument(data: ["name " : newName])
        
        // new color shceme
        let collectionRef = "\(userRef)/\(newProjectRef.documentID)/ColorSchemes"
        let colorScheme = db.collection(collectionRef).addDocument(data: ["sketches" : [String]()])
        
        // add new palette
        //colorScheme.setData(["palette" : [String]()])
                
                // send new info to the main view
        // save to ID
        mainView.projectID = newProjectRef.documentID
        // save to name
        mainView.projectName = newName
        // save to user
        mainView.user = user
        // save sketch with new color scheme
        mainView.colorScheme = colorScheme.documentID
        mainView.saveSketch(data: newSketch)
        // save image
        mainView.saveImage(data: newImage!)
        
        // save palette
        //mainView.savePalette(data: newPalette)
        
        //loadSketch(project: newName, for: mainView)
        
        
        
//                if let mainView = navigationController?.viewControllers[0] as? ViewController {
//
//                    // save to ID
//                    mainView.projectID = newProjectRef.documentID
//                    // save to name
//                    mainView.projectName = newName
//                    // save to user
//                    mainView.user = user
//                    // save sketch with new color scheme
//                    mainView.colorScheme = colorScheme.documentID
//                    mainView.saveSketch(data: newSketch)
//                    // save image
//                    mainView.saveImage(data: newImage!)
//
//                    // save palette
//                    //mainView.savePalette(data: newPalette)
//
//                    //loadSketch(project: newName, for: mainView)
//
//                }
                
                // pop view
                navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelNewProjectBtn(_ sender: UIButton) {
        animation.animateOut(desiredView: newProjectView)
    }
    
    
    // MARK: - LOGIN / SIGN UP
    @IBAction func showLoginSignup(_ sender: UIButton) {
        
        // open popup
        animation.animateIn(desiredView: loginSignupView, on: self.view)
        
    }
    
    @IBAction func loginSignupSegments(_ sender: UISegmentedControl) {
        let choice = sender.selectedSegmentIndex
        
        switch choice {
        case 0:
            willLogin = true
            loginCreateBtnName.titleLabel?.text = "Login"
            loginSignup.text = "Login"
        case 1:
            willLogin = false
            loginCreateBtnName.titleLabel?.text = "Create Account"
            loginSignup.text = "Sign Up"
        default:
            return
        }

    }
    
    @IBAction func loginSignupBtn(_ sender: UIButton) {
        
        switch willLogin {
        case true:
            login()
        case false:
            signup()
        }
        
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        animation.animateOut(desiredView: loginSignupView)
    }
    
    func signup(){
        
        // make sure text fields are not blank
        guard let checkEmail = emailField.text, let checkPassword = passwordField.text else {
            errorLabel.text = "Do not leave any field blank"
            errorLabel.textColor = .red
            return
            
        }
        email = checkEmail
        password = checkPassword
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            // check error
            guard error == nil else {
                print("ERROR SIGNUP: \(String(describing: error))")
                print("EMAIL: \(self.email) PASSWORD: \(self.password)")
                self.errorLabel.text = "error signing up"
                self.errorLabel.textColor = .red
                return
            }
            
            // success
            print("Succeful Signed up as: \(String(describing: result?.user.uid))")
            
            //creates new users firestore document
            self.db.collection("emails").document(self.email).setData(["sharedProjects" : [String]()]) { error in
                guard error == nil else {return}
                
                self.db.collection("emails").document(self.email).setData(["collaborators" : [String]()])
                self.db.collection("emails").document(self.email).setData(["locked" : false])
            }
            
            
            self.animation.animateOut(desiredView: self.loginSignupView)
            self.newUser = true
            self.login()
            
        }
    }
    
    func login(){
        
        // make sure text fields are not blank
        if newUser == false {
            guard let checkEmail = emailField.text, let checkPassword = passwordField.text else {
                errorLabel.text = "Do not leave any field blank"
                errorLabel.textColor = .red
                return
            }
            email = checkEmail
            password = checkPassword
        }
        
        // try to login
        Auth.auth().signIn(withEmail: email, password: password) { [self] result, error in
            
            // check error
            guard let result = result, error == nil else {
                print("ERROR LOGIN: \(String(describing: error))")
                self.errorLabel.text = "error logging in"
                self.errorLabel.textColor = .red
                return
            }
            
            // user
            self.user.uid = result.user.uid
            self.user.email = result.user.email!
            mainView.user.uid = result.user.uid
            mainView.user.email = result.user.email!
            //mainView.user.uid = user.uid
            //mainView.user.email = user.email
            
            // success
            print("Successfully Logged in as: \(String(describing: user.uid))")
            
            // get projects info
            loadProjects()
            
            self.animation.animateOut(desiredView: self.loginSignupView)
        }
    }

}


// MARK: - CollectionView
// selected item
extension ProjectsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // deslected
        projectsCollection.deselectItem(at: indexPath, animated: true)
        
        // get project based on the selected cell
        let selected = (indexPath[0] * 4) + indexPath[1]
        let chosenProject = projIDs[selected]
        var colorSchemes = [DocumentReference]()
        
        db.collection("emails/\(user.email)/\(user.uid)/\(chosenProject)/ColorSchemes").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {return}
            
            colorSchemes = snapshot.documents.map{$0.reference}
            //guard let name = self.projects[0].name else {return}
            //let colorScheme = snapshot.documents[0].documentID
            
            // send info to the main view
            
            // send project Name to root ViewController
            mainView.projectID = chosenProject
            mainView.colorSchemes = colorSchemes
            mainView.LoadData()
            
        }
        
        // pop view
        navigationController?.popViewController(animated: true)

    }
}

// cell info
extension ProjectsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return projIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectsCollection.dequeueReusableCell(withReuseIdentifier: ProjectsCollectionViewCell.identifier, for: indexPath) as! ProjectsCollectionViewCell
        
        print("PROJECTS: \(projIDs.count) IMAGES: \(images.count)")
        
        let i = (indexPath[0] * 4) + indexPath[1]
        print(i)
        
        cell.configure(with: images[i]!)
        
        return cell
    }
    
    
}
