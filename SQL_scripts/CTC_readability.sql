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



/*
UPDATE thecb.credential_ctc_readability 
SET "Credential Name" = concat (substring ("Credential Name",11), ' ' || substring ("Credential Name",1,9))
WHERE substring ("Credential Name",1,9) like '(%';

-- remove numbered parentheses from Description field (117)
UPDATE thecb.credential_ctc_readability 
SET "Description" = regexp_replace("Description", '\s*\(\d+\.\d+\)', '')
where "Description" ~ '\s*\(\d+\.\d+\)';
/*

---- HERE ----

-- Set title casing
/* More */

--DROP TABLE IF EXISTS thecb.credential_ctc_readability;
--SELECT * INTO thecb.credential_ctc_readability FROM thecb.credential_ctc ;

/*
select "Credential Name", "Description" from thecb.credential_ctc 
where "Credential Name" ~ '\s*\(\d+\.\d+\)'

select "Credential Name", "Description" from thecb.credential_ctc_readability 
where "Credential Name" ~ '\s*\(\d+\.\d+\)'
*/

