package de.blogblog.publicapi

import de.blogblog.model.*
import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * Created by Johannes on 05.11.2016.
 */
@RestController
@RequestMapping("/public/posts")
open class PostsController(val create: DSLContext) {

    companion object {
        val defaultPageSize = 10
        private val logger = LoggerFactory.getLogger(javaClass)
    }

    @GetMapping(path = arrayOf("", "/"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPosts(@RequestParam("pageSize",
                                    required = false) pageSize: Int?,
                      zone: ZoneId?): List<Post> {
        logger.debug("Loading {} posts for zone {}.", pageSize, zone)

        return create.selectPosts(pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
                .map(Post::shortened)
                .sortedByDescending(Post::created)
                .apply {
                    logger.debug("Found {} posts from {}.",
                                 size,
                                 map(Post::created))
                }
    }

    @GetMapping(path = arrayOf("/next"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getNextPosts(@RequestParam("pageSize",
                                        required = false) pageSize: Int?,
                          @RequestParam("from") from: ZonedDateTime,
                          zone: ZoneId?): List<Post> {
        logger.debug("Loading next {} posts from {} for zone {}.",
                     pageSize,
                     from,
                     zone)

        return create.selectOlderPosts(from,
                                       pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
                .map(Post::shortened)
                .sortedByDescending(Post::created)
                .apply { logger.debug("Found {} posts.", size) }
    }

    @GetMapping(path = arrayOf("/previous"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPreviousPosts(@RequestParam("pageSize",
                                            required = false) pageSize: Int?,
                              @RequestParam("from") from: ZonedDateTime,
                              zone: ZoneId?): List<Post> {
        logger.debug("Loading previous {} posts from {} for zone {}.",
                     pageSize,
                     from,
                     zone)

        return create.selectNewerPosts(from,
                                       pageSize ?: defaultPageSize)
                .fetch(intoPost(zone ?: ZoneId.systemDefault()))
                .map(Post::shortened)
                .sortedByDescending(Post::created)
                .apply { logger.debug("Found {} posts.", size) }
    }

    @GetMapping(path = arrayOf("/{id}"),
                produces = arrayOf("application/json", "text/plain"))
    open fun getPostForId(@PathVariable id: Int, zone: ZoneId?): Post {
        logger.debug("Loading post {} for zone {}.", id, zone)

        return create.selectPost(id)
                       .fetchOne(intoPost(zone ?: ZoneId.systemDefault()))
               ?: throw NoSuchPostException("No post found with ID $id.")
    }
}

@ResponseStatus(value = HttpStatus.NOT_FOUND)
class NoSuchPostException : RuntimeException {
    constructor(message: String, vararg params: Any?) : super(message.format(
            params))

    constructor(message: String, vararg params: Any?, cause: Exception) : super(
            message.format(params),
            cause)
}