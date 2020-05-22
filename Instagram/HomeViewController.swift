//
//  HomeViewController.swift
//  Instagram
//
//  Created by 0003 QBS on 2020/04/28.
//  Copyright © 2020 0003.kaori. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー（Firestoreのデータ更新の監視を行う）
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                // データベースの参照場所と取得順序を指定したクエリを作成
                // Firestoreの postsフォルダに格納されているドキュメントを投稿日時の新しい順に取得
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                // ドキュメントが追加されたり更新されたりするたびに何度も呼び出される
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    // mapメソッドは配列の要素を変換して新しい配列を作成
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する（いいね、コメント）
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(handle2Button(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    // セル内の「いいねボタン」がタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        // UITouch型のタッチ情報を取り出す
        let touch = event.allTouches?.first
        // タッチした座標(TableView内の座標)を割り出す
        let point = touch!.location(in: self.tableView)
        // タッチした座標がtableView内のどのindexPath位置になるのかを取得
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    // セル内の「コメントボタン」がタップされた時に呼ばれるメソッド
    @objc func handle2Button(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました。")

        // タップされたセルのインデックスを求める
        // UITouch型のタッチ情報を取り出す
        let touch = event.allTouches?.first
        // タッチした座標(TableView内の座標)を割り出す
        let point = touch!.location(in: self.tableView)
        // タッチした座標がtableView内のどのindexPath位置になるのかを取得
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // コメント入力画面に遷移
        let CommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        CommentViewController.postData = postData
        present(CommentViewController, animated: true, completion: nil)
        
    }
    
}
