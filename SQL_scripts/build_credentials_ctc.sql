
/*
Build up Credential table for CTC's
*/

DROP TABLE IF EXISTS thecb.credential_ctc;

SELECT
  ca.awardid,
  ca.fice,
  ca.level,
  inst.instlegalname,
  INITCAP(cp.name) program_name,
  'TBD-ORGCTID' "Owned By",
  'ctc_clearinghouse' || '_' || ca.awardid || '_' || ca.fice || '_' || ca.cip6 || '_' || ca.seq || '_' || ca.abbrev "External Identifier",
  INITCAP(ca.title) "Credential Name",
  award.ctdl_credential_type "CredentialType", 
  -- MADLIBS-Description
  'The ' || INITCAP(ca.title) || ' credential is ' || award.madlibs
    || ' offered by the ' || INITCAP(cp.name) || ' program at ' || inst.instlegalname || '.' "Description",

  'TBD-IPEDS-Webpage' "Subject Webpage",
  'Active' "Credential Status", 
  'English-en' "Language",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Approved By",
  'ce-4ea8b911-5659-49e0-b382-8dfed5277bbf' "Regulated By",
  substring (ca.cip6,1,2) || '.' || substring (ca.cip6,3,4) "CIP List"
INTO thecb.credential_ctc
FROM thecb.ctc_clearinghouse_award ca,
  thecb.ctc_clearinghouse_program cp,
  thecb.institution inst,
  thecb.award_type_crosswalk award
WHERE (ca.fice = cp.fice AND ca.programcip6 = cp.cip6 AND ca.programseq = cp.seq)
  AND (ca.fice = inst.instfice AND inst.insttype = '3' AND award.inst_type_id = inst.insttype)
  AND ca.level = award.program_inv_award_level
  AND (to_date(ca.startdate,'YYYYMMDD') is null OR to_date(ca.startdate, 'YYYYMMDD') < '2022-11-30')
  AND (to_date(ca.enddate,'YYYYMMDD') is null OR to_date(ca.enddate, 'YYYYMMDD') > '2022-11-30');

--Enrich with IPEDS information - institution webpage 
UPDATE thecb.credential_univ cu
SET "Subject Webpage" = ipeds.website
FROM thecb.opeid_fice_crosswalk cw,
  thecb.ipeds ipeds
WHERE cu.fice = cw.fice
  AND cw.opeid8 = ipeds.opeid8;

-- Identify institutions that aren't recognized by FICE-OPEDID crosswalk
select distinct instlegalname 
from thecb.credential_ctc where "Subject Webpage" = 'TBD-IPEDS-Webpage';

select * from thecb.credential_ctc;