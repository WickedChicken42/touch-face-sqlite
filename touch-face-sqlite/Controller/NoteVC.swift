//
//  ViewController.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import UIKit
import LocalAuthentication

class NoteVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var addNote: UIBarButtonItem!
    
    var myNotes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.delegate = self
        tableView.dataSource = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCoreDataObjects()
        
        tableView.reloadData()
    }

    func authenticateBiometrics(completion: @escaping (Bool) -> Void) {
        
        // Instanciates the Local Auth context
        let myContext = LAContext()
        let myLocalizedReasonString = "Our app uses Touch/Face ID to secure your notes."
        var authError: NSError?
        
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                // NEED TO ADD: The following key into the info.plist for the app:
                // NSFaceIDUsageDescription with the same text as the myLocalizedReasonString
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { [unowned self] (success, evaluateError) in
                        if success {
                            completion(true)
                        } else {
                            DispatchQueue.main.async {
                                guard let evalErrorString = evaluateError?.localizedDescription else { return }
                                // present an alter
                                self.showAlert(withMessage: evalErrorString)
                                completion(false)
                            }
                        }
                }
            } else {
                guard let authErrorString = authError?.localizedDescription else { return }
                self.showAlert(withMessage: authErrorString)
                completion(false)
            }
            
        } else {
            completion(false)
        }
        
    }
    
    func showAlert(withMessage message: String) {
        
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func addNotePressed(_ sender: Any) {
        
        let newNote = Note()
        myNotes.append(newNote)
        pushNoteFor(indexPath: IndexPath(row: myNotes.count - 1, section: 0))

    }
    
    // Retreives the data from persistent storage and sets if the table view is hidden
    func fetchCoreDataObjects() {
        
        myNotes = Note.getNotesFromData() { (complete) in
            if complete {
                // Dunno if I should do something
            }
        }
        
    }
    
    func showLockedAlert() {
        
        let alertVC = UIAlertController(title: "Locked Note", message: "You can not delete a Locked note.  Unlock the note first, then delete it.", preferredStyle: .alert)
//        let actionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
//            // Delete the current note
//            //notesArray.remove(at: self.index)
//        })
//        alertVC.addAction(actionYes)
//        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil) // Do nothing and allow it to go back
//        alertVC.addAction(actionNo)

        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil) // Do nothing and allow it to go back
        alertVC.addAction(actionOK)
        self.present(alertVC, animated: true)

    }

}

extension NoteVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as? NoteCell else { return UITableViewCell() }
        
        let note = myNotes[indexPath.row]
        cell.configureCell(note: note)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pass note and present VC
        if myNotes[indexPath.row].lockStatus == .locked {
            // perform the biometrics check
            authenticateBiometrics(completion: { (authenticated) in
                if authenticated {
                    self.myNotes[indexPath.row].flipLockStatus()
                    // Needed to call this Dispatch because the auth work happenes on a background thread but we need to push our VC on the main thread
                    DispatchQueue.main.async {
                        self.pushNoteFor(indexPath: indexPath)
                    }
                    
                }
            })
        } else {
            pushNoteFor(indexPath: indexPath)
        }
    }
    
    func pushNoteFor(indexPath: IndexPath) {
        
        guard let noteDetailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetailVC") as? NoteDetailVC else { return }
        
        noteDetailVC.currentNote = myNotes[indexPath.row]
        //noteDetailVC.index = indexPath.row
        navigationController?.pushViewController(noteDetailVC, animated: true)
        
    }
    
    // Added to support the swiping of row items to access their Actions - Allows editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Added to support the swiping of row items to access their Actions - Won't show any special icons
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // Added to support the swiping of row items to access their Actions - Defining the actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Define the Delete action shown when swiping on a row item
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            // What we will do when the Delete action is pressed (or full swiped)
            if self.myNotes[indexPath.row].lockStatus == .locked {
                // Show the alert that lets the user know they can not delete the locked note
                // perform the biometrics check
                self.authenticateBiometrics(completion: { (authenticated) in
                    if authenticated {
                        // Removes the goal from persistent storage
                        self.myNotes[indexPath.row].deleteFromData(completion: { (success) in
                            if success {
                                print("We deleted the data - YEA!!!!)")
                            } else {
                                print("We DID NOT delete the data - DOH!!!!)")
                            }
                        })
                        
                        DispatchQueue.main.async {
                            // Reload the local goals array from persisten storage
                            self.fetchCoreDataObjects()
                            
                            // Remove the deleted goal from the table view
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }

                    }
                })
            } else {
                // Removes the goal from persistent storage
                self.myNotes[indexPath.row].deleteFromData(completion: { (success) in
                    if success {
                        print("We deleted the data - YEA!!!!)")
                    } else {
                        print("We DID NOT delete the data - DOH!!!!)")
                    }
                })
                
                // Reload the local goals array from persisten storage
                self.fetchCoreDataObjects()
                
                // Remove the deleted goal from the table view
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }
                    }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        var actions: [UITableViewRowAction] = []
        actions.append(deleteAction)
        
        return actions
        // Alternative way to return the action array
        // return [deleteAction, addAction]
    }

}
