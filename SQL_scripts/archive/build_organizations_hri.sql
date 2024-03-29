/*
File: build_organizations_hri.sql

Function: Extract institutions we need to handle, based on HRI credential results

Output: Bulk staging table: thecb.organization_hri

Steps
1. First, follow instructions in build_credentials_hri.sql  -- to create credentials staging table
2. Run DROP, SELECT INTO query to create and populate Lookup table: thecb.hri_org_fice
3. Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_hri
4. Run UPDATE to Enrich with IPEDS data
5. Run UPDATE to add madlibs description where no mission statement found
6. Run quality check queries as needed
7. Update Credential records table with generated ORG CTID
8. Run SELECT to create result set for saving to CSV
*/

/*
1. First, follow instructions in build_credentials_hri.sql  -- to create credentials staging table
*/

/* 
2. Run SQL to create and populate Lookup table: thecb.hri_org_fice
*/
DROP TABLE IF EXISTS thecb.hri_org_fice;

select distinct fice, instlegalname 
into thecb.hri_org_fice from thecb.credential_hri;

/*
3. Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_hri
*/
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

/*
4. Run UPDATE to Enrich with IPEDS data
*/
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
  

/* 
5. Run UPDATE to add madlibs description where no mission statement found
*/
UPDATE thecb.organization_hri org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;


/*
6. Run quality check queries as needed
*/
/*
select count(*) from thecb.hri_org_fice;

select * from thecb.organization_hri order by "Name";

select * from thecb.organization_hri 
where "Webpage" != 'TBD-IPEDS'
order by fice;

-- crosswalk mismatch
select count(distinct "Name") from thecb.organization_hri
where "Webpage" = 'TBD-IPEDS';

select distinct "Name" from thecb.organization_hri
where "Webpage" = 'TBD-IPEDS';
*/

/*
7. Update Credential records table with generated ORG CTID
*/

/*
UPDATE thecb.credential_hri hri
SET "Owned By" = org."CTID"
FROM thecb.organization_hri org
WHERE hri.fice = org.fice;
*/


/*
8. Run SELECT to create result set for saving to CSV
*/
SELECT * from thecb.organization_hri;

--select * from thecb.organization_hri 
--where "Webpage" = 'TBD-IPEDS'
--order by fice;

--select * from thecb.organization_hri 
--where "Webpage" = 'TBD-IPEDS'
--order by fice;