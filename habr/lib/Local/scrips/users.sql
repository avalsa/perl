-- Table: public.users

-- DROP TABLE public.users;

CREATE TABLE public.users
(
  nik character varying(30) NOT NULL,
  ranking character varying(10) NOT NULL,
  karma character varying(10) NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (nik)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.users
  OWNER TO postgres;
