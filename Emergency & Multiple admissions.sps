*A syntax to create the data for the following indicators of the H&W profiles:
*   Emergency admissions.
*   Multiple emergency admissions (65+).

*Part 1 - Create an extract of all CISs that have a emergency diagnosis, using the CIS lookup file.
*Part 2 - create the emergency admission data, with only one emergency admission per a year for a patient.
*Part 3 - create the multiple admissions data, with patients with 2 or more admission per a year and for age 65+.
*Part 4 - Calling the macros

*Jaime Villacampa  September 17
*First 3 parts take ~30 mins to run
******************************************************************************.
******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
*****************************************************************.
*Part 1 - Create an extract of all CISs that have a emergency diagnosis, using the CIS lookup file.
*****************************************************************.
*read in SMR01 data. Following Secondary Care Team definitions.
INSERT FILE="/home/jamiev01/SMRA_pass.sps".
*people with no valid sex or age.
*Only emergency or urgent admissions.
*Selecting one record per admission.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select distinct link_no, cis_marker, min(AGE_IN_YEARS) age, min(SEX) sex_grp, min(DR_POSTCODE) pc7, "+
      "max(extract(year from discharge_date)) year, min(admission_date) doadm "+
    "FROM ANALYSIS.SMR01_PI  "+
    "where discharge_date between '2002-01-01' and '2016-12-31' " +
      "and sex not in ('9', '0') "+
      "and AGE_IN_YEARS is not null "+
      "and (admission_type between '20' and '22' or admission_type between '30' and '40')  "+
   "group by link_no, cis_marker  "+
   "order by link_no, cis_marker, min(admission_date) "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*match on the datazone2011 configurations from geography lookup file.
sort cases by pc7.
alter type pc7(a21).
match files file = *
   /table = '/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
   /by pc7 /keep  link_no doadm year sex_grp age datazone2001 datazone2011 intzone2011 ca2011 hb2014.
execute.

*Select out non Scottish residents.
select if datazone2011 ne "".
execute.

* Create variable (age_grp) and recode age to show age in 5-year age bands (to match the age bands in the new European Standard Population 2013).
recode age
   (0 thru 4 = 1) (5 thru 9 = 2) (10 thru 14 = 3) (15 thru 19 = 4) (20 thru 24 = 5) 	(25 thru 29 = 6)
   (30 thru 34 = 7) (35 thru 39 = 8) (40 thru 44 = 9) (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)
   (60 thru 64 = 13) (65 thru 69 = 14) (70 thru 74 = 15) (75 thru 79 = 16) (80 thru 84 = 17) (85 thru 89 = 18)
   (90 thru highest = 19)
   into age_grp.
execute.
*for matching later on.
alter type sex_grp (f3.0).

*Saving file that will be used for both indicators and for IRs.
save outfile = 'Raw Data/Prepared Data/SMR01_emergency_basefile.zsav'
/ZCOMPRESSED.

*****************************************************************.
*Part 2 - create the emergency admission data.
*****************************************************************.
*for each patient select their first stay in a year.sort by year and linkno, to get the patients in order.
sort cases by year link_no doadm.
*number the patients stays within that year.
compute staynum = 1.
if (link_no = lag(link_no) & year = lag(year)) staynum = lag(staynum) + 1.
execute.

*select the first stay within each year.
select if staynum = 1.
execute.

*aggregate to get the count for Scotland.
aggregate outfile = *
   /break year sex_grp age_grp
   /numerator = n.

*add in Scotlands code.
string code (A9).
compute code = 'S00000001'.
execute.

dataset name Scotland.
******************************************************************************************************************.
*Now for HB, LA and IZs a macro.
 * patients are only counted once if they move between age groups between emergency admissions
(This is changed for the first aggregation for all geographies except Scotland).
define !ea_agg (data = !tokens(1) ).
get file =  'Raw Data/Prepared Data/SMR01_emergency_basefile.zsav'
/rename (!data =code).

*aggregate to get the count for health board.
aggregate outfile = *
   /break link_no year code
   /sex_grp age_grp = first(sex_grp age_grp).

*aggregate again to count one patient in each health board.
aggregate outfile = *
   /break year sex_grp age_grp code
   /numerator = n.

alter type code(a9).

dataset name !data.
!enddefine.

!ea_agg data=HB2014.
!ea_agg data=ca2011.
!ea_agg data=intzone2011.

*Now for IZ2011.
add files file = Scotland
   /file = HB2014
   /file = ca2011
   /file = intzone2011.
execute.

save outfile = 'Raw Data/Prepared Data/EA_dz11_raw.sav'.

dataset close Scotland.
dataset close HB2014.
dataset close ca2011.
dataset close intzone2011.

*****************************************************************.
*Part 3 - create the multiple admissions data, with patients with 2 or more admission per year and for age 65+.
*****************************************************************.
*patients are only counted once if they move between age groups between emergency admissions
*For Scotland only count each patient once per a year.
get file = 'Raw Data/Prepared Data/SMR01_emergency_basefile.zsav'.

*aggregate to get the count for Scotland.
aggregate outfile = *
   /break link_no year 
   /admissions = n
   /sex_grp age_grp = first(sex_grp age_grp).

*select only patients who have had 2 or more admissions and 65+. and only scottish residents. 
select if admissions >= 2 and age_grp >= 14.
execute.

*aggregate again to count one patient in each Scotland.
aggregate outfile = *
   /break year sex_grp age_grp 
   /numerator = n.

*add in Scotlands code.
string code (A9).
compute code = 'S00000001'.
execute.
dataset name Scotland.

*Now for HB, LA and IZs a small macro.
define !ma_agg (data = !tokens(1) ).
get file = 'Raw Data/Prepared Data/SMR01_emergency_basefile.zsav'
/rename (!data =code).

*aggregate to get the count for health board.
aggregate outfile = *
   /break link_no year code
   /admissions = n
   /sex_grp age_grp = first(sex_grp age_grp).

*select only patients who have had 2 or more admissions and 65+.
select if admissions >= 2 and age_grp >= 14.
execute.

*aggregate again to count one patient in each health board.
aggregate outfile = *
   /break year sex_grp age_grp code
   /numerator = n.

alter type code(a9).

dataset name !data.
!enddefine.

!ma_agg data=hb2014.
!ma_agg data=ca2011.
!ma_agg data=intzone2011.

*Now for IZ2011.
add files file = Scotland
   /file = HB2014
   /file = ca2011
   /file = intzone2011.
execute.

save outfile = 'Raw Data/Prepared Data/MA_dz11_raw.sav'.

dataset close Scotland.
dataset close HB2014.
dataset close ca2011.
dataset close intzone2011.

**********************************************************************.
*Part 4 - Calling the macros
************************************************************************.
**Syntax to call the macro that formats EA & MA data ready for analysis macro.
INSERT FILE= !macros+"Raw data - EA & MA.sps".

***Indicator: emergency admissions.
!rawdata data='EA_dz11' domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' 
pop=DZ11_pop_allages_SR yearstart=2002 yearend=2016.

*Taking out IZ2011 for years where it does not have population.
get file ='Output/EA_dz11_formatted.sav'.
select if not (substr(code,1,3) = 'S02' and year < 2012).
frequencies year.

save outfile ='Output/EA_all_formatted.sav'.

***Indicator: multiple admissions.
!rawdata data='MA_dz11'  domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' 
pop=DZ11_pop_allages_SR yearstart=2002 yearend=2016.

*Taking out IZ2011 for years where it does not have population.
get file ='Output/MA_dz11_formatted.sav'.
select if not (substr(code,1,3) = 'S02' and year < 2012).
frequencies year.

save outfile ='Output/MA_all_formatted.sav'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE= !macros+"Analysis - standardisation.sps".

*Emergency Admissions. 
!standardisation data='EA_all' domain='Deaths, Injury and Disease' ind_id = 20305 year_type = calendar 
min_opt =397374 max_opt = 999999  Epop_total = 200000 profile = 'HN' .

***Graph for checking results***.
INSERT FILE= !macros+"final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

*Multiple Admissions.
!standardisation data=MA_all domain='Deaths, Injury and Disease' ind_id = 20306 year_type = calendar 
min_opt = 403101 max_opt = 999999  Epop_total = 39000 profile = 'HN'.

***Graph for checking results***.
INSERT FILE= !macros+"final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .

