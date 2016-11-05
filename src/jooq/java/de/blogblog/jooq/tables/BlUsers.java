/**
 * This class is generated by jOOQ
 */
package de.blogblog.jooq.tables;


import de.blogblog.jooq.Blogblog;
import de.blogblog.jooq.Keys;
import de.blogblog.jooq.tables.records.BlUsersRecord;

import java.util.Arrays;
import java.util.List;

import javax.annotation.Generated;

import org.jooq.Field;
import org.jooq.Identity;
import org.jooq.Schema;
import org.jooq.Table;
import org.jooq.TableField;
import org.jooq.UniqueKey;
import org.jooq.impl.TableImpl;


/**
 * This class is generated by jOOQ.
 */
@Generated(
    value = {
        "http://www.jooq.org",
        "jOOQ version:3.8.4"
    },
    comments = "This class is generated by jOOQ"
)
@SuppressWarnings({ "all", "unchecked", "rawtypes" })
public class BlUsers extends TableImpl<BlUsersRecord> {

    private static final long serialVersionUID = 1007343587;

    /**
     * The reference instance of <code>blogblog.bl_users</code>
     */
    public static final BlUsers BL_USERS = new BlUsers();

    /**
     * The class holding records for this type
     */
    @Override
    public Class<BlUsersRecord> getRecordType() {
        return BlUsersRecord.class;
    }

    /**
     * The column <code>blogblog.bl_users.id</code>.
     */
    public final TableField<BlUsersRecord, Integer> ID = createField("id", org.jooq.impl.SQLDataType.INTEGER.nullable(false).defaultValue(org.jooq.impl.DSL.field("nextval('blogblog.bl_users_id_seq'::regclass)", org.jooq.impl.SQLDataType.INTEGER)), this, "");

    /**
     * The column <code>blogblog.bl_users.username</code>.
     */
    public final TableField<BlUsersRecord, String> USERNAME = createField("username", org.jooq.impl.SQLDataType.VARCHAR.length(50).nullable(false), this, "");

    /**
     * The column <code>blogblog.bl_users.password</code>.
     */
    public final TableField<BlUsersRecord, String> PASSWORD = createField("password", org.jooq.impl.SQLDataType.VARCHAR.length(50).nullable(false), this, "");

    /**
     * The column <code>blogblog.bl_users.deactivated</code>.
     */
    public final TableField<BlUsersRecord, Boolean> DEACTIVATED = createField("deactivated", org.jooq.impl.SQLDataType.BOOLEAN.nullable(false).defaultValue(org.jooq.impl.DSL.field("false", org.jooq.impl.SQLDataType.BOOLEAN)), this, "");

    /**
     * Create a <code>blogblog.bl_users</code> table reference
     */
    public BlUsers() {
        this("bl_users", null);
    }

    /**
     * Create an aliased <code>blogblog.bl_users</code> table reference
     */
    public BlUsers(String alias) {
        this(alias, BL_USERS);
    }

    private BlUsers(String alias, Table<BlUsersRecord> aliased) {
        this(alias, aliased, null);
    }

    private BlUsers(String alias, Table<BlUsersRecord> aliased, Field<?>[] parameters) {
        super(alias, null, aliased, parameters, "");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Schema getSchema() {
        return Blogblog.BLOGBLOG;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Identity<BlUsersRecord, Integer> getIdentity() {
        return Keys.IDENTITY_BL_USERS;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public UniqueKey<BlUsersRecord> getPrimaryKey() {
        return Keys.BL_USERS_PKEY;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<UniqueKey<BlUsersRecord>> getKeys() {
        return Arrays.<UniqueKey<BlUsersRecord>>asList(Keys.BL_USERS_PKEY, Keys.BL_USERS_USERNAME_KEY);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsers as(String alias) {
        return new BlUsers(alias, this);
    }

    /**
     * Rename this table
     */
    public BlUsers rename(String name) {
        return new BlUsers(name, null);
    }
}
