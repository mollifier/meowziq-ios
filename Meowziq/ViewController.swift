//
//  ViewController.swift
//  Meowziq
//
//  Created by Seiji Kohyama on 2015/03/31.
//  Copyright (c) 2015年 FaithCreates Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import SVProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var songs = MusicManager.getSongs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        addRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pullToRefresh() {
        songs = MusicManager.getSongs()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents:.ValueChanged)
        tableView.addSubview(refreshControl!)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as! SongCell
        cell.setCell(songs[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SVProgressHUD.showWithStatus("送信中……")
        let song = songs[indexPath.row]
        let deselectRow = { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        MusicManager.getSongRawData(
            song,
            success: { rawData in
                APIClient.addSong(
                    song, songRawData: rawData,
                    success: {
                        SVProgressHUD.showSuccessWithStatus("送信成功!")
                        deselectRow()
                    },
                    fail: { e in
                        SVProgressHUD.showErrorWithStatus("送信失敗!")
                        print(e)
                        deselectRow()
                    }
                )
            },
            fail: { e in
                SVProgressHUD.showErrorWithStatus("送信失敗!")
                print(e)
                deselectRow()
            }
        )
    }
}

