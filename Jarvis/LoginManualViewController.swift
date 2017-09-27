//
//  LoginManualViewController.swift
//  Jarvis
//
//  Created by 박주영 on 2017. 9. 20..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit

class LoginManualViewController: UIViewController {
    //로그인 설명 뷰
    @IBOutlet weak var manualLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        manualLb.text = "회원가입/로그인 화면 : 아이디는 이메일 형식으로 생성해야합니다.(인증 필요 없어요.)        비밀번호는 8자 이상으로 생성 가능 합니다.                                                  '별명'은 별명 로그인 클릭시 사용자들의 전체 별명들이 뜹니다.                                           자신의 별명 선택하고 2차 비밀번호 입력하면 로그인이 더 쉽게 가능합니다. "
        manualLb.numberOfLines = 0
        manualLb.adjustsFontSizeToFitWidth = true
        manualLb.textColor = UIColor.white
        manualLb.backgroundColor = UIColor(r: 64, g: 65, b: 66)
        manualLb.frame = CGRect(x: self.view.frame.x, y: self.view.frame.y, w: self.view.frame.w, h:250 )
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
