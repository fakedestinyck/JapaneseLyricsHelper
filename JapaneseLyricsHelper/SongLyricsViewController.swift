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
    var fontSize = CGFloat(25);
    var displayLanguages = [0] // 0->jp, 1->kana, 2->romaji
    var currentDisplayLanguageIndex = 0
    var lyricRows = [LyricRow]()
    var lyricLabels = [UILabel]()
    
    @IBOutlet weak var lyricScrollView: UIScrollView!
    @IBOutlet weak var refreshLrcButton: UIBarButtonItem!
    
    
    /*
     This value is either passed by `SongTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new song.
     */
    var song: Song?
    

    @IBAction func refreshLrcButton(_ sender: UIBarButtonItem) {
        refreshLrcButton.isEnabled = false
        lyricRows.removeAll()
        lyricLabels.removeAll()
        for view in lyricScrollView.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        downloadLyric(songName: (song?.name)!)
    }
    
    
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
        refreshLrcButton.isEnabled = true
        
        var filename = song?.name
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        filename = dirPath + "/lyric/" + filename! + ".plist"
        let fileContent = NSDictionary(contentsOfFile: filename!) as! [String:AnyObject]
        let localVersion = Int(fileContent["version"] as! String)!
        let remoteVersion = Int((song?.version)!)!
        if (localVersion) < (remoteVersion) {
            refreshLrcButton.isEnabled = false
            downloadLyric(songName: (song?.name)!)
            return
        }
        let lyricArray = fileContent["lyrics"] as! Array<Any>
        let lyricRowsCount = lyricArray.count
        
        // 把歌词放进LyricRow
        for eachLine in lyricArray {
            var putIntoLyricRowArray = [[String:AnyObject]]()
            guard let eachLineHasWordOrNot = (eachLine as! [String:AnyObject])["word"] else {
                // 如果没有word这一行，就插入一行空白数据
                var tmpInfo = [String:AnyObject]()
                tmpInfo["wordIndex"] = -1 as AnyObject
                tmpInfo["wordArray"] = ["",""] as AnyObject
                tmpInfo["currentDisplayLanguageIndex"] = 0 as AnyObject
                putIntoLyricRowArray.append(tmpInfo)
                lyricRows.append(LyricRow(lyricInfo: putIntoLyricRowArray)!)
                continue
            }
            for (wordIndex, words) in (eachLineHasWordOrNot as! [String:[String]]) {
                var tmpInfo = [String:AnyObject]()
                tmpInfo["wordIndex"] = Int(wordIndex) as AnyObject
                tmpInfo["wordArray"] = words as [String] as AnyObject
                tmpInfo["currentDisplayLanguageIndex"] = 0 as AnyObject
                putIntoLyricRowArray.append(tmpInfo)
            }
            lyricRows.append(LyricRow(lyricInfo: putIntoLyricRowArray)!)
        }
        
        
        
        
        // 把歌词做成UILabel
        for lrcNum in 0..<lyricRowsCount {
            let lyricLabel = UILabel.init(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
            var lyricStr = (lyricArray[lrcNum] as! [String:AnyObject])["jp"] as! String
            lyricLabel.numberOfLines = 0
            lyricLabel.lineBreakMode = .byCharWrapping
            let attStr = NSMutableAttributedString.init(string: lyricStr)
            attStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Hiragino Maru Gothic ProN", size: fontSize)!, range: NSMakeRange(0, lyricStr.characters.count))
            
            lyricLabel.attributedText = attStr
            lyricLabel.enabledTapEffect = false
            lyricLabel.translatesAutoresizingMaskIntoConstraints = false
            lyricLabels.append(lyricLabel)
            dealWithEachRowOfLabel(lrcNum: lrcNum, lyricStr: lyricStr)
            let lineSpace = NSMutableParagraphStyle()
            lineSpace.lineSpacing = 1.0
            attStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: lineSpace, range: NSMakeRange(0, lyricStr.characters.count))
            lyricScrollView.addSubview(lyricLabel)
            if lrcNum == 0 {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .top, relatedBy: .equal, toItem: lyricScrollView, attribute: .top, multiplier: 1.0, constant: 1.0))
            } else {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .top, relatedBy: .equal, toItem: lyricLabels[lrcNum-1], attribute: .bottom, multiplier: 1.0, constant: 30.0))
            }
            lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .centerX, relatedBy: .equal, toItem: lyricScrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .width, relatedBy: .equal, toItem: lyricScrollView, attribute: .width, multiplier: 1.0, constant: -10.0))
            if lrcNum == lyricRowsCount - 1 {
                lyricScrollView.addConstraint(NSLayoutConstraint(item: lyricLabel, attribute: .bottom, relatedBy: .equal, toItem: lyricScrollView, attribute: .bottom, multiplier: 1.0, constant: -1.0))
            }
        }
        
    }
    
    func dealWithEachRowOfLabel(lrcNum: Int, lyricStr: String) {
        var tapWords = [String]()
        let currentRow = lyricRows[lrcNum]
        for tmpi in 0..<(lyricStr as NSString).length {
            tapWords.append(String(lyricStr[lyricStr.index(lyricStr.startIndex, offsetBy: tmpi)]))
        }
//        for tmp in 0..<currentRow.lyricInfo.count {
//            if (currentRow.lyricInfo[tmp]["wordIndex"] as! Int) == currentRow.lastAffectedIndex {
//                currentRow.lyricInfo[tmp]["currentDisplayLanguageIndex"] = (currentRow.lyricInfo[tmp]["currentDisplayLanguageIndex"] as! Int) + 1 as AnyObject
//            }
//        }
//        for (_, word) in (lyricArray[lrcNum] as! [String:AnyObject])["kanji"] as! [String: String] {
//            tapWords.append(word)
//        }
        let lyricLabel = lyricLabels[lrcNum]
        lyricLabel.yb_addAttributeTapAction(with: tapWords) { (string, range, int) in
            for eachWord in 0..<currentRow.lyricInfo.count {
                let tappedIndex = range.lowerBound // 当前点击的index
                let judgeLowerBound = (currentRow.lyricInfo[eachWord]["wordIndex"] as! Int) // 判断的数组下界
                let judgeWord = (currentRow.lyricInfo[eachWord]["wordArray"] as! [String])[currentRow.lyricInfo[eachWord]["currentDisplayLanguageIndex"] as! Int] // 当前正在判断的字符
                let thisSubWord = (currentRow.lyricInfo[eachWord]["wordArray"] as! [String])[(currentRow.lyricInfo[eachWord]["currentDisplayLanguageIndex"] as! Int + 1) % 2]
                let judgeOffest = (thisSubWord as NSString).length - (judgeWord as NSString).length // 当前判断的字符长度和原来的进行比较 （若大于一，则表示替换后会产生delta，需要计算偏移）
                if judgeLowerBound <= tappedIndex && tappedIndex <= judgeLowerBound + (judgeWord as NSString).length - 1 {
                    print(judgeWord)
                    currentRow.lastAffectedIndex = judgeLowerBound
                    currentRow.lastDelta = judgeOffest
                    // 开始重新储存该行的wordIndex
                    for tmpIndex in 0 ..< currentRow.lyricInfo.count {
                        if currentRow.lyricInfo[tmpIndex]["wordIndex"] as! Int > currentRow.lastAffectedIndex {
                            currentRow.lyricInfo[tmpIndex]["wordIndex"] = ((currentRow.lyricInfo[tmpIndex]["wordIndex"] as! Int) + judgeOffest) as AnyObject
                        }
                    }
                    // 然后重新计算当前字符的currentDisplayLanguageIndex
                    currentRow.lyricInfo[eachWord]["currentDisplayLanguageIndex"] = ((currentRow.lyricInfo[eachWord]["currentDisplayLanguageIndex"] as! Int) + 1) % 2 as AnyObject
                    // 最后重新制作当前label
                    var newLyricStr = (lyricStr as NSString).replacingCharacters(in: NSMakeRange(judgeLowerBound, (judgeWord as NSString).length), with: thisSubWord)
                    let subAttStr = NSMutableAttributedString.init(string: newLyricStr)
                    subAttStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Hiragino Maru Gothic ProN", size: self.fontSize)!, range: NSMakeRange(0, newLyricStr.characters.count))
                    lyricLabel.attributedText = subAttStr
                    // 并再次call这个函数
                    self.dealWithEachRowOfLabel(lrcNum: lrcNum, lyricStr: newLyricStr)
                    break
                }
            }
        }
//        lyricLabel.yb_addAttributeTapAction(with: tapWords, tapClicked: { (string, range, int) in
//            let thisIndex = range.lowerBound
//            let thisSubWord = ((lyricArray[lrcNum] as! [String:AnyObject])["kana"] as! [String: String])[String(thisIndex)]! as String
//            lyricStr = (lyricStr as NSString).replacingCharacters(in: range, with: thisSubWord)
//            //                lyricStr.insert(contentsOf: thisSubWord, at: lyricStr.index(lyricStr.startIndex, offsetBy: thisIndex))
//            let subAttStr = NSMutableAttributedString.init(string: lyricStr)
//            subAttStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Hiragino Maru Gothic ProN", size: self.fontSize)!, range: NSMakeRange(0, lyricStr.characters.count))
//
//            lyricLabel.attributedText = subAttStr
//
//        })
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
        
        attStr.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 25), range: NSMakeRange(0, str.characters.count))
        
        label.attributedText = attStr
        label.textAlignment = NSTextAlignment.center
//        label.yb_addAttributeTapAction(["の","時","の", "午前", "わりに"]) { (string, range, int) in
//            print(range)
//        }
        
        
        // MARK: 关闭点击效果 默认是开启的
        //        label.enabledTapEffect = false
        
        
        self.view.addSubview(label)
    }
    
    func loadSettings() {
        // Load from file and set three segs
        if let tmpDefault = UserDefaults.standard.object(forKey: "LANGUAGE_ONE") {
            
        } else {
            
        }
        
        if let tmpTouchOne = UserDefaults.standard.object(forKey: "LANGUAGE_TWO") {
            
            if tmpTouchOne as! Int != 3 {
                
            }
        }
        
        if let tmpTouchTwo = UserDefaults.standard.object(forKey: "LANGUAGE_THREE") {
        }
        
        if UserDefaults.standard.object(forKey: "FONT_SIZE") != nil{
            fontSize = CGFloat(UserDefaults.standard.float(forKey: "FONT_SIZE"))
        }
        
        //refreshLanguageTouchDisplayArray()
        
        
        
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = song?.title
        
        if !(song?.hasLyrics)! {
            let alert = UIAlertController(title: "未找到歌词！", message: "歌词还未更新，过一段时间再刷新试试吧", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            }))
            navigationController?.popToRootViewController(animated: true)
            self.present(alert, animated: true, completion: nil)
        } else {
            refreshLrcButton.isEnabled = true
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
