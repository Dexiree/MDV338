//
//  ViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/5/22.
//

import UIKit
import PencilKit
import FirebaseStorage

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIColorPickerViewControllerDelegate {
    
    // OUTLETS
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pallete: UIStackView!
    
    @IBOutlet var Popup: UIView!
    @IBOutlet var Edit: UIView!
    @IBOutlet var Blur: UIVisualEffectView!
    
    @IBOutlet weak var Hex: UILabel!
    @IBOutlet weak var colorEdit: UIView!
    
    // Variables
    private let storage = Storage.storage().reference()
    //var drawing = Data()
    let animation = Animations()
    
    var scheme: colorScheme = .analogous
    var temp: temperature = .auto
    
    var selected = 0
    var holding = false
    
    lazy var toolPicker: PKToolPicker = {
           let toolPicker = PKToolPicker()
            toolPicker.addObserver(self)
            return toolPicker
        }()
    var selectedColor = UIColor.black
    let colorPicker = UIColorPickerViewController()
    var ink = PKInkingTool(.pencil)
    
    var projectName = "Untiled"

    // MARK: Load View
    override func viewDidLoad() {
        super.viewDidLoad()
        // canvas
        canvasView.delegate = self
        // for testing purposes allow fingers to draw
        canvasView.drawingPolicy = .anyInput
        
        // color picker
        colorPicker.delegate = self
        
        // Popup
        Blur.bounds = self.view.bounds
        Popup.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.4)
        Popup.layer.cornerRadius = 20
        // Edit
        Edit.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.75, height: self.view.bounds.height * 0.3)
        Edit.layer.cornerRadius = 20
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // tool picker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // display project name
        navigationItem.title = projectName
    }
    
    // Hides home button
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    // MARK: - Palette
    // color picker
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // set selectColor
        selectedColor = viewController.selectedColor
        // change the color on the palette
        pallete.subviews[selected].backgroundColor = selectedColor
        
        // change color for tool
        ink.color = selectedColor
        toolPicker.selectedTool = ink
        
        //save color palette to Firebase
        savePalette()
    }
    
    // buttons
    @IBAction func addColor(_ sender: UIButton) {
        
        // show color picker
        present(colorPicker, animated: true)
        
        // add selected color to pallete
        new(color: selectedColor)
    }
    @IBAction func generateColors(_ sender: UIButton) {
        
        // TODO: Change to getting hsb from locked colors
        // get first colors info
        let first = pallete.subviews.first?.backgroundColor
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        first?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Generate new colors based on color theme
        switch scheme {
        case .analogous:
            if pallete.subviews.count > 1 {
                for i in 0...pallete.subviews.count - 1 {
                    // all the colors except the first
                    if i > 0 {
                        let newHue = CGFloat.random(in: hue - 0.17...hue + 0.17)
                        pallete.subviews[i].backgroundColor = UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
                    }
                }
            }
            
        default:
            // TODO: Do not change locked colors
            // generates random colors in palette
            pallete.subviews.forEach { color in
                color.backgroundColor = UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: CGFloat.random(in: 0.0...1.0), brightness: CGFloat.random(in: 0.0...1.0), alpha: 1.0)
            }
        }
        
        // save palette
        savePalette()
    }
    
    // functions
    func new(color: UIColor) {
        // creating new button
        let newColor = UIButton()
        newColor.backgroundColor = color
        newColor.layer.borderColor = CGColor(genericCMYKCyan: 1, magenta: 1, yellow: 1, black: 0, alpha: 1)
        
        // adding interactions to the button
        newColor.addTarget(self, action: #selector(tappedColor), for: .touchUpInside)
        newColor.addTarget(self, action: #selector(doubleTappedColor), for: .touchDownRepeat)
        newColor.addTarget(self, action: #selector(holdColor), for: .touchDown)
        
        // add new color to the palette
        pallete.addArrangedSubview(newColor)
        
        // add the color to the new button
        selected = pallete.subviews.count - 1
        
    }
    func savePalette(){
        var paletteString = ""
        for color in pallete.subviews {
            paletteString.append("#\((color.backgroundColor?.getHex())!)")
        }
        storage.child("Projects/projectName/palette.txt").putData(paletteString.data(using: .utf16)!, metadata: nil) { _, error in
            guard error == nil else {
                print("There was an issue")
                return
            }
        }
    }
    
    // MARK: - Palette Actions
    @objc private func tappedColor(_ sender: UIButton) {
        // user is not holding the color but is tapping
        holding = false
        
        // use selected color to sketch with
        toolPicker.selectedTool = PKInkingTool(ink.inkType, color: sender.backgroundColor!, width: ink.width)
        
        // hightlight selected color
        for i in 0...pallete.subviews.count - 1 {
            pallete.subviews[i].layer.borderWidth = 0
        }
        sender.layer.borderWidth = 5.0
    }
    @objc private func doubleTappedColor(_ sender: UIButton) {
        // user is not holding the color but is tapping
        holding = false
        
        // show color picker
        present(colorPicker, animated: true)
        
        //set selected color to change it
        selected = pallete.subviews.firstIndex(of: sender)!
    }
    @objc private func holdColor(_ sender: UIButton) {
        // user is holding the color
        holding = true
        
        // waiting 2 seconds to see if user is still holding down the color
        Wait(duration: 1.5) {
            if self.holding {
                self.animation.animateIn(desiredView: self.Edit, on: self.view)
                // convert UIColor TO HEX
                self.Hex.text = "#\(sender.backgroundColor!.getHex())"
                // show chosen color
                self.colorEdit.backgroundColor = sender.backgroundColor
                // get seleced
                self.selected = self.pallete.subviews.firstIndex(of: sender)!
                
            }
        }
    }
    func Wait(duration: Double, execute: ((() -> Void))?)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if let done = execute{done()}
        }
    }
    
    // MARK: - NavBar
    @IBAction func Settings(_ sender: UIBarButtonItem) {
        animation.animateIn(desiredView: Blur, on: self.view)
        animation.animateIn(desiredView: Popup, on: self.view)
    }
    
    // MARK: - Tools
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        
        if let inkling = toolPicker.selectedTool as? PKInkingTool {
            print("INK: \(inkling)")
            ink = inkling
        } else if let eraser = toolPicker.selectedTool as? PKEraserTool {
            print("ERASER: \(eraser)")
        } else if let lasso = toolPicker.selectedTool as? PKLassoTool {
            print("LASSO: \(lasso)")
        }
    }
    
    // MARK: - Popups
    // Settings
    @IBAction func Done(_ sender: UIButton) {
        animation.animateOut(desiredView: Popup)
        animation.animateOut(desiredView: Blur)
        
    }
    
    // Edit Color
    @IBAction func CloseEdit(_ sender: UIButton) {
        animation.animateOut(desiredView: Edit)
    }
    @IBAction func LockEdit(_ sender: UIButton) {
        
    }
    @IBAction func DuplicateEdit(_ sender: UIButton) {
        new(color: pallete.subviews[selected].backgroundColor!)
        savePalette()
    }
    @IBAction func DeleteEdit(_ sender: UIButton) {
        pallete.subviews[selected].removeFromSuperview()
        Edit.removeFromSuperview()
        savePalette()
    }
    
    
    // MARK: - Saving Sketch Data
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
        // saves drawing every time user edits the canvas
        saveSketch(data: canvasView.drawing.dataRepresentation())
        
        // Get Snapshot //
        // begin convertion of drawing to bitmap
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        // get the snapshot of image
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        // get snapshot from uigraphics and end
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // make sure the snapshot is not nil
        if snapshot != nil {
            // turn snapshot into data
            guard let snapData = snapshot?.pngData() else {return}
            // send data to firebase
            saveImage(data: snapData)
        }
        
    }
    
    func saveSketch(data: Data){
        // saves drawing as data to database
        storage.child("Projects/projectName/sketch.drawing").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                print("There was an issue")
                return
            }
            
//            self.storage.child("drawings/file.drawing").downloadURL { url, error in
//                guard let url = url, error == nil else {
//                    return
//                }
//                let urlString = url.absoluteString
//                print("Download: \(urlString)")
//            }
        }
        
    }
    func saveImage(data: Data) {
        storage.child("Projects/projectName/snapshot.png").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                print("There was an issue")
                return
            }
        }
    }

}

