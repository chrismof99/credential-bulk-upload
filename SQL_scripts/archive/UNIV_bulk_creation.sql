/*
UNIV Bulk file
*/

/*
CREDENTIAL - PART 1
*/

-- Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
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

-- Run UPDATE to enrich with IPEDS information (institution webpage)
UPDATE thecb.credential_univ cu
SET "Subject Webpage" = ipeds.website
FROM 
  thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE cu.fice = cw.fice
  AND cw.opeid8 = ipeds.opeid8;

-- Run UPDATE to appply distance ed information where it exists
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
ORGANIZATION File
*/

-- Run SQL to create and populate Lookup table: thecb.univ_org_fice
DROP TABLE IF EXISTS thecb.univ_org_fice;
select distinct fice, instlegalname 
into thecb.univ_org_fice from thecb.credential_univ;

-- Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_univ
DROP TABLE IF EXISTS thecb.organization_univ;

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
 into thecb.organization_univ
from
  thecb.univ_org_fice orgfice,
  thecb.institution inst,
  thecb.inst_type_lookup insttype
 where
   orgfice.fice = inst.instfice
   and insttype.inst_type_code = inst.insttype;

-- Run UPDATE to Enrich with IPEDS data
UPDATE thecb.organization_univ org
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
UPDATE thecb.organization_univ org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;


/*
CREDENTIAL - PART 2
*/
-- Update Credential records table with generated ORG CTID
UPDATE thecb.credential_univ cu
SET "Owned By" = org."CTID"
FROM thecb.organization_univ org
WHERE cu.fice = org.fice ;

-- Run SELECT to create result set for saving to bulk CSV template
select * from thecb.organization_univ order by "Name";
select * from thecb.credential_univ order by instlegalname;