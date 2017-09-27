//
//  MyMenuViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 13..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

struct BookMarks { //즐겨찾기 데이터
    var url : String
    var title : String
}
class MyMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // 유저 페이지 즐겨찾기와 자신이 검색한 키워드 뷰
    @IBOutlet weak var navi: UINavigationBar!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var myKeyword: UITableView!
    let KeyListDic = ["교통", "교육", "의료", "관광", "금융", "식품"]
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var myList : Set<String> = []
    var Middle : [[String : Int]] = []
    var News = [BookMarks]()
    var TotalList : [[String : String]] = []
    var image = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        image.image = UIImage(named: "star.jpeg")
        self.view.insertSubview(image, belowSubview: segment)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "THECandybar", size: 15)!]
        UINavigationBar.appearance().tintColor = UIColor.black
        let attr = NSDictionary(object: UIFont(name: "THECandybar", size: 20)!, forKey: NSFontAttributeName as NSCopying)
        segment.setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        segment.tintColor = UIColor.white
        MyKeyWord()
    }
    @IBAction func actMyMenu(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // MyKeyWord
            myList = []
            MyKeyWord()
        case 1: // BookMarks
            TotalList = []
            Total()
        default:
            return
        }
    }
    func Total() {
        handle = ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("BookMarks").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? [String : String] {
               
                self.TotalList.append(item)
                self.myKeyword.reloadData()
            }
        })
    }
    func MyKeyWord() {
        handle = ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("Keyword").observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? String {
                self.myList.insert(item) //없는거면 추가하고
                self.myKeyword.reloadData() // 로드
                    }
            })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segment.selectedSegmentIndex == 1 {
            return TotalList.count
        }
        let List = Array(myList)
        return List.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
     
        if segment.selectedSegmentIndex == 1 {
            let dic = TotalList[indexPath.row]
            cell.textLabel?.text = dic["title"]
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.font = UIFont(name: "THECandybar", size: 20)
            
            return cell
        }
        var List = Array(myList)
        cell.textLabel?.text = List[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.font = UIFont(name: "THECandybar", size: 20)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//해당 셀이 선택되었을 경우
        if segment.selectedSegmentIndex == 1 {
            performSegue(withIdentifier: "BookMarks", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { // 삭제했을시
            // Delete the row from the data source
            if segment.selectedSegmentIndex == 1{ //즐겨찾기 칸에서 삭제를 눌렀을 때
                let dic = TotalList[indexPath.row]
                ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("BookMarks").observe(.childAdded, with: { (snapshot) in
                    
                    if let item = snapshot.value as? [String : String] {
                        print(item)
                        if item["URL"] == dic["URL"] { // 삭제하려는 값과 가져온 값이 같으면 그 값의 부모 값을 삭제
                            let key = snapshot.key
                            self.ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("BookMarks").child(key).removeValue()
                        }
                    }
                })
                TotalList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }else { // My Keyword일시엔 그냥 종료
                return
            }
            
            
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segment.selectedSegmentIndex == 1 {
            if let indexpath = myKeyword.indexPathForSelectedRow {
                let dic = TotalList[indexpath.row]
                let destination = segue.destination as? BookMarkViewController
                destination?.address = dic["URL"] // 해당 url 넘기기 
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
