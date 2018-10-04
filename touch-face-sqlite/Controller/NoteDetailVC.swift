//
//  NoteDetailVC.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import UIKit

class NoteDetailVC: UIViewController {

    @IBOutlet var noteTextView: UITextView!
    
    var currentNote: Note!
    var lockNote: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        noteTextView.text = currentNote.message
    }
    
    @IBAction func lockButtonPressed(_ sender: Any) {
    
        lockNote = true
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            // The back button was pressed, save the text
            if noteTextView.text != "" && noteTextView.text != currentNote.message {
                currentNote.setMessage(message: noteTextView.text)
                currentNote.saveToData() { (success) in
                    if success {
                        print("We Saved the note!!!!!!")
                    } else {
                        print("We DID NOT Save the note!!!!!!")
                    }
                }
            } else {
                if lockNote {
                    currentNote.flipLockStatus()
                    currentNote.saveToData() { (success) in
                        if success {
                            print("We Saved the note!!!!!!")
                        } else {
                            print("We DID NOT Save the note!!!!!!")
                        }
                    }
                }
            }
        }
    }
    
}
