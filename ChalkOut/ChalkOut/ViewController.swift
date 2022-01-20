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
    @IBOutlet var Blur: UIVisualEffectView!
    
    
    // Variables
    var drawing = PKDrawing()
    var scheme: colorScheme = .analogous
    var temp: temperature = .auto
    var selected = 0
    
    
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
        let newColor = UIButton()
        newColor.backgroundColor = selectedColor
        newColor.layer.borderColor = CGColor(genericCMYKCyan: 1, magenta: 1, yellow: 1, black: 0, alpha: 1)
        newColor.addTarget(self, action: #selector(tappedColor), for: .touchUpInside)
        newColor.addTarget(self, action: #selector(doubleTappedColor), for: .touchDownRepeat)
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
    
    @objc private func tappedColor(_ sender: UIButton) {
        
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
        
        // show color picker
        present(colorPicker, animated: true)
        
        //set selected color to change it
        selected = pallete.subviews.firstIndex(of: sender)!
    }
    
    // MARK: NavBar
    @IBAction func Settings(_ sender: UIBarButtonItem) {
        animateIn(desiredView: Blur)
        animateIn(desiredView: Popup)
    }
    
    
    // MARK: Popup
    @IBAction func Done(_ sender: UIButton) {
        animateOut(desiredView: Popup)
        animateOut(desiredView: Blur)
    }
    
    // animations
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

