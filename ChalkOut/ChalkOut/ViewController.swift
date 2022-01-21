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
    @IBOutlet var Popup: UIView!
    @IBOutlet var Edit: UIView!
    @IBOutlet var Tools: UIView!
    @IBOutlet var Blur: UIVisualEffectView!
    @IBOutlet weak var Hex: UILabel!
    @IBOutlet weak var colorEdit: UIView!
    
    
    
    // Variables
    var drawing = PKDrawing()
    var scheme: colorScheme = .analogous
    var temp: temperature = .auto
    var selected = 0
    var holding = false
    var hexadecimal = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    
    
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
        
        // Popup
        Blur.bounds = self.view.bounds
        Popup.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.4)
        Popup.layer.cornerRadius = 20
        // Edit
        Popup.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.3)
        Edit.layer.cornerRadius = 20
        // Tools
        Tools.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.3)
        Edit.layer.cornerRadius = 20
        
    }
    
    // MARK: - Palette
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // set selectColor
        selectedColor = viewController.selectedColor
        
        // change the color on the palette
        pallete.subviews[selected].backgroundColor = selectedColor
    }
    
    @IBAction func addColor(_ sender: UIButton) {
        
        // show color picker
        present(colorPicker, animated: true)
        
        // add selected color to pallete
        new(color: selectedColor)
    }
    
    func new(color: UIColor) {
        // add selected color to pallete
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
    }
    
    // MARK: - Actions
    @objc private func tappedColor(_ sender: UIButton) {
        // user is not holding the color but is tapping
        holding = false
        
        // use selected color to sketch with
        // TODO: Change hardcoded tool and width
        //canvasView.tool = PKInkingTool(.pencil, color: sender.backgroundColor!, width: 1.0)
        toolPicker.selectedTool = PKInkingTool(.pencil, color: sender.backgroundColor!, width: 1.0)
        
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
                self.animateIn(desiredView: self.Edit)
                // convert UIColor TO HEX
                self.Hex.text = "#\(self.getHex(sender.backgroundColor!))"
                // show chosen color
                self.colorEdit.backgroundColor = sender.backgroundColor
                // get seleced
                self.selected = self.pallete.subviews.firstIndex(of: sender)!
                
            }
        }
    }
    func getHex(_ color: UIColor) -> String {
        
        // get colors info
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // convert to Ints
        let red = Int(r*255)
        let green = Int(g*255)
        let blue = Int(b*255)
        
        // multiply by 16 get the Ints
        let r1 = Int(red/16)
        let g1 = Int(green/16)
        let b1 = Int(blue/16)
        // get the remainder
        let r2 = red%16
        let g2 = green%16
        let b2 = blue%16
        // take first half and second halves and convert to hexiadecimal
        return "\(hexadecimal[r1])\(hexadecimal[r2])\(hexadecimal[g1])\(hexadecimal[g2])\(hexadecimal[b1])\(hexadecimal[b2])"
    }
    func Wait(duration: Double, execute: ((() -> Void))?)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if let done = execute{done()}
        }
    }
    
    // MARK: NavBar
    @IBAction func Settings(_ sender: UIBarButtonItem) {
        animateIn(desiredView: Blur)
        animateIn(desiredView: Popup)
    }
    @IBAction func ChooseTool(_ sender: UIBarButtonItem) {
        print("Clicked")
    }
    
    
    
    // MARK: Popups
    @IBAction func Done(_ sender: UIButton) {
        animateOut(desiredView: Popup)
        animateOut(desiredView: Blur)
    }
    
    @IBAction func CloseEdit(_ sender: UIButton) {
        animateOut(desiredView: Edit)
    }
    @IBAction func LockEdit(_ sender: UIButton) {
    }
    @IBAction func DuplicateEdit(_ sender: UIButton) {
        new(color: pallete.subviews[selected].backgroundColor!)
    }
    @IBAction func DeleteEdit(_ sender: UIButton) {
        pallete.subviews[selected].removeFromSuperview()
        Edit.removeFromSuperview()
    }
    
    
    // MARK: - Animations
    func animateIn(desiredView: UIView) {
        // get background
        let backgroundView = self.view!
        
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

