//
//  MusicManager.swift
//  Meowziq
//
//  Created by Seiji Kohyama on 2015/03/31.
//  Copyright (c) 2015年 FaithCreates Inc. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

class MusicManager {
    
    enum MusicManagerError : Int {
        case RawDataAccessFailed
    }
    
    class func getSongs() -> [MPMediaItem] {
        let songsQuery = MPMediaQuery.songsQuery()
        songsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
        return songsQuery.items as [MPMediaItem]!
    }
    
    class func getSongRawData(
        item: MPMediaItem,
        success: NSData -> Void,
        fail: NSError -> Void) -> Void {
            
            let exporter = createSongExporter(item)
            exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                switch exporter.status {
                case .Completed:
                    let rawData = NSData(contentsOfURL: exporter.outputURL!)!
                    success(rawData)
                default:
                    let e = NSError(
                        domain: "jp.co.faithcreates.Meowziq",
                        code: MusicManagerError.RawDataAccessFailed.rawValue,
                        userInfo: [
                            "exporterStatus": exporter.status.rawValue
                        ])
                    fail(e)
                }
                
                self.removeExportedFile(exporter.outputURL!)
            })
    }
    
    private class func createSongExporter(item: MPMediaItem) -> AVAssetExportSession {
        let url = item.assetURL
        let asset = AVURLAsset(URL: url!, options: nil)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        
        exporter!.outputFileType = "com.apple.m4a-audio";
        
        let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let fileName = createExportFileName()
        exporter!.outputURL = NSURL(fileURLWithPath: docDir).URLByAppendingPathComponent(fileName)
        
        return exporter!
    }
    
    private class func createExportFileName() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        return String(format: "%@.m4a", dateString)
    }
    
    private class func removeExportedFile(url: NSURL) -> Void {
        let manager = NSFileManager()
        do {
            try manager.removeItemAtURL(url)
        } catch let error as NSError {
            print(error)
        }
        
    }
}
