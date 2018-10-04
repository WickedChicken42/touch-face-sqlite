//
//  SQLiteAccess.swift
//  touch-face-sqlite
//
//  Created by James Ullom on 10/3/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteAccess {
    // Creating the Singleton instance so that there is only ever one in the app
    static  let instance = SQLiteAccess()
    
    // Defined to support SQLite 3
    var db: OpaquePointer?

    func openNotesDB(appendingPathComponent: String) {
        
        // Create the SQLite database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(appendingPathComponent)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Notes (noteUUIDText TEXT PRIMARY KEY, message TEXT, lockStatusRaw TEXT, timestamp1970 INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }

    }
}
