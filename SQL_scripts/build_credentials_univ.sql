
/*
File: build_credentials_univ.sql

Function: Builds up Credential table for Universities & BAYLOR (ID 01, 06)

Output: Bulk staging table: thecb.credential_univ

Steps
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
2. Run UPDATE to enrich with IPEDS information
3. Move to the script for creating the matching staging table for organizations (build_organizations_univ.sql)
    --- as part of this, the "Owned By" field is updated withOrg CTID
4. Run quality check queries as needed
5. Run SELECT to create result set for saving to Bulk CSV template

*/

/*
1. Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
*/

DROP TABLE IF EXISTS thecb.credential_univ;

SELECT 
  -- Tracking, lookup fields
  up.fice,
  up.programcip,
  up.programcipsub,
  inst.instlegalname,
  'TBD-ORGCTID' "Owned By",
  'univ_degree' || '_' || ud.tableseq || '_' || ud.fice || '_' || ud.programcip || '_' || ud.programcipsub  "External Identifier",
  ud.degreename || ' ' || INITCAP(up.name) "Credential Name",
  univ_award.ctdl_credential_type "Credential Type", 
  -- Madlibs construction for description
  'The ' || ud.degreename || ' ' || INITCAP(up.name) || ' credential is ' || univ_award.madlibs || ' offered by ' || inst.instlegalname || '.' "Description",
  'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By", -- THECB CTID
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By", -- THECB CTID
  univ_award.audience_level "Audience Level Type",
  'TBD-DISTANCE' "Learning Delivery Type",   -- Default to InPerson
  substring (ud.programcip,1,2) || '.' || substring (ud.programcip,3,4) "CIP List"
INTO thecb.credential_univ
FROM thecb.univ_degree ud,
  thecb.univ_degree_program up, 
  thecb.institution inst, 
  thecb.univ_award_type_crosswalk univ_award
WHERE
  -- Join Univ and Univ_Program tables
  (ud.fice = up.fice AND ud.programcip = up.programcip AND ud.programcipsub = up.programcipsub)
  -- Join with Institution table to get institution type (Public Universities and Baylor)
  AND (up.fice = inst.instfice AND inst.insttype in ('1', '6'))
	-- Join with Award crosswalk to get credential type
  AND (ud.degreelevel = univ_award.program_inv_award_level)
  -- Filter by start/end dates
  AND ((up.datestart = null or up.datestart < CURRENT_DATE) 
  AND (up.dateend is null or up.dateend > CURRENT_DATE));

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

/*
3. Run UPDATE to appply distance ed information where it exists
*/
/*
UPDATE thecb.credential_univ cu
SET "Learning Delivery Type" = dc.ce_delivery_type
FROM 
	thecb.dist_distanceaward da,
    thecb.distance_ed_crosswalk dc
WHERE
    cu.fice = da.ficecode
	AND cu.programcip = da.programcip 
	AND cu.programcipsub = da.cipsub
	AND da.distancetypeid = dc.distance_ed_typeid
	AND (da.active= '1' and da.deleted= '0'
		 and (da.startdate is null or da.startdate <= CURRENT_DATE)
         and (da.enddate is null) or (da.enddate > CURRENT_DATE)
	);
*/	

UPDATE thecb.credential_univ cu
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
    cu.fice = da.ficecode
	AND cu.programcip = da.programcip 
	AND cu.programcipsub = da.cipsub;
		
--Now default the rest to "InPerson"
UPDATE thecb.credential_univ cu
SET "Learning Delivery Type" = 'InPerson'
WHERE "Learning Delivery Type" = 'TBD-DISTANCE';
/*
4. Move to the script for creating the matching staging table for organizations (build_organizations_univ.sql)
*/
UPDATE thecb.credential_univ cu
SET "Owned By" = org."CTID"
FROM thecb.organization_univ org
WHERE cu.fice = org.fice;

/*
5. Run quality check queries as needed
*/
-- Identify institutions that aren't recognized by FICE-OPEDID crosswalk
--SELECT count(distinct instlegalname) 
--FROM thecb.credential_univ where "Subject Webpage" = 'TBD-IPEDS-Webpage';

--SELECT DISTINCT instlegalname 
--FROM thecb.credential_univ where "Subject Webpage" = 'TBD-IPEDS-Webpage';
--SELECT DISTINCT instlegalname, "Owned By" from thecb.credential_univ;

/*

5. Run SELECT to create result set for saving to CSV
*/

SELECT * from thecb.credential_univ;

--SELECT distinct "Learning Delivery Type" from thecb.credential_univ
--WHERE "Learning Delivery Type" != 'OnlineOnly'

/*
SELECT * from thecb.credential_univ 
WHERE "Subject Webpage" != 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname

SELECT * from thecb.credential_univ 
WHERE "Subject Webpage" = 'TBD-IPEDS-Webpage'
ORDER BY  instlegalname
*/


