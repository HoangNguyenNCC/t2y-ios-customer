//
//  AboutUsViewController.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 20/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import WebKit

class AboutUsViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.trailers2000.com.au/who-we-are")!
        webView.load(URLRequest(url: url))
    }
}
