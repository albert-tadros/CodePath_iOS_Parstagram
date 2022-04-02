//
//  FeedViewController.swift
//  Parstagram
//
//  Created by ALBERT TADROS on 3/25/22.

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    
    @IBOutlet weak var feedTableView: UITableView!
    var postsArray = [PFObject]()
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        commentBar.delegate = self
        feedTableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        commentBar.inputTextView.placeholder = "Add a comment....."
        commentBar.sendButton.title =  "Post"
        // Do any additional setup after loading the view.
    }
    
    
    
    override var inputAccessoryView: UIView?{
        return  commentBar
    }
    override var canBecomeFirstResponder: Bool  {
        return showCommentBar
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // create the comment in the API
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error ) in

            if success {
                print("Comment Saved")
            }
            else {
                print("Can not save comment")
            }
        }
        feedTableView.reloadData()
        
        // Clear and Dismiss the input bar
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) { // to view the new created post in the feed view upon submitting it and dismissing the camera view controller
        super.viewDidAppear(animated)
        
        let author = PFUser.current()
        
        // fetching posts from API for the current user
        let query = PFQuery(className:"Posts")
        query.whereKey("author", equalTo: author!)
        
        
        query.includeKey("author")
        query.includeKey("comments")
        query.includeKey("comments.author")
        query.limit = 20
        query.findObjectsInBackground { (posts, error) in
            if posts != nil { // note the returend posts are as of type PFObject similar to postsArray defined above
                self.postsArray = posts!
                self.feedTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = postsArray[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] // the operator in the middle takes care of the case where comments is nil
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return postsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
//        let currentUserId = PFUser.current()?.objectId
        let post = postsArray[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        
        if indexPath.row == 0 { // this indicates the post row in the current section. We will make  post always to be the 0th row of the section
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string : urlString)!
            cell.postPhotoView.af_setImage(withURL: url)
            return cell
        }else if indexPath.row <= comments.count { // in the following rows of the current section, list the comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as!  CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as? PFUser
            cell.usernameLabel.text = user?.username
            
            return  cell
        }else {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = postsArray[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
//        comment["text"] = "this is a radom comment"
//        comment["post"] = post
//        comment["author"] = PFUser.current()
//
//        post.add(comment, forKey: "comments")
//
//        post.saveInBackground { (success, error ) in
//
//            if success {
//                print("Comment Saved")
//            }
//            else {
//                print("Can not save comment")
//            }
//        }
        
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
//        PFUser.current()
        
        // we  can then dismiss the view which will return to the root of the  navigation in this  case
        //dismiss(animated: true, completion: nil)
        
        // or we can navigate to a specific page upon logging out action, as follows
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "loginViewController")
        
        // this is to access the windows property of the scence delgate class:
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        let window = delegate.window
        window?.rootViewController = loginViewController // set the current app window to the loginviewController, after logging out
        

    }
    
    
}
