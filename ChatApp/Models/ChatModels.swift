import UIKit
import MessageKit
import Foundation
import CoreLocation

struct Message: MessageType
{
    public var sender: any MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

extension MessageKind
{
    var messageKindString: String
    {
        switch self
        {
        case .text(_): return "text"
        case .attributedText(_): return "attributed_ text"
        case .photo(_): return "photo"
        case .video(_): return "video"
        case .location(_): return "location"
        case .emoji(_): return "emoji"
        case .audio(_): return "audio"
        case .contact(_): return "contact"
        case .linkPreview(_): return "linkPreview"
        case .custom(_): return "custom"
        }
    }
}

struct Sender: SenderType
{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem
{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem
{
    var location: CLLocation
    var size: CGSize
}
