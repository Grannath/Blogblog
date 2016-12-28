package de.blogblog

import org.jooq.Converter
import org.springframework.stereotype.Component
import java.sql.Timestamp
import java.time.ZoneId
import java.time.ZonedDateTime


class ZonedDateTimeConverter : Converter<Timestamp, ZonedDateTime> {

    override fun from(timestamp: Timestamp): ZonedDateTime {
        return ZonedDateTime.ofInstant(timestamp.toInstant(),
                                       ZoneId.systemDefault())
    }

    override fun to(zonedDateTime: ZonedDateTime): Timestamp {
        return Timestamp.from(zonedDateTime.toInstant())
    }

    override fun fromType(): Class<Timestamp> {
        return Timestamp::class.java
    }

    override fun toType(): Class<ZonedDateTime> {
        return ZonedDateTime::class.java
    }

    companion object {

        private val serialVersionUID = 1L
    }
}