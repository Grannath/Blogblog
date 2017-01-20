package de.blogblog.api.resources

import com.fasterxml.jackson.annotation.JsonUnwrapped
import org.springframework.hateoas.ResourceSupport
import org.springframework.hateoas.Resources
import org.springframework.hateoas.core.EmbeddedWrapper


/**
 * Created by Johannes on 12.01.2017.
 */
abstract class ResourceWithEmbeddeds : ResourceSupport() {

    // The @JsonUnwrapped annotation is required as EmbeddedWrappers are by default serialised in a "_embedded" container,
    // that has to be added directly into the top level object
    @JsonUnwrapped var embeddeds: Resources<EmbeddedWrapper>? = null
}
