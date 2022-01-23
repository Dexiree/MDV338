//
//  ProjectsViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/22/22.
//

import UIKit
import FirebaseStorage
import PencilKit

class ProjectsViewController: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var projectsCollection: UICollectionView!
    
    // VARIABLES
    private let storage = Storage.storage().reference()
    var numOfProjects = 0
    var thumbnail = UIImage(systemName: "scribble")
    var projects = [String]()
    

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
            }
        }
        storage.child("Projects/projectName/snapshot.png").getData(maxSize: 10 * 1024 * 1024) { data, error in
            
            // if error
            guard let data = data, error == nil else {
                print("There was an issue")
                return
            }

            // get data
            if let snapshot = UIImage(data: data){
                self.thumbnail = snapshot
            }
            // reload collectionView
            self.projectsCollection.reloadData()
        }
    }
    
    @IBAction func addNewProject(_ sender: UIBarButtonItem) {
        /*
         Project Name
         sketch.drawing
         snapshot.png
         palette.txt
         */
    }
    

}

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
            storage.child("Projects/\(chosenProject)/sketch.drawing").getData(maxSize: 10 * 1024 * 1024) { data, error in

                // if error
                guard let data = data, error == nil else {
                    print("There was an issue")
                    return
                }

                // get sketch data
                if let loadDrawing = try? PKDrawing(data: data){
                    mainView.canvasView.drawing = loadDrawing
                }
            }
            
            
            // removes all colors from pallete if any
            for color in mainView.pallete.subviews {
                color.removeFromSuperview()
            }
            
            // load palette data
            storage.child("Projects/\(chosenProject)/palette.txt").getData(maxSize: 10 * 1024 * 1024) { data, error in

                // if error
                guard let data = data, error == nil else {
                    print("There was an issue")
                    return
                }

                // get color data
                if let paletteString = String(data: data, encoding: .utf16) {
                    
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
                        mainView.new(color: color)
                    }
                    
                }
            }
            
        }
        
        // pop view
        navigationController?.popViewController(animated: true)
        
    }
}
extension ProjectsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return numOfProjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectsCollection.dequeueReusableCell(withReuseIdentifier: ProjectsCollectionViewCell.identifier, for: indexPath) as! ProjectsCollectionViewCell
        cell.configure(with: thumbnail!)
        
        return cell
    }
    
    
}
extension ProjectsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120, height: 120)
//    }
}