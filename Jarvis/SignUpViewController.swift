//
//  SignUpViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 9. 13..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import Firebase

struct NickDistinction {
    var nick : String
}

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource { //회원가입 뷰
    var EmailText = UITextField()
    var PasswordText = UITextField()
    var yearText = UITextField()
    var NicknameText = UITextField()
    var twicePass = UITextField()
    var signButton = UIButton()
    var picker = UIPickerView()
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var pickOption = ["20대", "30대", "40대", "50대"]
    let toolbar = UIToolbar()
    var backimage = UIImageView()
    var List : [NickDistinction] = []
    @IBOutlet weak var navi: UINavigationBar!
    func displayErrorMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func SuccessSignup(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "MainPage", sender: self)
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func Create() {

        handle = ref?.child("NickNameForLoginData").observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull {
                Auth.auth().createUser(withEmail: self.EmailText.text!, password: self.PasswordText.text!, completion: { (user, error) in
                    if user != nil {
                        print("success")
                        let data = ["Email_Name" : self.EmailText.text!]
                        let data1 = ["generation" : self.yearText.text!]
                        let data2 = ["NickName" : self.NicknameText.text!]
                        self.ref?.child("User").child(user!.uid).child("UserProfile").setValue(data)// 유저 란 밑에 아이디
                        self.ref?.child("User").child(user!.uid).child("UserProfile").updateChildValues(data1)
                        self.ref?.child("User").child(user!.uid).child("UserProfile").updateChildValues(data2)
                        self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).setValue(["Email" : self.EmailText.text!])
                        self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["Password" : self.PasswordText.text!])
                        self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["TwicePass" : self.twicePass.text!])
                        self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["NickName" : self.NicknameText.text!])
                        self.SuccessSignup(title: "회원가입을 환영합니다.", message: "")
                        
                    } else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                        } else {
                            print("error")
                        }
                    }
                            
                })
            } else {
                self.handle = self.ref?.child(snapshot.key).child(self.NicknameText.text!).observe(.value, with: { (snapshot) in
                    if snapshot.exists() { // 회원 계정이 있을 때 닉네임 텍스트필드에 값이 키로 존재하면
                        self.displayErrorMessage(title: "닉네임 중복입니다.", message: "다시 입력해주십시오")
                    } else { // 존재하지 않는다? == 중복이 없다.
                        Auth.auth().createUser(withEmail: self.EmailText.text!, password: self.PasswordText.text!, completion: { (user, error) in
                            if user != nil {
                                print("success")
                                let data = ["Email_Name" : self.EmailText.text!]
                                let data1 = ["generation" : self.yearText.text!]
                                let data2 = ["NickName" : self.NicknameText.text!]
                                self.ref?.child("User").child(user!.uid).child("UserProfile").setValue(data)// 유저 란 밑에 아이디
                                self.ref?.child("User").child(user!.uid).child("UserProfile").updateChildValues(data1)
                                self.ref?.child("User").child(user!.uid).child("UserProfile").updateChildValues(data2)
                                self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).setValue(["Email" : self.EmailText.text!])
                                self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["Password" : self.PasswordText.text!])
                                self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["TwicePass" : self.twicePass.text!])
                                self.ref?.child("NickNameForLoginData").child(self.NicknameText.text!).updateChildValues(["NickName" : self.NicknameText.text!])
                                self.SuccessSignup(title: "회원가입을 환영합니다.", message: "")
                                
                            } else {
                                if let myError = error?.localizedDescription {
                                    print(myError)
                                } else {
                                    print("error")
                                }
                            }
                            
                        })

                    }
                })
            }
        })
    }
    func Signup(sender : UIButton!) {
//        var bool : Bool = false
        if EmailText.text != "" && PasswordText.text != "" && yearText.text != "" && NicknameText.text != "" && twicePass.text != "" { // 전부 다 공백이 아니면
            if (twicePass.text?.length)! == 4 { // 공백 아닌 상태에서 네자리가 맞다.? 그럼 닉네임 중복검사
                Create()
            } else {
                displayErrorMessage(title: "2차 비밀번호는 4자리 입니다.", message: "")
            }
        }   else { //공백이 있는경우.
            displayErrorMessage(title: "공백이 있습니다.", message: "입력 해주세요")
        }
    }
    func donePicker(sender : UIBarButtonItem!) {
        yearText.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        ref = Database.database().reference()
        backimage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backimage.image = UIImage(named: "signup.png")
        
        let superView = self.view!
        superView.insertSubview(backimage, belowSubview: navi)
        picker.delegate = self
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let donebutton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([donebutton], animated: false)
        toolbar.isUserInteractionEnabled = true
        yearText.inputAccessoryView = toolbar
        
        EmailText = UITextField(frame: CGRect(x: 0, y: 0, width: superView.frame.width/4, height: 30))
        EmailText.attributedPlaceholder = NSAttributedString(string: "Email ", attributes: [NSForegroundColorAttributeName : UIColor.red])
        PasswordText.attributedPlaceholder = NSAttributedString(string: "Password ", attributes: [NSForegroundColorAttributeName : UIColor.red])
        NicknameText.attributedPlaceholder = NSAttributedString(string: "별명", attributes: [NSForegroundColorAttributeName : UIColor.red])
        yearText.attributedPlaceholder = NSAttributedString(string: "ex) 20대 30대 ", attributes: [NSForegroundColorAttributeName : UIColor.red])
        twicePass.attributedPlaceholder = NSAttributedString(string: "2차 비밀번호 4자리", attributes: [NSForegroundColorAttributeName : UIColor.red])
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "THECandybar", size: 20)!]
        EmailText.backgroundColor = UIColor.white
        PasswordText.backgroundColor = UIColor.white
        NicknameText.backgroundColor = UIColor.white
        yearText.backgroundColor = UIColor.white
        twicePass.backgroundColor = UIColor.white
        EmailText.borderStyle = .roundedRect
        PasswordText.borderStyle = .roundedRect
        NicknameText.borderStyle = .roundedRect
        yearText.borderStyle = .roundedRect
        twicePass.borderStyle = .roundedRect
        yearText.inputView = picker
        EmailText.autocapitalizationType = .none
        PasswordText.autocapitalizationType = .none
        PasswordText.isSecureTextEntry = true
        twicePass.autocapitalizationType = .none
        NicknameText.autocapitalizationType = .none
        twicePass.isSecureTextEntry = true
        twicePass.adjustsFontSizeToFitWidth = true
        EmailText.autocorrectionType = .no
        PasswordText.autocorrectionType = .no
        NicknameText.autocorrectionType = .no
        
        superView.addSubview(EmailText)
        superView.addSubview(PasswordText)
        superView.addSubview(NicknameText)
        superView.addSubview(signButton)
        superView.addSubview(yearText)
        superView.addSubview(twicePass)
        
        signButton.setImage(UIImage(named: "membership.png"), for: .normal)
        signButton.isHighlighted = true
        signButton.addTarget(self, action: #selector(self.Signup), for: .touchUpInside)
        
        EmailText.snp.makeConstraints { (make) in
            make.top.equalTo(superView).offset(self.view.frame.height/5)
            make.left.equalTo(superView).offset(self.view.frame.width/4)
            make.right.equalTo(superView).offset(-(self.view.frame.width/4))
        }
        PasswordText.snp.makeConstraints { (make) in
            make.size.equalTo(EmailText)
            make.top.equalTo(EmailText.snp.bottom).offset(25)
            make.left.equalTo(EmailText)
            make.right.equalTo(EmailText)
        }
        signButton.snp.makeConstraints { (make) in
            make.size.equalTo(superView.frame.width/3)
            make.top.equalTo(twicePass.snp.bottom).offset(25)
            make.centerX.equalTo(twicePass.snp.centerX)
            
        }
        NicknameText.snp.makeConstraints { (make) in
            make.size.equalTo(EmailText)
            make.top.equalTo(PasswordText.snp.bottom).offset(25)
            make.left.equalTo(EmailText)
            make.right.equalTo(EmailText)
        }
        yearText.snp.makeConstraints { (make) in
            make.size.equalTo(EmailText)
            make.top.equalTo(NicknameText.snp.bottom).offset(25)
            make.left.equalTo(EmailText)
            make.right.equalTo(EmailText)
        }
        twicePass.snp.makeConstraints { (make) in
            make.size.equalTo(twicePass)
            make.top.equalTo(yearText.snp.bottom).offset(25)
            make.left.equalTo(EmailText)
            make.right.equalTo(EmailText)
        }
        navi.snp.makeConstraints { (make) in
            make.top.equalTo(superView.snp.top).offset(3)
            make.left.equalTo(superView.snp.left)
            make.right.equalTo(superView.snp.right)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearText.text = pickOption[row]
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
