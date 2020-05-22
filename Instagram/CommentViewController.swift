//
//  CommentViewController.swift
//  Instagram
//
//  Created by 0003 QBS on 2020/05/11.
//  Copyright © 2020 0003.kaori. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {

    // 格納データ用の配列を設定する
    var postData: PostData!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    // コメント投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func commentPostButton(_ sender: Any) {

        print("DEBUG_PRINT: commentPostButtonボタンがタップされました。")
        
        // FireStoreに投稿データを保存する
        let commentname = Auth.auth().currentUser?.displayName
        
        // コメントの投稿を配列に追加する
        let postDic = [
            "commentname": commentname!,
            "comment": self.commentTextField.text!,
            ] as [String : Any]
        
        print("DEBUG_PRINT: postDic", postDic)
        
        // 投稿データの保存場所を定義する
        var updateValue: FieldValue
        updateValue = FieldValue.arrayUnion([postDic])
        // postDicのアップデート処理（どの投稿（postData.id）かと紐付ける）
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
        
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()

        // postDicに更新データを書き込む
        postRef.updateData(["comments": updateValue])
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "コメント投稿しました")
        // 投稿処理が完了したので先頭画面に戻る
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func commentCancelButton(_ sender: Any) {
        // ホーム画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
