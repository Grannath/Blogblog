package de.blogblog.model

import de.blogblog.jooq.tables.BlPosts.BL_POSTS
import de.blogblog.jooq.tables.BlUsers.BL_USERS
import org.jooq.DSLContext
import org.jooq.Record
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * Created by Johannes on 05.11.2016.
 */
data class Post(val id: Int,
                val title: String,
                val staticLink: String,
                val content: String,
                val author: String,
                val created: ZonedDateTime) {

    companion object {
        val fields = arrayOf(BL_POSTS.ID,
                             BL_POSTS.TITLE,
                             BL_POSTS.STATIC_LINK,
                             BL_POSTS.CONTENT,
                             BL_USERS.USERNAME,
                             BL_POSTS.CREATED)
    }

    fun shortened() =
            copy(content = short(this.content))

    private fun short(full: String) =
            if (full.countWords() < 200) full
            else full.firstParagraph()

    private fun String.countWords() = split(' ', '\n').size

    private fun String.firstParagraph() = splitToSequence("\n\n").first()

}

fun intoPost(zone: ZoneId) = {
    rec: Record ->
    Post(rec.getId(),
         rec.getTitle(),
         rec.getStaticLink(),
         rec.getContent(),
         rec.getAuthor(),
         rec.getCreated()
                 .withZoneSameInstant(zone))
}

private fun Record.getId() = this.getValue(BL_POSTS.ID)!!

private fun Record.getTitle() = this.getValue(BL_POSTS.TITLE)!!

private fun Record.getStaticLink() = this.getValue(BL_POSTS.STATIC_LINK)!!

private fun Record.getContent() = this.getValue(BL_POSTS.CONTENT)!!

private fun Record.getAuthor() = this.getValue(BL_USERS.USERNAME)!!

private fun Record.getCreated() = this.getValue(BL_POSTS.CREATED)!!

fun DSLContext.selectPosts(pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.desc())
                .limit(pageSize)!!

fun DSLContext.selectOlderPosts(created: ZonedDateTime, pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.desc())
                .seek(created)
                .limit(pageSize)!!

fun DSLContext.selectNewerPosts(created: ZonedDateTime,
                                pageSize: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.HIDDEN.eq(false))
                .orderBy(BL_POSTS.CREATED.asc())
                .seek(created)
                .limit(pageSize)!!

fun DSLContext.selectPost(id: Int) =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .where(BL_POSTS.ID.eq(id))
                .orderBy(BL_POSTS.CREATED.desc())!!

fun DSLContext.selectPost() =
        this.select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
