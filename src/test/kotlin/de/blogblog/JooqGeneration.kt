package de.blogblog

import org.jooq.util.GenerationTool
import org.jooq.util.jaxb.*
import org.jooq.util.jaxb.Target
import org.junit.Test
import org.junit.experimental.categories.Category
import org.junit.runner.RunWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.junit4.SpringRunner
import java.time.ZonedDateTime
import javax.sql.DataSource

/**
 * Created by Johannes on 29.10.2016.
 */

@RunWith(SpringRunner::class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@ActiveProfiles("jooq-gen")
@Category(JooqGeneration::class)
class JooqGeneration {

    @Autowired
    lateinit var dataSource: DataSource

    @Value("\${flyway.schemas}")
    lateinit var schemata: Array<String>

    @Value("\${flyway.table:schema_version}")
    lateinit var flywayTable: String

    @Test
    fun generateClasses() {
        val conf = Configuration().withGenerator(
                Generator()
                        .withDatabase(
                                Database()
                                        .withIncludes(".*")
                                        .withExcludes(flywayTable)
                                        .withInputSchema(schemata[0])
                                        .withForcedTypes(
                                                ForcedType()
                                                        .withUserType(
                                                                ZonedDateTime::class.java.name)
                                                        .withConverter(
                                                                ZonedDateTimeConverter::class.java.name)
                                                        .withTypes("TIMESTAMP.*")))
                        .withTarget(
                                Target().withPackageName("de.blogblog.jooq")
                                        .withDirectory("src/jooq/java"))
                        .withGenerate(
                                Generate()))

        val tool = GenerationTool()
        tool.setDataSource(dataSource)
        tool.run(conf)
    }
}