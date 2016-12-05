-- Table: public.users

-- DROP TABLE public.users;

CREATE TABLE public.users
(
  nik character varying(30) NOT NULL,
  karma real NOT NULL,
  ranking real NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (nik)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.users
  OWNER TO postgres;
