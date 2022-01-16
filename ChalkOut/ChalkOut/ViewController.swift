//
//  ViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/5/22.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    // OUTLETS
    @IBOutlet weak var canvasView: PKCanvasView!
    
    // Variables
    var drawing = PKDrawing()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // set canvas delegate to self
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        // for testing purposes allow fingers to draw
        canvasView.drawingPolicy = .anyInput
        
        // tool picker
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
//        if let window = parent?.view.window {
//            let toolPicker = PKToolPicker()
//            toolPicker.setVisible(true, forFirstResponder: canvasView)
//            toolPicker.addObserver(canvasView)
//
//            canvasView.becomeFirstResponder()
//        }
    }


}

