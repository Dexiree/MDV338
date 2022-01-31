//
//  ViewController.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/5/22.
//

import UIKit
import PencilKit
import FirebaseStorage
import FirebaseFirestore

var mainView = ViewController()

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIColorPickerViewControllerDelegate {
    
    // OUTLETS
    @IBOutlet weak var vStack: UIStackView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pallete: UIStackView!
    
    @IBOutlet var Popup: UIView!
    @IBOutlet var Edit: UIView!
    
    @IBOutlet weak var lockedBtn: UIButton!
    @IBOutlet weak var refColorSwitch: UISwitch!
    @IBOutlet weak var refColorLabel: UILabel!
    
    
    @IBOutlet var Blur: UIVisualEffectView!
    
    @IBOutlet weak var Hex: UILabel!
    @IBOutlet weak var colorEdit: UIView!
    
    // Variables
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    let animation = Animations()
    
    var scheme: colorScheme = .complementary
    var temp: temperature = .auto
    var locked = [Bool]()
    var referenceColor = [Bool]()
    //var colorTheoryChoice = 0
    
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
    var projectID = "YbCCa5kf6U6kQexcIQna"
    var colorSchemes = [DocumentReference]()
    var colorScheme = "LeNbWMAA1JeiNmkkakAp"
    var sketch = 0
    var user = User(email: "design", uid: "JjyOH9HwS2dlMt34lJW3K19Avvm2")

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
        Popup.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.1)
        Popup.layer.cornerRadius = 20
        // Edit
        Edit.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.75, height: self.view.bounds.height * 0.3)
        Edit.layer.cornerRadius = 20
        
        mainView = self
        
    }
    func LoadData(){
        
        var docRef = db.collection("emails/\(user.email)/\(user.uid)/\(projectID)/ColorSchemes").document("\(colorScheme)")

        if colorSchemes.count > 0 {
            docRef = colorSchemes[0]
        }
        
        // getting specific document from user
        docRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {return print(error.debugDescription)}
            
            do {
                // get data
                guard let data = snapshot.data() else {
                    print("NO DATA")
                    return
                }
                let colorScheme = try ColorSchemes(snapshot: data)
                
                // get palette
                if let palette = colorScheme.palette {
                    let colors = palette.map { UIColor(hex: $0)}
                    self.loadPalette(colors: colors)
                }
                
                //get sketch
                guard let sketches = colorScheme.sketches else {return}
                
                if sketches.count == 0 {
                    //         create new sketch.drawing
                            let newSketch = PKCanvasView().drawing.dataRepresentation()
                    //         create new image.png
                            let newImage = UIImage(systemName: "scribble")?.pngData()
                    self.saveSketch(data: newSketch)
                    self.saveImage(data: newImage!)
                }
                let sketch = sketches[0]
                self.loadSketch(sketch: sketch)
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func loadPalette(colors: [UIColor]) {
        
        colors.forEach { color in
            self.new(color: color)
        }
        
        // when updating colors it removes the old colors
        if self.pallete.subviews.count > colors.count {
            repeat {
                self.pallete.subviews.first?.removeFromSuperview()
            } while self.pallete.subviews.count > colors.count
        }
    }
    
    func loadSketch(sketch: String) {
        
        // convert string to url
        guard let url = URL(string: sketch) else {
            print("NO URL")
            return}
    
        do {
            // convert url to data
            let data = try Data(contentsOf: url)
            
            // convert data to PKDrawing
            guard let sketch = try? PKDrawing(data: data) else {
                print("NO DRAWING")
                return}
            
            // load sketch on canvas
            self.canvasView.drawing = sketch
            
        } catch {
            print("error")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // tool picker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        // display project name
        navigationItem.title = projectName
        LoadData()
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
        let paletteData = getPaletteColors()
        savePalette(palette: paletteData)
    }
    
    // buttons
    @IBAction func addColor(_ sender: UIButton) {
        
        // show color picker
        present(colorPicker, animated: true)
        
        new(color: selectedColor)
    }
    @IBAction func generateColors(_ sender: UIButton) {

        // get first colors info
        var color: UIColor?
        for i in 0...referenceColor.count - 1 {
            if referenceColor[i] == true {
                color = pallete.subviews[i].backgroundColor
            }
        }
        guard let refColor = color else {
            QuickAlert(title: "Warning", message: "Please select a Reference Color", buttonMessage: "OK")
            return
        }
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        refColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Generate new colors based on color theme
        switch scheme {
        case .analogous:
            if pallete.subviews.count > 1 {
                for i in 0...pallete.subviews.count - 1 {
                    // all the colors except the locked ones
                    if locked[i] != true {
                        let newHue = CGFloat.random(in: hue - 0.17...hue + 0.17)
                        pallete.subviews[i].backgroundColor = UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
                    }
                }
            }
        case .monochromatic:
            if pallete.subviews.count > 1 {
                for i in 0...pallete.subviews.count - 1 {
                    // all the colors except the locked ones
                    if locked[i] != true {
                        let newBright = CGFloat.random(in: brightness - 0.17...brightness + 0.17)
                        pallete.subviews[i].backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: newBright, alpha: alpha)
                    }
                }
            }
        case .complementary:
            if pallete.subviews.count > 1 {
                for i in 0...pallete.subviews.count - 1 {
                    // all the colors except the locked ones
                    if locked[i] != true {
                        
                        // get complimentary color
                        var newHex = ""
                        let hex = refColor.getHex()
                        hex.forEach { char in
                            newHex.append(complimentary(value: char))
                        }
                        var complimentaryColor = UIColor(hex: newHex)
                        
                         //random brightness
                        var h,s,b: CGFloat
                        h = 0; s = 0; b = 0
                        complimentaryColor.getHue(&h, saturation: &s, brightness: &b, alpha: &alpha)
                        let newB = CGFloat.random(in: b - 0.17...b + 0.17)
                        complimentaryColor = UIColor(hue: h, saturation: s, brightness: newB, alpha: 1.0)
                        
                        // set color
                        pallete.subviews[i].backgroundColor = complimentaryColor
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
        let paletteData = getPaletteColors()
        savePalette(palette: paletteData)
    }

    func QuickAlert(title t: String, message m: String, buttonMessage b: String)
    {
        // creates the alert
        let alert = UIAlertController(title: t, message: m, preferredStyle: UIAlertController.Style.alert)
        
        // creates the alert button
        let okButton = UIAlertAction(title: b, style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        // presents the alert
        present(alert, animated: true, completion: nil)
    }

    func complimentary(value: Character) -> Character{
        // 0f,1e,2d,3c,4b,5a,69,78
        print("VALUE: \(value)")
        var newValue: Character = "0"
        
        switch value {
        case "0":
            newValue = "F"
        case "1":
            newValue = "E"
        case "2":
            newValue = "D"
        case "3":
            newValue = "C"
        case "4":
            newValue = "B"
        case "5":
            newValue = "A"
        case "6":
            newValue = "9"
        case "7":
            newValue = "8"
        case "A":
            newValue = "5"
        case "B":
            newValue = "4"
        case "C":
            newValue = "3"
        case "D":
            newValue = "2"
        case "E":
            newValue = "1"
        case "F":
            newValue = "0"
        default:
            newValue = "0"
        }
        
        return newValue
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
        
        // add lock to color
        locked.append(false)
        
        // add refColor option to color
        referenceColor.append(false)
        
        // add new color to the palette
        pallete.addArrangedSubview(newColor)
        
        // add the color to the new button
        selected = pallete.subviews.count - 1
        
    }
    
    func getPaletteColors() -> [String] {
        
        var paletteStrings = [String]()
        
        for color in pallete.subviews {
            paletteStrings.append("\((color.backgroundColor?.getHex())!)")
        }
        
        return paletteStrings
    }
    func savePalette(palette: [String]){
        
        let collectionRef = "emails/\(user.email)/\(user.uid)/\(projectID)/ColorSchemes"
        db.collection(collectionRef).document(colorScheme).setData(["palette" : palette])
        
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
                // set lock
                if self.locked[self.selected] == true {
                    self.lockedBtn.setImage(UIImage(systemName: "lock"), for: .normal)
                    self.lockedBtn.setTitle(" Locked", for: .normal)
                } else {
                    self.lockedBtn.setImage(UIImage(systemName: "lock.open"), for: .normal)
                    self.lockedBtn.setTitle(" Unlocked", for: .normal)
                }
                // set reference color
                if self.locked[self.selected] == true {
                    self.refColorSwitch.isEnabled = true
                    self.refColorLabel.isEnabled = true
                } else {
                    self.refColorSwitch.isEnabled = false
                    self.refColorLabel.isEnabled = false
                }
                if self.referenceColor[self.selected] == true {
                    self.refColorSwitch.isOn = true
                } else {
                    self.refColorSwitch.isOn = false
                }
                
                
            }
        }
    }
    func Wait(duration: Double, execute: ((() -> Void))?) {
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
            ink = inkling
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
        if locked[selected] == true {
            locked[selected] = false
            lockedBtn.setImage(UIImage(systemName: "lock.open"), for: .normal)
            lockedBtn.setTitle(" Unlocked", for: .normal)
            refColorSwitch.isEnabled = false
            refColorLabel.isEnabled = false
            refColorSwitch.isOn = false
            
        } else {
            locked[selected] = true
            lockedBtn.setImage(UIImage(systemName: "lock"), for: .normal)
            lockedBtn.setTitle(" Locked", for: .normal)
            refColorSwitch.isEnabled = true
            refColorLabel.isEnabled = true
        }
    }
    @IBAction func DuplicateEdit(_ sender: UIButton) {
        new(color: pallete.subviews[selected].backgroundColor!)
        let paletteData = getPaletteColors()
        savePalette(palette: paletteData)
    }
    @IBAction func DeleteEdit(_ sender: UIButton) {
        pallete.subviews[selected].removeFromSuperview()
        Edit.removeFromSuperview()
        locked.remove(at: selected)
        let paletteData = getPaletteColors()
        savePalette(palette: paletteData)
    }
    @IBAction func toggleReference(_ sender: UISwitch) {
        for i in 0...referenceColor.count - 1 {
            if i != selected {
                referenceColor[i] = false
            } else {
                referenceColor[i] = true
            }
        }
    }
    
    @IBAction func ColorTheorySegmented(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        switch index {
        case 0:
            scheme = .analogous
        case 1:
            scheme = .monochromatic
        case 2:
            scheme = .complementary
        default:
            scheme = .analogous
        }
        
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
    
    // saving functions
    func saveSketch(data: Data){
        let collectionRef = "emails/\(user.email)/\(user.uid)/\(projectID)/ColorSchemes"
        let sketchRef = "\(user.uid)/\(projectID)/ColorSchemes/\(colorScheme)/sketches/\(sketch).drawing"
        
        // saves sketch as data to storage
        storage.child(sketchRef).putData(data, metadata: nil) { _, error in
            guard error == nil else {
                print("There was an issue")
                return
            }
            
            // get url of sketch
            self.storage.child(sketchRef).downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                print("Download: \(urlString)")
                
                // send sketch link to database
                self.db.collection(collectionRef).document(self.colorScheme).getDocument { snapshot, error in
                    guard let snapshot = snapshot, error == nil else {
                        print("NO DOCUMENT")
                        return}
                    guard let data = snapshot.data() else {return}
                    
                    // either update or add sketch
                    do {
                        let colorScheme = try ColorSchemes(snapshot: data)
                        
                        // get all the sketches in the sketches array from database
                        if var sketches = colorScheme.sketches {
                            if sketches.count > 0 {
                                // update
                                sketches[self.sketch] = urlString

                                self.db.collection(collectionRef).document(self.colorScheme).updateData(["sketches" : sketches])
                            }
                            else {
                                // add new sketch to database
                                self.db.collection(collectionRef).document(self.colorScheme).updateData(["sketches" : FieldValue.arrayUnion([urlString])])
                            }
                        }
                        else {
                            // add new sketch to database
                            self.db.collection(collectionRef).document(self.colorScheme).updateData(["sketches" : FieldValue.arrayUnion([urlString])])
                        }
                        
                        
                    } catch {
                        print("NO DATA: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
        
    }
    
    func saveImage(data: Data) {
        let collectionRef = "emails/\(user.email)/\(user.uid)"
        let imageRef = "\(user.uid)/\(projectID)/image.png"
        
        // save image to storage
        storage.child(imageRef).putData(data, metadata: nil) { _, error in
            guard error == nil else {
                print("There was an issue")
                return
            }
            
            // get url from image
            self.storage.child(imageRef).downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
            
                // upload url to database
                self.db.collection(collectionRef).document(self.projectID).updateData(["image" : urlString])
        }
    }

}
    
}

