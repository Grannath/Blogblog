CREATE TABLE blogblog.bl_users (
  id          SERIAL,
  username    VARCHAR(50)           NOT NULL UNIQUE,
  password    VARCHAR(50)           NOT NULL,
  deactivated BOOLEAN DEFAULT FALSE NOT NULL,
  PRIMARY KEY (id)
);

GRANT SELECT, INSERT ON blogblog.bl_users TO blog_user;
GRANT UPDATE (username, password, deactivated) ON blogblog.bl_users TO blog_user;

CREATE TABLE blogblog.bl_posts (
  id      SERIAL,
  title   TEXT                                     NOT NULL,
  content TEXT                                     NOT NULL,
  created TIMESTAMPTZ(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  author  INTEGER                                  NOT NULL REFERENCES blogblog.bl_users,
  hidden  BOOLEAN DEFAULT FALSE                    NOT NULL,
  PRIMARY KEY (id)
);

GRANT SELECT, INSERT ON blogblog.bl_posts TO blog_user;
GRANT UPDATE (hidden, title, content) ON blogblog.bl_posts TO blog_user;