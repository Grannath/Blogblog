/**
 * This class is generated by jOOQ
 */
package de.blogblog.jooq.tables.records;


import de.blogblog.jooq.tables.BlUsers;

import javax.annotation.Generated;

import org.jooq.Field;
import org.jooq.Record1;
import org.jooq.Record4;
import org.jooq.Row4;
import org.jooq.impl.UpdatableRecordImpl;


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
public class BlUsersRecord extends UpdatableRecordImpl<BlUsersRecord> implements Record4<Integer, String, String, Boolean> {

    private static final long serialVersionUID = 996973368;

    /**
     * Setter for <code>blogblog.bl_users.id</code>.
     */
    public void setId(Integer value) {
        set(0, value);
    }

    /**
     * Getter for <code>blogblog.bl_users.id</code>.
     */
    public Integer getId() {
        return (Integer) get(0);
    }

    /**
     * Setter for <code>blogblog.bl_users.username</code>.
     */
    public void setUsername(String value) {
        set(1, value);
    }

    /**
     * Getter for <code>blogblog.bl_users.username</code>.
     */
    public String getUsername() {
        return (String) get(1);
    }

    /**
     * Setter for <code>blogblog.bl_users.password</code>.
     */
    public void setPassword(String value) {
        set(2, value);
    }

    /**
     * Getter for <code>blogblog.bl_users.password</code>.
     */
    public String getPassword() {
        return (String) get(2);
    }

    /**
     * Setter for <code>blogblog.bl_users.deactivated</code>.
     */
    public void setDeactivated(Boolean value) {
        set(3, value);
    }

    /**
     * Getter for <code>blogblog.bl_users.deactivated</code>.
     */
    public Boolean getDeactivated() {
        return (Boolean) get(3);
    }

    // -------------------------------------------------------------------------
    // Primary key information
    // -------------------------------------------------------------------------

    /**
     * {@inheritDoc}
     */
    @Override
    public Record1<Integer> key() {
        return (Record1) super.key();
    }

    // -------------------------------------------------------------------------
    // Record4 type implementation
    // -------------------------------------------------------------------------

    /**
     * {@inheritDoc}
     */
    @Override
    public Row4<Integer, String, String, Boolean> fieldsRow() {
        return (Row4) super.fieldsRow();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Row4<Integer, String, String, Boolean> valuesRow() {
        return (Row4) super.valuesRow();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Field<Integer> field1() {
        return BlUsers.BL_USERS.ID;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Field<String> field2() {
        return BlUsers.BL_USERS.USERNAME;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Field<String> field3() {
        return BlUsers.BL_USERS.PASSWORD;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Field<Boolean> field4() {
        return BlUsers.BL_USERS.DEACTIVATED;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Integer value1() {
        return getId();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String value2() {
        return getUsername();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String value3() {
        return getPassword();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Boolean value4() {
        return getDeactivated();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsersRecord value1(Integer value) {
        setId(value);
        return this;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsersRecord value2(String value) {
        setUsername(value);
        return this;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsersRecord value3(String value) {
        setPassword(value);
        return this;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsersRecord value4(Boolean value) {
        setDeactivated(value);
        return this;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BlUsersRecord values(Integer value1, String value2, String value3, Boolean value4) {
        value1(value1);
        value2(value2);
        value3(value3);
        value4(value4);
        return this;
    }

    // -------------------------------------------------------------------------
    // Constructors
    // -------------------------------------------------------------------------

    /**
     * Create a detached BlUsersRecord
     */
    public BlUsersRecord() {
        super(BlUsers.BL_USERS);
    }

    /**
     * Create a detached, initialised BlUsersRecord
     */
    public BlUsersRecord(Integer id, String username, String password, Boolean deactivated) {
        super(BlUsers.BL_USERS);

        set(0, id);
        set(1, username);
        set(2, password);
        set(3, deactivated);
    }
}
