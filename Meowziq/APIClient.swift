//
//  APIClient.swift
//  Meowziq
//
//  Created by Seiji Kohyama on 2015/03/31.
//  Copyright (c) 2015年 FaithCreates Inc. All rights reserved.
//

import Foundation
import Alamofire
import MediaPlayer

class APIClient {
    
    private final class Urls {
        private init() {}
        
        var apiServerURL = NSUserDefaults.standardUserDefaults().stringForKey("apiServerURL") ?? ""
        var songs: String {
            return "\(apiServerURL)/songs"
        }
        
        class var instance : Urls {
            struct Static {
                static let instance = Urls()
            }
            return Static.instance
        }
    }
    
    class var apiServerURL: String {
        set(apiServerURL) {
            Urls.instance.apiServerURL = apiServerURL
            NSUserDefaults.standardUserDefaults().setObject(self.apiServerURL, forKey: "apiServerURL")
        }
        get {
            return Urls.instance.apiServerURL
        }
    }
    
    class func addSong(song: MPMediaItem, songRawData: NSData,
        success: Void -> Void, fail: (ErrorType) -> Void
        ) -> Void {
            Alamofire.upload(
                .POST,
                Urls.instance.songs,
                multipartFormData: { formData in
                    if let title = song.title?.dataUsingEncoding(NSUTF8StringEncoding) {
                        formData.appendBodyPart(data: title, name: "title")
                    }
                    if let artist = song.artist?.dataUsingEncoding(NSUTF8StringEncoding) {
                        formData.appendBodyPart(data: artist, name: "artist")
                    }
                    formData.appendBodyPart(data: songRawData, name: "file", fileName: "file.mp4", mimeType: "audio/mp4")
                },
                encodingCompletion: { result in
                    switch result {
                    case .Success(_, _, _):
                        success()
                    case .Failure(let error):
                        fail(error)
                    }
            })
    }
}