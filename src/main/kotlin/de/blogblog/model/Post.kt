package de.blogblog.model

import de.blogblog.jooq.tables.BlPosts
import de.blogblog.jooq.tables.BlUsers
import java.time.LocalDateTime

/**
 * Created by Johannes on 05.11.2016.
 */
data class Post(val id: Int,
                val title: String,
                val content: String,
                val author: String,
                val created: LocalDateTime) {
    companion object {
        val fields = arrayOf(BlPosts.BL_POSTS.ID,
                             BlPosts.BL_POSTS.TITLE,
                             BlPosts.BL_POSTS.CONTENT,
                             BlUsers.BL_USERS.USERNAME,
                             BlPosts.BL_POSTS.CREATED)
    }
}