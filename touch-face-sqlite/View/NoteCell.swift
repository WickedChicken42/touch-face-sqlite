//
//  NoteCellTableViewCell.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet var messageLbl: UILabel!
    @IBOutlet var lockImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func configureCell(note: Note) {
        
        if note.lockStatus == .locked {
            messageLbl.text = "This note is locked.  Unlock to read."
            lockImageView.isHidden = false
        } else {
            messageLbl.text = note.message
            lockImageView.isHidden = true
        }
    }

}
