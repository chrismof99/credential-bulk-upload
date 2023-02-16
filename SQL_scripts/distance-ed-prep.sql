DROP TABLE IF EXISTS thecb.active_disted_awards;

SELECT * 
INTO thecb.active_disted_awards
FROM thecb.dist_distanceaward 
WHERE
	distancetypeid in ('1','2','3')
	AND (active= '1' and deleted= '0'
    AND (startdate is null or startdate <= CURRENT_DATE)
    AND (enddate is null) or (enddate > CURRENT_DATE));
	

DROP TABLE IF EXISTS thecb.active_disted_awards_dedup;

SELECT ficecode, programcip, awardcip, cipsub, award, distancetypeid, count(*) as cnt 
INTO thecb.active_disted_awards_dedup
FROM thecb.active_disted_awards
GROUP BY ficecode, programcip, awardcip, cipsub, award, distancetypeid
ORDER BY ficecode, programcip, awardcip, cipsub, award, distancetypeid;

select count(*) from thecb.active_disted_awards;

select count(*) from thecb.active_disted_awards_dedup;	