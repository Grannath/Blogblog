package de.blogblog.api

import de.blogblog.api.resources.PostResource
import de.blogblog.api.resources.asEmbeddedResource
import de.blogblog.api.resources.asResource
import de.blogblog.jooq.tables.BlPosts.BL_POSTS
import de.blogblog.model.Post
import de.blogblog.model.intoPost
import de.blogblog.model.selectPost
import org.jooq.DSLContext
import org.jooq.Record
import org.jooq.SelectConditionStep
import org.jooq.SelectWhereStep
import org.jooq.impl.DSL.select
import org.springframework.hateoas.ExposesResourceFor
import org.springframework.hateoas.Link
import org.springframework.hateoas.Resources
import org.springframework.hateoas.mvc.ControllerLinkBuilder.linkTo
import org.springframework.http.HttpStatus
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.bind.annotation.*
import org.springframework.web.util.UriComponentsBuilder
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

/**
 * Created by Johannes on 05.11.2016.
 */
@RestController
@ExposesResourceFor(PostResource::class)
@RequestMapping("/api/posts")
@Transactional
class PostsController(private val create: DSLContext) {

    @GetMapping(path = arrayOf(""),
                produces = arrayOf("application/json",
                                   "application/hal+json",
                                   "text/plain"))
    fun showAll(@RequestParam(name = "pageSize",
                              defaultValue = "10") pageSize: Int,
                @RequestParam(name = "olderThan",
                              required = false) olderThan: ZonedDateTime?,
                @RequestParam(name = "newerThan",
                              required = false) newerThan: ZonedDateTime?,
                zoneId: ZoneId): Resources<PostResource> {
        return if (olderThan != null)
            olderPosts(olderThan, newerThan, pageSize, zoneId)
        else if (newerThan != null)
            newerPosts(newerThan, olderThan, pageSize, zoneId)
        else
            firstPosts(pageSize, zoneId)
    }

    private fun olderPosts(from: ZonedDateTime,
                           newerThan: ZonedDateTime?,
                           pageSize: Int,
                           zoneId: ZoneId): Resources<PostResource> {
        val resources = create.selectPost()
                .visibleOnly()
                .andNewerThan(newerThan)
                .orderBy(BL_POSTS.CREATED.desc())
                .seek(from)
                .limit(pageSize)
                .fetch(intoPost(zoneId))
                .asEmbeddedResource()

        resources.add(linkToFirstPosts())

        val nextFrom = resources.oldest() ?: newerThan
        if (nextFrom != null && hasPostsOlderThan(nextFrom))
            resources.add(linkToOlderPosts(nextFrom, pageSize))

        if (hasPostsNewerThan(from))
            resources.add(linkToNewerPosts(from, pageSize))

        return resources
    }

    private fun newerPosts(from: ZonedDateTime,
                           olderThan: ZonedDateTime?,
                           pageSize: Int,
                           zoneId: ZoneId): Resources<PostResource> {
        val resources = create.selectPost()
                .visibleOnly()
                .andOlderThan(olderThan)
                .orderBy(BL_POSTS.CREATED.asc())
                .seek(from)
                .limit(pageSize)
                .fetch(intoPost(zoneId))
                .asEmbeddedResource()

        resources.add(linkToFirstPosts())

        if (hasPostsOlderThan(from))
            resources.add(linkToOlderPosts(from, pageSize))

        val prevFrom = resources.newest() ?: olderThan
        if (prevFrom != null && hasPostsNewerThan(prevFrom))
            resources.add(linkToNewerPosts(prevFrom, pageSize))

        return resources
    }

    private fun firstPosts(pageSize: Int,
                           zoneId: ZoneId): Resources<PostResource> {
        val resources = create.selectPost()
                .visibleOnly()
                .orderBy(BL_POSTS.CREATED.desc())
                .limit(pageSize)
                .fetch(intoPost(zoneId))
                .asEmbeddedResource()

        resources.add(linkToFirstPosts().withSelfRel())

        val nextFrom = resources.oldest()
        if (nextFrom != null && hasPostsOlderThan(nextFrom))
            resources.add(linkToOlderPosts(nextFrom, pageSize))

        return resources
    }


    private fun hasPostsOlderThan(from: ZonedDateTime) =
            create.selectZero()
                    .whereExists(postsOlderThan(from))
                    .fetch()
                    .isNotEmpty


    private fun hasPostsNewerThan(from: ZonedDateTime) =
            create.selectZero()
                    .whereExists(postsNewerThan(from))
                    .fetch()
                    .isNotEmpty


    @GetMapping(path = arrayOf("/{title}"),
                produces = arrayOf("application/json",
                                   "application/hal+json",
                                   "text/plain"))
    fun showPost(@PathVariable("title") title: String,
                 zoneId: ZoneId): PostResource {
        return create.selectPost()
                .where(BL_POSTS.STATIC_LINK.eq(title))
                .fetch(intoPost(zoneId))
                .map(Post::asResource)
                .oneOrFailure()
    }
}

// Select helper

private fun Resources<PostResource>.oldest() =
        minBy { it.created }?.created

private fun Resources<PostResource>.newest() =
        maxBy { it.created }?.created

private fun postsOlderThan(from: ZonedDateTime) =
        select(BL_POSTS.ID)
                .from(BL_POSTS)
                .visibleOnly()
                .and(BL_POSTS.CREATED.lt(from))

private fun postsNewerThan(from: ZonedDateTime) =
        select(BL_POSTS.ID)
                .from(BL_POSTS)
                .visibleOnly()
                .and(BL_POSTS.CREATED.gt(from))

private fun <R : Record> SelectWhereStep<R>.visibleOnly() =
        where(BL_POSTS.HIDDEN.eq(false))

private fun <R : Record> SelectConditionStep<R>.andOlderThan(from: ZonedDateTime?) =
        let {
            if (from != null)
                and(BL_POSTS.CREATED.le(from))
            else
                this
        }

private fun <R : Record> SelectConditionStep<R>.andNewerThan(from: ZonedDateTime?) =
        let {
            if (from != null)
                and(BL_POSTS.CREATED.ge(from))
            else
                this
        }

private fun List<PostResource>.oneOrFailure() =
        if (size == 1)
            first()
        else if (size > 1)
            throw NonUniqueQueryException("More than one post found.")
        else
            throw NoSuchPostException("No post found.")

// Link helper

private fun UriComponentsBuilder.withRel(rel: String) =
        Link(toUriString(), rel)


private fun linkToFirstPosts() =
        linkTo(PostsController::class.java)
                .withRel(Link.REL_FIRST)!!

private fun linkToOlderPosts(from: ZonedDateTime,
                             pageSize: Int): Link {
    return linkTo(PostsController::class.java)
            .toUriComponentsBuilder()
            .queryParam("pageSize", pageSize)
            .queryParam("olderThan",
                        DateTimeFormatter.ISO_OFFSET_DATE_TIME
                                .format(from))
            .withRel(Link.REL_NEXT)
}

private fun linkToNewerPosts(from: ZonedDateTime,
                             pageSize: Int): Link {
    return linkTo(PostsController::class.java)
            .toUriComponentsBuilder()
            .queryParam("pageSize", pageSize)
            .queryParam("newerThan",
                        DateTimeFormatter.ISO_OFFSET_DATE_TIME
                                .format(from))
            .withRel(Link.REL_PREVIOUS)
}

// Exceptions

@ResponseStatus(value = HttpStatus.NOT_FOUND)
class NoSuchPostException : RuntimeException {
    constructor(message: String, vararg params: Any?) : super(message.format(
            params))
}

@ResponseStatus(value = HttpStatus.NOT_FOUND)
class NonUniqueQueryException : RuntimeException {
    constructor(message: String, vararg params: Any?) : super(message.format(
            params))
}