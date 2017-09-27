//
//  GeneMenuViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 9. 18..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import Firebase

class GeneMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //세대별 선호하는 키워드 랭킹 뷰
    let KeyListDic = ["교통", "교육", "의료", "관광", "금융", "식품"]    
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var total : [KeyWordList] = []
    var array1 : [KeyWordList] = []
    var array2 : [KeyWordList] = []
    var pickOption = ["20대", "30대", "40대", "50대"]
    
    @IBOutlet weak var myKeyword: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference() // connect
        setList()
        // Do any additional setup after loading the view.
    }
    func setList() {
        for i in 0...pickOption.count-1 { // 두 번 돈다.
            handle = ref?.child("Generation").child(pickOption[i]).observe(.childAdded, with: { (snapshot) in
                
                if let item = snapshot.value as? [String : String] {
                    self.array1.append(KeyWordList(name: snapshot.key, count: Int(item["KeyValue"]!)!))
                }
                if self.array1.count == self.KeyListDic.count {
                    self.total.append(self.KeyCountSort(self.array1))
                    self.array1 = []
                    if i == self.pickOption.count-1 {
                        self.myKeyword.reloadData()
                    }
                }
                
            })
            
        }
    }
    func KeyCountSort(_ array : [KeyWordList]) -> KeyWordList {
        var ss = array
        for i in (1...KeyListDic.count-1).reversed() { // 버블 횟수
            for j in 0...i-1 {
                if ss[j].count > ss[j+1].count { //맨 앞값이 크면 계속하기
                    continue
                }
                else if ss[j].count < ss[j+1].count { // 그다음 값이 크게 되면 자리 바꾸기
                    swap(&ss[j], &ss[j+1])
                }
            }
        }
        
        return ss[0]
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return total.count
        }
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = myKeyword.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let label = cell.viewWithTag(1) as? UILabel
            label?.text = "\(pickOption[indexPath.row]) : \(total[indexPath.row].name)"
            label?.font = UIFont(name: "THECandybar", size: 20)
            label?.adjustsFontSizeToFitWidth = true
            return cell
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
