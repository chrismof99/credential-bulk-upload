/*
HRI Bulk - Organisation and Credential
*/

/*
CREDENTIAL PART 1
*/
-- Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
DROP TABLE IF EXISTS thecb.credential_hri;

SELECT 
  -- Tracking, lookup fields
  ud.fice,
  up.programcip,
  up.programcipsub,
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
  'TBD-DISTANCE' "Learning Delivery Type",
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
  AND ((up.datestart = null or up.datestart < CURRENT_DATE) 
  AND (up.dateend is null or up.dateend > CURRENT_DATE));

-- Enrich with award-type info -- multiple passes (TO BE IMPROVED)
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
	  
-- Run UPDATE to enrich with IPEDS information (institution webpage)
UPDATE thecb.credential_hri hri
SET "Subject Webpage" = ipeds.website
FROM 
  thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE hri.fice = cw.fice 
AND cw.opeid8 = ipeds.opeid8;	

-- Run UPDATE to appply distance ed information where it exists
UPDATE thecb.credential_hri hri
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
    hri.fice = da.ficecode
	AND hri.programcip = da.programcip 
	AND hri.programcipsub = da.cipsub;

--Now default the rest to "InPerson"
UPDATE thecb.credential_hri hri
SET "Learning Delivery Type" = 'InPerson'
WHERE "Learning Delivery Type" = 'TBD-DISTANCE';

/*
ORGANIZATION FILE
*/ 
-- Run SQL to create and populate Lookup table: thecb.hri_org_fice
DROP TABLE IF EXISTS thecb.hri_org_fice;

select distinct fice, instlegalname 
into thecb.hri_org_fice from thecb.credential_hri;

-- Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_hri
DROP TABLE IF EXISTS thecb.organization_hri;

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
 'Public' "OrganizationSector",
 insttype.ce_agent_type "Organization Types",
 'Tiffani.Tatum@highered.texas.gov' "Contact Email",
 'Tiffani' "Contact First Name",
 'Tatum' "Contact Last Name",
 'TBD-IPEDS' "Street Address",
 'TBD-IPEDS'"City",
 'Texas'"StateProvince",
 'TBD-IPEDS'"PostalCode",
 'United States'"Country"
 into thecb.organization_hri
from
  thecb.hri_org_fice orgfice,
  thecb.institution inst,
  thecb.inst_type_lookup insttype
 where
   orgfice.fice = inst.instfice
   and insttype.inst_type_code = inst.insttype;

-- Run UPDATE to Enrich with IPEDS data
UPDATE thecb.organization_hri org
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
UPDATE thecb.organization_hri org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;

/* 
CREDENTIAL PART 2
*/
-- Update Credential records table with generated ORG CTID
UPDATE thecb.credential_hri hri
SET "Owned By" = org."CTID"
FROM thecb.organization_hri org
WHERE hri.fice = org.fice;


-- Run SELECT to create result set for saving to bulk CSV template
select * from thecb.organization_hri order by "Name";
select * from thecb.credential_hri order by instlegalname;