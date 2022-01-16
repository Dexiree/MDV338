//
//  ViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/5/22.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIColorPickerViewControllerDelegate {
    
    // OUTLETS
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pallete: UIStackView!
    
    // Variables
    var drawing = PKDrawing()
    lazy var toolPicker: PKToolPicker = {
           let toolPicker = PKToolPicker()
            toolPicker.addObserver(self)
            return toolPicker
        }()
    var selectedColor = UIColor.black
    let colorPicker = UIColorPickerViewController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // canvas
        canvasView.delegate = self
        canvasView.drawing = drawing
        // for testing purposes allow fingers to draw
        canvasView.drawingPolicy = .anyInput
        
        // tool picker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // color picker
        colorPicker.delegate = self
        
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        pallete.subviews.last?.backgroundColor = selectedColor
    }
    
    @IBAction func addColor(_ sender: UIButton) {
        
        present(colorPicker, animated: true)
        
        let newColor = UIButton()
        newColor.backgroundColor = selectedColor
        newColor.addTarget(self, action: #selector(tappedColor), for: .touchUpInside)
        pallete.addArrangedSubview(newColor)
    }
    
    @objc private func tappedColor(_ sender: UIButton) {
        // TODO: Change hardcoded tool and width
        canvasView.tool = PKInkingTool(.pencil, color: sender.backgroundColor!, width: 5.0)
    }
    

}

