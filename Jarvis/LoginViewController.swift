//
//  ViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 2..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SnapKit
import Speech

struct NickName {
    var Email : String
    var Passwd : String
}
class LoginViewController: UIViewController, SFSpeechRecognizerDelegate, UIPopoverPresentationControllerDelegate {//로그인 뷰

    @IBOutlet weak var segement: UISegmentedControl!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    var EmailText = UITextField()
    var PasswordText = UITextField()
    let margin : CGFloat = 8.0
    var rect = CGRect()
    var tableView = UITableView()
       var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var textItem : String?
    var manualBtn2 = UIButton()
    var List : [String] = []
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var reco : SFSpeechAudioBufferRecognitionRequest?
    private var result : SFSpeechRecognitionTask?
    private let audio = AVAudioEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        manualBtn2 = UIButton(frame: CGRect(x: 250, y: 30, width: 30, height: 30))
        manualBtn2.setTitle("설명", for: .normal)
        manualBtn2.showsTouchWhenHighlighted = true
        manualBtn2.addTarget(self, action: #selector(popOver), for: .touchUpInside )
        
        self.view.insertSubview(manualBtn2, aboveSubview: self.view)
        
        manualBtn2.snp.makeConstraints{(make) in
            make.top.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
        }
        
        
        segement.tintColor = UIColor.white
        EmailText.backgroundColor = UIColor.white
        PasswordText.backgroundColor = UIColor.white
        button.tintColor = UIColor.white
        let superView = self.view!
        button1.tintColor = UIColor.white
        
        self.speechRecognizer?.delegate = self
        let attr = NSDictionary(object: UIFont(name: "THECandybar", size: 20)!, forKey: NSFontAttributeName as NSCopying)
        segement.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        
        ref = Database.database().reference() // database connected
        let imageview = UIImageView()
        imageview.backgroundColor = UIColor.black
        let robotImageview = UIImageView()
        robotImageview.image = UIImage(named: "robot.jpg")
        self.view.insertSubview(robotImageview, belowSubview: button)
        self.view.insertSubview(imageview, belowSubview: robotImageview)
        self.view.insertSubview(EmailText, aboveSubview: button)
        self.view.insertSubview(PasswordText, aboveSubview: button)
        self.view.insertSubview(segement, aboveSubview: robotImageview)
        self.view.insertSubview(button1, aboveSubview: robotImageview)
        EmailText.borderStyle = .roundedRect
        PasswordText.borderStyle = .roundedRect
        EmailText.autocapitalizationType = .none
        PasswordText.autocapitalizationType = .none
        PasswordText.isSecureTextEntry = true
        EmailText.autocorrectionType = .no
        PasswordText.autocorrectionType = .no
        imageview.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: self.view.frame.width, height: (self.view.frame.height / 2) + 50))
            make.top.equalTo(superView)
            make.left.equalTo(superView)
            make.right.equalTo(superView)
        }
        
        segement.snp.makeConstraints { (make) in
            make.top.equalTo(manualBtn2.snp.bottom).offset(20)
            make.centerX.equalTo(superView.snp.centerX)
        }
        EmailText.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: self.view.frame.width/2, height: 30))
            make.top.equalTo(segement.snp.bottom).offset(50)
            make.centerX.equalTo(superView)
        }
        PasswordText.snp.makeConstraints { (make) in
            make.size.equalTo(EmailText)
            make.top.equalTo(EmailText.snp.bottom).offset(50)
            make.centerX.equalTo(EmailText.snp.centerX)
        }
        button.snp.makeConstraints { (make) in
            make.left.equalTo(superView).offset(50)
            make.top.equalTo(PasswordText).offset(90)
        }
        button1.snp.makeConstraints { (make) in
            make.size.equalTo(button)
            make.right.equalTo(superView).offset(-50)
            make.top.equalTo(button)
        }
        robotImageview.snp.makeConstraints { (make1) in
            make1.size.equalTo(CGSize(width: self.view.frame.width, height: (self.view.frame.height / 2) + 50))
            
            make1.bottom.equalTo(superView)
            make1.right.equalTo(superView)
            make1.left.equalTo(superView)
            
            
        }
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button1.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view, typically from a nib.
        
        if Config.IS_AUTO_PASS_LOGIN {
            EmailText.text = "step332@naver.com"
            PasswordText.text = "qkrwltjd1"
            actLogin(nil)
        }
    }
    @IBAction func speech(_ sender: UIButton) {
        popOver2(sender)
    }
    
    func popOver(_ send : UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "manual2")
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 300, height: 300)
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        popover.sourceView = send as UIView
        popover.sourceRect = send.bounds
        self.present(vc, animated: true, completion: nil)
    }
    func popOver2(_ send : UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NickName")
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 300, height: 300)
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.permittedArrowDirections = .up
        popover.sourceView = send as UIView
        popover.sourceRect = send.bounds
        self.present(vc, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    func reset(email : String)  { // 이메일 찾기 > 재설정
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil { //성공적으로 이메일 전송
               self.displayErrorMessage(title: "입력된 이메일로 전송되었습니다.", message: "")
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    func displayErrorMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func loop(_ text : String, _ List : [String])-> Bool {
        var bool : Bool = false
        for key in List {
            
            if text == key {  //같은 별명을 찾았다 그럼 트루
                bool = true
            }
        }
        return bool
    }
    @IBAction func actSignup(_ sender: UISegmentedControl) {
        if segement.selectedSegmentIndex == 1 {
            performSegue(withIdentifier: "signupPage", sender: self)
        }
        else if segement.selectedSegmentIndex == 2 {
            let Alert = UIAlertController(title: "비밀번호 재설정", message: nil, preferredStyle: .alert)
            Alert.setValue(NSAttributedString(string: Alert.title!, attributes: [NSFontAttributeName : UIFont(name: "THECandybar", size: 20)!]), forKey: "attributedTitle")
            let St1 = UIAlertAction(title: "비밀번호 재설정", style: .default) {
                (action : UIAlertAction) -> Void in
                let alert1 = UIAlertController(title: "비밀번호 재설정", message: nil, preferredStyle: .alert)
                alert1.addTextField(configurationHandler: { (textfield) in
                    textfield.attributedPlaceholder = NSAttributedString(string: "인증 메일을 전송할 이메일", attributes: [NSForegroundColorAttributeName : UIColor.red])
                })
                let confirm = UIAlertAction(title: "인증 이메일 전송", style: .default) {
                    (action : UIAlertAction) -> Void in
                    self.reset(email: (Alert.textFields?[0].text)!)
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                alert1.addAction(confirm)
                alert1.addAction(cancel)
                self.present(alert1, animated: true, completion: nil)
            }
            let St2 = UIAlertAction(title: "2차 비밀번호 찾기", style: .default) {
                (action : UIAlertAction) -> Void in
                let alert2 = UIAlertController(title: "2차 비밀번호 찾기", message: nil, preferredStyle: .alert)
                alert2.addTextField(configurationHandler: { (textfield) in
                    textfield.attributedPlaceholder = NSAttributedString(string: "찾고자하는 Email", attributes: [NSForegroundColorAttributeName : UIColor.red])
                })
                let confirm = UIAlertAction(title: "찾기", style: .default) {
                    (action : UIAlertAction) -> Void in
                    self.handle = self.ref?.child("NickNameForLoginData").observe(.childAdded, with: { (snapshot) in
                        if let item = snapshot.value as? [String : String] {
                            if item["Email"] == (alert2.textFields?[0].text) {
                               self.displayErrorMessage(title: "2차 비밀번호는", message: "\(item["TwicePass"]!)")
                            }
                        }
                    })
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                cancel.setValue(UIColor.red, forKey: "titleTextColor")
                alert2.addAction(confirm)
                alert2.addAction(cancel)
                self.present(alert2, animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            Alert.addAction(St1)
            Alert.addAction(St2)
            Alert.addAction(cancel)
            present(Alert, animated: true, completion: nil)
        }
    }

    @IBAction func actLogin(_ sender: Any?) { //로그인
        if EmailText.text != "" &&  PasswordText.text != "" { // 둘다 값이 있을 때
            if segement.selectedSegmentIndex == 0 { // 로그인 세그먼트일 때
               Auth.auth().signIn(withEmail: EmailText.text!, password: PasswordText.text!, completion: { (user, error) in
                if user != nil {
                    print("Success")
                    self.performSegue(withIdentifier: "Login", sender: self)
                }
                else {
                    if let myError = error?.localizedDescription {
                        print(myError)
                    }
                    else {
                        print("error")
                    }
                }
               })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

