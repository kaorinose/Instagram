//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 0003 QBS on 2020/05/08.
//  Copyright © 2020 0003.kaori. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        // 画像ダウンロード中のグレーのくるくる回るアイコンを指定
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        // 自動的に指定場所から画像をダウンロードしてUIImageViewに表示（2回目以降の表示はキャッシュを使用）
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"

        // 日時の表示（DateFormatterで文字列に変換）
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
            
        }

        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示（UIButtonクラスのsetImage(_:for:)メソッドを使用して、ボタンの画像を変更）
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        //コメントの表示
        // コメント格納用の配列allCommentを空に設定する
        var allComment = ""
        var commentLiv2 = ""
        // コメントラベルに複数行の表示が行えるように設定する
        commentLabel.numberOfLines = 0;
        // postData.commentsの中から要素を１行ずつ取り出しcommentLivへ格納後、表示に合わせて要素を取り出す
        for commentLiv in postData.comments{
            commentLiv2 = "\(commentLiv["commentname"]!) ： \(commentLiv["comment"]!)"
            // 複数のコメントがある場合に「コメント入力者名 : コメント内容」の形の文字列にし、
            // それに改行を加えながら全てのコメントを全てallCommentに入れる
            allComment += (commentLiv2 + "\n")
            // allCommentの内容をcommentLabelに表示する
            self.commentLabel.text = allComment
        }
        
    }
    
}
