//
//  SpeechViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 2..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import FirebaseAuth
import Firebase


class SpeechViewController: UIViewController, SFSpeechRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    //음성인식 메인뷰
    @IBOutlet weak var tab: UITabBarItem!
    @IBOutlet weak var speech: UIButton!
    @IBOutlet weak var label: UILabel!
    var textItem : String?
    var manualBtn3 = UIButton()
    var keyBtn3 = UIButton()
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var KeyDic : [[String : Int]] = []
    var count : Int = 0
    let KeyListDic = ["교통", "교육", "의료", "관광", "금융", "식품"]
    var pickOption = ["20대", "30대", "40대", "50대"]
    var dic1 : [String : Int]? = [:]
    var dic2 : [String : String] = [:]
    var str : String? = nil
    var backimage = UIImageView()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    let synthesizer = AVSpeechSynthesizer()
    var speaktext : String = ""
    func displayErrorMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func popOver(_ iden : String, _ send : UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iden)
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 300, height: 300)
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        popover.sourceView = send as UIView
        popover.sourceRect = send.bounds
        self.present(vc, animated: true, completion: nil)
    }
    func popOver2(_ send :UIButton){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        if send == keyBtn3 {
            vc = storyboard.instantiateViewController(withIdentifier: "keyword")
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 300, height: 300)
        } else if send == manualBtn3 {
            vc = storyboard.instantiateViewController(withIdentifier: "manual3")
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 400, height: 400)
        }
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        popover.sourceView = send as UIView
        popover.sourceRect = send.bounds
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func UserMenu(_ sender: UIButton) {
        let UserMenuAlert = UIAlertController(title: "UserMenu", message: nil, preferredStyle: .actionSheet)
        UserMenuAlert.setValue(NSAttributedString(string: UserMenuAlert.title!, attributes: [NSFontAttributeName : UIFont(name: "THECandybar", size: 20)!]), forKey: "attributedTitle")
        if let presenter = UserMenuAlert.popoverPresentationController {
            presenter.sourceView = sender as UIView
            presenter.sourceRect = sender.bounds
        }
        let MyPage = UIAlertAction(title: "MyPage", style: .default) { (action : UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "MyPage", sender: self)
        }
        let KeyWordPage = UIAlertAction(title: "KeyWordRanking", style: .default) {
                (action1 : UIAlertAction) -> Void in
            self.popOver("Users", sender)
                        }
        let GenePage = UIAlertAction(title: "GenerationRanking", style: .default) {
            (action : UIAlertAction) -> Void in
            self.popOver("Generation", sender)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let logout = UIAlertAction(title: "LogOut", style: .default) {
            (action : UIAlertAction) -> Void in
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "Logout", sender: self)
        }
        logout.setValue(UIColor.red, forKey: "titleTextColor")
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        UserMenuAlert.addAction(MyPage)
        UserMenuAlert.addAction(KeyWordPage)
        UserMenuAlert.addAction(cancel)
        UserMenuAlert.addAction(GenePage)
        UserMenuAlert.addAction(logout)
        present(UserMenuAlert, animated: true, completion: nil)
        }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = ref?.child("User").observe(.childAdded, with: { (snapshot) in
            if snapshot.value is NSNull {
                print(" null")
            }
            if let item = snapshot.value as? String {
                print(item)
            }
        })
        
        manualBtn3 = UIButton(frame: CGRect(x: 250, y: 30, width: 30, height: 30))
        manualBtn3.setTitle("설명", for: .normal)
        manualBtn3.showsTouchWhenHighlighted = true
        manualBtn3.addTarget(self, action: #selector(popOver2), for: .touchUpInside )
        
        self.view.insertSubview(manualBtn3, aboveSubview: self.view)
        
        manualBtn3.snp.makeConstraints{(make) in
            make.top.equalTo(self.view).offset(40)
            make.right.equalTo(self.view).offset(-20)
        }
        keyBtn3 = UIButton(frame: CGRect(x: 250, y: 30, width: 30, height: 30))
        keyBtn3.setTitle("KeyWord", for: .normal)
        keyBtn3.setTitleColor(UIColor.red, for: .normal)
        keyBtn3.showsTouchWhenHighlighted = true
        keyBtn3.addTarget(self, action: #selector(popOver2), for: .touchUpInside )
        
        self.view.insertSubview(keyBtn3, aboveSubview: self.view)
        
        keyBtn3.snp.makeConstraints{(make) in
            make.top.equalTo(self.view).offset(40)
            make.left.equalTo(self.view).offset(20)
        }
        
        self.view.backgroundColor = UIColor.black
        ref = Database.database().reference()
        speaktext = "다시 말씀해 주십시오."
        backimage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backimage.image = UIImage(named: "star.jpeg")
        backimage.alpha = 0
        self.view.insertSubview(backimage, belowSubview: label)
        
        let utterence = AVSpeechUtterance(string: "버튼을 누르고 해당 키워드를 말씀해주세요.")
        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterence.rate = 0.4
        synthesizer.speak(utterence)
        label.text = "버튼을 누르고 해당 키워드를 말씀해주세요."
        
        speech.isEnabled = false
        speechRecognizer?.delegate = self
        UINavigationBar.appearance().tintColor = UIColor.white
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.speech.isEnabled = isButtonEnabled
            }
            
        }
        
    }
    @IBAction func ActButton(_ sender: Any) {
        UIView.animate(withDuration: 3.0, animations: ({
            self.backimage.alpha = 1
        }))
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speech.isEnabled = false
            speech.setTitle("말하기!", for: .normal)
        } else {
            speech.setTitle("말하기 멈추기", for: .normal)
            
//            if Config.TEST_KEYWORD != nil {
//                self.textItem = Config.TEST_KEYWORD
//                self.label.text = self.textItem
//                self.gotoParsing(sendAnalysis: false)
//            } else {
            startRecording()
            //}
            
        }
    }
    
    func KeywordAnalysis(_ keyWord : String) {// 키워드 카운트 관리
        for key in KeyListDic {
            if keyWord == key {
                handle = ref?.child("KeyList").child(key).child("KeyValue").observe(.childAdded, with: {(snapshots) in
                    
                    if let item = snapshots.value as? String {
                        self.count = Int(item)!
                        self.count += 1
                    self.ref?.child("KeyList").child(key).child("KeyValue").setValue(["KeyValue" : "\(self.count)"])
                        
                    }
                    
                })
            }
        }
    }
    
    func sendAnalysis() {
        self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Keyword").childByAutoId().setValue(self.textItem) //자신의 키워드에 저장
        self.KeywordAnalysis(self.textItem!)
    }
    
    func gotoParsing(sendAnalysis isSendAnalysis: Bool = false) {
        //  검색결과를 보여주기전에 카운트 데이터 기록
        if isSendAnalysis {
            sendAnalysis()
        }
        
        self.performSegue(withIdentifier: "Parsing", sender: nil) // 말하고 텍스트에 표현이 되고 바로 이동
        speech.setTitle("말하기!", for: .normal)
    }
    func loop(_ text : String) -> Bool{
        var bool : Bool = false
        for key in 0...KeyListDic.count { //이 과정 통과 후 세그 전환
            if key == KeyListDic.count {
                break
            }
            if text == KeyListDic[key] { //자동차나 교육같은 키워드와 동일시 일 댸
                bool = true
            }
        }
        return bool
    }
    func CheckGene() { //연배 체크
        handle = ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("UserProfile").observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                for gene in self.pickOption {
                    
                    if item["generation"] == gene { //20대
                        self.PlusCount(item["generation"]!)
                    }
                }
            }
        })
    }
    func PlusCount(_ gene : String) { //해당 연배에 키워드 카운트 증가 함수
        for key in KeyListDic {
            
            if self.textItem! == key { // 불렀던값이 같을경우 그 세대 값에 넣는다.
                handle = ref?.child("Generation").child(gene).child(self.textItem!).observe(.childAdded, with: { (snapshot) in
                    if let item = snapshot.value as? String { // 그 해당 세대의 해당 키워드로 들어가서 카운트 증가시키고 다시 저장
                        self.count = Int(item)!
                        self.count += 1
                        self.ref?.child("Generation").child(gene).child(self.textItem!).setValue(["KeyValue" : "\(self.count)"])
                    }
                })
               
            }
        }
    }
    func startRecording() { //인식
        if recognitionTask != nil{
            recognitionTask?.cancel()
            recognitionTask = nil
            
        }
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
        } catch {
            print("audioSession properties weren't set because of error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            
            fatalError("Unalbe to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {(result, error)in
    
            var isFinal = false
            if result != nil{
                self.textItem = result?.bestTranscription.formattedString
                self.label.text = self.textItem
                if recognitionRequest.shouldReportPartialResults == true {
                    recognitionRequest.shouldReportPartialResults = false
                   let bool = self.loop(self.textItem!)
                    print(bool)
                    if bool { // 같은 키워드를 찾았을시에
                        self.CheckGene()
                        self.label.text = self.textItem
                        self.gotoParsing(sendAnalysis: true) // 키워드 카운트 증가
                        return
                    }
                    else if bool == false {
                        self.label.text = self.speaktext
                        return
                    }
                }
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop() // 인식 멈추고 세그
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.speech.isEnabled = true

            }
            
        })
        
        let recordingFormat = inputNode.outputFormat(forBus:0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer,when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            
            try audioEngine.start()
            
        }catch {
            
            print("audioEngine couldn't start because of an error.")
            
        }
        
        label.text = "설명서에 따른 단어 말씀해주십시오."
        
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speech.isEnabled = true
        } else {
            speech.isEnabled = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Parsing" {
            if let destination = segue.destination as? SearchNewsViewController {
                destination.UserQuery = self.textItem
            }
        }
    }
}
