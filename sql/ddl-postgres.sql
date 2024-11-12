--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.artist (
    artist_id integer NOT NULL,
    artist_name character varying(1000) NOT NULL
);


ALTER TABLE public.artist OWNER TO onnoji_user;

--
-- Name: song_artist; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.song_artist (
    song_id integer NOT NULL,
    artist_id integer NOT NULL
);


ALTER TABLE public.song_artist OWNER TO onnoji_user;

--
-- Name: song_genre; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.song_genre (
    song_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.song_genre OWNER TO onnoji_user;

--
-- Name: artist_genre; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.artist_genre AS
 SELECT t1.artist_id,
    t3.genre_id
   FROM ((public.artist t1
     JOIN public.song_artist t2 ON ((t2.artist_id = t1.artist_id)))
     JOIN public.song_genre t3 ON (((t3.song_id)::text = (t2.song_id)::text)))
  WHERE (t3.genre_id IS NOT NULL)
  GROUP BY t1.artist_id, t3.genre_id;


ALTER VIEW public.artist_genre OWNER TO onnoji_user;

--
-- Name: artwork; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.artwork (
    artwork_id integer NOT NULL,
    artwork_file_path text NOT NULL,
    mime_type character varying(100),
    digest character varying(100)
);


ALTER TABLE public.artwork OWNER TO onnoji_user;

--
-- Name: genre; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.genre (
    genre_id integer NOT NULL,
    genre_name character varying(100) NOT NULL,
    genre_file_path text
);


ALTER TABLE public.genre OWNER TO onnoji_user;

--
-- Name: history; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.history (
    history_id integer NOT NULL,
    song_id integer NOT NULL,
    request_datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.history OWNER TO onnoji_user;

--
-- Name: playlist; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.playlist (
    playlist_id integer NOT NULL,
    playlist_name character varying(1000) NOT NULL,
    is_album character(1) NOT NULL,
    creation_datetime timestamp without time zone NOT NULL,
    update_datetime timestamp without time zone
);


ALTER TABLE public.playlist OWNER TO onnoji_user;

--
-- Name: song_playlist; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.song_playlist (
    song_id integer NOT NULL,
    playlist_id integer NOT NULL,
    disc_number integer,
    track_number integer
);


ALTER TABLE public.song_playlist OWNER TO onnoji_user;

--
-- Name: playlist_artist; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.playlist_artist AS
 SELECT t1.playlist_id,
    t3.artist_id
   FROM ((public.playlist t1
     JOIN public.song_playlist t2 ON (((t2.playlist_id)::text = (t1.playlist_id)::text)))
     JOIN public.song_artist t3 ON (((t3.song_id)::text = (t2.song_id)::text)))
  WHERE (t3.artist_id IS NOT NULL)
  GROUP BY t1.playlist_id, t3.artist_id;


ALTER VIEW public.playlist_artist OWNER TO onnoji_user;

--
-- Name: song; Type: TABLE; Schema: public; Owner: onnoji_user
--

CREATE TABLE public.song (
    song_id integer NOT NULL,
    title character varying(1000) NOT NULL,
    pub_date integer,
    copyright character varying(1000),
    time_length_milliseconds integer NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_path text NOT NULL,
    digest character varying(100) NOT NULL,
    artwork_id integer,
    creation_datetime timestamp without time zone NOT NULL,
    comment text
);


ALTER TABLE public.song OWNER TO onnoji_user;

--
-- Name: playlist_artwork; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.playlist_artwork AS
 SELECT t1.playlist_id,
    t3.artwork_id
   FROM ((public.playlist t1
     JOIN public.song_playlist t2 ON (((t2.playlist_id)::text = (t1.playlist_id)::text)))
     JOIN public.song t3 ON (((t3.song_id)::text = (t2.song_id)::text)))
  WHERE (t3.artwork_id IS NOT NULL)
  GROUP BY t1.playlist_id, t3.artwork_id
  ORDER BY t1.playlist_id, t3.artwork_id;


ALTER VIEW public.playlist_artwork OWNER TO onnoji_user;

--
-- Name: playlist_genre; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.playlist_genre AS
 SELECT t1.playlist_id,
    t3.genre_id
   FROM ((public.playlist t1
     JOIN public.song_playlist t2 ON (((t2.playlist_id)::text = (t1.playlist_id)::text)))
     JOIN public.song_genre t3 ON (((t3.song_id)::text = (t2.song_id)::text)))
  WHERE (t3.genre_id IS NOT NULL)
  GROUP BY t1.playlist_id, t3.genre_id
  ORDER BY t1.playlist_id, t3.genre_id;


ALTER VIEW public.playlist_genre OWNER TO onnoji_user;

--
-- Name: playlist_genre_detailed; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.playlist_genre_detailed AS
 SELECT t1.genre_id,
    t2.genre_name,
    t1.playlist_id,
    t3.playlist_name
   FROM ((public.playlist_genre t1
     LEFT JOIN public.genre t2 ON ((t2.genre_id = t1.genre_id)))
     LEFT JOIN public.playlist t3 ON ((t3.playlist_id = t1.playlist_id)));


ALTER VIEW public.playlist_genre_detailed OWNER TO onnoji_user;

--
-- Name: song_playlist_detailed; Type: VIEW; Schema: public; Owner: onnoji_user
--

CREATE VIEW public.song_playlist_detailed AS
 SELECT t1.playlist_id,
    t2.playlist_name,
    t1.disc_number,
    t1.track_number,
    t3.song_id,
    t3.title
   FROM ((public.song_playlist t1
     LEFT JOIN public.playlist t2 ON ((t2.playlist_id = t1.playlist_id)))
     LEFT JOIN public.song t3 ON ((t3.song_id = t1.song_id)));


ALTER VIEW public.song_playlist_detailed OWNER TO onnoji_user;

--
-- Name: artist artist_pkey; Type: CONSTRAINT; Schema: public; Owner: onnoji_user
--

ALTER TABLE ONLY public.artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (artist_id);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: onnoji_user
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (genre_id);


--
-- Name: playlist playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: onnoji_user
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (playlist_id);


--
-- Name: song song_pkey1; Type: CONSTRAINT; Schema: public; Owner: onnoji_user
--

ALTER TABLE ONLY public.song
    ADD CONSTRAINT song_pkey1 PRIMARY KEY (song_id);


--
-- PostgreSQL database dump complete
--

