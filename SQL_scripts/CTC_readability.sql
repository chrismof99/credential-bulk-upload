/* 
TEMP FIXUP 2 two rows in CTC  -- see email with Jana - 3-1
*/
/*
SELECT ca.startdate, ca.enddate, ca.awardid, cp.programid, ca.fice , cp.fice, ca.programcip6, cp.cip6, ca.programseq, cp.seq
FROM 
  thecb.ctc_clearinghouse_award ca
LEFT JOIN thecb.ctc_clearinghouse_program cp ON (ca.fice = cp.fice AND ca.programcip6 = cp.cip6 AND ca.programseq = cp.seq)
where ca.awardid in ('20929', '20930');
*/

/*
UPDATE thecb.ctc_clearinghouse_award 
SET fice = '003626' , enddate = null
WHERE awardid in ('20929', '20930');

UPDATE thecb.ctc_clearinghouse_program 
SET fice = '003626'
WHERE programid = '6777';
*/

/*
Scripts to improve the readability of of CTC credentials -- title and description
*/

DROP TABLE IF EXISTS thecb.ctc_clearinghouse_award_readability;
SELECT * INTO thecb.ctc_clearinghouse_award_readability FROM thecb.ctc_clearinghouse_award;

-- Move pre-pended parentheses at the beginning of the Credential name to the end -- 117 found

UPDATE thecb.ctc_clearinghouse_award_readability
SET title = concat (substring (title,11), ' ' || substring (title,1,9))
WHERE substring (title,1,9) like '(%';

-- remove numbered parentheses from Description field (117)
UPDATE thecb.ctc_clearinghouse_award_readability 
SET title = regexp_replace(title, '\s*\(\d+\.\d+\)', '')
where title ~ '\s*\(\d+\.\d+\)';

--select title from thecb.ctc_clearinghouse_award_readability;

UPDATE thecb.ctc_clearinghouse_award_readability
SET title = INITCAP(title);

UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Aa ', 'AA ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Aas ', 'AAS ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'As ', 'AS ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Atc ', 'ATC ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Aat ', 'AAT ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Bas ', 'BAS ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Bsn ', 'BSN ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Cad ', 'CAD ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Ceu ', 'CEU ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Cit ', 'CIT ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Esc ', 'ESC ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Hvac ', 'HVAC ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Osa ', 'OSA ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Pc ', 'PC ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Cadd ', 'CADD ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Ccoe ', 'CCOE ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Cnc ', 'CNC ');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, '2d', '2D');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, '3d', '3D');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Tdc', 'TDC');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Ii', 'II');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Cis', 'CIS');
UPDATE thecb.ctc_clearinghouse_award_readability SET title= REPLACE (title, 'Ser', 'SER');


