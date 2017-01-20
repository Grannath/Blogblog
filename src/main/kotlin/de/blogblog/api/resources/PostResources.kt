package de.blogblog.api.resources

import de.blogblog.api.PostsController
import de.blogblog.model.Post
import org.springframework.hateoas.Resources
import org.springframework.hateoas.core.Relation
import org.springframework.hateoas.mvc.ControllerLinkBuilder
import java.time.ZonedDateTime

/**
 * Created by Johannes on 12.01.2017.
 */
@Relation(value = "post", collectionRelation = "posts")
class PostResource(var title: String,
                   var content: String,
                   var author: String,
                   var created: ZonedDateTime) : ResourceWithEmbeddeds() {

    constructor(post: Post) : this(post.title,
                                   post.content,
                                   post.author,
                                   post.created)
}

fun Post.asResource(): PostResource {
    val res = PostResource(this)
    res.add(ControllerLinkBuilder
                    .linkTo(PostsController::class.java)
                    .slash(staticLink)
                    .withSelfRel())
    return res
}

fun List<Post>.asEmbeddedResource(): Resources<PostResource> {
    return Resources(map(Post::asResource))
}