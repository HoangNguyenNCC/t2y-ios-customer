//
//  PDFViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var pdfContainer: UIView!
    
    var pdfView = PDFView()
    var pdfData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        pdfView.frame = pdfContainer.bounds
        pdfContainer.addSubview(pdfView)
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: pdfData)
    }

    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
