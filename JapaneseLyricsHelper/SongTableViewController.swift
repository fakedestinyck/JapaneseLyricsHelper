//
//  SongTableViewController.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit

class SongTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var songs = [Song]()
    
    //MARK: Private Methods
    
    private func loadSampleSongs() {
        guard let song1 = Song(title: "淡い花", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let song2 = Song(title: "Childish Flower", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let song3 = Song(title: "前々前世", languages: ["jp"], lyrics: nil) else {
            fatalError("Unable to instantiate meal1")
        }
        
        songs += [song1, song2, song3]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleSongs()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
