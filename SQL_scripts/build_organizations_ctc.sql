/*
File: build_organizations_ctc.sql

Function: Extract institutions we need to handle, based on CTC credential results

Output: Bulk staging table: thecb.organization_ctc

Steps
1. First, follow instructions in build_credentials_ctc.sql  -- to create credentials staging table
2. Run DROP, SELECT INTO query to create and populate Lookup table: thecb.ctc_org_fice
3. Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_ctc
4. Run UPDATE to Enrich with IPEDS data
5. Run UPDATE to add madlibs description where no mission statement found
6. Run quality check queries as needed
7. Update Credential records table with generated ORG CTID
8. Run SELECT to create result set for saving to CSV
*/

/*
1. First, follow instructions in build_credentials_ctc.sql  -- to create credentials staging table
*/

/*
2. Run DROP, SELECT INTO query to create and populate Lookup table: thecb.ctc_org_fice
*/

DROP TABLE IF EXISTS thecb.ctc_org_fice;

select distinct fice, instlegalname 
into thecb.ctc_org_fice from thecb.credential_ctc;

select count(*) from thecb.ctc_org_fice;

/*
3. Run DROP, SELECT INTO query to create and populate bulk staging table: thecb.organization_ctc
*/

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
 'TBD-CONTACT-IPEDS' "PrimaryEmail",
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

/*
4. Run UPDATE to Enrich with IPEDS data
*/
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
  

/*
5. Run UPDATE to add madlibs description where no mission statement found
*/

UPDATE thecb.organization_ctc org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;

/*
6. Run quality check queries as needed
*/
/*
-- crosswalk mismatch
select count(distinct fice) from thecb.organization_ctc
where "Webpage" = 'TBD-IPEDS';
*/

/*
7. Update Credential records table with generated ORG CTID
*/
/*
UPDATE thecb.credential_ctc ctc
SET "Owned By" = org."CTID"
FROM thecb.organization_ctc org
WHERE ctc.fice = org.fice;
*/

/*
8. Run SELECT to create result set for saving to CSV
*/
--select * from thecb.organization_ctc order by "Name";


select * from thecb.organization_ctc
where "Webpage" != 'TBD-IPEDS'
order by fice;

--select * from thecb.organization_ctc
--where "Webpage" = 'TBD-IPEDS'
--order by fice;