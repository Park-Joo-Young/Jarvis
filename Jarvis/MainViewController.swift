//
//  MainViewController.swift
//  Jarvis
//
//  Created by 박주영 on 2017. 8. 23..
//  Copyright © 2017년 apple. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FlexiblePageControl
import SnapKit

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate
{ //4차 산업혁명 전체 뉴스 뷰
    let headers = ["X-Naver-Client-Id" : "jhTqCNNdUtuebI3LyVmL", "X-Naver-Client-Secret" : "PBTEyPTMMh"]
    var address : String!
    var Books : [[String : String]] = []
    let display = 1
    var pageCount : Int = 1
    var pageControl = FlexiblePageControl()
    var manualBtn = UIButton()
    
    
    var back = UIImageView()
    var webView = UIWebView()
    var monitor = UIImageView()

    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            pageCount = pageCount + 1
            Search(pageCount)
            pageControl.currentPage = pageCount-1
            
        }
        if (sender.direction == .right) {
            if pageCount >= 2{
                pageCount = pageCount-1
                Search(pageCount)
                pageControl.currentPage = pageCount-1
            } else {
                pageCount = 1
                Search(pageCount)
                pageControl.currentPage = 0
            }
            
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        back = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        monitor = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.view.frame.height/2)))
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: monitor.frame.width, height: monitor.frame.height))
        pageControl.frame = CGRect(x: 167, y: 30, w: 39, h: 37)
        
        back.image = UIImage(named: "star.jpeg")
        monitor.image = UIImage(named: "monitor1.png")
        self.view.insertSubview(back, belowSubview: self.view)
        self.view.insertSubview(webView, aboveSubview: monitor)
        self.view.insertSubview(monitor, belowSubview: webView)
        self.view.insertSubview(pageControl, aboveSubview: self.view)
        pageControl.numberOfPages = 100
        view.addSubview(pageControl)
        webView.layer.cornerRadius = 5
        webView.clipsToBounds = true
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        self.view!.addGestureRecognizer(leftSwipe)
        self.view!.addGestureRecognizer(rightSwipe)
        webView.scrollView.panGestureRecognizer.require(toFail: rightSwipe)
        webView.scrollView.panGestureRecognizer.require(toFail: leftSwipe)
        webView.scalesPageToFit = true
        
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(monitor.snp.top).offset(22)
            make.left.equalTo(monitor.snp.left).offset(20)
            make.right.equalTo(monitor.snp.right).offset(-20)
            make.bottom.equalTo(monitor.snp.bottom).offset(-50)
        }
        monitor.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(50)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view.snp.bottom).offset(-50)
        }
        pageControl.snp.makeConstraints{(make) in
            make.top.equalTo(self.view).offset(20)
            make.centerX.equalTo(self.view.snp.centerX)
        }

        // Updated to the minimum size according to the displayCount
        pageControl.updateViewSize()
        pageControl.dotSize = 6
        pageControl.dotSpace = 5
        
        pageControl.displayCount = 6
        
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        Search(pageCount)

    }
    
    func Search(_ pageCount : Int) {
        let str = "https://openapi.naver.com/v1/search/news.json?query=4차 산업혁명&display=\(display)&start=\(pageCount)&sort=date"
        let strFo = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: strFo!)
        Alamofire.request(url!, method: .get, headers: headers).responseJSON { (reponsedata) -> Void in
            if ((reponsedata.result.value) != nil) {
                print("parsing Success")
                let swiftyJsonVar = JSON(reponsedata.result.value!)
                if let resdata = swiftyJsonVar["items"].arrayObject {
                    self.Books = resdata as! [[String : String]]
                    
                    
                    var dic = self.Books[0]
                    
                    dic["originallink"] = dic["originallink"]?.replacingOccurrences(of: "amp;", with: "")
                    
                    if let url = URL(string: dic["originallink"]!) {
                        let request = URLRequest(url: url)
                        self.webView.loadRequest(request)
                    }
                    
                }
                
            }
        }
    }
}

