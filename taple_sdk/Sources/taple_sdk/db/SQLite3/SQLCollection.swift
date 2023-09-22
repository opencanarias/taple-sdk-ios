import taple_sdk
import SQLite3

import Foundation

class SQLCollection: taple_sdk.DbCollectionInterface {
    
    let myDb: OpaquePointer
    
    
    init(db: OpaquePointer){
        debugPrint("New Collection")
        myDb = db
    }
    
    func get(key: String) throws -> [UInt8]? {
        let keyTrimmed = key.trimmingCharacters(in: .whitespaces)
        let query = "SELECT \(VALUE_COL) FROM \(TABLE_NAME) WHERE TRIM(\(ID_COL)) = '\(keyTrimmed)';"
        var runQuery: OpaquePointer? = nil
        var byteArray: [UInt8]?

        if sqlite3_prepare_v2(myDb, query, -1, &runQuery, nil) == SQLITE_OK {
            if sqlite3_step(runQuery) == SQLITE_ROW {
                let blobData = sqlite3_column_blob(runQuery, 0)!
                let blobSize = sqlite3_column_bytes(runQuery, 0)
                let data = Data(bytes: blobData, count: Int(blobSize))

                byteArray = [UInt8](data) // Convert the 'Data' object back to an array of bytes (UInt8)

                debugPrint("Get success")
            } else {
                debugPrint("Get not found")
            }
        } else {
            debugPrint("Error get query")
        }
        sqlite3_finalize(runQuery)
        return byteArray
    }
    
    func put(key: String, value: [UInt8]) throws {
        let data = Data(value)
        let keyTrimmed = key.trimmingCharacters(in: .whitespaces)
        let query = "REPLACE INTO \(TABLE_NAME) (\(ID_COL),\(VALUE_COL)) VALUES ('\(keyTrimmed)', ?);"
        var runQuery: OpaquePointer? = nil

        if sqlite3_prepare_v2(myDb, query, -1, &runQuery, nil) == SQLITE_OK {
            sqlite3_bind_blob(runQuery, 1, (data as NSData).bytes, Int32(data.count), nil)
//            debugPrint("VALUE PUT: \(value)")

            if sqlite3_step(runQuery) == SQLITE_DONE {
                debugPrint("Put succes")
            }else {
                debugPrint("Put fails")
            }
        } else {
            debugPrint("Error put query")
        }
        sqlite3_finalize(runQuery)
    }
    
    func del(key: String) throws {
        let keyTrimmed = key.trimmingCharacters(in: .whitespaces)
        let query = "DELETE FROM \(TABLE_NAME) WHERE \(ID_COL) = '\(keyTrimmed)';"
        var runQuery: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(myDb, query, -1, &runQuery, nil) == SQLITE_OK {
            if sqlite3_step(runQuery) == SQLITE_DONE {
                debugPrint("Data deleted")
            } else {
                debugPrint("Del not found")
            }
        } else {
            debugPrint("Error del query")
        }
        sqlite3_finalize(runQuery)
    }
    
    
    func iter(reverse: Bool, prefix: String) -> taple_sdk.DbCollectionIteratorInterface {
//        debugPrint("Prefijo: \(prefix)")
        let prefix_trimmed = prefix.trimmingCharacters(in: .whitespaces)
        var query = "SELECT \(ID_COL), \(VALUE_COL) FROM \(TABLE_NAME) WHERE TRIM(\(ID_COL)) LIKE '\(prefix_trimmed)%' ORDER BY \(ID_COL)"
    
        var runQuery: OpaquePointer? = nil
        
        if (reverse){
            query += " ASC;"
        }else {
            query += " DESC;"
        }
        
        var iterator: taple_sdk.DbCollectionIteratorInterface?
        if sqlite3_prepare_v2(myDb, query, -1, &runQuery, nil) == SQLITE_OK {
//            sqlite3_bind_text(runQuery, 0, prefix_trimmed, -1, nil)
            if (reverse){
                debugPrint("Calling rev Iter")
                iterator =  SQLRevIterator(iterator: runQuery!, db: myDb)
            }else {
                debugPrint("Calling Iter")
                iterator =  SQLIterator(iterator: runQuery!, db: myDb)
            }
        }
        
        return iterator!
    }

//    func checkContent(prefix: String){
//        let query0 = "SELECT \(ID_COL) FROM \(TABLE_NAME);"
//        var runQuery0: OpaquePointer? = nil
//        if sqlite3_prepare_v2(myDb, query0, -1, &runQuery0, nil) == SQLITE_OK {
//            while(sqlite3_step(runQuery0) == SQLITE_ROW){
//                let col = String(cString: sqlite3_column_text(runQuery0, 0))
//                debugPrint("Elements: \(col)")
//            }
//        }
//        sqlite3_finalize(runQuery0)
//
//
//        let query = "SELECT COUNT(*) FROM \(TABLE_NAME) WHERE TRIM(\(ID_COL)) LIKE '\(prefix)';"
//        var runQuery: OpaquePointer? = nil
//        if sqlite3_prepare_v2(myDb, query, -1, &runQuery, nil) == SQLITE_OK {
//            while(sqlite3_step(runQuery) == SQLITE_ROW){
//                let count = sqlite3_column_int(runQuery, 0)
//                debugPrint("Elements for \(prefix): \(count)")
//            }
//        }
//        sqlite3_finalize(runQuery)
//    }
}

