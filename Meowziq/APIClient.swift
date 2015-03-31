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
        
        var entryPoint = NSUserDefaults.standardUserDefaults().stringForKey("entryPoint") ?? ""
        var songs: String {
            return "\(entryPoint)/songs"
        }
        
        class var instance : Urls {
            struct Static {
                static let instance = Urls()
            }
            return Static.instance
        }
    }
    
    class var entryPoint: String {
        set(entryPoint) {
            Urls.instance.entryPoint = entryPoint
            NSUserDefaults.standardUserDefaults().setObject(self.entryPoint, forKey: "entryPoint")
        }
        get {
            return Urls.instance.entryPoint
        }
    }
    
    class func addSong(song: MPMediaItem, songRawData: NSData,
        success: Void -> Void, fail: (NSError) -> Void
        ) -> Void {
            
        let urlRequest = urlRequestWithComponentsForAddSong(
            Urls.instance.songs,
            song: songRawData,
            artwork: song.artwork,
            parameters: [
                "title": song.title,
                "artist": song.artist
            ])
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .response { (request, response, data, error) in
                if let error = error {
                    fail(error)
                } else {
                    success()
                }
        }
    }
    
    // ref. http://stackoverflow.com/questions/26121827/uploading-file-with-parameters-using-alamofire
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    private class func urlRequestWithComponentsForAddSong(
        urlString: String, song: NSData, artwork: MPMediaItemArtwork?, parameters: Dictionary<String, String>
        ) -> (URLRequestConvertible, NSData)
    {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add song
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.m4a\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: audio/mp4\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(song)
        
        // add artwork
        if let artwork = artwork {
            let image = artwork.imageWithSize(artwork.bounds.size)
            let imageData = UIImagePNGRepresentation(image)
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"artwork\"; filename=\"artwork.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(imageData)
        }
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }

}