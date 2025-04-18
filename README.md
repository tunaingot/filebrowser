# filebrowser
 
- MIDIFilebrowseView.swift
- MIDIFilebrowseView.storyboard

の二つは、ViewControllerから独立した構造にしてあります。  
なので、ご自身のXcodeプロジェクトにそのまま取り込むことができます。  

# extension
FileManager、StringのextensionをMIDIFilebrowseView.swiftの中に記述しています。  
必要に応じて別のファイルに移すなどして管理するのも良いでしょう。  

# Standard MIDI File
**Standard MIDI File**フォルダにファイルを入れてあります。  
必要であればお使いください。  

# 応用
このサンプルはStandard MIDI Fileの選択・表示に特化しています。  
改造すれば、別の種類のファイル選択・表示に特化することができます。  
ファイルの識別には拡張子を利用しています。 　
