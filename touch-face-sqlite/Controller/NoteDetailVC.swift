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
    //var index: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        noteTextView.text = currentNote.message
    }
    
    @IBAction func lockButtonPressed(_ sender: Any) {
    
        currentNote.flipLockStatus()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            // The back button was pressed, save the text
            if noteTextView.text != "" {
                currentNote.setMessage(message: noteTextView.text)
                currentNote.saveToData { (success) in
                    if success {
                        print("We Saved the note!!!!!!")
                    } else {
                        print("We DID NOT Save the note!!!!!!")
                    }
                }
            } else {
//                let alertVC = UIAlertController(title: "Empty Text", message: "Did you want to delete this note?", preferredStyle: .alert)
//                let actionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
//                    // Delete the current note
//                    notesArray.remove(at: self.index)
//                })
//                alertVC.addAction(actionYes)
//                let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil) // Do nothing and allow it to go back
//                alertVC.addAction(actionNo)
//                self.present(alertVC, animated: true)

            }
        }
    }
    
}
