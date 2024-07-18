//
//  StorageManager.swift
//  ChatApp
//
//  Created by Umman on 03.07.24.
//

import UIKit
import Foundation
import FirebaseStorage

/// Allows you to get, fetch and upload files to firebase storage
final class StorageManager
{
    static let shared = StorageManager()
    private init() {}
    private let storage = Storage.storage().reference()
    
    /*
     /images/randomuser-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with image: UIImage, fileName: String, completion: @escaping UploadPictureCompletion)
    {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
                    print("Failed to compress image data")
                    completion(.failure(StorageErrors.failedToCompressImage))
                    return
                }
        
        storage.child("images/\(fileName)").putData(imageData, metadata: nil) { [weak self] metadata, error in
            
            guard let strongSelf = self else { return }
           
            guard error == nil else
            {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else
                {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion)
    {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else
            {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else
                {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion)
    {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) { [weak self] metadata, error in
            guard error == nil else
            {
                // failed
                print("failed to upload video file to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else
                {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error
    {
        case failedToUpload
        case failedToGetDownloadUrl
        case failedToCompressImage
    }
    
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void)
    {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else
            {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
}
