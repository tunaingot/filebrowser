//
//  MIDIFilebrowseView.swift
//  filebrowser
//
//  Created by 大川 博 on 2025/04/18.
//

import UIKit

class MIDIFilebrowseView: UIViewController {
    @IBOutlet weak var fileListTableView: UITableView!
    
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!

    /*==========================================================================
     
     ==========================================================================*/
    public static let fileSelectFinishNotification = Notification.Name(rawValue: "MIDIFilebrowseView.fileSelectFinishNotification")
    public static let selectedFileKey = "MIDIFilebrowseView.selectedFileKey"  //選択されたファイルのフルパスを取り出すキー
    
    /*==========================================================================
     
     ==========================================================================*/
    private let STORYBOARD_IDENTIFY = "filebrowser"
    
    /*==========================================================================
     
     ==========================================================================*/
    fileprivate var currentDirectory = FileManager.default.documentPath!
    public var selectedFile = "" {
        didSet {
            selectedFile = FileManager.default.replacementApplicationPath(filePath: selectedFile, deviceDocumentPath: FileManager.default.documentPath!)
            print(selectedFile)
            if FileManager.default.fileExists(atPath: selectedFile) {
                if selectedFile.isMIDIFile {
                    currentDirectory = selectedFile.deletingLastPathComponent
                    let relPath = currentDirectory.deletingDocumentDirectory    //Documentsフォルダ以降の階層を含んだパス
                    var dirs = relPath.split(separator: "/")                    //分割されたフォルダ
                    
                    if dirs.count == 0 {        //ルートフォルダ上のファイルが選択された
                        
                    } else {
                        /*------------------------------------------------------
                         append home view controller
                         -----------------------------------------------------*/
                        let homeVC = storyboard?.instantiateViewController(identifier: STORYBOARD_IDENTIFY) as! MIDIFilebrowseView
                        
                        homeVC.title = "Files".localized
                        navigationController?.viewControllers.insert(homeVC, at: 0) //viewControllersに挿入
                        
                        /*------------------------------------------------------
                         home以降のディレクトリview controllerを生成
                         -----------------------------------------------------*/
                        var insertIndex = 1
                        var path = FileManager.default.documentPath!
                        
                        dirs.removeLast()   //最後のディレクトリはNavigation Controllerですでに生成されている
                        
                        for dir in dirs {
                            let vc = storyboard?.instantiateViewController(withIdentifier: STORYBOARD_IDENTIFY) as! MIDIFilebrowseView
                            
                            path += "/" + String(dir)
                            vc.currentDirectory = path  //作ったview controllerがファイルを表示するパス
                            vc.title = String(dir)      //view controller上部中央のタイトルはディレクトリ名
                            navigationController?.viewControllers.insert(vc, at: insertIndex)   //viewControllersに挿入
                            insertIndex += 1
                        }
                    }
                }
            }
        }
    }

    /*==========================================================================
     
     ==========================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewDidLoadSubwork()
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

/*==============================================================================
 
 =============================================================================*/
extension MIDIFilebrowseView: UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    private func viewDidLoadSubwork() {
        print(currentDirectory)
        navigationController?.delegate = self
        navigationController?.isToolbarHidden = false
        
        fileListTableView.delegate = self
        fileListTableView.dataSource = self
        
        if currentDirectory == FileManager.default.documentPath! {
            title = "Files".localized
        } else {
            title = currentDirectory.lastPathComponent
        }
        
        /*----------------------------------------------------------------------
         tool bar
         ---------------------------------------------------------------------*/
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(homeButton(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButton(_:)))

        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton(_:)))
        doneButton.isEnabled = false
        toolbarItems = [cancelButton, flexibleSpace, homeButton, flexibleSpace, doneButton]
    }
    
    /*==========================================================================
     
     ==========================================================================*/
    override func viewWillAppear(_ animated: Bool) {
        let displayFiles = FileManager.default.MIDIContents(ofDirectory: currentDirectory)
        var row = 0
        
        for file in displayFiles {
            if file.lastPathComponent == selectedFile.lastPathComponent {
                fileListTableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .middle)
                doneButton.isEnabled = true
            }
            row += 1
        }
    }
    //MARK: - action
    /*==========================================================================
     
     ==========================================================================*/
    @objc func doneButton(_ sender: Any) {
        if let rowIndex = fileListTableView.indexPathForSelectedRow {
            let selectedFile = FileManager.default.MIDIContents(ofDirectory: currentDirectory)[rowIndex.row]
            NotificationCenter.default.post(name: MIDIFilebrowseView.fileSelectFinishNotification, object: self, userInfo: [MIDIFilebrowseView.selectedFileKey: selectedFile])
        }
        dismiss(animated: true)
    }

    @objc func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc func homeButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    //MARK: - tableview
    /*==========================================================================
     
     ==========================================================================*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileManager.default.MIDIContents(ofDirectory: currentDirectory).count
    }
    
    /*==========================================================================
     
     ==========================================================================*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let item = FileManager.default.MIDIContents(ofDirectory: currentDirectory)[indexPath.row]
        
        cell.textLabel?.text = item.lastPathComponent.deletingPathExtension
        
        if item.isDirectory {                           //ディレクトリなら
            cell.accessoryType = .disclosureIndicator   //奥の階層がある目印をつける
        }
        
        return cell
    }
    
    /*==========================================================================
     
     ==========================================================================*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        let item = FileManager.default.MIDIContents(ofDirectory: currentDirectory)[selectedRow]
        
        if item.isDirectory {
            let vc = storyboard?.instantiateViewController(withIdentifier: STORYBOARD_IDENTIFY) as! MIDIFilebrowseView  //次の階層のview controllerを作る
            
            vc.currentDirectory = item                                      //表示するディレクトリ
            vc.title = item.lastPathComponent                               //上部中央に表示するタイトル(フォルダ名)
            navigationController?.pushViewController(vc, animated: true)    //次の階層へ遷移する
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
}

/*==============================================================================
 
 =============================================================================*/
extension FileManager {
    public var documentPath: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    public func isDirectory(atPath: String) -> Bool {
        var isDir: ObjCBool = false
        
        FileManager.default.fileExists(atPath: atPath, isDirectory: &isDir)
        
        return isDir.boolValue
    }
    
    public func MIDIContents(ofDirectory: String, sort: NSSortDescriptor? = NSSortDescriptor(key: "", ascending: true), isPlaceFoldersOnTop: Bool = true) -> [String] {
        var result = [String]()
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: ofDirectory)
            
            for item in contents {    //不可視ファイルを削除
                if item.first == "." {
                    
                } else {
                    if item.isMIDIFile {
                        result.append(item)
                    } else if FileManager.default.isDirectory(atPath: ofDirectory + "/" + item) {
                        result.append(item)
                    }
                }
            }
            
            for index in 0 ..< result.count {   //フルパス表記にする
                result[index] = ofDirectory + "/" + result[index]
            }
            
            /*------------------------------------------------------------------
             結果のソート
             -----------------------------------------------------------------*/
            if sort != nil {
                if sort!.ascending {
                    result.sort { $0.localizedStandardCompare($1) == ComparisonResult.orderedAscending }
                } else {
                    result.sort { $0.localizedStandardCompare($1) == ComparisonResult.orderedDescending }
                }
            }
            
            if isPlaceFoldersOnTop {
                /*--------------------------------------------------------------
                 フォルダとファイルを分ける
                 -------------------------------------------------------------*/
                var directorys = [String]()
                var subfiles = [String]()
                
                for fl in result {
                    if FileManager.default.isDirectory(atPath: fl) {
                        directorys.append(fl)
                    } else {
                        subfiles.append(fl)
                    }
                }
                
                /*--------------------------------------------------------------
                 フォルダを上に
                 -------------------------------------------------------------*/
                result.removeAll()
                result.append(contentsOf: directorys)
                result.append(contentsOf: subfiles)
            }
        } catch {
            
        }
        return result
    }
    
    ///シミュレータのDocumentディレクトリが変わった時などに便利に使えます
    public func replacementApplicationPath(filePath: String, deviceDocumentPath: String) -> String {
        //        let devPathRange = filePath.range(of: deviceDocumentPath.lastPathComponent)!
        //        let devPath = String(filePath[filePath.startIndex ..< devPathRange.upperBound])
        //
        //        return FileManager.default.documentPath! + filePath.replacingOccurrences(of: devPath, with: "")
        if let devPathRange = filePath.range(of: deviceDocumentPath.lastPathComponent) {
            let devPath = String(filePath[filePath.startIndex ..< devPathRange.upperBound])
            
            return FileManager.default.documentPath! + filePath.replacingOccurrences(of: devPath, with: "")
        } else {
            return FileManager.default.documentPath! + "/" + filePath
        }
    }
}

/*==============================================================================
 
 =============================================================================*/
extension String {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    public var pathExtension: String? {
        if let start = lastIndex(of: Character(".")) {
            if String(self[index(start, offsetBy: 1) ..< endIndex]).contains("/") { //ディレクトリ内の.を検出した
                return nil
            }
            return String(self[index(start, offsetBy: 1) ..< endIndex])
        } else {
            return nil
        }
    }

    public var deletingPathExtension: String {
        let result = self
        
        if let pos = result.lastIndex(of: Character(".")) {
            return String(result[startIndex ..< pos])
        } else {
            return result
        }
    }

    public var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    public var deletingLastPathComponent: String {
        return replacingOccurrences(of: "/" + lastPathComponent, with: "")
    }

    public var isDirectory: Bool {
        return FileManager.default.isDirectory(atPath: self)
    }
    
    public var isMIDIFile: Bool {
        if let pe = pathExtension {
            if pe.lowercased() == "mid" || pe.lowercased() == "midi" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public var deletingDocumentDirectory: String {
        let deletePath = FileManager.default.documentPath!
        var resultPath = replacingOccurrences(of: deletePath, with: "")
        
        if resultPath.first == "/" {
            resultPath.removeFirst()
            return String(resultPath)
        } else {
            return resultPath
        }
    }


}
