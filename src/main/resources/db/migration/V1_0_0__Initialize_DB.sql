GRANT USAGE ON SCHEMA blogblog TO blog_user;

CREATE TABLE blogblog.bl_users (
  id          SERIAL,
  username    VARCHAR(50)           NOT NULL,
  password    VARCHAR(50)           NOT NULL,
  deactivated BOOLEAN DEFAULT FALSE NOT NULL,
  CONSTRAINT pk_users PRIMARY KEY (id),
  CONSTRAINT uq_users_username UNIQUE (username)
);

GRANT SELECT, INSERT ON blogblog.bl_users TO blog_user;
GRANT UPDATE (username, password, deactivated) ON blogblog.bl_users TO blog_user;

CREATE TABLE blogblog.bl_posts (
  id          SERIAL,
  title       VARCHAR(200)                             NOT NULL,
  static_link VARCHAR(100)                             NOT NULL,
  content     TEXT                                     NOT NULL,
  created     TIMESTAMPTZ(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  author      INTEGER                                  NOT NULL,
  hidden      BOOLEAN DEFAULT FALSE                    NOT NULL,
  CONSTRAINT pk_posts PRIMARY KEY (id),
  CONSTRAINT uq_posts_static_link UNIQUE (static_link),
  CONSTRAINT fk_posts_author FOREIGN KEY (author) REFERENCES blogblog.bl_users
);

GRANT SELECT, INSERT ON blogblog.bl_posts TO blog_user;
GRANT UPDATE (hidden, title, content) ON blogblog.bl_posts TO blog_user;