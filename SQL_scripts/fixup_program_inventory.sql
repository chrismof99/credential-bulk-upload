-- Fix dates in UNIV where 2 digit dates should be 19th century
/*
select datestart , datestart - INTERVAL '100 years'
from thecb.univ_degree
where datestart > '2050-01-01'
*/

UPDATE thecb.univ_degree
SET datestart = datestart - INTERVAL '100 years'
where datestart > '2050-01-01';

-- Fix dates in distance-ed award
/*
select startdate , startdate - INTERVAL '100 years'
from thecb.dist_distanceaward
where startdate > '2030-01-01'
*/

UPDATE thecb.dist_distanceaward
SET startdate = startdate - INTERVAL '100 years'
where startdate > '2050-01-01';




 

