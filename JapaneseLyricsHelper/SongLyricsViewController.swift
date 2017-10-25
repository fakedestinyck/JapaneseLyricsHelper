//
//  SongLyricsViewController.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/24/2017.
//

import UIKit

class SongLyricsViewController: UIViewController {
    
    //MARK: Properties
    
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var song: Song?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = song?.title
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
