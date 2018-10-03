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

    // Holds the data object for reading and saving
    //public private(set) var noteData: NoteData?
    
    // Default new note initializer
    init() {
        self.noteUUID = NEW_UUID!
        self.message = ""
        self.lockStatus = .unlocked
    }

    // New note initializer with message and lock status
    init(message: String, lockStatus: LockStatus) {

        self.noteUUID = NEW_UUID!
        self.message = message
        self.lockStatus = lockStatus
        //self.noteData = nil
    }

    init(noteData: NoteData) {
    
        self.noteUUID = noteData.noteUUID!
        self.message = noteData.noteMessage!
        self.lockStatus =  LockStatus(rawValue: noteData.noteLockState!)!
        //self.noteData = noteData
    }
    
    func loadNoteData(noteData: NoteData) {
        
        noteData.noteUUID = self.noteUUID
        noteData.noteMessage = self.message
        noteData.noteLockState = self.lockStatus.rawValue
    }
    
    func setLockStatus(isLocked: Bool) {
        if isLocked { lockStatus = .locked } else { lockStatus = .unlocked }
    }
    
    func setMessage(message: String) {
        self.message = message
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
    }
    
    // Function to save the Note to persisten storage
    func saveToData(completion: (_ finished: Bool) -> ()) {
        
        //let appDelegate = UIApplication.shared.delegate as? AppDelegate
        // Using this version as it does not require me to Import UIKit into my class
        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return }
        
        // Getting the Managed Context to work with the CoreData tools
        guard let managedContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext? else { return }
        // Creating the new goal data object as Goal data type from the managed context

        if noteUUID == NEW_UUID {
            // This is a new note so we just create it

            // Create a new NoteData object to work with
            let newNoteData = NoteData(context: managedContext)
            
            // Setting the properties of the Goal data obejct
            newNoteData.noteUUID = UUID()
            newNoteData.noteMessage = self.message
            newNoteData.noteLockState = self.lockStatus.rawValue

            // Save the data to storage
            do {
                try managedContext.save()
                print("Successfuly saved data!!")
                completion(true)
            } catch {
                debugPrint("Could not save \(error.localizedDescription)")
                completion(false)
            }

        } else {
            // Saving an existig item by retreiving it from storage and then saving it

            let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
            // create an NSPredicate to get the instance you want to make change
            let predicate = NSPredicate(format: "noteUUID = %@", self.noteUUID.uuidString)
            fetchRequest.predicate = predicate
            
            // Using a Do/Try/Catch to make the final save call of the managed context to write the data to storage
            // Also setting the value of the completion handler based on our success in saving the data.
            do {
                // Loading the goals array with the data retreived from storage
                let noteDataArray = try managedContext.fetch(fetchRequest) as [NoteData]
                
                // Setting the properties of the Goal data obejct
                if noteDataArray.count == 1 {
                    print("Successfully fetched 1 note of data for updating.")
                    noteDataArray[0].noteMessage = self.message
                    noteDataArray[0].noteLockState = self.lockStatus.rawValue

                    try managedContext.save()

                    completion(true)
                } else if noteDataArray.count == 0 {
                    debugPrint("Could not fetch note data with UUID: \(self.noteUUID.uuidString)")
                    completion(false)
                    
                } else {
                    debugPrint("Returned more than one note data with UUID: \(self.noteUUID.uuidString)")
                    completion(false)
                }

            } catch {
                debugPrint("Could not fetch note data: \(error.localizedDescription)")
                completion(false)
            }

        }
        
    }

    // Retreives the data from persisten storage and loads them to the local goals array
    static func getNotesFromData(completion: (_ complete: Bool) -> ()) -> [Note] {
        
        // Using this version as it does not require me to Import UIKit into my class
        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return [Note]() }

        // Get the managed context for this app
        guard let managedContext = appDelegate.persistentContainer.viewContext as? NSManagedObjectContext else  { return [Note]() }
        
        // Define the request we are making as a type Goal using the entity name "Goal" from the data model
        let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
        var notes = [Note]()
        
        do {
            // Loading the goals array with the data retreived from storage
            let noteDataArray = try managedContext.fetch(fetchRequest)
            print("Successfully fetched note data.")
            
            var newNote: Note
            for dataItem in noteDataArray {
                newNote = Note(noteData: dataItem)
                notes.append(newNote)
            }
            
            completion(true)
            
        } catch {
            debugPrint("Could not fetch note data: \(error.localizedDescription)")
            completion(false)
        }
        
        return notes
    }

    // Used to remove a specific goal from our data based on the indexPath being passed in
    func deleteFromData(completion: (_ complete: Bool) -> ()) {
        
        // Using this version as it does not require me to Import UIKit into my class
        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return }

        // Get the managed context for this app
        guard let managedContext = appDelegate.persistentContainer.viewContext as? NSManagedObjectContext else { return }
        
        let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
        // create an NSPredicate to get the instance you want to make change
        let predicate = NSPredicate(format: "noteUUID = %@", self.noteUUID.uuidString)
        fetchRequest.predicate = predicate

        do {
            // Loading the goals array with the data retreived from storage
            let noteDataArray = try managedContext.fetch(fetchRequest)
        
            if noteDataArray.count == 1 {
                print("Successfully fetched note data.")
                
                // Delete the item from our managed context
                managedContext.delete(noteDataArray[0])
                
                completion(true)
            } else if noteDataArray.count == 0 {
                debugPrint("Could not fetch note data: \(self.noteUUID.uuidString)")
                completion(false)

            } else {
                debugPrint("Returned more than one note data: \(self.noteUUID.uuidString)")
                completion(false)
            }
            
        } catch {
            debugPrint("Could not fetch note data: \(error.localizedDescription)")
            completion(false)
        }

        // Perform a Do/Try/Catch to save the context which will remove the deleted item from storage
        do {
            try managedContext.save()
            print("Successfully deleted a goal!")
        } catch {
            debugPrint("Could not delete a goal: \(error.localizedDescription)")
        }
    }

}
