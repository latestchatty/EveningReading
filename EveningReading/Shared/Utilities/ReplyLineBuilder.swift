//
//  ReplyLineBuilder.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/6/21.
//

import Foundation

class ReplyLineBuilder {
    
    static func getLines(post: ChatPosts, thread: ChatThread) -> String {
        // -------------------- //
        // ReplyLines.ttf       //
        // 'A' is a junction    //
        // 'B' is a passthrough //
        // 'C' is an end        //
        // -------------------- //
        var replyLine = ""

        // root post
        if post.parentId == post.threadId {
            if self.isLastReplyInHeirchy(postId: post.id, thread: thread) {
                replyLine = "C"
            } else {
                replyLine = "A"
            }
        } else {
            replyLine = ""
        }
        
        // not root post
        if post.parentId != post.threadId {
            var postId = post.id
            var replyLineDepth = 0
            while thread.posts.filter({ return $0.id == postId }).count > 0 {
                // going from right to left (stop at root post or first child)
                if postId != post.threadId && postId > 0 {
                    // if depth is zero then it is the right-most line
                    if replyLineDepth == 0 {
                        if self.isLastReplyInHeirchy(postId: postId, thread: thread) {
                            replyLine = replyLine + "C"
                        } else {
                            replyLine = replyLine + "A"
                        }
                    } else {
                        if self.isLastReplyInHeirchy(postId: postId, thread: thread) {
                            replyLine = " " + replyLine
                        } else {
                            replyLine = "B" + replyLine
                        }
                    }
                    replyLineDepth = replyLineDepth + 1
                }
                // get the next postId up the heirchy
                postId = thread.posts.filter({ return $0.id == postId })[0].parentId
            }
        }
            
        return replyLine
    }
    
    static func isLastReplyInHeirchy(postId: Int, thread: ChatThread) -> Bool {
        let post = thread.posts.filter({ return $0.id == postId })
        if post.count > 0 {
            let posts = thread.posts.filter({ return $0.parentId == post[0].parentId })
            let postsSorted = posts.sorted(by: { $0.id < $1.id })
            if postsSorted[postsSorted.count-1].id == postId {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

}
