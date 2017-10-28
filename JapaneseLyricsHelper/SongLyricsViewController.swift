//
//  SongLyricsViewController.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/24/2017.
//

import UIKit
import Alamofire



class SongLyricsViewController: UIViewController {
    
    //MARK: Properties
    var fontSize = CGFloat(20);
    var displayLanguages = [0] // 0->jp, 1->kana, 2->romaji
    var currentDisplayLanguageIndex = 0
    
    @IBOutlet weak var lyricScrollView: UIScrollView!
    
    /*
     This value is either passed by `SongTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new song.
     */
    var song: Song?
    
    
    
    
    
    private func downloadLyric(songName: String) {
        SwiftSpinner.show("正在下载")
        let urlString = "http://jathere.cn/japaneseLyricsHelper/lyric/"+songName+".plist"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("lyric/\(songName).plist")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(urlString, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if response.result.value != nil {
                    SwiftSpinner.hide()
                    self.loadLyric()
                }
        }
    }
    
    func loadLyric() {
        var filename = song?.name
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        filename = dirPath + "/lyric/" + filename! + ".plist"
        let lyricArray = NSArray(contentsOfFile: filename!) as! Array<Any>
        
        // 把歌词做成UILabel
        let lyricRowsCount = lyricArray.count
        var lyricLabels = [UILabel]()
        for lrcNum in 0..<lyricRowsCount {
            let lyricLabel = UILabel.init(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
            var lyricStr = (lyricArray[lrcNum] as! [String:AnyObject])["jp"] as! String
            lyricLabel.numberOfLines = 0
            lyricLabel.lineBreakMode = .byCharWrapping
            let attStr = NSMutableAttributedString.init(string: lyricStr)
            
            attStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Hiragino Maru Gothic ProN", size: fontSize)!, range: NSMakeRange(0, lyricStr.characters.count))
            
            lyricLabel.attributedText = attStr
            var tapWords = [String]()
            for (_, word) in (lyricArray[lrcNum] as! [String:AnyObject])["kanji"] as! [String: String] {
                tapWords.append(word)
            }
            print(tapWords)
//            lyricLabel.yb_addAttributeTapAction(tapWords) { (string, range, int) in
//                print(string)
//            }
            lyricLabel.yb_addAttributeTapAction(with: tapWords, tapClicked: { (string, range, int) in
                let thisIndex = range.lowerBound
                let thisSubWord = ((lyricArray[lrcNum] as! [String:AnyObject])["kana"] as! [String: String])[String(thisIndex)]! as String
                lyricStr = (lyricStr as NSString).replacingCharacters(in: range, with: thisSubWord)
//                lyricStr.insert(contentsOf: thisSubWord, at: lyricStr.index(lyricStr.startIndex, offsetBy: thisIndex))
                let subAttStr = NSMutableAttributedString.init(string: lyricStr)
                subAttStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Hiragino Maru Gothic ProN", size: self.fontSize)!, range: NSMakeRange(0, lyricStr.characters.count))
                
                lyricLabel.attributedText = subAttStr
                
            })
            lyricLabel.enabledTapEffect = false
            lyricLabel.translatesAutoresizingMaskIntoConstraints = false
            lyricLabels.append(lyricLabel)
            
            lyricScrollView.addSubview(lyricLabel)
            if lrcNum == 0 {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .top, relatedBy: .equal, toItem: lyricScrollView, attribute: .top, multiplier: 1.0, constant: 1.0))
            } else {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .top, relatedBy: .equal, toItem: lyricLabels[lrcNum-1], attribute: .bottom, multiplier: 1.0, constant: 10.0))
            }
            lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .centerX, relatedBy: .equal, toItem: lyricScrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .width, relatedBy: .equal, toItem: lyricScrollView, attribute: .width, multiplier: 1.0, constant: -10.0))
            if lrcNum == lyricRowsCount - 1 {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .bottom, relatedBy: .equal, toItem: lyricScrollView, attribute: .bottom, multiplier: 1.0, constant: -1.0))
            }
        }
        
        // 开始放歌词进UIScrollView
        

        
    }
    
    func createLabel(strText: String) {
        var label : UILabel
        label = UILabel.init(frame: CGRect.init(x: 10, y: 100, width: 200, height: 1000))
        let str = strText
        label.layer.borderWidth = 1;
        label.layer.borderColor = UIColor.gray.cgColor
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        let attStr = NSMutableAttributedString.init(string: str)
        
        attStr.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20), range: NSMakeRange(0, str.characters.count))
        
        label.attributedText = attStr
        label.textAlignment = NSTextAlignment.center
//        label.yb_addAttributeTapAction(["の","時","の", "午前", "わりに"]) { (string, range, int) in
//            print(range)
//        }
        
        
        // MARK: 关闭点击效果 默认是开启的
        //        label.enabledTapEffect = false
        
        
        self.view.addSubview(label)
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = song?.title
        
        if UserDefaults.standard.object(forKey: "FONT_SIZE") != nil{
            fontSize = CGFloat(UserDefaults.standard.float(forKey: "FONT_SIZE"))
        }
        
        let fileManager = FileManager.default
        var filename = song?.name
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        filename = dirPath + "/lyric/" + filename! + ".plist"
        if !fileManager.fileExists(atPath: filename!) {
            downloadLyric(songName: (song?.name)!)
        } else {
            loadLyric()
        }
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
