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
    
    var numOfProjects = 0
    var images = [UIImage(systemName: "scribble")]
    var projects = [String]()
    
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
//        storage.child("Projects").listAll { list, error in
//            guard error == nil else {
//                print("ERROR")
//                return
//            }
//            // getting the number of projects in the database
//            self.numOfProjects = list.prefixes.capacity
//
//            // getting the name of each project in the database
//            for prefixes in list.prefixes {
//                self.projects.append(prefixes.name)
//                self.loadImage(file: prefixes.name)
//            }
//        }
        
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
            self.projects = snapshot.documents.map{$0.documentID}
            
            // load info on app
            snapshot.documents.forEach { document in
                do {
                    let project = try Projects(snapshot: document.data())
                    
                    self.loadImage(file: project.image)
                    
                } catch {
                    print(error.localizedDescription)
                }
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
        
        
        //snapshots.removeAll()
        
        // getting snapshot from database
//        storage.child("Projects/\(file)/snapshot.png").getData(maxSize: 10 * 1024 * 1024) { data, error in
//
//            // if error
//            guard let data = data, error == nil else {
//                print("There was an issue")
//                return
//            }
//
//            // get data
//            if let snapshot = UIImage(data: data){
//                self.snapshots.append(snapshot)
//
//            }
//            // reload collectionView
//            if self.snapshots.count == self.projects.count{
//                self.projectsCollection.reloadData()
//            }
//        }
        
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
                
                // send new info to the main view
                if let mainView = navigationController?.viewControllers[0] as? ViewController {
                    
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
                    
                }
                
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
            self.db.collection("emails").document(self.email).setData(["sharedProjects" : [String]()])
            
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
            
            // success
            print("Successfully Logged in as: \(String(describing: user.uid))")
            // get uid
            //self.uid = user.uid
            
            // get projects info
            db.collection("emails/\(user.email)/\(user.uid)").getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Document not found")
                    return
                }
                // save docIds
                projects = snapshot.documents.map{$0.documentID}
                
                // load info on app
                snapshot.documents.forEach { document in
                    do {
                        print("DOCUMENTS: \(document.documentID)")
                        let project = try Projects(snapshot: document.data())
                        
                        loadImage(file: project.image)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
            
            
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
        let selected = (indexPath[0]*4) + indexPath[1]
        let chosenProject = projects[selected]
        
        // send info to the main view
        if let mainView = navigationController?.viewControllers[0] as? ViewController {
            
            // send project Name to root ViewController
            mainView.projectName = chosenProject
            
            // load data as drawing
            loadSketch(project: chosenProject, for: mainView)
            
            // load data as palette
            loadPalette(project: chosenProject, for: mainView)
            
        }
        
        // pop view
        navigationController?.popViewController(animated: true)
        
    }
    
    func loadSketch(project: String, for view: ViewController) {
        storage.child("Projects/\(project)/sketch.drawing").getData(maxSize: 10 * 1024 * 1024) { data, error in

            // if error
            guard let data = data, error == nil else {
                print("There was an issue")
                return
            }

            // get sketch data
            if let loadDrawing = try? PKDrawing(data: data){
                view.canvasView.drawing = loadDrawing
            }
        }
    }
    
    func loadPalette(project: String, for view: ViewController) {
        
        // removes all colors from pallete if any
        for color in view.pallete.subviews {
            color.removeFromSuperview()
        }
        storage.child("Projects/\(project)/palette.txt").getData(maxSize: 10 * 1024 * 1024) { data, error in

            // if error
            guard let data = data, error == nil else {
                print("ERROR: \(error!)")
                return
            }

            // get color data
            if let paletteString = String(data: data, encoding: .utf16) {
                
                if paletteString != "" {
                    
                    // each hex code has 7 char (EX. #FFFFFF)
                    let numOfColors = paletteString.count / 7
                    
                    var start = 1
                    var endBefore = 7
                    var colors = [UIColor]()
                    
                    // seperating each color into an array
                    for _ in 1...numOfColors {
                        let hexColor = paletteString[start ..< endBefore]
                        colors.append(UIColor(hex: hexColor))
                        
                        start += 7
                        endBefore += 7
                    }
                    
                    // add colors to palette
                    colors.forEach { color in
                        view.new(color: color)
                    }
                }
                
            }
        }
    }
}

// cell info
extension ProjectsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectsCollection.dequeueReusableCell(withReuseIdentifier: ProjectsCollectionViewCell.identifier, for: indexPath) as! ProjectsCollectionViewCell
        
        print("PROJECTS: \(projects.count) SNAPSHOTS: \(images.count)")
        let i = (indexPath[0] * 4) + indexPath[1]
        print(i)
        cell.configure(with: images[i]!)
        
        return cell
    }
    
    
}
