//
//  NickNameLoginViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 9. 26..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class NickNameLoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //별명 로그인 뷰
    @IBOutlet weak var myNickName: UITableView!
    var List : Set<String> = []
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        snapKeyList()
    }
    func displayErrorMessage(title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    func snapKeyList() {
        var index = 0
        handle = ref?.child("NickNameForLoginData").observe(.childAdded, with: { (snapshot) in
            
            
                index += 1
                self.List.insert(snapshot.key)
            if self.List.count == index {
                self.myNickName.reloadData()
            }

        })
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return List.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myNickName.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        let list = Array(List)
        label.text = list[indexPath.row]
        label.font = UIFont(name: "THECandybar", size: 20)
        label.textColor = UIColor.blue
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = Array(List)
        let Alert = UIAlertController(title: "2차 비밀번호 입력", message: "", preferredStyle: .alert)
        Alert.addTextField { (textfield) in
            textfield.attributedPlaceholder = NSAttributedString(string: "2차 비밀번호", attributes: [NSForegroundColorAttributeName : UIColor.red])
            textfield.isSecureTextEntry = true
        }
        let confirm = UIAlertAction(title: "확인", style: .default) {
            (action : UIAlertAction) -> Void in
            self.NickLogin(text: list[indexPath.row], pass: (Alert.textFields?[0].text)!)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        Alert.addAction(confirm)
        Alert.addAction(cancel)
        present(Alert, animated: true, completion: nil)
    }
    func NickLogin(text : String, pass : String) {
        handle = ref?.child("NickNameForLoginData").child(text).observe(.value, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
                if item["TwicePass"]! == pass {
                    Auth.auth().signIn(withEmail: item["Email"]!, password: item["Password"]!, completion: { (user, error) in
                        if user != nil {
                            print("Success")
                            let alert = UIAlertController(title: "환영합니다.", message: "다음 화면의 설명을 꼭 확인하시기바랍니다.", preferredStyle: .alert)
                            let confirm = UIAlertAction(title: "확인", style: .default) {
                                (action : UIAlertAction) -> Void in
                                self.performSegue(withIdentifier: "NickLogin", sender: self)
                            }
                            alert.addAction(confirm)
                            self.present(alert, animated: true, completion: nil)

                        } else {
                            if let myError = error?.localizedDescription {
                                print(myError)
                            } else {
                                print("error")
                            }
                        }
                    })
                } else {
                    self.displayErrorMessage(title: "비밀번호가 틀립니다.", message: "다시 해주십시오.")
                }
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
