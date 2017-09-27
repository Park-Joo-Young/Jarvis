//
//  NewsViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 2..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class NewsViewController: UIViewController {
    //파싱 이후 실제 뉴스 뷰
    @IBOutlet weak var webView: UIWebView!
    var address : String?
    var newsTitle : String?
    var ref : DatabaseReference?
    @IBAction func Favorite(_ sender: UIBarButtonItem) { // 즐겨찾기
        
        let dic = ["title" : "\(newsTitle!)", "URL" : "\(address!)"]
        ref?.child("User").child((Auth.auth().currentUser?.uid)!).child("BookMarks").childByAutoId().setValue(dic) // 해당 url 저장

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference() //connect
        UINavigationBar.appearance().tintColor = UIColor.black
        if let url = URL(string: address!) {
            let request = URLRequest(url: url)
            print(request)
            webView.loadRequest(request)
        }
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
