import taple_sdk

import taple_sdk
import SQLite3

import Foundation

class SQLIterator: taple_sdk.DbCollectionIteratorInterface{
    let myIter: OpaquePointer
    let myDb: OpaquePointer
    
    init(iterator: OpaquePointer, db: OpaquePointer){
        myIter = iterator
        myDb = db
    }
    
    func next() -> taple_sdk.Tuple? {
        let step = sqlite3_step(myIter)
        if step == SQLITE_ROW {
            debugPrint("Iter")
            if let idPointer = sqlite3_column_text(myIter, 0) {
                let id = String(cString: idPointer)
                
                if let blobData = sqlite3_column_blob(myIter, 1) {
                    let blobSize = sqlite3_column_bytes(myIter, 1)
                    let data = Data(bytes: blobData, count: Int(blobSize))
                    
                    let byteArray = [UInt8](data)

//                    debugPrint("KEY: \(id)")
//                    debugPrint("VALUE: \(byteArray)")
                    
                    return taple_sdk.Tuple(key: id, value: byteArray)
                } else {
                    debugPrint("Error with value")
                }
                
            }
            debugPrint("Error with key")
            return nil
        } else {
            if step == SQLITE_DONE {
                debugPrint("Iter end/not found")
            } else {
                let error = String(cString: sqlite3_errmsg(myDb))
                debugPrint("Error RevIter: \(error)")
            }
            sqlite3_finalize(myIter)
            return nil
        }
    }
}

class SQLRevIterator: taple_sdk.DbCollectionIteratorInterface{
    let myIter: OpaquePointer
    let myDb: OpaquePointer
    
    init(iterator: OpaquePointer, db: OpaquePointer){
        myIter = iterator
        myDb = db
    }
    
    func next() -> taple_sdk.Tuple? {
        let step = sqlite3_step(myIter)
        if step == SQLITE_ROW {
            debugPrint("Iter")
            if let idPointer = sqlite3_column_text(myIter, 0) {
                let id = String(cString: idPointer)
                
                if let blobData = sqlite3_column_blob(myIter, 1) {
                    let blobSize = sqlite3_column_bytes(myIter, 1)
                    let data = Data(bytes: blobData, count: Int(blobSize))
                    
                    let byteArray = [UInt8](data)
                    
//                    debugPrint("KEY: \(id)")
//                    debugPrint("VALUE: \(byteArray)")
                    
                    return taple_sdk.Tuple(key: id, value: byteArray)
                } else {
                    debugPrint("Error with value")
                }
                
            }
            debugPrint("Error with key")
            return nil
        } else {
            if step == SQLITE_DONE {
                debugPrint("Iter end/not found")
            } else {
                let error = String(cString: sqlite3_errmsg(myDb))
                debugPrint("Error RevIter: \(error)")
            }
            sqlite3_finalize(myIter)
            return nil
        }
    }
}
