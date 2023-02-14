/*
Fixup to IPEDS and FICE crosswalks
*/

/*
Add new rows to IPEDS & FICE crosswalk manually -- provided by THECB (Jana) 
*/
-- Universities - Sul Ross State University Rio Grande College
--select * from thecb.ipeds where institution_name like 'Sul%'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'Sul%'
delete from thecb.ipeds where institution_name = 'Sul Ross State University Rio Grande College'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00000020', 'Sul Ross State University Rio Grande College', '000020', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'Sul Ross State University Rio Grande College', 'Sul Ross State University Rio Grande College',
	'HWY 90 East', 'Alpine','79832', 'https://www.sulross.edu/','00000020', '4328378011',
	'Sul Ross State University in Far West Texas and the Middle Rio Grande Region boasts a combination of small class sizes, an appreciation of both fine arts and the sciences and popular professional programs in a relaxed, friendly environment.', 
	'https://www.sulross.edu/about/', NULL);

-- Texas A&M University at Galveston
--select * from thecb.ipeds where institution_name like 'Texas A&M University%'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'Texas A&M University%'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00010298', 'Texas A&M University at Galveston', '010298', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'Texas A&M University at Galveston', 'Texas A&M University at Galveston',
	'200 Seawolf Parkway', 'Galveston','77554', 'https://tamug.edu/','00010298', '4097404400',
	'Texas A&M University at Galveston is the island campus of Texas A&M University dedicated to developing leaders who are changing the world. We educate nearly 2,300 undergraduate and graduate students annually in maritime and maritime programs whose commitment to our Core Values positions them to fuel the blue economy now and in the future. Spotlight Link 1',
	NULL, NULL);

/*
HRI's
*/
-- Texas A&M University System Health Science Center
--select * from thecb.ipeds where institution_name like 'Texas A&M University System Health Science Center'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'Texas A&M University System Health Science Center'
--delete from thecb.ipeds where institution_name = 'Texas A&M University System Health Science Center'
--delete from thecb.opeid_fice_crosswalk where institution_name = 'Texas A&M University System Health Science Center'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00000089', 'Texas A&M University System Health Science Center', '000089', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'Texas A&M University System Health Science Center', 'Texas A&M University System Health Science Center',
	'8441 Riverside Parkway', 'Bryan','77807', 'https://health.tamu.edu/','00000089', '9794369100',
	'We’re creating the next generation of innovators, advocates, caregivers and life-savers. Founded in 1999 to bring together the health professions of Texas A&M, our relatively young, nimble attitude allows us to keep up with a rapidly evolving health care landscape, while not abandoning our land-grant origins. Through cutting-edge medical research, service and education, we’re addressing the health care needs of the 21st century.',
	 NULL, NULL);

-- Sam Houston State University Medical School
--select * from thecb.ipeds where institution_name like 'Sam Houston State University Medical School'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'Sam Houston State University Medical School'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00103606', 'Sam Houston State University Medical School', '103606', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'Sam Houston State University Medical School', 'Sam Houston State University Medical School',
	'925 City Central Ave', 'Conroe','77304', 'https://www.shsu.edu/academics/osteopathic-medicine/','00103606', '9362025202',
	'Sam Houston State University (SHSU) College of Osteopathic Medicine (COM) seeks to prepare students for the degree of Doctor of Osteopathic Medicine (DO) with an emphasis toward primary care and rural practice, to develop culturally aware, diverse and compassionate physicians, who follow osteopathic principles, that are prepared for residency, and will serve the people of Texas with professionalism and patient-centered care.',
	 NULL, NULL);

-- The University of Texas-Rio Grande Valley - Medical School
--select * from thecb.ipeds where institution_name like 'The University of Texas-Rio Grande Valley - Medical School'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'The University of Texas-Rio Grande Valley - Medical School'
--delete from thecb.ipeds where institution_name = 'The University of Texas-Rio Grande Valley - Medical School'
--delete from thecb.opeid_fice_crosswalk where institution_name = 'The University of Texas-Rio Grande Valley - Medical School'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00203599', 'The University of Texas-Rio Grande Valley - Medical School', '203599', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'The University of Texas-Rio Grande Valley - Medical School', 'The University of Texas-Rio Grande Valley - Medical School',
	'1201 West University Drive', 'Edinburg','78501', 'https://www.utrgv.edu/school-of-medicine/','00203599', '9562961600',
	'Founded in 2013, the UTRGV School of Medicine educates students and graduate physicians, provides patient care, and performs advanced scientific research.',
    NULL, NULL);

-- University of Houston Medical School
select * from thecb.ipeds where institution_name like 'University of Houston Medical School'
select * from thecb.opeid_fice_crosswalk where institution_name like 'University of Houston Medical School'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00203652', 'University of Houston Medical School', '203652', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'University of Houston Medical School', 'University of Houston Medical School',
	'5055 Medical Circle', 'Houston','77204', 'https://www.uh.edu/medicine/','00203652', '7137437047',
	NULL,
	'https://www.uh.edu/medicine/about/', NULL);

-- The University of Texas at Austin Dell Medical School
--select * from thecb.ipeds where institution_name like 'The University of Texas at Austin Dell Medical School'
--select * from thecb.opeid_fice_crosswalk where institution_name like 'The University of Texas at Austin Dell Medical School'

INSERT INTO thecb.opeid_fice_crosswalk VALUES ('00203658', 'The University of Texas at Austin Dell Medical School', '203658', NULL, NULL);

INSERT INTO thecb.ipeds VALUES (
	'The University of Texas at Austin Dell Medical School', 'The University of Texas at Austin Dell Medical School',
	'1501 Red River St.', 'Austin','78712', 'https://dellmed.utexas.edu/','00203658', '5124955555',
	'As a new medical school created in partnership with our community and built on the foundation of a top-tier research university, Dell Medical School is redefining the academic health environment.',
	 NULL, NULL);


/*
URL Fixup
*/
UPDATE thecb.ipeds
SET mission_statement = 'Sul Ross State University in Far West Texas and the Middle Rio Grande Region boasts a combination of small class sizes, an appreciation of both fine arts and the sciences and popular professional programs in a relaxed, friendly environment.'
WHERE institution_name = 'Sul Ross State University';

-- Fixup webpage entries in IPEDS -- ensure has "https:" in the prefix
*/
update thecb.ipeds
set website = 'https://' || website
where left(website,8) != 'https://';

update thecb.ipeds
set mission_statement_url = 'https://' || mission_statement_url
where left(mission_statement_url,8) != 'https://';