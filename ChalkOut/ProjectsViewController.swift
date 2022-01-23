//
//  ProjectsViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/22/22.
//

import UIKit
import FirebaseStorage

class ProjectsViewController: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var projectsCollection: UICollectionView!
    
    // VARIABLES
    private let storage = Storage.storage().reference()
    var numOfProjects = 0
    var thumbnail = UIImage(systemName: "scribble")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // register the cell
        projectsCollection.register(ProjectsCollectionViewCell.nib(), forCellWithReuseIdentifier: ProjectsCollectionViewCell.identifier)
        
        // set layout for cells
        var layout: UICollectionViewFlowLayout {
            let flow = UICollectionViewFlowLayout()
            flow.itemSize = CGSize(width: self.view.bounds.width / 4, height: self.view.bounds.height / 10)
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
        storage.child("drawings").listAll { list, error in
            guard error == nil else {
                print("ERROR")
                return
            }
            // getting the number of projects in the database
            self.numOfProjects = list.items.capacity
        }
        storage.child("drawings/snapshot.png").getData(maxSize: 10 * 1024 * 1024) { data, error in
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProjectsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        projectsCollection.deselectItem(at: indexPath, animated: true)
        
        print("Tapped")
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
