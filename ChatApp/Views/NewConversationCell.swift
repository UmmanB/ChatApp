//
//  NewConversationCell.swift
//  ChatApp
//
//  Created by Umman on 09.07.24.
//

import UIKit
import SnapKit
import Foundation
import SDWebImage

class NewConversationCell: UITableViewCell
{
    static let identifier = "NewConversationCell"
    
    private let outerBorderView: UIView =
    {
        let view = UIView()
        view.layer.cornerRadius = 45
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.customPurple.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let innerBorderView: UIView =
    {
        let view = UIView()
        view.layer.cornerRadius = 43
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 41
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel =
    {
        let label = UILabel()
        label.font = UIFont(name: "Poppins-Medium", size: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(outerBorderView)
        outerBorderView.addSubview(innerBorderView)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        
        outerBorderView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        innerBorderView.snp.makeConstraints { make in
            make.centerX.equalTo(outerBorderView.snp.centerX)
            make.centerY.equalTo(outerBorderView.snp.centerY)
            make.width.equalTo(86)
            make.height.equalTo(86)
        }
        
        userImageView.snp.makeConstraints { make in
            make.centerX.equalTo(innerBorderView.snp.centerX)
            make.centerY.equalTo(innerBorderView.snp.centerY)
            make.width.equalTo(82)
            make.height.equalTo(82)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(outerBorderView.snp.centerY)
            make.leading.equalTo(outerBorderView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        outerBorderView.layer.cornerRadius = 45
        innerBorderView.layer.cornerRadius = 43
        userImageView.layer.cornerRadius = 41
    }
    
    public func configure(with model: SearchResult)
    {
        userNameLabel.text = model.name
        userImageView.image = nil
        
        let path = "images/\(model.email)_profile_picture.png"
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            switch result
            {
            case .success(let url):
                DispatchQueue.main.async
                {
                    self?.userImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
                        if let error = error 
                        {
                            print("Failed to load image with error: \(error.localizedDescription)")
                            return
                        }
                    
                        UIView.transition(with: self!.userImageView, duration: 0.2, options: .transitionCrossDissolve, animations:
                        {
                            self?.userImageView.image = image
                        }, completion: nil)
                    }
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        }
    }
}
