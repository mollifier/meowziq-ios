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
            
        let urlRequest = urlRequestWithComponentsForAddSong(
            Urls.instance.songs,
            song: songRawData,
            parameters: [
                "title": song.title,
                "artist": song.artist
            ])
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
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
        urlString: String, song: NSData, parameters: Dictionary<String, String?>
        ) -> (URLRequestConvertible, NSData)
    {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
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