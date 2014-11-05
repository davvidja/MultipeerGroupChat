//
//  DataStreamController.swift
//  MultipeerGroupChat
//
//  Created by Carina Macia on 03/11/14.
//  Copyright (c) 2014 Apple, Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class DataStreamController: NSObject, NSStreamDelegate {
    
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var fileManager: NSFileManager
    var txData, rxData: NSMutableData?
    var byteIndex = 0
    var bytesRead = 0
   
    
    init (forInputStream inputStream: NSInputStream) {
        self.inputStream = inputStream;
        self.fileManager = NSFileManager()
        
        super.init();
        
        settingStream(self.inputStream!)
    }

    init (forOutputStream outputStream: NSOutputStream) {
        self.outputStream = outputStream;
        self.fileManager = NSFileManager()

        super.init();
        
        settingStream(self.outputStream!)
        self.txData = getData()
    }

    
    func settingStream (varStream: NSStream){
        //Step 1: setting the delegate
        varStream.delegate = self
        
        //Step 2: setting the handling of stream events
        varStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        //Step 3: opening the stream
        varStream.open()
    }
    
    func getData() -> NSMutableData? {
        return self.syncReadContentOfTxFile()
    }
    
    func syncReadContentOfTxFile () -> NSMutableData? {
        var data: NSMutableData?
        
        let result = self.createTxFile()
        
        if result.successed {
            data = NSMutableData(contentsOfURL: result.fileURL!)
        }
        
        return data
    }
    
    //The following function is just for the prototype: creates the file 'file.tx' that would be transmited.
    func createTxFile() -> (successed: Bool, fileURL: NSURL?) {
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
        
        case NSStreamEvent.HasBytesAvailable:
            println("Bytes available event received")
            
            var buffer = UnsafeMutablePointer<UInt8>.alloc(1024)
            
            var len: Int = 0
            len = self.inputStream!.read(buffer, maxLength: 1024)
            
            if (len != 0) {
                self.rxData!.appendBytes(buffer, length: len)
                bytesRead += len
            } else {
                NSLog("No buffer!")
            }
            
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

            var buffer: UnsafeMutablePointer<UInt8>
            
            buffer = UnsafeMutablePointer<UInt8>(self.txData!.mutableBytes)
            var dataLen: Int = self.txData!.length
            var len: Int = ((dataLen - byteIndex) >= 1024) ? 1024: (dataLen - byteIndex)
            
            self.outputStream!.write(buffer, maxLength: len)
            
            byteIndex += len

            
//            uint8_t *readBytes = (uint8_t *)[_data mutableBytes];
//            readBytes += byteIndex; // instance variable to move pointer
//            int data_len = [_data length];
//            unsigned int len = ((data_len - byteIndex >= 1024) ?
//                1024 : (data_len-byteIndex));
//            uint8_t buf[len];
//            (void)memcpy(buf, readBytes, len);
//            len = [stream write:(const uint8_t *)buf maxLength:len];
//            byteIndex += len;
            
        case NSStreamEvent.EndEncountered:
            println("End encountered event received")
            
        case NSStreamEvent.ErrorOccurred:
            println("Error ocurred event received")

        default:
            println("Event received but not treated")
        }
    }
    
}
