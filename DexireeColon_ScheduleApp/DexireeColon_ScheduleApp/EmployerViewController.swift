//
//  LoginViewController.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 7/23/21.
//

import UIKit
import Firebase

class EmployerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets and Variables
    @IBOutlet weak var employeesView: UITableView!
    let database = Firestore.firestore()
    struct employee {
        let firstname, lastname, title, time, wages: String
    }
    var employees = [employee]()

    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set tableviews delegate and datasource
        employeesView.delegate = self
        employeesView.dataSource = self
        
        // read the data in the database
        ReadData()

    }
    
    // MARK: - Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? EmployeeTableViewCell
        
        let employee = employees[indexPath.row]
        cell?.Name.text = "\(employee.firstname) \(employee.lastname)"
        cell?.wages.text = employee.wages
        cell?.title.text = employee.title
        
        return cell!
    }
    func ReadData() {
        
        database.collection("employees").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    guard let firstName = data["firstname"] as? String,
                          let lastName = data["lastname"] as? String,
                          let title = data["title"] as? String,
                          let time = data["time"] as? String,
                          let wages = data["wages"] as? String
                    else {return}
                    let newEmployee = employee(firstname: firstName, lastname: lastName, title: title, time: time, wages: wages)
                    self.employees.append(newEmployee)
                }
            }
        }
        
        // reload tableView
        DispatchQueue.main.async {
            self.employeesView.reloadData()
        }
    }
    

    // MARK: - Buttons
    @IBAction func SortPressed(_ sender: Any) {
    }
    @IBAction func AddPressed(_ sender: Any) {
        let pop = Popup()
        self.view.addSubview(pop)
    }
    @IBAction func FilterPressed(_ sender: Any) {
    }
    

}
