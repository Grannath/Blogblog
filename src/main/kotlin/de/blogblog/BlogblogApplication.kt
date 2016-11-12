package de.blogblog

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.builder.SpringApplicationBuilder
import org.springframework.context.annotation.Bean
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

@SpringBootApplication
open class BlogblogApplication {
    @Bean open fun securityAdapter() =
            object : WebSecurityConfigurerAdapter(false) {
                override open fun configure(http: HttpSecurity) {
                    http.authorizeRequests()
                            .regexMatchers("/.*").anonymous()
                            .anyRequest().authenticated()
                            .and()
                            .httpBasic()
                            .and()
                            .formLogin()
                }
            }
}

fun main(args: Array<String>) {
    val userHome = System.getProperty("user.home")
    SpringApplicationBuilder(BlogblogApplication::class.java)
            .properties("spring.config.location=file:$userHome/blogblog/")
            .run(*args)
}
