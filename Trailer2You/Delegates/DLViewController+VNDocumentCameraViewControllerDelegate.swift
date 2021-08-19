//
//  DLViewController+ImagScannerDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import VisionKit
import PDFKit

extension DLViewController : VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let pdf = PDFDocument()
        let pdfPage = PDFPage(image: scan.imageOfPage(at: 0))
        pdf.insert(pdfPage!, at: 0)
        self.licenseScanData = pdf.dataRepresentation()?.base64EncodedString()
        self.addScanButton.setTitle("View Scan", for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
