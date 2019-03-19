//
//  SiriSetupVC.swift
//  Golfication
//
//  Created by Rishabh Sood on 19/03/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import IntentsUI

class SiriSetupVC: UIViewController {
    
    @IBOutlet weak var btnSiri: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //INIntent
        let button = INUIAddVoiceShortcutButton(style: .white)
        let customIntent = DistanceOfGreenIntent()
        if let shortcut = INShortcut(intent: customIntent) {
            button.shortcut = shortcut
        }
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Add To Siri"
        self.navigationController?.navigationItem.leftBarButtonItem?.title = "Back"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        btnSiri.addSubview(button)
        // Do any additional setup after loading the view.
    }
}
extension SiriSetupVC: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension SiriSetupVC: INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
