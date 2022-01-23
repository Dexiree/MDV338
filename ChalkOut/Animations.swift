//
//  Animations.swift
//  
//
//  Created by Dexiree Colon on 1/23/22.
//

import Foundation
import UIKit

class Animations {

    func animateIn(desiredView: UIView, on mainView: UIView) {
        // get background
        let backgroundView = mainView
        
        // add popup and blur and supview
        backgroundView.addSubview(desiredView)
        
        // start values of view before animation
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        // animate
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
        }
    }
    func animateOut(desiredView: UIView){
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0

        } completion: { _ in
            desiredView.removeFromSuperview()
        }

    }
    
}
