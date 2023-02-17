/*
File: build_credentials_ctc.sql

Function: Builds up Credential table for 2 year institutions

Output: Bulk staging table: thecb.credential_ctc

Steps
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_ctc
2. Run UPDATE to enrich with IPEDS information

3. Move to the script for creating the matching staging table for organizations (build_organizations_ctc.sql)
    --- as part of this, the "Owned By" field is updated withOrg CTID
4. Run quality check queries as needed
5. Run SELECT to create result set for saving to bulk CSV template
*/

/*
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_ctc
*/

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

--select * from thecb.credential_ctc
/*
1.b Enrich with award-type info -- multiple passes
*/
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level in ('2','3','4','5','6','7','0') AND 
   ctc.level = ctc_award.program_inv_award_level;
   
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = 'TYPO 1', --ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1'
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) = '1'
	AND substr(ctc_award.abbrev,1,3) = 'AAA';
	
UPDATE thecb.credential_ctc ctc
SET "Credential Type" = 'TYPO2', --ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1'
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) = '1'
	AND substr(ctc_award.abbrev,1,3) = 'AAS';

UPDATE thecb.credential_ctc ctc
SET "Credential Type" = 'TYPO3', --ctc_award.ctdl_credential_type,
    "Description" = 'The ' || ctc.title || ' credential is ' || ctc_award.madlibs|| ' offered by the ' || INITCAP(ctc.name) || ' program at ' || ctc.instlegalname || '.',
	 "Audience Level Type" = ctc_award.audience_level 
FROM thecb.ctc_award_type_crosswalk ctc_award
WHERE ctc.level = '1' 
	AND ctc.level = ctc_award.program_inv_award_level 
	AND substr(ctc_award.type_major,1,1) != '1';

/*
2. Run UPDATE to enrich with IPEDS information - institution webpage
*/
--Enrich with IPEDS information - institution webpage 
UPDATE thecb.credential_ctc ctc
SET "Subject Webpage" = ipeds.website
FROM thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE ctc.fice = cw.fice
  AND cw.opeid8 = ipeds.opeid8;

/*
3. Run UPDATE to appply distance ed information where it exists
*/

--select count(ctc.instlegalname)
--, ctc."Credential Name", da.distancetypeid, ctc.fice, da.ficecode, ctc.cip6, substring(da.programcip, 1, 6), ctc.seq, substring(da.cipsub,1,2)
--from 
--	thecb.credential_ctc ctc,
--	thecb.active_disted_awards_dedup da
--WHERE
--    ctc.fice = da.ficecode
--	AND ctc.cip6 = substring(da.programcip, 1, 6) 
--	AND ctc.seq = substring(da.cipsub,1,2);

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
4. Move to the script for creating the matching staging table for organizations (build_organizations_ctc.sql)
    --- as part of this, the "Owned By" field is updated withOrg CTID
*/
UPDATE thecb.credential_ctc ctc
SET "Owned By" = org."CTID"
FROM thecb.organization_ctc org
WHERE ctc.fice = org.fice; 

/*
5. Run quality check queries as needed
*/

-- Identify institutions that aren't recognized by FICE-OPEDID crosswalk
--select distinct instlegalname 
--from thecb.credential_ctc where "Subject Webpage" != 'TBD-IPEDS-Webpage';

--select distinct instlegalname 
--from thecb.credential_ctc where "Subject Webpage" = 'TBD-IPEDS-Webpage';


/*
6. Run SELECT to create result set for saving to bulk CSV template
*/

select * from thecb.credential_ctc;

select * from thecb.credential_ctc
where abbrev = 'AAS';

/*
SELECT * from thecb.credential_ctc 
WHERE "Subject Webpage" != 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname

SELECT * from thecb.credential_ctc 
WHERE "Subject Webpage" = 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname
*/