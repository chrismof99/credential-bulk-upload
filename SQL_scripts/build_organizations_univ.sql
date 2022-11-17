/*
Extract institutions we need to handle, based on University credential results
*/

DROP TABLE IF EXISTS thecb.univ_org_fice;

select distinct fice, instlegalname 
into thecb.univ_org_fice from thecb.credential_univ;

select count(*) from thecb.univ_org_fice;

/*
Build up organization table
*/
DROP TABLE IF EXISTS thecb.organization_univ;

SELECT 
 inst.instfice fice, 
 inst.insttype,
 inst.instlegalname "Name",
 'TBD-CE' "CTID",
 'thecb_inst' || '_' ||inst.instfice "External Identifier",
 'TBD-IPEDS' "Webpage",
 'TBD-IPEDS' "Description",
 --'TBD-IPEDS' "Description2",
 'TBD-THECB' "PrimaryPhoneNumber",
 'TBD-THECB' "PrimaryPhoneNumberExtension",
 'TBD-THECB' "PrimaryEmail",
 'CredentialOrganization' "Publishing Roles",
 'BulkUpload' "Publishing Methods",
 'Public' "Organization Sector",
 insttype.ce_agent_type "Organization Types",
 'chris.moffatt@touchdownllc.com' "Contact Email",
 'Chris' "Contact First Name",
 'Moffatt' "Contact Last Name",
 'TBD-IPEDS' "Street Address",
 'TBD-IPEDS'"City",
 'Texas'"StateProvince",
 'TBD-IPEDS'"PostalCode",
 'United States'"Country",
 'TBD' "Publishing Estimates"
 into thecb.organization_univ
from
  thecb.univ_org_fice orgfice,
  thecb.institution inst,
  thecb.inst_type_lookup insttype
 where
   orgfice.fice = inst.instfice
   and insttype.inst_type_code = inst.insttype;

/*
Enrich with IPEDS data
*/
update thecb.organization_univ org
set "Webpage" =ipeds.website,
    "Description" = ipeds.mission_statement,
	"Street Address" = ipeds.street_address,
	"City" = ipeds.city,
	"PostalCode" = ipeds.zip
FROM thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE org.fice = cw.fice
  and cw.opeid8 = ipeds.opeid8;
  

-- 2nd crosswalk
/*
update thecb.organization_univ org
set "Webpage" =ipeds.website,
    "Description" = ipeds.mission_statement,
	"Street Address" = ipeds.street_address,
	"City" = ipeds.city,
	"PostalCode" = ipeds.zip
FROM thecb.opeid_fice_crosswalk2 cw,
  thecb.ipeds ipeds
WHERE org.fice = cw.fice
  and cw.opeid8 = ipeds.opeid8;
*/
-- crosswalk mismatch
select count(distinct "Name") from thecb.organization_univ
where "Webpage" = 'TBD-IPEDS';

select distinct "Name" from thecb.organization_univ
where "Webpage" = 'TBD-IPEDS';

/* 
Add madlibs description where no mission statement
*/
UPDATE thecb.organization_univ org
SET "Description" = org."Name" || ' is ' || it.madlibs ||'.'
FROM thecb.inst_type_lookup it
WHERE ("Description" is null OR "Description" = 'TBD-IPEDS')
AND it.inst_type_code = org.insttype;

select * from thecb.organization_univ order by "Webpage";
