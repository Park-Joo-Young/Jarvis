//
//  MainManualViewController.swift
//  Jarvis
//
//  Created by 박주영 on 2017. 9. 20..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit

class MainManualViewController: UIViewController { // 음성인식 메인 설명 뷰
    
    @IBOutlet weak var manualLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        manualLb.adjustsFontSizeToFitWidth = true
        manualLb.textColor = UIColor.white
        manualLb.backgroundColor = UIColor(r: 64, g: 65, b: 66)
        manualLb.frame = CGRect(x: self.view.frame.x, y: self.view.frame.y, w: self.view.frame.w, h:self.view.frame.h )
        manualLb.snp.makeConstraints{(make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
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
