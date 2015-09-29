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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var refreshControl: UIRefreshControl!
    
    var songs = MusicManager.getSongs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        addRefreshControl()
        
        searchBar.delegate = self
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
        MusicManager.getSongRawData(
            song,
            success: { rawData in
                APIClient.addSong(
                    song, songRawData: rawData,
                    success: { SVProgressHUD.showSuccessWithStatus("送信成功!") },
                    fail: { e in
                        SVProgressHUD.showErrorWithStatus("送信失敗!")
                        print(e)
                    }
                )
            },
            fail: { e in
                SVProgressHUD.showErrorWithStatus("送信失敗!")
                print(e)
            }
        )
    }
    
    // UISearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        navigationController?.setNavigationBarHidden(false, animated: true)
        searchBar.text = ""
        songs = MusicManager.getSongs()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let keyword = searchBar.text {
            // 曲のタイトルまたはアーティスト名に部分一致する曲を絞り込みます
            // 大文字小文字の違いを無視します
            let lowercaseKeyword = keyword.lowercaseString
            let searchResult = MusicManager.getSongs().filter { ($0.title?.lowercaseString.containsString(lowercaseKeyword) == true) || ($0.artist?.lowercaseString.containsString(lowercaseKeyword) == true) }
            songs = searchResult
            tableView.reloadData()
        }
        
        // キーボードを消します
        searchBar.resignFirstResponder()
        // キーボードを消すとキャンセルボタンが自動的に無効状態になってしまいます
        // それを防ぐために、キーボードを消した後にキャンセルボタンを明示的に有効状態にします
        // searchBarのsubviewsおよびsubviewsのsubviewsからUIButtonを探して、それをenabled = trueにします
        searchBar.subviews.flatMap({ [$0] + $0.subviews }).flatMap({ $0 as? UIButton }).forEach({ $0.enabled = true })
    }
}

