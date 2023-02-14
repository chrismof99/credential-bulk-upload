-- Fixup webpage entries in IPEDS -- ensure has "https:" in the prefix
*/
update thecb.ipeds
set website = 'https://' || website
where left(website,8) != 'https://';

update thecb.ipeds
set mission_statement_url = 'https://' || mission_statement_url
where left(mission_statement_url,8) != 'https://';


// fixup casing in ctc_clearinghouse_program
select name, lower(name), INITCAP(name) from thecb.ctc_clearinghouse_program

UPDATE thecb.ctc_clearinghouse_program
SET name = INITCAP(name)



// Remove number prefixes from titles in ctc_clearinghouse_award;
select title, substring(title,11,100) from thecb.ctc_clearinghouse_award
where title like '(%'

UPDATE thecb.ctc_clearinghouse_award
SET title = substring(title,11,100)
WHERE title like '(%'

// Fixup to casing in ctc_clearinghouse_program

// Fix casing in ctc_clearinghouse_award
select title, lower(title) , INITCAP(title) from thecb.ctc_clearinghouse_award;

UPDATE thecb.ctc_clearinghouse_award
SET title = INITCAP(title)

// Now find where TLA's need to be set back to upper case
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Aa ', 'AA ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Aas ', 'AAS ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'As ', 'AS ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Atc ', 'ATC ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Aat ', 'AAT ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Bas ', 'BAS ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Bsn ', 'BSN ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Cad ', 'CAD ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Ceu ', 'CEU ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Cit ', 'CIT ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Esc ', 'ESC ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Hvac ', 'HVAC ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Osa ', 'OSA ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Pc ', 'PC ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Cadd ', 'CADD ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Ccoe ', 'CCOE ');
UPDATE thecb.ctc_clearinghouse_award SET title= REPLACE (title, 'Cnc ', 'CNC ');

select title from  thecb.ctc_clearinghouse_award order by title






 

