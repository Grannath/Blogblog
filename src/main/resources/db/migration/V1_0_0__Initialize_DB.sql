DO
$body$
BEGIN
  IF NOT EXISTS(
      SELECT *
      FROM pg_catalog.pg_user
      WHERE usename = 'blog_user')
  THEN
    CREATE ROLE blog_user LOGIN PASSWORD 'blogblog';
  END IF;
END
$body$;

GRANT USAGE ON SCHEMA blogblog TO blog_user;

CREATE TABLE blogblog.bl_users (
  id          SERIAL,
  username    VARCHAR(50)           NOT NULL UNIQUE,
  password    VARCHAR(50)           NOT NULL,
  deactivated BOOLEAN DEFAULT FALSE NOT NULL,
  PRIMARY KEY (id)
);

GRANT SELECT, INSERT ON blogblog.bl_users TO blog_user;
GRANT UPDATE (username, deactivated) ON blogblog.bl_users TO blog_user;

CREATE TABLE blogblog.bl_posts (
  id      SERIAL,
  title   TEXT                                NOT NULL,
  content TEXT                                NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  author  INTEGER                             NOT NULL REFERENCES blogblog.bl_users,
  hidden  BOOLEAN DEFAULT FALSE               NOT NULL,
  PRIMARY KEY (id)
);

GRANT SELECT, INSERT ON blogblog.bl_posts TO blog_user;
GRANT UPDATE (hidden) ON blogblog.bl_posts TO blog_user;