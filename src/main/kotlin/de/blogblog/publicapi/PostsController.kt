package de.blogblog.publicapi

import de.blogblog.jooq.tables.BlPosts.BL_POSTS
import de.blogblog.jooq.tables.BlUsers.BL_USERS
import de.blogblog.model.Post
import org.jooq.DSLContext
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

/**
 * Created by Johannes on 05.11.2016.
 */
@RestController
@RequestMapping("/public/posts")
open class PostsController(val create: DSLContext) {

    companion object {
        val pageSize = 10
    }

    @GetMapping(path = arrayOf("/"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPostsForPage(@RequestParam("page",
                                           required = false) page: Int?): List<Post> {
        return create
                .select(*Post.fields)
                .from(BL_POSTS)
                .join(BL_USERS)
                .onKey(BL_POSTS.AUTHOR)
                .orderBy(BL_POSTS.CREATED.desc())
                .limit(pageSize)
                .offset((page ?: 0) * pageSize)
                .fetchInto(Post::class.java)
    }

    @GetMapping(path = arrayOf("/{id}"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPostForId(@PathVariable id: Int): Post {

        return create.select(*Post.fields)
                     .from(BL_POSTS)
                     .join(BL_USERS)
                     .onKey(BL_POSTS.AUTHOR)
                     .where(BL_POSTS.ID.eq(id))
                     .fetchOneInto(Post::class.java)
               ?: throw NoSuchPostException("No post found with ID $id.")
    }
}

@ResponseStatus(value = HttpStatus.NOT_FOUND)
class NoSuchPostException : RuntimeException {
    constructor(message: String, vararg params: Any?) : super(message.format(params))

    constructor(message: String, vararg params: Any?, cause: Exception) : super(message.format(params), cause)
}