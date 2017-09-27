//
//  LoadingViewController.swift
//  Jarvis
//
//  Created by apple on 2017. 8. 23..
//  Copyright © 2017년 apple. All rights reserved.
//


import UIKit
import AVFoundation
import SnapKit

class LoadingViewController: UIViewController { //로딩 뷰
    
    
    var lavel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(lavel)
        lavel.text = "JarVis"
        lavel.font = UIFont(name: "THECandybar", size: 50)
        lavel.tintColor = UIColor.black
        lavel.adjustsFontSizeToFitWidth = true
        lavel.snp.makeConstraints { (make) in
            make.size.equalTo(self.view.frame.width/2)
            make.top.equalTo(self.view.snp.top).offset(20)
            make.centerX.equalTo(self.view.snp.centerX).offset(10)
        }
        lavel.alpha = 0
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        let synthesizer = AVSpeechSynthesizer()
        let speaktext = "안녕하세요 자비스입니다."
        let utterence = AVSpeechUtterance(string: speaktext)
        utterence.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterence.rate = 0.4
        synthesizer.speak(utterence)
        
        UIView.animate(withDuration: 3.0, animations: ({
            self.lavel.alpha = 1
        }))
        if Config.IS_SKIP_LOADING_VIEW { //테스트용 자동 로딩
            self.performSegue(withIdentifier: "Loading", sender: self)
            return
        }
        
        LoadingHUD.show()
        
        let when = DispatchTime.now() + 5// change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            LoadingHUD.hide()
            self.performSegue(withIdentifier: "Loading", sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class LoadingHUD: NSObject {
    private static let sharedInstance = LoadingHUD()
    private var popupView: UIImageView?
    
    class func show() {
        
        let popupView = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
        popupView.backgroundColor = UIColor.white
        popupView.animationImages = LoadingHUD.getAnimationImageArray()
        popupView.animationDuration = 3.0
        popupView.animationRepeatCount = 0
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(popupView)
            popupView.center = window.center
            popupView.startAnimating()
            sharedInstance.popupView?.removeFromSuperview()
            sharedInstance.popupView = popupView
        }
    }
    
    class func hide() {
        if let popupView = sharedInstance.popupView {
            popupView.stopAnimating()
            popupView.removeFromSuperview()
        }
        
    }
    
    class func getAnimationImageArray() -> [UIImage] {
        var animationArray: [UIImage] = []
        animationArray.append(UIImage(named: "banking.png")!)
        animationArray.append(UIImage(named: "books.png")!)
        animationArray.append(UIImage(named: "car.png")!)
        animationArray.append(UIImage(named: "pill.png")!)
        animationArray.append(UIImage(named: "tour.png")!)
        animationArray.append(UIImage(named: "food.png")!)
        return animationArray
    }
}
