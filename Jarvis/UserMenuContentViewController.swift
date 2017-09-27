//
//  UserMenuContentViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 18..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

struct KeyWordList { //키워드 데이터 사전 구성
    var name : String
    var count : Int
}
class UserMenuContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { // 키워드 랭킹뷰
    let KeyListDic = ["교통", "교육", "의료", "관광", "금융", "식품"]
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var KeyResult : [KeyWordList] = []
    var array = [KeyWordList]()
    @IBOutlet weak var myKeyword: UITableView!
        override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        NumberOfCount(KeyListDic)
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KeyResult.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myKeyword.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as? UILabel
        let int : [Int] = [1,2,3,4,5,6]
        label?.text = "\(int[indexPath.row]) : \(KeyResult[indexPath.row].name)"
        label?.font = UIFont(name: "THECandybar", size: 20)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func NumberOfCount(_ KeyList : [String]) { // 앱 시작시에 카운트 별로 딕셔너리로 저장 해서 리턴하는 함수
        for i in KeyList {
            handle = ref?.child("KeyList").child(i).child("KeyValue").observe(.childAdded, with: { (snapshot)
                in
                let item = (snapshot.value as? String)!
                self.array.append(KeyWordList(name : i, count : Int(item)!))
                if i == KeyList[KeyList.count - 1] { //마지막 인덱스에 다 다랐을 때 즉, 딕셔너리 완성 시
                    self.KeyResult = self.SortKeyValue(self.array, self.KeyListDic)
                    print(self.KeyResult)
                    self.myKeyword.reloadData() //저장한 다음 테이블 뷰에 올린다.
                }
            })
        }
    }
    func SortKeyValue(_  SortDic : [KeyWordList], _ List : [String]) -> [KeyWordList] {// 카운트 별로 정리 후 테이블뷰에 그대로 띄움
        var SS = SortDic
        for i in (1...List.count-1).reversed() { // 버블 횟수
            for j in 0...i-1 {
                if SS[j].count > SS[j+1].count { //맨 앞값이 크면 계속하기
                    continue
                }
                else if SS[j].count < SS[j+1].count { // 그다음 값이 크게 되면 자리 바꾸기
                    swap(&SS[j], &SS[j+1])
                }
            }
        }
        return SS
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
