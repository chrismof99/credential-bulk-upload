/*
File: build_credentials_hri.sql

Function: Builds up Credential table for HRI's (ID = 05)

Output: Bulk staging table: thecb.credential_hri

Steps
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
2. Run UPDATE to enrich with IPEDS information
3. Run quality check queries as needed
4. Move to the script for creating the matching staging table for organizations (build_organizations_univ.sql)
    --- as part of this, the "Owned By" field is updated withOrg CTID
5. Run SELECT to create result set for saving to Bulk CSV template

*/

/*
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
*/

DROP TABLE IF EXISTS thecb.credential_hri;

SELECT 
  -- Tracking, lookup fields
  ud.fice,
  inst.instlegalname,
  ud.degreename,
  up.name,
  ud.degreelevel,
  'TBD-ORGCTID' "Owned By",
  'univ_degree' || '_' || ud.tableseq || '_' || ud.fice || '_' || ud.programcip || '_' || ud.programcipsub  "External Identifier",
  ud.degreename || ' ' || INITCAP(up.name) "Credential Name",
  'TBD-AWARD-TYPE' "Credential Type",
  'TBD-AWARD-TYPE' "Description",
  'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By", -- THECB CTID
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By", -- THECB CTID
  'TBD-AWARD-TYPE' "Audience Level Type",
  'TBD' "Learning Delivery Type",
  substring (ud.programcip,1,2) || '.' || substring (ud.programcip,3,4) "CIP List"
INTO thecb.credential_hri
FROM thecb.univ_degree ud,
  thecb.univ_degree_program up, 
  thecb.institution inst
WHERE
  -- Join Univ and Univ_Program tables
  (ud.fice = up.fice AND ud.programcip = up.programcip AND ud.programcipsub = up.programcipsub)
  -- Join with Institution table to get institution type
  AND (up.fice = inst.instfice AND inst.insttype = '5')
  -- Filter by start/end dates
  AND ((up.datestart = null or up.datestart < '2023-01-31') 
  AND (up.dateend is null or up.dateend > '2023-01-31'));

/*
1.b Enrich with award-type info -- multiple passes
*/
UPDATE thecb.credential_hri hri
SET "Credential Type" = hri_award.ctdl_credential_type,
    "Description" = 'The ' || hri.degreename || ' ' || INITCAP(hri.name) || ' credential is ' || hri_award.madlibs || ' offered by ' || hri.instlegalname || '.', -- Madlibs construction for description
	 "Audience Level Type" = hri_award.audience_level 
FROM thecb.hri_award_type_crosswalk hri_award
WHERE hri.degreelevel in ('1','4','5')
AND hri.degreelevel = hri_award.program_inv_award_level;

UPDATE thecb.credential_hri hri
SET "Credential Type" = hri_award.ctdl_credential_type,
  "Description" = 'The ' || hri.degreename || ' ' || INITCAP(hri.name) || ' credential is ' || hri_award.madlibs || ' offered by ' || hri.instlegalname || '.', -- Madlibs construction for description
  "Audience Level Type" = hri_award.audience_level
FROM thecb.hri_award_type_crosswalk hri_award
WHERE hri.degreelevel in ('2','3')
  AND hri.degreelevel = hri_award.program_inv_award_level AND substring (hri_award.program_inv_cer, 1, 2) = 'NA';

UPDATE thecb.credential_hri hri
SET "Credential Type" = hri_award.ctdl_credential_type,
  "Description" = 'The ' || hri.degreename || ' ' || INITCAP(hri.name) || ' credential is ' || hri_award.madlibs || ' offered by ' || hri.instlegalname || '.', -- Madlibs construction for description
  "Audience Level Type" = hri_award.audience_level 
FROM thecb.hri_award_type_crosswalk hri_award
WHERE hri.degreelevel in ('2','3')
  AND hri.degreelevel = hri_award.program_inv_award_level AND substring (hri.degreename, 1, 3) = substring (hri_award.program_inv_cer, 1, 3);
	  
/*
2. Run UPDATE to enrich with IPEDS information (institution webpage)
*/
-- First crosswalk
UPDATE thecb.credential_hri hri
SET "Subject Webpage" = ipeds.website
FROM 
  thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE hri.fice = cw.fice 
AND cw.opeid8 = ipeds.opeid8;

/*
3. Run quality check queries as needed
*/
-- Identify institutions that aren't recognized by FICE-OPEDID crosswalk
SELECT count(distinct instlegalname) 
FROM thecb.credential_hri where "Subject Webpage" = 'TBD-IPEDS-Webpage';

SELECT DISTINCT instlegalname 
FROM thecb.credential_hri where "Subject Webpage" = 'TBD-IPEDS-Webpage';					  

/*
4. Move to the script for creating the matching staging table for organizations (build_organizations_univ.sql)
*/

/*
5. Verify CTID's where added
*/
SELECT DISTINCT instlegalname, "Owned By" from thecb.credential_hri

/*

5. Run SELECT to create result set for saving to CSV
*/

SELECT * from thecb.credential_hri 
WHERE "Subject Webpage" != 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname

SELECT * from thecb.credential_hri
WHERE "Subject Webpage" = 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname

SELECT * from thecb.credential_hri 
where degreelevel = '2'
and degreename like 'CER%'
--WHERE "Credential Type" = 'TYPE_LOOKUP_ERROR 1'
--AND "Credential Name" like 'CER%'
ORDER BY  instlegalname
