package de.blogblog

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.ObjectCodec
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.SerializerProvider
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.builder.SpringApplicationBuilder
import org.springframework.boot.jackson.JsonObjectDeserializer
import org.springframework.boot.jackson.JsonObjectSerializer
import org.springframework.context.annotation.Bean
import org.springframework.core.convert.converter.Converter
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

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

    @Bean open fun localDateTimeParser(): Converter<String, LocalDateTime> {
        return Converter { source ->
            DateTimeFormatter.ISO_LOCAL_DATE_TIME.parse(source, {
                LocalDateTime.from(it)
            })
        }
    }

    @Bean open fun zonedDateTimeParser(): Converter<String, ZonedDateTime> {
        return Converter { source ->
            DateTimeFormatter.ISO_ZONED_DATE_TIME.parse(source) {
                ZonedDateTime.from(it)
            }
        }
    }

    @Bean open fun offsetDateTimeParser(): Converter<String, OffsetDateTime> {
        return Converter { source ->
            DateTimeFormatter.ISO_OFFSET_DATE_TIME.parse(source) {
                OffsetDateTime.from(it)
            }
        }
    }
}

fun main(args: Array<String>) {
    val userHome = System.getProperty("user.home")
    SpringApplicationBuilder(BlogblogApplication::class.java)
            .properties("spring.config.location=file:$userHome/blogblog/")
            .run(*args)
}
