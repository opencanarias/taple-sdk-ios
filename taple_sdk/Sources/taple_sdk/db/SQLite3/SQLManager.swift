import taple_sdk
import SQLite3

import Foundation

public class SQLManager: taple_sdk.DatabaseManagerInterface {
    let myDb: OpaquePointer?
    let myCollection: SQLCollection
    let tableName: String
    
    public init?(table_name: String){
        tableName = table_name
        let dataBaseUrl = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("taple.sqlite")
        
        var db: OpaquePointer? = nil
        
        //         Intenta abrirla
        if sqlite3_open_v2(dataBaseUrl.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
            myDb = db
            myCollection = SQLCollection(db: db!)
            dropTable()
            createTable()
        } else {
            
            sqlite3_close(db)
            
            //            Si no la pueda abrir la crea
            if sqlite3_open_v2(dataBaseUrl.path, &db,SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK {
                myDb = db
                myCollection = SQLCollection(db: db!)
                createTable()
            } else {
                return nil
            }
        }
    }
    
    private func createTable(){
        
        let query = "CREATE TABLE \(tableName)(\(ID_COL) TEXT PRIMARY KEY, \(VALUE_COL) MEDIUMBLOB);"
        var createTable: OpaquePointer?
        
        if sqlite3_prepare_v2(myDb, query, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE {
                debugPrint("Table created")
            }
        }
        
        let query1 = "CREATE INDEX SQL_TAPLE ON \(TABLE_NAME) (\(ID_COL));"
        var createIndex: OpaquePointer?
        
        if sqlite3_prepare_v2(myDb, query1, -1, &createIndex, nil) == SQLITE_OK {
            if sqlite3_step(createIndex) == SQLITE_DONE {
                debugPrint("Index created")
            }
        }
    }
    
    private func dropTable(){
        let query0 = "DROP TABLE \(tableName);"
        var dropTable: OpaquePointer?

        if sqlite3_prepare_v2(myDb, query0, -1, &dropTable, nil) == SQLITE_OK {
            if sqlite3_step(dropTable) == SQLITE_DONE {
                debugPrint("Table dropped")
            }
        }
    }
    
    public func createCollection(identifier: String) -> taple_sdk.DbCollectionInterface {
//        debugPrint("Coleccion \(identifier)")
        return myCollection
    }
    
}
