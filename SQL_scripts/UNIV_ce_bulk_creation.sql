/*
UNIV Bulk file
*/

-- Fix dates in UNIV where 2 digit dates should be 19th century
/*
select datestart , datestart - INTERVAL '100 years'
from thecb.univ_degree
where datestart > '2050-01-01'
*/

UPDATE thecb.univ_degree
SET datestart = datestart - INTERVAL '100 years'
where datestart > '2050-01-01';


/*
CREDENTIAL - PART 1
*/

-- Run the SELECT INTO query to create and populate bulk staging table: thecb.credential_univ
DROP TABLE IF EXISTS thecb.credential_univ;
SELECT 
  -- Tracking, lookup fields
  ud.tableseq,
  ud.fice,
  ud.programcip,
  ud.programcipsub,
  ud.degreename,
  ud.degreelevel,
  ud.inserttime,
  ud.updatetime,
  ud.datestart,
  ud.dateend,
  --up.name programname,
  up_readability.name programname,
  inst.instlegalname,
  'TBD-ORGCTID' "Owned By",
  '' "CTID",
  'univ_degree' || '_' || ud.tableseq || '_' || ud.fice || '_' || ud.programcip || '_' || ud.programcipsub  "External Identifier",
  --ud.degreename || ' ' || INITCAP(up.translatename) "Credential Name",
  ud.degreename || ' ' || INITCAP(up_readability.translatename) "Credential Name",
  -- AWARD TYPE INLINE 
  CASE
  	WHEN ud.degreelevel = '1' AND ud.degreename != 'CER' THEN 'AssociateDegree'
	WHEN ud.degreelevel = '2'  AND ud.degreename != 'CER' THEN 'BachelorDegree'
	WHEN ud.degreelevel = '3' AND ud.degreename != 'CER' THEN 'MasterDegree'
	WHEN ud.degreelevel = '3' AND ud.degreename = 'CER' THEN 'Certificate'
	WHEN ud.degreelevel = '4' AND ud.degreename != 'CER' THEN 'ResearchDoctorate'
	WHEN ud.degreelevel = '5' AND ud.degreename != 'CER' THEN 'ProfessionalDoctorate'
	ELSE 'ERROR-UNMATCHED'
  END "Credential Type",
  -- AUDIENCE LEVEL TYPE INLINE,
  CASE
  	WHEN ud.degreelevel = '1' THEN 'AssociatesDegreeLevel'
	WHEN ud.degreelevel = '2'  THEN 'BachelorsDegreeLevel'
	WHEN ud.degreelevel = '3'  THEN 'MastersDegreeLevel'
	WHEN ud.degreelevel in ('4', '5') THEN 'DoctoralDegreeLevel'
	ELSE 'ERROR-UNMATCHED'
  END "Audience Level Type",-- univ_award.ctdl_credential_type "Credential Type", 
 -- 'The ' || ud.degreename || ' ' || INITCAP(up.translatename) || ' credential is offered by ' || inst.instlegalname || '.' "Description",  -- Madlibs construction for description
 'The ' || ud.degreename || ' ' || INITCAP(up_readability.translatename) || ' credential is offered by ' || inst.instlegalname || '.' "Description",  -- Madlibs construction for description
 'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By", -- THECB CTID
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By", -- THECB CTID
  ud.datestart "Date Effective",
 -- 'InPerson' "Learning Delivery Type",   -- Default to InPerson
  substring (ud.programcip,1,2) || '.' || substring (ud.programcip,3,4) "CIP List"
INTO thecb.credential_univ
FROM thecb.univ_degree ud
    LEFT JOIN thecb.institution inst on ud.fice = inst.instfice
--	LEFT JOIN thecb.univ_degree_program up on ud.fice = up.fice AND ud.programcip = up.programcip AND ud.programcipsub = up.programcipsub 
	LEFT JOIN thecb.univ_degree_program_readability up_readability on ud.fice = up_readability.fice AND ud.programcip = up_readability.programcip AND ud.programcipsub = up_readability.programcipsub 
WHERE
  (ud.datestart is null or ud.datestart <= CURRENT_DATE)  -- Filter by start/end dates
  AND (ud.dateend is null or ud.dateend > CURRENT_DATE)
  AND inst.insttype = '1';
  
-- Run UPDATE to enrich with IPEDS information (institution webpage)
UPDATE thecb.credential_univ cu
SET "Subject Webpage" = ipeds.website
FROM 
  thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE cu.fice = cw.fice
  AND cw.opeid8 = ipeds.opeid8;



-- Run UPDATE to appply distance ed information where it exists ('OnlineOption'). Rows not found stay with the default set above ('InPerson')
/*
-- 3/1 - remove Learning Delivery Type from initial upload
UPDATE thecb.credential_univ cu
SET "Learning Delivery Type" = 'OnlineOption'
FROM thecb.active_disted_awards_dedup da
WHERE cu.fice = da.ficecode
	AND cu.programcip = da.programcip 
	AND cu.programcipsub = da.cipsub
	AND cu.degreename = da.award;
*/

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
 'TBD-CTID' "CTID",
 'thecb_inst' || '_' ||inst.instfice "External Identifier",
 'TBD-IPEDS' "Webpage",
 'TBD-IPEDS' "Description",
 'TBD-CONTACT-IPEDS' "PrimaryPhoneNumber",
 'Tiffani.Tatum@highered.texas.gov' "PrimaryEmail",
 'CredentialOrganization' "Publishing Roles",
 'BulkUpload' "Publishing Methods",
 'Public' "OrganizationSector",
 insttype.ce_agent_type "Organization Types",
 'chris.moffatt@touchdownllc.com' "Contact Email",
 'Chris' "Contact First Name",
 'Moffatt' "Contact Last Name",
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

-- Run UPDATE to Enrich with IPEDS data & add assigned CTID
UPDATE thecb.organization_univ org
SET "CTID" = cw.org_ctid,
    "PrimaryPhoneNumber" = ipeds.phone,
    "Webpage" =ipeds.website,
    "Description" = ipeds.mission_statement,
	"Street Address" = ipeds.street_address,
	"City" = ipeds.city,
	"PostalCode" = ipeds.zip
FROM thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE org.fice = cw.fice
  and cw.opeid8 = ipeds.opeid8;
  
/*
Update CTID for organizations that are already in Credential engine
*/
UPDATE thecb.organization_univ org
SET "CTID" = ct.org_ctid
FROM thecb.org_ctid_mapping ct
WHERE org."Name" =  ct.institution_name
AND ct.institution_type = '1' ;

  
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

-- Update Credential records with pre-assigned CTIDS
UPDATE thecb.credential_univ cu
SET "CTID" = cred.credential_ctid
FROM thecb.credential_ctid_mapping cred
WHERE cu."External Identifier" =  cred.thecb_identifier;

-- Run SELECT to create result set for saving to bulk CSV template
select * from thecb.organization_univ order by "Name";
select * from thecb.credential_univ order by instlegalname;

