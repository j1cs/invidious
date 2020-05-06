-- CREATE DATABASE invidious;
-- CREATE USER kemal WITH PASSWORD 'kemal';
-- \c invidious kemal
-- Type: privacy

-- DROP TYPE privacy;

CREATE TYPE privacy AS ENUM
(
    'Public',
    'Unlisted',
    'Private'
);
-- Table: channels

-- DROP TABLE channels;

CREATE TABLE channels
(
  id text NOT NULL,
  author text,
  updated timestamp with time zone,
  deleted boolean,
  subscribed timestamp with time zone,
  CONSTRAINT channels_id_key UNIQUE (id)
);

GRANT ALL ON TABLE channels TO kemal;

-- Index: channels_id_idx

-- DROP INDEX channels_id_idx;

CREATE INDEX channels_id_idx
  ON channels
  USING btree
  (id COLLATE pg_catalog."default");

-- Table: videos

-- DROP TABLE videos;

CREATE TABLE videos
(
  id text NOT NULL,
  info text,
  updated timestamp with time zone,
  title text,
  views bigint,
  likes integer,
  dislikes integer,
  wilson_score double precision,
  published timestamp with time zone,
  description text,
  language text,
  author text,
  ucid text,
  allowed_regions text[],
  is_family_friendly boolean,
  genre text,
  genre_url text,
  license text,
  sub_count_text text,
  author_thumbnail text,
  CONSTRAINT videos_pkey PRIMARY KEY (id)
);

GRANT ALL ON TABLE videos TO kemal;

-- Index: id_idx

-- DROP INDEX id_idx;

CREATE UNIQUE INDEX id_idx
  ON videos
  USING btree
  (id COLLATE pg_catalog."default");

-- Table: channel_videos

-- DROP TABLE channel_videos;

CREATE TABLE channel_videos
(
  id text NOT NULL,
  title text,
  published timestamp with time zone,
  updated timestamp with time zone,
  ucid text,
  author text,
  length_seconds integer,
  live_now boolean,
  premiere_timestamp timestamp with time zone,
  views bigint,
  CONSTRAINT channel_videos_id_key UNIQUE (id)
);

GRANT ALL ON TABLE channel_videos TO kemal;

-- Index: channel_videos_ucid_idx

-- DROP INDEX channel_videos_ucid_idx;

CREATE INDEX channel_videos_ucid_idx
  ON channel_videos
  USING btree
  (ucid COLLATE pg_catalog."default");

-- Table: users

-- DROP TABLE users;

CREATE TABLE users
(
  updated timestamp with time zone,
  notifications text[],
  subscriptions text[],
  email text NOT NULL,
  preferences text,
  password text,
  token text,
  watched text[],
  feed_needs_update boolean,
  CONSTRAINT users_email_key UNIQUE (email)
);

GRANT ALL ON TABLE users TO kemal;

-- Index: email_unique_idx

-- DROP INDEX email_unique_idx;

CREATE UNIQUE INDEX email_unique_idx
  ON users
  USING btree
  (lower(email) COLLATE pg_catalog."default");

-- Table: session_ids

-- DROP TABLE session_ids;

CREATE TABLE session_ids
(
  id text NOT NULL,
  email text,
  issued timestamp with time zone,
  CONSTRAINT session_ids_pkey PRIMARY KEY (id)
);

GRANT ALL ON TABLE session_ids TO kemal;

-- Index: session_ids_id_idx

-- DROP INDEX session_ids_id_idx;

CREATE INDEX session_ids_id_idx
  ON session_ids
  USING btree
  (id COLLATE pg_catalog."default");

-- Table: nonces

-- DROP TABLE nonces;

CREATE TABLE nonces
(
  nonce text,
  expire timestamp with time zone,
  CONSTRAINT nonces_id_key UNIQUE (nonce)
);

GRANT ALL ON TABLE nonces TO kemal;

-- Index: nonces_nonce_idx

-- DROP INDEX nonces_nonce_idx;

CREATE INDEX nonces_nonce_idx
  ON nonces
  USING btree
  (nonce COLLATE pg_catalog."default");

-- Table: annotations

-- DROP TABLE annotations;

CREATE TABLE annotations
(
  id text NOT NULL,
  annotations xml,
  CONSTRAINT annotations_id_key UNIQUE (id)
);

GRANT ALL ON TABLE annotations TO kemal;
-- Table: playlists

-- DROP TABLE playlists;

CREATE TABLE playlists
(
    title text,
    id text primary key,
    author text,
    description text,
    video_count integer,
    created timestamptz,
    updated timestamptz,
    privacy privacy,
    index int8[]
);

GRANT ALL ON playlists TO kemal;
-- Table: playlist_videos

-- DROP TABLE playlist_videos;

CREATE TABLE playlist_videos
(
    title text,
    id text,
    author text,
    ucid text,
    length_seconds integer,
    published timestamptz,
    plid text references playlists(id),
    index int8,
    live_now boolean,
    PRIMARY KEY (index,plid)
);

GRANT ALL ON TABLE playlist_videos TO kemal;
