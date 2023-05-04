SET statement_timeout = 0;

--DROP DATABASE IF EXISTS credential_pipeline;


/*
CREATE DATABASE credential_pipeline
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
*/	
	
	
--DROP SCHEMA IF EXISTS thecb ;

--CREATE SCHEMA IF NOT EXISTS thecb
--    AUTHORIZATION postgres; 


-- DROP TABLE IF EXISTS thecb.institution;

CREATE TABLE IF NOT EXISTS thecb.institution
(
    instfice character varying(6) COLLATE pg_catalog."default" NOT NULL,
  --  instfice2 character varying(6) COLLATE pg_catalog."default",
    instname character varying(60) COLLATE pg_catalog."default",
    insttype character varying(2) COLLATE pg_catalog."default",
    instcnty character varying(3) COLLATE pg_catalog."default",
    instsy character varying(10) COLLATE pg_catalog."default",
    instpill character varying(10) COLLATE pg_catalog."default",
    instbp character varying(10) COLLATE pg_catalog."default",
    instsw character varying(10) COLLATE pg_catalog."default",
    instlegalname character varying(200) COLLATE pg_catalog."default",
    instabbrevname character varying(50) COLLATE pg_catalog."default",
    instcountycode character varying(8) COLLATE pg_catalog."default",
    instcountyname character varying(20) COLLATE pg_catalog."default",
    instcounty character varying(20) COLLATE pg_catalog."default",
    instregionnum character varying(5) COLLATE pg_catalog."default",
    instregion character varying(50) COLLATE pg_catalog."default",
    instacctsys character varying(20) COLLATE pg_catalog."default",
    instpeergroup character varying(10) COLLATE pg_catalog."default",
    insttypecode character varying(8) COLLATE pg_catalog."default",
    zipcode character varying(8) COLLATE pg_catalog."default",
    CONSTRAINT institution_pkey PRIMARY KEY (instfice)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.institution
    OWNER to postgres;
-- UNIV-DEGREE-PROGRAM TABLE	

DROP TABLE IF EXISTS thecb.univ_degree_program;

CREATE TABLE IF NOT EXISTS thecb.univ_degree_program
(
    tableseq integer NOT NULL,
    fice character varying(6) COLLATE pg_catalog."default",
    primarycode character varying(2) COLLATE pg_catalog."default",
    secondarycode character varying(2) COLLATE pg_catalog."default",
    administrativeunitcode character varying(4) COLLATE pg_catalog."default",
    programcip character varying(8) COLLATE pg_catalog."default",
    programcipsub character varying(2) COLLATE pg_catalog."default",
    name character varying(50) COLLATE pg_catalog."default",
	--datestart character varying(15) COLLATE pg_catalog."default",
	--dateend character varying(15) COLLATE pg_catalog."default",
    datestart date,
    dateend date,
    flag character varying(1) COLLATE pg_catalog."default",
    sopcip character varying(8) COLLATE pg_catalog."default",
    sopcipsub character varying(2) COLLATE pg_catalog."default",
    translatename character varying(1000) COLLATE pg_catalog."default",
    updatetime date,
    updateuser character varying(20) COLLATE pg_catalog."default",
    inserttime date,
    insertuser character varying(20) COLLATE pg_catalog."default",
    CONSTRAINT "univ_Degreeprogram_pkey" PRIMARY KEY (tableseq)
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.univ_degree_program
    OWNER to postgres;
	

-- UNIV-DEGREE TABLE	
DROP TABLE IF EXISTS thecb.univ_degree;

CREATE TABLE IF NOT EXISTS thecb.univ_degree
(
	
    tableseq integer NOT NULL,
    fice character varying(6) COLLATE pg_catalog."default",
    primarycode character varying(2) COLLATE pg_catalog."default",
    secondarycode character varying(2) COLLATE pg_catalog."default",
    administrativeunitcode character varying(4) COLLATE pg_catalog."default",
    programcip character varying(8) COLLATE pg_catalog."default",
    programcipsub character varying(2) COLLATE pg_catalog."default",
    degreecip character varying(8) COLLATE pg_catalog."default",
    degreecipsub character varying(2) COLLATE pg_catalog."default",
    degreelevel character varying(1) COLLATE pg_catalog."default",
    degreename character varying(7) COLLATE pg_catalog."default",
    --datestart character varying(15) COLLATE pg_catalog."default",
	--dateend character varying(15) COLLATE pg_catalog."default",
    datestart date,
    dateend date,
    positionx character varying(1) COLLATE pg_catalog."default",
    footnoteposition character varying(1) COLLATE pg_catalog."default",
    footnotetext character varying(125) COLLATE pg_catalog."default",
    placeholder character varying(1) COLLATE pg_catalog."default",
    distanceed character varying(1) COLLATE pg_catalog."default",
    minimumsch numeric,
    maximumsch numeric,
    updatetime date,
    updateuser character varying(20) COLLATE pg_catalog."default",
    inserttime date,
    insertuser character varying(20) COLLATE pg_catalog."default",
    originalstartdate character varying(100) COLLATE pg_catalog."default",
    programcip2010 character varying(8) COLLATE pg_catalog."default",
    degreecip2010 character varying(8) COLLATE pg_catalog."default",
    CONSTRAINT "Univ_degree_pkey" PRIMARY KEY (tableseq)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.univ_degree
    OWNER to postgres;
	
-- CTC CLEARNING HOUSE PROGRAM
DROP TABLE IF EXISTS thecb.ctc_clearinghouse_program;

CREATE TABLE IF NOT EXISTS thecb.ctc_clearinghouse_program
(
    programid integer NOT NULL,
    fice character varying(6) COLLATE pg_catalog."default",
    cip6 character varying(8) COLLATE pg_catalog."default",
    cipsuffix character varying(2) COLLATE pg_catalog."default",
    seq character varying(2) COLLATE pg_catalog."default",
    name character varying(50) COLLATE pg_catalog."default",
    approvaldate character varying(8) COLLATE pg_catalog."default",
    revisiondate character varying(8) COLLATE pg_catalog."default",
    closedate character varying(8) COLLATE pg_catalog."default",
    advtechflag character varying(1) COLLATE pg_catalog."default",
    lastupdate character varying(8) COLLATE pg_catalog."default",
    lastupdateaction character varying(1) COLLATE pg_catalog."default",
    lastupdater character varying(3) COLLATE pg_catalog."default",
    evalstatus character varying(2) COLLATE pg_catalog."default",
    evaldate character varying(8) COLLATE pg_catalog."default",
    updatetime date,
    updateuser character varying(50) COLLATE pg_catalog."default",
    inserttime date,
    insertuser character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT "CTC_ClearingHouse_Program_pkey" PRIMARY KEY (programid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.ctc_clearinghouse_program
    OWNER to postgres;
	
-- CTC CLEARING HOUSE AWARD
-- Table: thecb.ctc_clearinghouse_award

DROP TABLE IF EXISTS thecb.ctc_clearinghouse_award;

CREATE TABLE IF NOT EXISTS thecb.ctc_clearinghouse_award
(
    awardid integer NOT NULL,
    fice character varying(6) COLLATE pg_catalog."default",
    cip6 character varying(8) COLLATE pg_catalog."default",
    cipsuffix character varying(2) COLLATE pg_catalog."default",
    seq character varying(3) COLLATE pg_catalog."default",
    programcip6 character varying(8) COLLATE pg_catalog."default",
    programcipsuffix character varying(2) COLLATE pg_catalog."default",
    programseq character varying(2) COLLATE pg_catalog."default",
    typemajor character varying(1) COLLATE pg_catalog."default",
    level character varying(1) COLLATE pg_catalog."default",
    abbrev character varying(8) COLLATE pg_catalog."default",
    title character varying(60) COLLATE pg_catalog."default",
    length character varying(3) COLLATE pg_catalog."default",
    intervalx character varying(3) COLLATE pg_catalog."default",
    contacthours numeric,
    mincredithours numeric,
    maxcredithours numeric,
    startdate character varying(8) COLLATE pg_catalog."default",
    enddate character varying(8) COLLATE pg_catalog."default",
    tpimpldate character varying(8) COLLATE pg_catalog."default",
    outdistflag character varying(1) COLLATE pg_catalog."default",
    corrflag character varying(1) COLLATE pg_catalog."default",
    evalstatus character varying(2) COLLATE pg_catalog."default",
    evaldate character varying(8) COLLATE pg_catalog."default",
    lastupdateaction character varying(2) COLLATE pg_catalog."default",
    actioneffdate character varying(8) COLLATE pg_catalog."default",
    lastupdate character varying(8) COLLATE pg_catalog."default",
    lastupdater character varying(3) COLLATE pg_catalog."default",
    updatetime date,
    updateuser character varying(50) COLLATE pg_catalog."default",
    inserttime date,
    insertuser character varying(50) COLLATE pg_catalog."default",
    cip2010 character varying(6) COLLATE pg_catalog."default",
    CONSTRAINT ctc_clearinghouse_award_pkey PRIMARY KEY (awardid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.ctc_clearinghouse_award
    OWNER to postgres;
	
-- DISTANCEAWARD table
-- Table: thecb.dist_DistanceAward
DROP TABLE IF EXISTS thecb.dist_DistanceAward;

CREATE TABLE IF NOT EXISTS thecb.dist_DistanceAward
(
	DistanceAwardID integer NOT NULL,
	InstType character varying(1) COLLATE pg_catalog."default",
	FiceCode character varying(6) COLLATE pg_catalog."default",
	ProgramCip character varying(8) COLLATE pg_catalog."default",
	ProgramCipName character varying(200) COLLATE pg_catalog."default",
	CipSub character varying(5) COLLATE pg_catalog."default",
	AwardCip character varying(8) COLLATE pg_catalog."default",
	AwardCipName character varying(200) COLLATE pg_catalog."default",
	Award character varying(8) COLLATE pg_catalog."default",
	AwardLevel character varying(1) COLLATE pg_catalog."default",
	AwardStatus character varying(10) COLLATE pg_catalog."default",
	StartDate date,
	EndDate date,
	DistanceTypeID character varying(1) COLLATE pg_catalog."default",
	DistanceLocationID character varying(10) COLLATE pg_catalog."default",
	AwardSubmitDate date,
	Deleted character varying(1) COLLATE pg_catalog."default",
	Active character varying(1) COLLATE pg_catalog."default",
	CreatedBy character varying(100) COLLATE pg_catalog."default",
	CreatedDate date,
	UpdatedBy character varying(100) COLLATE pg_catalog."default",
	UpdatedDate date,
    CONSTRAINT dist_DistanceAward_pkey PRIMARY KEY (DistanceAwardID)
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.dist_DistanceAward
    OWNER to postgres;



/*
IPEDS artifacts
*/
-- Table: thecb.ipeds

DROP TABLE IF EXISTS thecb.ipeds;

CREATE TABLE IF NOT EXISTS thecb.ipeds
(
    
    institution_name character varying(100) COLLATE pg_catalog."default",
	institution_name2 character varying(100) COLLATE pg_catalog."default",
    street_address character varying(200) COLLATE pg_catalog."default",
    city character varying(15) COLLATE pg_catalog."default",
    zip character varying(10) COLLATE pg_catalog."default",
	website character varying(200) COLLATE pg_catalog."default",
	opeid8 character varying(8) COLLATE pg_catalog."default",
	phone character varying(15) COLLATE pg_catalog."default",
    mission_statement character varying(4000) COLLATE pg_catalog."default",
    mission_statement_url character varying(200) COLLATE pg_catalog."default",
	dummy character varying(200) COLLATE pg_catalog."default"
) TABLESPACE pg_default; 

ALTER TABLE IF EXISTS thecb.ipeds OWNER to postgres;
	
-- Table: thecb.opeid_fice_crosswalk

DROP TABLE IF EXISTS thecb.opeid_fice_crosswalk;

CREATE TABLE IF NOT EXISTS thecb.opeid_fice_crosswalk
(
    opeid8 character varying(8) COLLATE pg_catalog."default" NOT NULL,
    institution_name character varying(100) COLLATE pg_catalog."default",
    fice character varying(8) COLLATE pg_catalog."default",
    dupflag character varying(1) COLLATE pg_catalog."default",
    issue_flag character varying(1) COLLATE pg_catalog."default",
    CONSTRAINT crosswalk_pkey PRIMARY KEY (opeid8)
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.opeid_fice_crosswalk OWNER to postgres;
	

-- Updated FICE OPEID crosswalk
DROP TABLE IF EXISTS thecb.opeid_fice_crosswalk2;

CREATE TABLE IF NOT EXISTS thecb.opeid_fice_crosswalk2
(
    fice character varying(8) COLLATE pg_catalog."default",
	institution_name character varying(100) COLLATE pg_catalog."default",
	opeid8 character varying(8) COLLATE pg_catalog."default",
	opeunit character varying(8) COLLATE pg_catalog."default",
	ipeds character varying(1) COLLATE pg_catalog."default",
    CONSTRAINT crosswalk2_pkey PRIMARY KEY (fice)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.opeid_fice_crosswalk2
    OWNER to postgres;

/*
Lookup tables
*/

-- Table: thecb.inst_type_lookup
DROP TABLE IF EXISTS thecb.inst_type_lookup;

CREATE TABLE IF NOT EXISTS thecb.inst_type_lookup
(
    inst_type_code character varying(1) COLLATE pg_catalog."default" NOT NULL,
    inst_type_desc character varying(50) COLLATE pg_catalog."default",
	include_flag character varying(1) COLLATE pg_catalog."default",
    ce_agent_type character varying(50) COLLATE pg_catalog."default",
	madlibs character varying(50) COLLATE pg_catalog."default"
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.inst_type_lookup
    OWNER to postgres;

-- Table ORG CTID mapping

DROP TABLE IF EXISTS thecb.org_ctid_mapping;

CREATE TABLE IF NOT EXISTS thecb.org_ctid_mapping
(
	org_ctid text COLLATE pg_catalog."default" NOT NULL,
	institution_name character varying(100) COLLATE pg_catalog."default",
	institution_type character varying(1) COLLATE pg_catalog."default",
    CONSTRAINT org_ctid_mapping_pkey PRIMARY KEY (org_ctid)
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.ctc_clearinghouse_award
    OWNER to postgres;
	
-- Table CREDENTIAL CTID mapping
DROP TABLE IF EXISTS thecb.credential_ctid_mapping;

CREATE TABLE IF NOT EXISTS thecb.credential_ctid_mapping
(
	thecb_identifier text COLLATE pg_catalog."default" NOT NULL,
	credential_ctid text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT credential_ctid_mapping_pkey PRIMARY KEY (thecb_identifier, credential_ctid )
) TABLESPACE pg_default;

ALTER TABLE IF EXISTS thecb.ctc_clearinghouse_award
    OWNER to postgres;

