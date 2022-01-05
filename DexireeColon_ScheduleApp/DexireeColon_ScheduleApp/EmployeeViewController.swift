//
//  SignUpViewController.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 7/23/21.
//

import UIKit
import FirebaseAuth
import Firebase


class EmployeeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Outlet
    @IBOutlet weak var name: UINavigationItem!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wagesLabel: UILabel!
    @IBOutlet weak var timeEmployedLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var schedule: UITableView!
    
    var uid = ""
    let database = Firestore.firestore()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        GetUid()
    }
    
    func GetUid() {
        if Auth.auth().currentUser != nil {
            
            let user = Auth.auth().currentUser
            if let user = user {
              uid = user.uid
              //let email = user.email
              //let photoURL = user.photoURL
              var multiFactorString = "MultiFactor: "
              for info in user.multiFactor.enrolledFactors {
                multiFactorString += info.displayName ?? "[DispayName]"
                multiFactorString += " "
              }
                GetInfo()
                print("Uid: \(uid)")
            }
        }
    }
    
    func GetInfo() {
        
        let ref = database.document("employees/\(uid)")
        
        ref.addSnapshotListener { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {return}
            guard let firstName = data["firstname"] as? String,
                  let lastName = data["lastname"] as? String,
                  let title = data["title"] as? String,
                  let wages = data["wages"] as? String,
                  let time = data["time"] as? String
            else {return}
            
            // display info
            DispatchQueue.main.async {
                self!.name.title = "\(firstName) \(lastName)"
                self!.titleLabel.text = title
                self!.wagesLabel.text = "\(wages)/hour"
                self?.timeEmployedLabel.text = time
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? ScheduleTableViewCell
        
        
        return cell!
    }
    
    

}
