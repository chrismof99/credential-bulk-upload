-- Fixup webpage entries in IPEDS -- ensure has "https:" in the prefix
*/
update thecb.ipeds
set website = 'https://' || website
where left(website,8) != 'https://';

update thecb.ipeds
set mission_statement_url = 'https://' || mission_statement_url
where left(mission_statement_url,8) != 'https://';


// fixup casing in program inventory tables
select name, lower(name), INITCAP(name) from thecb.ctc_clearinghouse_program

UPDATE thecb.ctc_clearinghouse_program
SET name = INITCAP(name)


// Remove number prefixes from titles in ctc_clearinghouse_award;
select title, substring(title,11,100) from thecb.ctc_clearinghouse_award
where title like '(%'

UPDATE thecb.ctc_clearinghouse_award
SET title = substring(title,11,100)
WHERE title like '(%'



// Fix casing in ctc_clearinghouse_award
select title, lower(title) , INITCAP(title) from thecb.ctc_clearinghouse_award;

UPDATE thecb.ctc_clearinghouse_award
SET title = INITCAP(title)

// Now find where TLA's need to be set back to upper case
select title, REPLACE (title, 'Aas', 'AAS')  from thecb.ctc_clearinghouse_award
where substring(title, 1,3) = 'Aas';

select title, REPLACE (title, 'Esc', 'ESC')  from thecb.ctc_clearinghouse_award
where substring(title, 1,3) = 'Esc';

select title, REPLACE (title, 'As', 'AS')  from thecb.ctc_clearinghouse_award
where substring(title, 1,3) = 'As';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Aas', 'AAS')
where substring(title, 1,3) = 'Aas';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Esc', 'ESC')
where substring(title, 1,3) = 'Esc';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Osa', 'OSA')
where substring(title, 1,3) = 'Osa';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Aa', 'AA')
where substring(title, 1,2) = 'Aa';


UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'As', 'AS')
where substring(title, 1,2) = 'As';


UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Atc', 'ATC')
where substring(title, 1,3) = 'Atc';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Aat', 'AAT')
where substring(title, 1,3) = 'Aat';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Cadd', 'CADD')
where substring(title, 1,4) = 'Cadd';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Ccoe', 'CCOE')
where substring(title, 1,4) = 'Ccoe';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Cnc', 'CNC');
where substring(title, 1,4) = 'Ccoe';

UPDATE thecb.ctc_clearinghouse_award
SET title= REPLACE (title, 'Pc', 'PC')
where substring(title,1,2) = 'Pc';


select title from thecb.ctc_clearinghouse_award
where substring(title,1,2) = 'PC';






 

