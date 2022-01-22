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
    @IBOutlet weak var palette: UIView!
    
    
    static let identifier = "ProjectsCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image: UIImage, and palette: UIView) {
        snapshot.image = image
        self.palette = palette
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ProjectsCollectionViewCell", bundle: nil)
    }

}
