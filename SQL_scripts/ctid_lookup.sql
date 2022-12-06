-- Table: thecb.institution

-- DROP TABLE IF EXISTS thecb.ctid_lookup;

CREATE TABLE IF NOT EXISTS thecb.ctid_lookup
(
    instname character varying(60) COLLATE pg_catalog."default",
    ctid character varying(50) COLLATE pg_catalog."default",
    externalid character varying(25) COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.ctid_lookup
    OWNER to postgres;