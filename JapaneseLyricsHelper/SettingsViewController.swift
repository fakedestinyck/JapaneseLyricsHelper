//
//  SettingsViewController.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/25/2017.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: Properties
    
    var displayLanguages = [0] // 0->jp, 1->kana, 2->romaji
    var currentDisplayLanguageIndex = 0
    var previewTextArray = ["プレビュー：佐藤友咲", "プレビュー：さとうゆうさく", "pu re byu -：sa to u yu u sa ku"]
    var previewTimesTouched = 0;
    var fontSize = CGFloat(25);
    
    @IBOutlet weak var defaultDisplaySeg: UISegmentedControl!
    @IBOutlet weak var touchDisplayOneSeg: UISegmentedControl!
    @IBOutlet weak var touchDisplayTwoSeg: UISegmentedControl!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var previewLabel: UILabel!
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(defaultDisplaySeg.selectedSegmentIndex, forKey: "LANGUAGE_ONE")
        UserDefaults.standard.set(touchDisplayOneSeg.selectedSegmentIndex, forKey: "LANGUAGE_TWO")
        UserDefaults.standard.set(touchDisplayTwoSeg.selectedSegmentIndex, forKey: "LANGUAGE_THREE")
        UserDefaults.standard.set(fontSize, forKey: "FONT_SIZE")
        let alert = UIAlertController(title: "成功！", message: "设置已保存", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            //self.createScore()
            //                if dismissOrNot == true {
            //                    self.dismiss(animated: true, completion: nil)
            //                }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func defaultDisplaySeg(_ sender: UISegmentedControl) {
        let previewString = previewTextArray[defaultDisplaySeg.selectedSegmentIndex]
        let mutableString = NSMutableAttributedString(string: previewString)
        mutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: previewLabel.font.familyName, size: fontSize)!,range: NSMakeRange(0,(previewString as NSString).length))
        previewLabel.attributedText = mutableString
        if defaultDisplaySeg.selectedSegmentIndex == touchDisplayOneSeg.selectedSegmentIndex {
            touchDisplayOneSeg.selectedSegmentIndex = 3
            touchDisplayTwoSeg.selectedSegmentIndex = 3
            touchDisplayTwoSeg.isEnabled = false
        }
        for tmpIndex in 0...3 {
            if tmpIndex != defaultDisplaySeg.selectedSegmentIndex {
                touchDisplayOneSeg.setEnabled(true, forSegmentAt: tmpIndex)
                if tmpIndex != touchDisplayOneSeg.selectedSegmentIndex {
                    touchDisplayTwoSeg.setEnabled(true, forSegmentAt: tmpIndex)
                }
            } else {
                touchDisplayOneSeg.setEnabled(false, forSegmentAt: tmpIndex)
                touchDisplayTwoSeg.setEnabled(false, forSegmentAt: tmpIndex)
            }
        }
        refreshLanguageTouchDisplayArray()
    }
    
    @IBAction func touchDisplayOneSeg(_ sender: UISegmentedControl) {
        for tmpIndex in 0...3 {
            if tmpIndex != defaultDisplaySeg.selectedSegmentIndex {
                touchDisplayTwoSeg.setEnabled(true, forSegmentAt: tmpIndex)
            }
        }
        if touchDisplayOneSeg.selectedSegmentIndex != 3 {
            touchDisplayTwoSeg.isEnabled = true
            touchDisplayTwoSeg.setEnabled(false, forSegmentAt: touchDisplayOneSeg.selectedSegmentIndex)
        } else {
            touchDisplayTwoSeg.isEnabled = false
            touchDisplayTwoSeg.selectedSegmentIndex = 3
            for tmpIndex in 0...3 {
                if tmpIndex != defaultDisplaySeg.selectedSegmentIndex {
                    touchDisplayOneSeg.setEnabled(true, forSegmentAt: tmpIndex)
                }
            }
        }
        previewTimesTouched = 0
        refreshLanguageTouchDisplayArray()
    }
    
    @IBAction func touchDisplayTwoSeg(_ sender: UISegmentedControl) {
        for tmpIndex in 0...3 {
            if tmpIndex != defaultDisplaySeg.selectedSegmentIndex {
                touchDisplayOneSeg.setEnabled(true, forSegmentAt: tmpIndex)
            }
        }
        if touchDisplayTwoSeg.selectedSegmentIndex != 3 {
            touchDisplayOneSeg.setEnabled(false, forSegmentAt: touchDisplayTwoSeg.selectedSegmentIndex)
        }
        refreshLanguageTouchDisplayArray()
    }
    
    @IBAction func fontSizeSlider(_ sender: UISlider) {
        let previewString = previewLabel.text
        let mutableString = NSMutableAttributedString(string: previewString!)
        mutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: previewLabel.font.familyName, size: CGFloat(fontSizeSlider.value))!,range: NSMakeRange(0,(previewString! as NSString).length))
        previewLabel.attributedText = mutableString
        fontSize = CGFloat(fontSizeSlider.value)
    }
    
    func refreshLanguageTouchDisplayArray() {
        displayLanguages = [defaultDisplaySeg.selectedSegmentIndex]
        if touchDisplayOneSeg.selectedSegmentIndex != -1 && touchDisplayOneSeg.selectedSegmentIndex != 3 {
            displayLanguages.append(touchDisplayOneSeg.selectedSegmentIndex)
            if touchDisplayTwoSeg.selectedSegmentIndex != -1 && touchDisplayTwoSeg.selectedSegmentIndex != 3 {
                displayLanguages.append(touchDisplayTwoSeg.selectedSegmentIndex)
            }
        }
        print(displayLanguages)
    }
    
    @objc func textTouched(sender:UITapGestureRecognizer){
        previewTimesTouched = (previewTimesTouched+1)%displayLanguages.count
        let previewString = previewTextArray[displayLanguages[previewTimesTouched]]
        let mutableString = NSMutableAttributedString(string: previewString)
        mutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: previewLabel.font.familyName, size: fontSize)!,range: NSMakeRange(0,(previewString as NSString).length))
        previewLabel.attributedText = mutableString
        print(previewTimesTouched)
    }
    
    func loadSettings() {
        // Load from file and set three segs
        if let tmpDefault = UserDefaults.standard.object(forKey: "LANGUAGE_ONE") {
            defaultDisplaySeg.selectedSegmentIndex = tmpDefault as! Int
            touchDisplayOneSeg.setEnabled(false, forSegmentAt: tmpDefault as! Int)
            touchDisplayTwoSeg.setEnabled(false, forSegmentAt: tmpDefault as! Int)
        } else {
            touchDisplayOneSeg.setEnabled(false, forSegmentAt: 0)
            touchDisplayTwoSeg.setEnabled(false, forSegmentAt: 0)
        }
        
        if let tmpTouchOne = UserDefaults.standard.object(forKey: "LANGUAGE_TWO") {
            touchDisplayOneSeg.selectedSegmentIndex = tmpTouchOne as! Int
            touchDisplayTwoSeg.setEnabled(false, forSegmentAt: tmpTouchOne as! Int)
            if tmpTouchOne as! Int != 3 {
                touchDisplayTwoSeg.isEnabled = true
            }
        }
        
        if let tmpTouchTwo = UserDefaults.standard.object(forKey: "LANGUAGE_THREE") {
            touchDisplayTwoSeg.selectedSegmentIndex = tmpTouchTwo as! Int
        }
        
        if UserDefaults.standard.object(forKey: "FONT_SIZE") != nil{
            fontSize = CGFloat(UserDefaults.standard.float(forKey: "FONT_SIZE"))
            fontSizeSlider.value = Float(fontSize)
        }
        
        refreshLanguageTouchDisplayArray()
        
        let previewString = previewTextArray[displayLanguages[0]]
        let mutableString = NSMutableAttributedString(string: previewString)
        mutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: previewLabel.font.familyName, size: fontSize)!,range: NSMakeRange(0,(previewString as NSString).length))
        previewLabel.attributedText = mutableString
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapPreviewTextGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textTouched))
        previewLabel.addGestureRecognizer(tapPreviewTextGesture)
        loadSettings()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
