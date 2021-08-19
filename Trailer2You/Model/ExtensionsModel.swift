//
//  ExtensionsModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

func convertToImage(str64: String?) -> UIImage? {
    if str64 == nil {
        return nil
    }
    let dataDecoded : Data = Data(base64Encoded: str64!, options: .ignoreUnknownCharacters)!
    let decodedimage = UIImage(data: dataDecoded)
    return decodedimage
}
