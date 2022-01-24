//
//  ProjectsViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/22/22.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import PencilKit

class ProjectsViewController: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var projectsCollection: UICollectionView!
    
    @IBOutlet weak var loginSignup: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginCreateBtnName: UIButton!
    @IBOutlet weak var loginSignupView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    // VARIABLES
    private let storage = Storage.storage().reference()
    var numOfProjects = 0
    var snapshots = [UIImage(systemName: "scribble")]
    var projects = [String]()
    let animation = Animations()
    var willLogin = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // register the cell
        projectsCollection.register(ProjectsCollectionViewCell.nib(), forCellWithReuseIdentifier: ProjectsCollectionViewCell.identifier)
        
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
        
        // popup
        loginSignupView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.height * 0.5)
        loginSignupView.layer.cornerRadius = 20
        
        // load data from database
        storage.child("Projects").listAll { list, error in
            guard error == nil else {
                print("ERROR")
                return
            }
            // getting the number of projects in the database
            self.numOfProjects = list.prefixes.capacity
            
            // getting the name of each project in the database
            for prefixes in list.prefixes {
                self.projects.append(prefixes.name)
                self.loadImage(file: prefixes.name)
            }
        }
        
    }
    
    func loadImage(file: String){
        snapshots.removeAll()
        
        // getting snapshot from database
        storage.child("Projects/\(file)/snapshot.png").getData(maxSize: 10 * 1024 * 1024) { data, error in
            
            // if error
            guard let data = data, error == nil else {
                print("There was an issue")
                return
            }

            // get data
            if let snapshot = UIImage(data: data){
                self.snapshots.append(snapshot)
                
            }
            // reload collectionView
            if self.snapshots.count == self.projects.count{
                self.projectsCollection.reloadData()
            }
        }
        
    }
    
    @IBAction func addNewProject(_ sender: UIBarButtonItem) {
//         Project Name
        let newName = "newProject"
//         sketch.drawing
        let newSketch = PKCanvasView().drawing.dataRepresentation()
//         snapshot.png
        let newSnapshot = UIImage(systemName: "scribble")?.pngData()
//         palette.txt
        let paletteString = ""
        let newPalette = paletteString.data(using: .utf16)!
        
        
        // save than send new info to the main view
        if let mainView = navigationController?.viewControllers[0] as? ViewController {
            
            // save to name
            mainView.projectName = newName
            // save sketch
            mainView.saveSketch(data: newSketch)
            // save snapshot
            mainView.saveImage(data: newSnapshot!)
            // save palette
            mainView.savePalette(data: newPalette)
            
            //loadSketch(project: newName, for: mainView)
            
        }
        
        // pop view
        navigationController?.popViewController(animated: true)
        
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
        if !(emailField.text!.isEmpty) || !(passwordField.text!.isEmpty) {
            Auth.auth().createUser(withEmail: "\(String(describing: emailField.text))", password: "\(String(describing: passwordField.text))") { result, error in
                
                // check error
                guard error == nil else {
                    print("ERROR SIGNUP: \(String(describing: error))")
                    self.errorLabel.text = "error signing up"
                    self.errorLabel.textColor = .red
                    return
                }
                
                // success
                print("Succeful Signed up as: \(String(describing: result?.user.uid))")
                self.animation.animateOut(desiredView: self.loginSignupView)
                
            }
        } else {
            
        }
    }
    func login(){
        Auth.auth().signIn(withEmail: "myEmail@gmail.com", password: "password") { result, error in
            
            // check error
            guard error == nil else {
                print("ERROR LOGIN: \(String(describing: error))")
                self.errorLabel.text = "error logging in"
                self.errorLabel.textColor = .red
                return
            }
            
            // success
            print("Successfully Logged in as: \(String(describing: result?.user.uid))")
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
                print("There was an issue")
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
                        colors.append(UIColor().convertRGB(from: hexColor))
                        
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
        
        return numOfProjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectsCollection.dequeueReusableCell(withReuseIdentifier: ProjectsCollectionViewCell.identifier, for: indexPath) as! ProjectsCollectionViewCell
        
        print("PROJECTS: \(projects.count) SNAPSHOTS: \(snapshots.count)")
        let i = (indexPath[0] * 4) + indexPath[1]
        print(i)
        cell.configure(with: snapshots[i]!)
        
        return cell
    }
    
    
}
