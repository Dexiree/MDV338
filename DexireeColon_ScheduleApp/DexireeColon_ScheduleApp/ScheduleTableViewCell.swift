//
//  ScheduleTableViewCell.swift
//  DexireeColon_ScheduleApp
//
//  Created by Dexiree Colon on 8/2/21.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var payLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
