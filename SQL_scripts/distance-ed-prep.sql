-- Fix dates in distance-ed award
/*
select startdate , startdate - INTERVAL '100 years'
from thecb.dist_distanceaward
where startdate > '2030-01-01'
*/

UPDATE thecb.dist_distanceaward
SET startdate = startdate - INTERVAL '100 years'
where startdate > '2050-01-01';


-- Create a table of active distance ed awards. Follows logic from Jana's MTF and QA script
DROP TABLE IF EXISTS thecb.active_disted_awards;

SELECT * INTO thecb.active_disted_awards
FROM thecb.dist_distanceaward 
WHERE
	distancetypeid in ('1','2','3')
	AND active= '1'
	AND deleted= '0'
    AND (startdate is null or startdate <= CURRENT_DATE)
    AND (enddate is null) or (enddate > CURRENT_DATE);
	

DROP TABLE IF EXISTS thecb.active_disted_awards_dedup;

SELECT distanceawardid, ficecode, programcip, awardcip, cipsub, award, count(*) as cnt 
INTO thecb.active_disted_awards_dedup
FROM thecb.active_disted_awards
GROUP BY distanceawardid, ficecode, programcip, awardcip, cipsub, award
ORDER BY distanceawardid, ficecode, programcip, awardcip, cipsub, award;