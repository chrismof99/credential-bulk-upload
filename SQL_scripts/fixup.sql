-- Fixup webpage entries in IPEDS -- ensure has "https:" in the prefix
*/
update thecb.ipeds
set website = 'https://' || website
where left(website,8) != 'https://';

update thecb.ipeds
set mission_statement_url = 'https://' || mission_statement_url
where left(mission_statement_url,8) != 'https://';


// fixup casing in program inventory tables
select title, lower(title) , INITCAP(title) from thecb.ctc_clearinghouse_award;

UPDATE thecb.ctc_clearinghouse_award
SET title = lower(t)

