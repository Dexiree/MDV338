//
//  EmployeeTableViewCell.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 7/31/21.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var wages: UILabel!
    @IBOutlet weak var title: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
