-- Table: thecb.credential_hri

DROP TABLE IF EXISTS thecb.credential_twc;

CREATE TABLE IF NOT EXISTS thecb.credential_twc
(
    owned_by text COLLATE pg_catalog."default",
	target_credentials text COLLATE pg_catalog."default",
	credential_name text COLLATE pg_catalog."default",
	credential_type text COLLATE pg_catalog."default",
	description text COLLATE pg_catalog."default",
	onet_list text COLLATE pg_catalog."default",
	cip_list text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.credential_twc
    OWNER to postgres;
	
DROP TABLE IF EXISTS thecb.credential_cb;

CREATE TABLE IF NOT EXISTS thecb.credential_cb
(
    inst_type text COLLATE pg_catalog."default",
	institution text COLLATE pg_catalog."default",
	owned_by text COLLATE pg_catalog."default",
	external_identifier text COLLATE pg_catalog."default",
	credential_name text COLLATE pg_catalog."default",
	credential_type text COLLATE pg_catalog."default",
	description text COLLATE pg_catalog."default",
	cip_list text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.credential_cb
    OWNER to postgres;