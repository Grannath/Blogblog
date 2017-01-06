package de.blogblog

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.web.ErrorViewResolver
import org.springframework.boot.builder.SpringApplicationBuilder
import org.springframework.context.annotation.Bean
import org.springframework.core.convert.converter.Converter
import org.springframework.http.HttpStatus
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.web.servlet.ModelAndView
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAccessor
import java.time.temporal.TemporalQuery

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

    @Bean open fun zonedDateTimeParser(): Converter<String, ZonedDateTime> {
        return Converter { source ->
            ZonedDateTime.from(
                    DateTimeFormatter.ISO_DATE_TIME
                            .parseBest(source,
                                       TemporalQuery(::fromZone),
                                       TemporalQuery(::fromOffset),
                                       TemporalQuery(::fromLocal)))
        }
    }

    @Bean open fun notFoundHandler(): ErrorViewResolver {
        val logger = LoggerFactory.getLogger("NotFoundHandler")
        return ErrorViewResolver { request, status, model ->
            if (status == HttpStatus.NOT_FOUND) {
                logger.warn("404 error caught, redirecting to index.html")
                ModelAndView("index.html")
            } else {
                null
            }
        }
    }

}

private fun fromZone(access: TemporalAccessor) =
        ZonedDateTime.from(access)!!

private fun fromOffset(access: TemporalAccessor) =
        OffsetDateTime.from(access)
                .atZoneSameInstant(
                        ZoneId.systemDefault())!!

private fun fromLocal(access: TemporalAccessor) =
        LocalDateTime.from(access).atZone(
                ZoneId.systemDefault())!!

fun main(args: Array<String>) {
    val userHome = System.getProperty("user.home")
    SpringApplicationBuilder(BlogblogApplication::class.java)
            .properties("spring.config.location=file:$userHome/blogblog/")
            .run(*args)
}
