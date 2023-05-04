-- UNIV

select * from thecb.univ_degree where tableseq in ('33542', '12663');

select * from thecb.univ_degree_program where tableseq in ('33542', '12663');

select * from thecb.credential_univ where tableseq in ('33542', '12663');


-- CTC
select fice from thecb.ctc_clearinghouse_award where awardid in ('20929', '20930');

select * from thecb.ctc_clearinghouse_program where  fice = '008901'

select * from thecb.ctc_clearinghouse_award  where fice = '003626'

select * from thecb.ctc_clearinghouse_award where fice = '008901'

select * from thecb.credential_ctc where awardid in ('20929', '20930');

select * from thecb.credential_ctc where fice = '008901'

select fice, instlegalname from thecb.credential_ctc where instlegalname like 'Tarrant%'

select * from thecb.institution where instfice = '008901'

select instfice, instlegalname from thecb.institution where instlegalname like 'Tarrant%'

select * from thecb.opeid_fice_crosswalk where institution_name like 'Tarrant%'

select * from thecb.ipeds where institution_name like 'Tarrant%'

"Tarrant County Junior College Trinity River Campus"


SELECT ca.awardid, ca.fice , cp.programid, cp.fice
FROM 
  thecb.ctc_clearinghouse_award ca
LEFT JOIN thecb.ctc_clearinghouse_program cp ON (ca.fice = cp.fice AND ca.programcip6 = cp.cip6 AND ca.programseq = cp.seq)
where ca.awardid in ('20929', '20930');



/*
SELECT ca.startdate, ca.enddate, ca.awardid, cp.programid, ca.fice , cp.fice, ca.programcip6, cp.cip6, ca.programseq, cp.seq
FROM 
  thecb.ctc_clearinghouse_award ca
LEFT JOIN thecb.ctc_clearinghouse_program cp ON (ca.fice = cp.fice AND ca.programcip6 = cp.cip6 AND ca.programseq = cp.seq)
where ca.awardid in ('20929', '20930');
*/

/*
UPDATE thecb.ctc_clearinghouse_award 
SET fice = '003626' 
WHERE awardid in ('20929', '20930');

UPDATE thecb.ctc_clearinghouse_program 
SET fice = '003626'
WHERE programid = '6777';
*/

/*
UPDATE thecb.ctc_clearinghouse_award 
SET fice = '008901'
WHERE awardid in ('20929', '20930');

UPDATE thecb.ctc_clearinghouse_program 
SET fice = '008901'
WHERE programid = '6146';





