//
//  ViewController.swift
//  filebrowser
//
//  Created by 大川 博 on 2025/04/18.
//

import UIKit

class ViewController: UIViewController {
    private let SELECTED_FILE_SAVE_KEY = "Selected File Path"
    private var selectedFile = ""

    /*==========================================================================
     
     =========================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewDidLoadSubwork()
    }

}

/*==============================================================================
 
 =============================================================================*/
extension ViewController: UIPopoverPresentationControllerDelegate {
    private func viewDidLoadSubwork() {
        if let fp = UserDefaults.standard.string(forKey: SELECTED_FILE_SAVE_KEY) {
            selectedFile = fp
        }
        NotificationCenter.default.addObserver(self, selector: #selector(fileSelected(_:)), name: MIDIFilebrowseView.fileSelectFinishNotification, object: nil)
    }
    //MARK: - popover
    /*==========================================================================
     
     =========================================================================*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextCtrl = segue.destination as? UINavigationController {
            nextCtrl.popoverPresentationController?.delegate = self
            segue.destination.preferredContentSize = UIScreen.main.bounds.size
            (nextCtrl.viewControllers.first as! MIDIFilebrowseView).selectedFile = selectedFile //表示されるポップオーバーにselectedFileを渡す
        }
        super.prepare(for: segue, sender: sender)
    }
    
    /*==========================================================================
     
     =========================================================================*/
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        /*----------------------------------------------------------------------
         UIModalPresentationStyleの値を.noneで返せばiPhoneでも変更したサイズで
         popoverが表示される
         ---------------------------------------------------------------------*/
        return .none
        
    }

    //MARK: - notification
    /*==========================================================================
     
     =========================================================================*/
    @objc func fileSelected(_ notification: Notification) {
        selectedFile = notification.userInfo?[MIDIFilebrowseView.selectedFileKey] as! String
        UserDefaults.standard.set(selectedFile, forKey: SELECTED_FILE_SAVE_KEY)
        UserDefaults.standard.synchronize()
    }
}
