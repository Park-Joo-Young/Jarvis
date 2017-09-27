//
//  KeywordManualViewController.swift
//  Jarvis
//
//  Created by 박주영 on 2017. 9. 20..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit

class KeywordManualViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    //검색 할 수 있는 키워드 설명 뷰
    let KeyListDic = ["교통", "교육", "의료", "관광", "금융", "식품"]    

  

    @IBOutlet weak var myKeyword: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KeyListDic.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myKeyword.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = KeyListDic[indexPath.row]
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
