
/*
File: build_credentials_univ.sql

Function: Builds up Credential table for Universities

Output: Bulk staging table: thecb.credential_univ

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

DROP TABLE IF EXISTS thecb.credential_univ;

SELECT 
  -- Tracking, lookup fields
  ud.fice,
  inst.instlegalname,
  'TBD-ORGCTID' "Owned By",
  'univ_degree' || '_' || ud.tableseq || '_' || ud.fice || '_' || ud.programcip || '_' || ud.programcipsub  "External Identifier",
  ud.degreename || ' ' || INITCAP(up.name) "Credential Name",
  award.ctdl_credential_type "CredentialType", 
  -- Madlibs construction for description
  'The ' || ud.degreename || ' ' || INITCAP(up.name) || ' credential is ' || award.madlibs || ' offered by ' || inst.instlegalname || '.' "Description",
  'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By", -- THECB CTID
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By", -- THECB CTID
  substring (ud.programcip,1,2) || '.' || substring (ud.programcip,3,4) "CIP List"
INTO thecb.credential_univ
FROM thecb.univ_degree ud,
  thecb.univ_degree_program up, 
  thecb.institution inst, 
  thecb.award_type_crosswalk award
WHERE
  -- Join Univ and Univ_Program tables
  (ud.fice = up.fice AND ud.programcip = up.programcip AND ud.programcipsub = up.programcipsub)
  -- Join with Institution table to get institution type
  AND (up.fice = inst.instfice AND inst.insttype in ('1', '5', '6'))
	-- Join with Award crosswalk to get credential type
	AND (award.inst_type_id = inst.insttype AND ud.degreelevel = award.program_inv_award_level)
  -- Filter by start/end dates
  AND ((up.datestart = null or up.datestart < '2022-11-30') 
  AND (up.dateend is null or up.dateend > '2022-11-30'));

/*
2. Run UPDATE to enrich with IPEDS information (institution webpage)
*/
-- First crosswalk
UPDATE thecb.credential_univ cu
SET "Subject Webpage" = ipeds.website
FROM 
  thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE cu.fice = cw.fice
  AND cw.opeid8 = ipeds.opeid8;

-- 2nd crosswalk
/*
UPDATE thecb.credential_univ cu
SET "Subject Webpage" = ipeds.website
FROM thecb.opeid_fice_crosswalk2 cw,
  thecb.ipeds ipeds
WHERE cu.fice = cw.fice
  and cw.opeid8 = ipeds.opeid8;
*/

/*
3. Run quality check queries as needed
*/
-- Identify institutions that aren't recognized by FICE-OPEDID crosswalk
SELECT count(distinct instlegalname) 
FROM thecb.credential_univ where "Subject Webpage" = 'TBD-IPEDS-Webpage';

SELECT DISTINCT instlegalname 
FROM thecb.credential_univ where "Subject Webpage" = 'TBD-IPEDS-Webpage';

SELECT * from thecb.credential_univ
 where "Owned By" in ('ce-481a71f8-17fe-4e1e-9a89-df242ef08d5e','ce-b8089143-9786-408f-859a-e0ea5b7ee5fd','ce-1597374d-e19c-4b8b-9182-8c817fd9c2a9', 
					  'ce-fae94918-cabc-480c-907d-8e8305569047','ce-091cb7d3-38f6-4c5f-8fed-ab471ee5e3c3')
					  

/*
4. Move to the script for creating the matching staging table for organizations (build_organizations_univ.sql)
*/

/*
5. Verify CTID's where added
*/
SELECT DISTINCT instlegalname, "Owned By" from thecb.credential_univ

/*

5. Run SELECT to create result set for saving to CSV
*/
SELECT * from thecb.organization_univ