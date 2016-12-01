-- Table: public.posts

-- DROP TABLE public.posts;

CREATE TABLE public.posts
(
  id integer NOT NULL,
  author character varying(30) NOT NULL,
  ranking character varying(10) NOT NULL,
  stars integer NOT NULL,
  title character varying(100) NOT NULL,
  views character varying(10) NOT NULL,
  CONSTRAINT posts_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.posts
  OWNER TO postgres;
