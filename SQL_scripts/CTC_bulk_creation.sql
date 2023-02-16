/* 
CTC - combined Organization and Credential
*/

/*
CREDENTIAL - PART 1
*/

-- Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_ctc
DROP TABLE IF EXISTS thecb.credential_ctc;

SELECT
  to_date(ca.startdate,'YYYYMMDD') "Start date",
  to_date(ca.enddate,'YYYYMMDD') "End date",
  ca.awardid,
  ca.fice,
  cp.cip6,
  cp.seq,
  ca.level,
  ca.title,
  ca.typemajor,
  ca.abbrev,
  cp.name,
  inst.instlegalname,
  'TBD-ORGCTID' "Owned By",
  'ctc_clearinghouse' || '_' || ca.awardid || '_' || ca.fice || '_' || ca.cip6 || '_' || ca.seq || '_' || ca.abbrev "External Identifier",
  ca.title "Credential Name",
  'TBD-AWARD-TYPE' "Credential Type",
  'TBD-AWARD-TYPE' "Description",
  'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By", -- THECB CTID
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By", -- THECB CTID
  'TBD-AWARD-TYPE' "Audience Level Type",
  'TBD-DISTANCE' "Learning Delivery Type",
  substring (ca.cip6,1,2) || '.' || substring (ca.cip6,3,4) "CIP List"
INTO thecb.credential_ctc
FROM thecb.ctc_clearinghouse_award ca,
  thecb.ctc_clearinghouse_program cp,
  thecb.institution inst
  --thecb.award_type_crosswalk award
WHERE (ca.fice = cp.fice AND ca.programcip6 = cp.cip6 AND ca.programseq = cp.seq)
  AND (ca.fice = inst.instfice AND inst.insttype = '3')
  AND (to_date(ca.startdate,'YYYYMMDD') is null OR to_date(ca.startdate, 'YYYYMMDD') < '2023-01-31')
  AND (to_date(ca.enddate,'YYYYMMDD') is null OR to_date(ca.enddate, 'YYYYMMDD') > '2023-01-31' OR to_date(ca.enddate, 'YYYYMMDD')= '0001-01-01 BC');


-- Enrich with award-type info -- multiple passes
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level in ('2','3','4','5','6','7','0') AND 
   ctc.level = ctc_award.program_inv_award_level;
   
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1'
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) = '1'
	AND substr(ctc_award.abbrev,1,3) = 'AAA';
	
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1'
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) = '1'
	AND substr(ctc_award.abbrev,1,3) = 'AAS';

UPDATE thecb.credential_ctc ctc
SET "Credential Type" = ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1' 
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) != '1';

-- Run UPDATE to enrich with IPEDS information - institution webpage
UPDATE thecb.credential_ctc ctc
SET "Subject Webpage" = ipeds.website
FROM thecb.opeid_fice_crosswalk cw, thecb.ipeds ipeds
WHERE ctc.fice = cw.fice AND cw.opeid8 = ipeds.opeid8;

-- Update Learning delivery type
UPDATE thecb.credential_ctc ctc
SET "Learning Delivery Type" = 
    CASE
		WHEN da.distancetypeid in ('1','2','6') THEN 'OnlineOnly'
		WHEN da.distancetypeid in ('3','4') THEN 'OnlineOnly'
		WHEN da.distancetypeid in ('5') THEN 'InPerson'
		ELSE "Learning Delivery Type"
	END 
FROM 
	thecb.active_disted_awards_dedup da
WHERE
    ctc.fice = da.ficecode
	AND ctc.cip6 = substring(da.programcip, 1, 6) 
	AND ctc.seq = substring(da.cipsub,1,2);
	
-- Update everything else as 'InPerson'
UPDATE thecb.credential_ctc ctc
SET "Learning Delivery Type" = 'InPerson'
WHERE "Learning Delivery Type" = 'TBD-DISTANCE';


/*
==============
ORG File
==============
*/


-- Run DROP, SELECT INTO query to create and populate Lookup table: thecb.ctc_org_fice
DROP TABLE IF EXISTS thecb.ctc_org_fice;
SELECT DISTINCT fice, instlegalname 
INTO thecb.ctc_org_fice FROM thecb.credential_ctc;


-- Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_ctc
DROP TABLE IF EXISTS thecb.organization_ctc;

SELECT 
 inst.instfice fice, 
 inst.insttype,
 inst.instlegalname "Name",
 'ce-' || gen_random_uuid () "CTID",
 'thecb_inst' || '_' ||inst.instfice "External Identifier",
 'TBD-IPEDS' "Webpage",
 'TBD-IPEDS' "Description",
 'TBD-CONTACT-IPEDS' "PrimaryPhoneNumber",
 'Tiffani.Tatum@highered.texas.gov' "PrimaryEmail",
 'CredentialOrganization' "Publishing Roles",
 'BulkUpload' "Publishing Methods",
 'Public' "Organization Sector",
 insttype.ce_agent_type "Organization Types",
 'Tiffani.Tatum@highered.texas.gov' "Contact Email",
 'Tiffani' "Contact First Name",
 'Tatum' "Contact Last Name",
 'TBD-IPEDS' "Street Address",
 'TBD-IPEDS'"City",
 'Texas'"StateProvince",
 'TBD-IPEDS'"PostalCode",
 'United States'"Country"
into thecb.organization_ctc
from
  thecb.ctc_org_fice orgfice,
  thecb.institution inst,
  thecb.inst_type_lookup insttype
 where
   orgfice.fice = inst.instfice
   and insttype.inst_type_code = inst.insttype;

-- Run UPDATE to Enrich with IPEDS data
update thecb.organization_ctc org
SET "PrimaryPhoneNumber" = ipeds.phone,
    "Webpage" =ipeds.website,
    "Description" = ipeds.mission_statement,
	"Street Address" = ipeds.street_address,
	"City" = ipeds.city,
	"PostalCode" = ipeds.zip
FROM thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE org.fice = cw.fice
  and cw.opeid8 = ipeds.opeid8;
  

-- Run UPDATE to add madlibs description where no mission statement found
UPDATE thecb.organization_ctc org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;


/*
CREDENTIAL PART 2
*/

-- Update Credential records table with generated ORG CTID
UPDATE thecb.credential_ctc ctc
SET "Owned By" = org."CTID"
FROM thecb.organization_ctc org
WHERE ctc.fice = org.fice;

-- Run SELECT to create result set for saving to bulk CSV template
select * from thecb.organization_ctc order by "Name";
select * from thecb.credential_ctc order by instlegalname;

