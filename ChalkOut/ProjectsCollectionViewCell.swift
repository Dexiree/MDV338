//
//  ProjectsCollectionViewCell.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/22/22.
//

import UIKit

class ProjectsCollectionViewCell: UICollectionViewCell {
    
    // OUTLETS
    @IBOutlet weak var snapshot: UIImageView!
    
    
    static let identifier = "ProjectsCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image: UIImage) {
        snapshot.image = image
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ProjectsCollectionViewCell", bundle: nil)
    }

}
