package de.blogblog.model

import de.blogblog.jooq.tables.BlPosts.BL_POSTS
import de.blogblog.jooq.tables.BlUsers.BL_USERS
import org.jooq.DSLContext
import org.jooq.Record
import java.sql.Timestamp
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

/**
 * Created by Johannes on 05.11.2016.
 */
data class Post(val id: Int,
                val title: String,
                val content: String,
                val author: String,
                val created: LocalDateTime) {

    companion object {
        val fields = arrayOf(BL_POSTS.ID,
                             BL_POSTS.TITLE,
                             BL_POSTS.CONTENT,
                             BL_USERS.USERNAME,
                             BL_POSTS.CREATED)
    }
}

data class PostPage(val page: Int,
                    val numberPages: Int,
                    val posts: List<Post>)

fun intoPost(zone: ZoneId) = {
    rec: Record ->
    Post(rec.getId(),
         rec.getTitle(),
         rec.getContent(),
         rec.getAuthor(),
         rec.getCreated()
                 .toInstant()
                 .toLocalDateTime(zone))
}

fun Record.getId() = this.getValue(BL_POSTS.ID)!!

fun Record.getTitle() = this.getValue(BL_POSTS.TITLE)!!

fun Record.getContent() = this.getValue(BL_POSTS.CONTENT)!!

fun Record.getAuthor() = this.getValue(BL_USERS.USERNAME)!!

fun Record.getCreated() = this.getValue(BL_POSTS.CREATED)!!

fun Timestamp.toInstant() = Instant.ofEpochMilli(time)

fun Instant.toTimestamp() = Timestamp.from(this)

fun Instant.toLocalDateTime(zone: ZoneId) =
        LocalDateTime.ofInstant(this,
                                zone.rules.getOffset(this))

fun DSLContext.selectPosts(pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.desc())
                .limit(pageSize)

fun DSLContext.selectNextPosts(created: Instant, pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.desc())
                .seek(created.toTimestamp())
                .limit(pageSize)

fun DSLContext.selectPreviousPosts(created: Instant,
                                   pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.asc())
                .seek(created.toTimestamp())
                .limit(pageSize)

fun DSLContext.selectPost(id: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.ID.eq(id))
                .orderBy(BL_POSTS.CREATED.desc())
