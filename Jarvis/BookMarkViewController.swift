//
//  BookMarkViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 16..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit

class BookMarkViewController: UIViewController {
    // 즐겨찾기 뉴스뷰
    @IBOutlet weak var navi: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    var address : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "THECandybar", size: 30)!]
        if let url = URL(string: address!) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        // Do any additional setup after loading the view.
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
