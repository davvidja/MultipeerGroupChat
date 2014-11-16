//
//  DataStreamController.swift
//  MultipeerGroupChat
//
//  Created by Carina Macia on 03/11/14.
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc protocol DataStreamControllerDelegate {
    optional func streamEventReceived (eventCode: NSStreamEvent, inSeesson session: MCSession, fromPeer peerID: MCPeerID, addedComments message: String?)
    
    func streamEndEncountered()
}



class DataStreamController: NSObject, NSStreamDelegate {
    
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var fileManager: NSFileManager = NSFileManager ()
    var txData, rxData: NSMutableData?
    var byteIndex = 0
    var bytesRead = 0
    var delegate : DataStreamControllerDelegate?
    var session: MCSession?
    var peerID: MCPeerID?
    var runLoop: NSRunLoop?
    var hasSpaceAvailable: Bool
   
//Initialization methods
    override init() {
        self.hasSpaceAvailable = false
        
        super.init()
    }

    
    init (forInputStream inputStream: NSInputStream, session: MCSession, peerID: MCPeerID) {

        self.inputStream = inputStream
        //self.fileManager = NSFileManager()
        self.session = session
        self.peerID = peerID
        self.hasSpaceAvailable = false
        
        super.init()

        //settingStream(self.inputStream!)
    }

    init (forOutputStream outputStream: NSOutputStream, session: MCSession, peerID: MCPeerID) {

        self.outputStream = outputStream
        //self.fileManager = NSFileManager()
        self.session = session
        self.peerID = peerID

        
        //settingStream(self.outputStream!)
        self.hasSpaceAvailable = false
        
        super.init()
        
        //self.txData = getData()
    }

    func openStream (stream: NSStream){
        stream.open()
    }
    
    private func settingStream (varStream: NSStream){
        //Step 1: setting the delegate
        varStream.delegate = self
        
        //Step 2: setting the handling of stream events
        varStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        
        //NSRunLoop.currentRunLoop().run();
        
        //Step 3: opening the stream
        //varStream.open()
    }
    
    private func getData() -> NSMutableData? {
        return self.syncReadContentOfTxFile()
    }
    
    private func syncReadContentOfTxFile () -> NSMutableData? {
        var data: NSMutableData?
        
        let result = self.createTxFile()
        
        if result.successed {
            data = NSMutableData(contentsOfURL: result.fileURL!)
        }
        
        return data
    }
    
    //The following function is just for the prototype: creates the file 'file.tx' that would be transmited.
    //According with the stack model, that functionalities should not be here
    private func createTxFile() -> (successed: Bool, fileURL: NSURL?) {
        var fileURLs = fileManager.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var fileURL: NSURL?
        var filePath: NSString?
        var error: NSError?
        var dirExist, success: Bool

        success = true
        
        fileURL = fileURLs[0] as? NSURL
        
        filePath = fileURL!.absoluteString
        
        dirExist = fileManager.fileExistsAtPath(filePath!)
        
        if !dirExist {
            fileManager.createDirectoryAtURL(fileURL!, withIntermediateDirectories: false, attributes: nil, error: &error)
            if (error != nil) {
                println("Error \(error) creating directory at URL: \(fileURL!.absoluteString!)")
                //success = false
                
                //return (success,nil)
            }
        }
        
        fileURL = fileURL!.URLByAppendingPathComponent("file.tx")
        
        let content = "hola"
        content.writeToURL(fileURL!, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        
        if (error != nil) {
            println("Error \(error) writing file \(fileURL!.absoluteString!)")
            //success = false
            
            //return (success,nil)
        }
        
        return (success, fileURL)
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            println("Open completed event received")
            self.delegate!.streamEventReceived!(eventCode, inSeesson: self.session!, fromPeer: self.peerID!, addedComments: nil)

        
        case NSStreamEvent.HasBytesAvailable:
            println("Bytes available event received")
            
            var buffer = UnsafeMutablePointer<UInt8>.alloc(1024)
            //var buffer: UInt8
            
            var len: Int
            len = (aStream as NSInputStream).read(buffer, maxLength: 1024)
            
            if (len > 0) {
                if (self.rxData == nil)
                {
                    self.rxData = NSMutableData(capacity: len)
                }
                self.rxData!.appendBytes(&buffer, length: len)
                bytesRead += len
            } else {
                NSLog("No data read!")
            }
            
            self.delegate!.streamEventReceived!(eventCode, inSeesson: self.session!, fromPeer: self.peerID!, addedComments: "bytes read: \(len)")
//            if(!_data) {
//                _data = [[NSMutableData data] retain];
//            }
//            uint8_t buf[1024];
//            unsigned int len = 0;
//            len = [(NSInputStream *)stream read:buf maxLength:1024];
//            if(len) {
//                [_data appendBytes:(const void *)buf length:len];
//                // bytesRead is an instance variable of type NSNumber.
//                [bytesRead setIntValue:[bytesRead intValue]+len];
//            } else {
//                NSLog(@"no buffer!");
//            }
            
        case NSStreamEvent.HasSpaceAvailable:
              println("Space available event received")
//
//            var buffer: UnsafeMutablePointer<UInt8>
//            
//            buffer = UnsafeMutablePointer<UInt8>(self.txData!.mutableBytes)
//            var dataLen: Int = self.txData!.length
//            var len: Int = ((dataLen - byteIndex) >= 1024) ? 1024: (dataLen - byteIndex)
//            
//            if (len > 0)
//            {
////                (aStream as NSOutputStream).write(buffer, maxLength: len)
//                self.delegate!.streamEventReceived!(eventCode, inSeesson: self.session, fromPeer: self.peerID, addedComments: "bytes written: \(len)")
//
//            }
//            
//            // we keep the index still, to be transmitting everytime the same word
//            byteIndex += len
//
//            
////            uint8_t *readBytes = (uint8_t *)[_data mutableBytes];
////            readBytes += byteIndex; // instance variable to move pointer
////            int data_len = [_data length];
////            unsigned int len = ((data_len - byteIndex >= 1024) ?
////                1024 : (data_len-byteIndex));
////            uint8_t buf[len];
////            (void)memcpy(buf, readBytes, len);
////            len = [stream write:(const uint8_t *)buf maxLength:len];
////            byteIndex += len;
            if (aStream == self.outputStream!)
            {
                self.hasSpaceAvailable = true
                println("Stream event received: hasSpaceAvailable")
            }
            
        case NSStreamEvent.EndEncountered:
            println("End encountered event received")
            
            self.closeStreams()
            
            self.delegate!.streamEventReceived!(eventCode, inSeesson: self.session!, fromPeer: self.peerID!, addedComments: "Stream end encountered")
            
            self.delegate!.streamEndEncountered()
            
            
            
        case NSStreamEvent.ErrorOccurred:
            println("Error ocurred event received")
            self.delegate!.streamEventReceived!(eventCode, inSeesson: self.session!, fromPeer: self.peerID!, addedComments: "Stream error ocurred")

        default:
            println("Event received but not treated")
        }
    }
    
    func txByStream ()
    {
        var buffer: UInt8 = 1
        var bytesWritten: Int

        if (self.hasSpaceAvailable)
        {
            bytesWritten = self.outputStream!.write(&buffer, maxLength: 1)
            
            self.hasSpaceAvailable = false
        
            println("bytes written: \(bytesWritten)")
            
        } else
        {
            println("no space available for writing into the outputStream")
        }
        
    }

    func closeStreams()
    {
        if (self.outputStream != nil) {
            self.outputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            self.outputStream!.close()
            self.outputStream = nil
        }

        if (self.inputStream != nil) {
            self.inputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            self.inputStream!.close()
            self.inputStream = nil
        }
    }
}


