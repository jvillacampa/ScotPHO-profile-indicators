*   Syntax to create data for indicator: Early deaths from coronary heart disease.

*Part 1 - Extract and format the data
*Part 2 - Calling the macros

*Neil Davies - 12 April 2017.
*Jaime Villacampa December17
******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************************************.
*Part 1 - Extract and format the data.
******************************************************************************.
insert file = '/home/jamiev01/SMRA_pass.sps'. /* SMRA password.
*Extract deaths data where: Valid sex exists, Scottish resident, Aged less than 75, Cause of death was coded as CHD (ICD-10: I20-I25).

GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT year_of_registration year, age, SEX sex_grp, POSTCODE pc7  "+
   "FROM ANALYSIS.GRO_DEATHS_C  " +
   "where sex <> 9 " +
   "and country_of_residence = 'XS' "+
   "and age < 75 "+
   "and date_of_registration between '2002-01-01' and '2016-12-31'  "+
   "and regexp_like(primary_cause_of_death, '^I2[0-5]')"
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

recode age
   (0 thru 4 = 1) (5 thru 9 = 2) (10 thru 14 = 3) (15 thru 19 = 4) (20 thru 24 = 5) 	(25 thru 29 = 6)
   (30 thru 34 = 7) (35 thru 39 = 8) (40 thru 44 = 9) (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)
   (60 thru 64 = 13) (65 thru 69 = 14) (70 thru 74 = 15) (75 thru 79 = 16) (80 thru 84 = 17) (85 thru 89 = 18)
   (90 thru highest = 19)  into age_grp.
execute.

*Bringing LA and datazone11 info.
sort cases by pc7.
alter type pc7(a21).
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7 /keep year age_grp sex_grp datazone2011 datazone2001.
execute.

dataset name basefile.

*For datazone 2011 raw datafile.
*aggregate to get the count by datazone2011.
aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = n.

rename variables (datazone2011 = datazone ).

save outfile = 'Raw Data/Prepared Data/under75_CHDdeaths_dz11_raw.sav'.

*For datazone 2001, used for IRs.
dataset activate basefile.
rename variables (datazone2001 = datazone ).
select if year< 2011.
execute.

*aggregate to get the count by datazone2001.
aggregate outfile = *
   /break year datazone sex_grp age_grp
   /numerator = n.

save outfile = 'Raw Data/Prepared Data/under75_CHDdeaths_dz01_raw.sav'.

dataset close basefile.

*To create Information request basefile.
add files file= 'Raw Data/Prepared Data/under75_CHDdeaths_dz01_raw.sav'
/file= 'Raw Data/Prepared Data/under75_CHDdeaths_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards.
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile=  'Raw Data/Prepared Data/DZ_under75_CHDdeaths_IR_raw.sav'.

**********************************************************************.
*Part 2 - Calling the raw data macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and standardised rates.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/DZ11 raw data - standardised rates.sps".

!stdrate data=under75_CHDdeaths_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2015 pop='DZ11_pop_under75_SR' epop_age=''.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/under75_CHDdeaths_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
frequencies year.

save outfile='Output/under75_CHDdeaths_dz11_formatted.sav'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/Analysis - standardisation.sps".

!standardisation data =under75_CHDdeaths_dz11 domain='Deaths, Injury and Disease' ind_id =20105 year_type = calendar 
min_opt = 168822 max_opt = 800000 profile = HN Epop_total=182000.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .

