import UIKit

enum OfficeStyle: Int, CaseIterable {
    case lofi = 0
    case casual
    
    var name: String {
        switch self {
        case .lofi:
            return "lo-fi"
        case .casual:
            return "casual"
        }
    }
    
    var bgImage: UIImage {
        switch self {
        case .lofi:
            return Images.Office.Lofi.bg
        case .casual:
            return Images.Office.Casual.bg
        }
    }
    
    var deskImage: UIImage {
        switch self {
        case .lofi:
            return Images.Office.Lofi.desk
        case .casual:
            return Images.Office.Casual.desk
        }
    }
}
