/*
Scripts to improve the readability of of  UNIV credentials -- title and description
*/

DROP TABLE IF EXISTS thecb.univ_degree_program_readability;
SELECT * INTO thecb.univ_degree_program_readability FROM thecb.univ_degree_program;

-- Remove references to years
update thecb.univ_degree_program_readability
set translatename = regexp_replace(translatename, '\d{4}', '')


-- Fix dates in UNIV where 2 digit dates should be 19th century
/*
select datestart , datestart - INTERVAL '100 years'
from thecb.univ_degree
where datestart > '2050-01-01'
*/

UPDATE thecb.univ_degree
SET datestart = datestart - INTERVAL '100 years'
where datestart > '2050-01-01';

