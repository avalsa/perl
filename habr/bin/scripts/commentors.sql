-- Table: public.commentors

-- DROP TABLE public.commentors;

CREATE TABLE public.commentors
(
  id_post integer NOT NULL,
  nik character varying(30) NOT NULL,
  CONSTRAINT commentors_pkey PRIMARY KEY (id_post, nik)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.commentors
  OWNER TO postgres;
