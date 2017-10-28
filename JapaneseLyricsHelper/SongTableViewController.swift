//
//  SongTableViewController.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit
import AVFoundation
import Alamofire

class SongTableViewController: UITableViewController{
    
    //MARK: Properties
    
    var songs = [Song]()
    private var audioPlayer: AVAudioPlayer?
    private var lastPlayedName = ""
    private var lastPlayedButton: UIImageView?
    

    
    
    
    //MARK: Private Methods
    
    private func loadSampleSongs() {
        guard let song1 = Song(name:"awaihana", title: "淡い花", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let song2 = Song(name:"childish_flower", title: "Childish Flower", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let song3 = Song(name:"zenzenzensei", title: "前々前世", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let song4 = Song(name:"yumemaboro", title: "夢幻花火", languages: ["jp","kana"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        songs += [song1, song2, song3, song4]
    }
    
    private func playMusic(songName: String) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let fileName = "/mp3/" + songName + ".mp3"
        let music = URL(fileURLWithPath: dirPath+fileName)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: music)
        audioPlayer!.prepareToPlay()
        lastPlayedName = songName
        
        audioPlayer!.play()
    }
    
    private func downloadMusic(songName: String, image: UIImageView) {
        SwiftSpinner.show(progress: 0, title: "正在下载\n0.00%")
        let urlString = "http://jathere.cn/japaneseLyricsHelper/music/"+songName+".mp3"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("mp3/\(songName).mp3")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(urlString, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
                SwiftSpinner.show(progress: progress.fractionCompleted, title: "正在下载\n\(Float(Int(progress.fractionCompleted*10000))/100.00)%")
            }
            .responseData { response in
                if response.result.value != nil {
                    SwiftSpinner.hide()
                    image.image = #imageLiteral(resourceName: "PlayTouched")
                    self.playMusic(songName: songName)
                }
            }
    }
    
    @objc func playButtonTouched(sender:UITapGestureRecognizer) {
        let songIndex = sender.view?.tag
        let songName = songs[songIndex!].name
        let image = sender.view as! UIImageView
        if image.image != #imageLiteral(resourceName: "PlayTouched") { // don't know why image.image == #imageLiteral(resourceName: "Play") didn't work
            
            // if last played mp3 is this song, continue
            if lastPlayedName == songName {
                image.image = #imageLiteral(resourceName: "PlayTouched")
                audioPlayer!.play()
            } else {
                //prepare mp3
                let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
                let fileName = "/mp3/" + songName + ".mp3"
                
                let fileManager = FileManager.default
                if !fileManager.fileExists(atPath: dirPath+fileName) {
                    downloadMusic(songName: songName, image: image)
                } else {
                    image.image = #imageLiteral(resourceName: "PlayTouched")
                    playMusic(songName: songName)
                }
                if lastPlayedButton != nil {
                    lastPlayedButton?.image = #imageLiteral(resourceName: "Play")
                }
                lastPlayedButton = image
            }
        } else {
            image.image = #imageLiteral(resourceName: "Play")
            audioPlayer!.pause()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleSongs()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SongTableViewSell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SongTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SongTableViewCell.")
        }
        
        // Fetches the appropriate song for the data source layout.
        let song = songs[indexPath.row]
        
        cell.songTitleLabel.text = song.title
        cell.languagesLabel.text = song.languages[0]
        cell.playButtonImage.image = #imageLiteral(resourceName: "Play")
        cell.playButtonImage.tag = indexPath.row
        
        let tapPlayGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SongTableViewController.playButtonTouched))
        
        cell.playButtonImage.addGestureRecognizer(tapPlayGesture)
        
        return cell
    }
    
    
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Settings":
            print("Settings")
            
        case "ShowSong":
            guard let songLyricsViewController = segue.destination as? SongLyricsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedSongCell = sender as? SongTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "Unknown")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedSongCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedSong = songs[indexPath.row]
            songLyricsViewController.song = selectedSong
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "Unknown")")
        }
    }

}

