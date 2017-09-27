//
//  SearchNewsViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 28..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import Speech
import SwiftyJSON
import Alamofire

class SearchNewsViewController: UIViewController, SFSpeechRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {// 파싱된 뉴스 보는 뷰
    let headers =  ["X-Naver-Client-Id" : "jhTqCNNdUtuebI3LyVmL", "X-Naver-Client-Secret" : "PBTEyPTMMh"]
    var Books : [[String : String]] = []
    let display = 10
    var currentPage = 1
    var UserQuery : String? = nil
    var query : String = ""
    var detailsQuery : String? = nil
    var resultQ : String?
    var count : Int = 1
    @IBOutlet weak var search: UIButton!
    
    @IBOutlet weak var navi: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        if let subQuery = UserQuery {
            query = subQuery
            
        }
        navi.topItem?.title = "\(query)"
        navi.titleTextAttributes = [NSFontAttributeName : UIFont(name: "THECandybar", size : 20)!]
        MainSearch(currentPage)
        return
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        speechRecognizer?.delegate = self
        UINavigationBar.appearance().tintColor = UIColor.black
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
                
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to search recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("search recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("search recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.search.isEnabled = isButtonEnabled
            }
            
            
        }
        
        
    }
    
    @IBAction func detailsSearch(_ sender: UIButton) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            search.isEnabled = false
            search.setTitle("말하기!", for: .normal)
        }
        else {
            startRecording()
            search.setTitle("말하기 멈추기", for: .normal)
        }
    }
    // 음성인식 부분
    func startRecording() {
        
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
            
            fatalError("Unalbe to create an SFsearchAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {(result, error) in
            
            
            if result != nil {
                
                self.detailsQuery = result?.bestTranscription.formattedString // 세부검색 단어 결과 저장
                self.resultQ = self.detailsQuery!
            
                
                let Alert = UIAlertController(title: "\(self.count)차 세부 검색 결과는 \(self.resultQ!)입니다.", message: "이 결과로 진행하시겠습니까?", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) {
                    (action : UIAlertAction) -> Void in

                    self.count += 1
                    self.query += " \(self.resultQ!)"

                    self.currentPage = 1
                    self.MainSearch(self.currentPage)
                    self.search.setTitle("세부검색", for: .normal)
                    
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.search.isEnabled = true
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                Alert.addAction(confirm)
                Alert.addAction(cancel)
                self.present(Alert, animated: true, completion: nil)
                
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
        
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            search.isEnabled = true
        } else {
            search.isEnabled = false
        }
    }
    
    @IBAction func Next(_ sender: UIBarButtonItem) {
        currentPage += display
        MainSearch(currentPage)
    }
    @IBAction func Previous(_ sender: UIBarButtonItem) {
        if currentPage == 1 {
            return
        }
        currentPage -= display
        MainSearch(currentPage)
    }
    func MainSearch(_ currentPage : Int) {
        let str = "https://openapi.naver.com/v1/search/news.json?query=4차 산업혁명 \(query)&display=\(display)&start=\(currentPage)&sort=sim"
        let strFo = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: strFo!)
        Alamofire.request(url!, method: .get, headers: headers).responseJSON { (reponsedata) -> Void in
            if ((reponsedata.result.value) != nil) {
                print("parsing Success")
                let swiftyJsonVar = JSON(reponsedata.result.value!)
                if let resdata = swiftyJsonVar["items"].arrayObject {
                    self.Books = resdata as! [[String : String]]
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of row
        return Books.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var dic = Books[indexPath.row]
        dic["title"] = dic["title"]?.replacingOccurrences(of: "<b>", with: "")
        dic["title"] = dic["title"]?.replacingOccurrences(of: "</b>", with: "")
        dic["title"] = dic["title"]?.replacingOccurrences(of: "&amp;", with: "")
        dic["description"] = dic["description"]?.replacingOccurrences(of: "<b>", with: "")
        dic["description"] = dic["description"]?.replacingOccurrences(of: "</b>", with: "")
        dic["description"] = dic["description"]?.replacingOccurrences(of: "&amp;", with: "")
        dic["title"] = dic["title"]?.replacingOccurrences(of: "&quot;", with: "")
        dic["description"] = dic["description"]?.replacingOccurrences(of: "&quot;", with: "")
        dic["pubDate"] = dic["pubDate"]?.replacingOccurrences(of: "+0900", with: "")
        let title = cell.viewWithTag(1) as? UILabel
        title?.text = dic["title"]

        title?.adjustsFontSizeToFitWidth = true
        let link = cell.viewWithTag(2) as? UILabel
        link?.text = dic["description"]
        link?.adjustsFontSizeToFitWidth = true
        let date = cell.viewWithTag(3) as? UILabel
        date?.text = dic["pubDate"]
        date?.adjustsFontSizeToFitWidth = true
        
        // Configure the cell...
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            var dic = Books[indexPath.row]
            dic["originallink"] = dic["originallink"]?.replacingOccurrences(of: "amp;", with: "")
            dic["title"] = dic["title"]?.replacingOccurrences(of: "<b>", with: "")
            dic["title"] = dic["title"]?.replacingOccurrences(of: "</b>", with: "")
            dic["title"] = dic["title"]?.replacingOccurrences(of: "&quot;", with: "")
            let view = segue.destination as? NewsViewController
            view?.address = dic["originallink"]
            view?.newsTitle = dic["title"] // 주소와 제목을 넘긴다.
        }
        
        
    }
    
}
