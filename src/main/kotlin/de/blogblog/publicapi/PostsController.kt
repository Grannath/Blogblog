package de.blogblog.publicapi

import de.blogblog.model.*
import org.jooq.DSLContext
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime
import java.time.ZoneId

/**
 * Created by Johannes on 05.11.2016.
 */
@RestController
@RequestMapping("/public/posts")
open class PostsController(val create: DSLContext) {

    companion object {
        val defaultPageSize = 10
    }

    @GetMapping(path = arrayOf(""),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPosts(@RequestParam("pageSize",
                                    required = false) pageSize: Int?,
                      zone: ZoneId?): List<Post> {
        return create.selectPosts(pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
    }

    @GetMapping(path = arrayOf("/next"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getNextPosts(@RequestParam("pageSize",
                                        required = false) pageSize: Int?,
                          @RequestParam("from") from: LocalDateTime,
                          zone: ZoneId?): List<Post> {
        return create.selectNextPosts(from.toInstant(zone ?: ZoneId.systemDefault()),
                                      pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
    }

    @GetMapping(path = arrayOf("/previous"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPreviousPosts(@RequestParam("pageSize",
                                            required = false) pageSize: Int?,
                              @RequestParam("from") from: LocalDateTime,
                              zone: ZoneId?): List<Post> {
        return create.selectPreviousPosts(from.toInstant(zone ?: ZoneId.systemDefault()),
                                          pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
    }

    @GetMapping(path = arrayOf("/{id}"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPostForId(@PathVariable id: Int, zone: ZoneId?): Post {

        return create.selectPost(id)
                       .fetchOne(intoPost(zone ?: ZoneId.systemDefault()))
               ?: throw NoSuchPostException("No post found with ID $id.")
    }
}

fun LocalDateTime.toInstant(zone: ZoneId) = atZone(zone).toInstant()

@ResponseStatus(value = HttpStatus.NOT_FOUND)
class NoSuchPostException : RuntimeException {
    constructor(message: String, vararg params: Any?) : super(message.format(
            params))

    constructor(message: String, vararg params: Any?, cause: Exception) : super(
            message.format(params),
            cause)
}