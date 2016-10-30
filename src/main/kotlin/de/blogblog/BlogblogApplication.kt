package de.blogblog

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.builder.SpringApplicationBuilder

@SpringBootApplication
open class BlogblogApplication

fun main(args: Array<String>) {
    val userHome = System.getProperty("user.home")
    SpringApplicationBuilder(BlogblogApplication::class.java)
            .properties("spring.config.location=file:$userHome/blogblog/")
            .run(*args)
}
