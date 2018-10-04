//
//  Note.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import Foundation
import SQLite3

class Note {
    
    private var noteUUID: UUID
    public private(set) var message: String
    public private(set) var lockStatus: LockStatus
    public private(set) var timestamp: Date
    
    // Default new note initializer
    init() {
        self.noteUUID = NEW_UUID!
        self.message = ""
        self.lockStatus = .unlocked
        self.timestamp = Date()
    }

    // New note initializer with message and lock status
    init(message: String, lockStatus: LockStatus) {

        self.noteUUID = NEW_UUID!
        self.message = message
        self.lockStatus = lockStatus
        self.timestamp = Date()
    }

    // Used to initialize a Note object from SQLite data
    static func loadFromData(uuidText: String, message: String, lockStateRaw: String, timeInterval1970: Int32) -> Note {
    
        let newNote = Note()
        
        newNote.noteUUID = UUID(uuidString: uuidText)!
        newNote.message = message
        newNote.lockStatus = LockStatus(rawValue: lockStateRaw)!
        newNote.timestamp = Date(timeIntervalSince1970: TimeInterval(timeInterval1970))
        
        return newNote
    }
    
    func setLockStatus(isLocked: Bool) {
        if isLocked { lockStatus = .locked } else { lockStatus = .unlocked }
        self.timestamp = Date()
    }
    
    func setMessage(message: String) {
        self.message = message
        self.timestamp = Date()
    }
    
    func isNoteLocked() -> Bool {
        if self.lockStatus == .locked {
            return true
        } else {
            return false
        }
    }
    
    func flipLockStatus() {
        if self.lockStatus == .locked {
            self.lockStatus = .unlocked
        } else {
            self.lockStatus = .locked
        }
        self.timestamp = Date()
    }
    
    // Function to save the Note to persistent storage
    func saveToData(db: OpaquePointer?, completion: (_ finished: Bool) -> ()) {

        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        var queryString: String
        if self.noteUUID == NEW_UUID {

            // Set a real UUID to the object before saving it
            self.noteUUID = UUID()
            
            // Define the INSERT statement with placeholders
            queryString = "INSERT INTO Notes (noteUUIDText, message, lockStatusRaw, timestamp1970) VALUES (?,?,?,?)"

            // Preparing the query with '_v2' due to use of placeholders '?'
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("error preparing insert: \(errmsg)")
                return
            }

            // Binding the sql parameters

            // Paramter: noteUUID
            if sqlite3_bind_text(stmt, 1, self.noteUUID.uuidString.asUTF8(), -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding noteUUID: \(errmsg)")
                return
            }

            // Paramter: message
            if sqlite3_bind_text(stmt, 2, self.message.asUTF8(), -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding message: \(errmsg)")
                return
            }
            
            // Paramter: lockStatus - not sure why this didn't require the utf8 treatment
            if sqlite3_bind_text(stmt, 3, self.lockStatus.rawValue, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding name: \(errmsg)")
                return
            }
            
            // Paramter: timestamp in UTC UNIX time
            if sqlite3_bind_int(stmt, 4, Int32(self.timestamp.timeIntervalSince1970)) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding timestamp: \(errmsg)")
                return
            }
            
        } else {

            // Define the UPDATE statement with placeholders
            queryString = "UPDATE Notes SET message = ?, lockStatusRaw = ?, timestamp1970 = ? WHERE noteUUIDText = ?"

            // Preparing the query with '_v2' due to use of placeholders '?'
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("error preparing insert: \(errmsg)")
                return
            }

            // Binding the sql parameters

            // Paramter: message
            if sqlite3_bind_text(stmt, 1, self.message.asUTF8(), -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding message: \(errmsg)")
                return
            }
            
            // Paramter: lockStatus - not sure why this didn't need the utf8 treatment
            if sqlite3_bind_text(stmt, 2, self.lockStatus.rawValue, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding name: \(errmsg)")
                return
            }
            
            // Paramter: timestamp in UTC UNIX time
            if sqlite3_bind_int(stmt, 3, Int32(self.timestamp.timeIntervalSince1970)) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding timestamp: \(errmsg)")
                return
            }

            // Paramter: noteUUID
            if sqlite3_bind_text(stmt, 4, self.noteUUID.uuidString.asUTF8(), -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding noteUUID: \(errmsg)")
                return
            }

        }
        
        // Executing the query to insert/update values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            debugPrint("failure inserting hero: \(errmsg)")
            return
        }

        // Finalize the SQL execution
        sqlite3_finalize(stmt)

    }

    // Retreives the data from persistent storage and loads them to the local goals array
    static func getNotesFromData(db: OpaquePointer?, completion: (_ complete: Bool) -> ()) -> [Note] {

        // Define an empty note array
        var notes = [Note]()
        
        // Selecting all notes in descending order
        let queryString = "SELECT * FROM Notes ORDER BY timestamp1970 DESC"
        
        // Statement pointer
        var stmt:OpaquePointer?
        
        // Preparing the query - no '_v2' since there are no placeholders
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            debugPrint("error preparing insert: \(errmsg)")
            return [Note]() // Return an empty array if this fails
        }
        
        // Traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let noteUUIDText = String(cString: sqlite3_column_text(stmt, 0))
            let message = String(cString: sqlite3_column_text(stmt, 1))
            let lockStateRaw = String(cString: sqlite3_column_text(stmt, 2))
            let timeInterval1970 = sqlite3_column_int(stmt, 3)
            
            //adding values to list
            notes.append(Note.loadFromData(uuidText: noteUUIDText, message: String(describing: message), lockStateRaw: String(describing: lockStateRaw), timeInterval1970: timeInterval1970))
        }
        
        return notes
    }

    // Used to remove this note from our data
    func deleteFromData(db: OpaquePointer?, completion: (_ complete: Bool) -> ()) {
        
        // Delete statment for a single note by noteUUIDText using sa placeholder
        let deleteStatementStirng = "DELETE FROM Notes WHERE noteUUIDText = ?"
        
        var deleteStatement: OpaquePointer? = nil
        // Preparing the query with '_v2' due to use of placeholders '?'
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            // Paramter: noteUUID
            if sqlite3_bind_text(deleteStatement, 1, self.noteUUID.uuidString.asUTF8(), -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                debugPrint("failure binding noteUUID: \(errmsg)")
                return
            }

            // Execute the delete statement
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                debugPrint("Successfully deleted row.")
            } else {
                debugPrint("Could not delete row.")
            }
        } else {
            debugPrint("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    
    }

}
