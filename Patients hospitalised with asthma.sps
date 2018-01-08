*   Syntax to create data for ScotPHO indicators: Patients hospitalised with asthma and children hospitalised with asthma (under16). 
*   Jaime Villacampa December 2017.

*   Part 1 - Extract data from SMRA.
*   Part 2 -  Create the different geographies basefiles
*   Part 3 - Run macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************************************.
*Part 1 - Extract data from SMRA.
******************************************************************************.
*Looking to admissions with a main diagnosis of asthma, excluding unknown sex, by financial year. 
*Creates one record per CIS and selects only one case per patient/year.
INSERT FILE="/home/jamiev01/SMRA_pass.sps". /* SMRA password.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select distinct link_no linkno, min(AGE_IN_YEARS) age, min(SEX) sex_grp, min(DR_POSTCODE) pc7, "+
 "CASE WHEN extract(month from admission_date) > 3 THEN extract(year from admission_date) ELSE extract(year from admission_date) -1 END as year "
      "FROM ANALYSIS.SMR01_PI z "+
    "where admission_date between  '2002-04-01' and '2017-03-31' " +
   "and sex <> 0 "+
      "and regexp_like(main_condition, 'J4[5-6]')  " +
   "group by link_no, "+
   "CASE WHEN extract(month from admission_date) > 3 THEN extract(year from admission_date) ELSE extract(year from admission_date) -1 END   "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Creating age groups for standardization.
recode age
   (0 thru 4 = 1) (5 thru 9 = 2) (10 thru 14 = 3) (15 thru 19 = 4) (20 thru 24 = 5) 	(25 thru 29 = 6) (30 thru 34 = 7) 
   (35 thru 39 = 8) (40 thru 44 = 9) (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12) (60 thru 64 = 13) 
   (65 thru 69 = 14) (70 thru 74 = 15) (75 thru 79 = 16) (80 thru 84 = 17) (85 thru 89 = 18) (90 thru highest = 19)
     into age_grp.
execute.

*Bringing  LA and datazone info.
sort cases by pc7.
alter type pc7(a21).
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7 /keep year age_grp age sex_grp datazone2001 datazone2011 ca2011.
execute.

*select out non-scottish.
select if datazone2011 ne ''.
execute.

 dataset name basefile.
******************************************************************************.
*Part 2 - Create the different geographies basefiles
******************************************************************************.
*For datazone 2011, used for IRs and H&W profile dz11.
aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = n.

rename variables (datazone2011 = datazone ).

save outfile = 'Raw Data/Prepared Data/asthma_dz11_raw.sav'.

***************************************************.
*For datazone 2001, used for IRs.
dataset activate basefile.

aggregate outfile = *
   /break year datazone2001 sex_grp age_grp
   /numerator = n.

rename variables (datazone2001 = datazone ).
select if year< 2011.
execute.

save outfile = 'Raw Data/Prepared Data/asthma_dz01_raw.sav'.

***************************************************.
dataset activate basefile.
*For LA, used for CYP profile.
select if age<16.
execute.

aggregate outfile = *
   /break year ca2011 sex_grp age_grp
   /numerator = n.

rename variables (ca2011 = LA ).

save outfile = 'Raw Data/Prepared Data/asthma_LA_raw.sav'.

dataset close basefile.

***************************************************.
*IR basefile.
add files file='Raw Data/Prepared Data/asthma_dz01_raw.sav'
/file='Raw Data/Prepared Data/asthma_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards.
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile= 'Raw Data/Prepared Data/DZ_asthma_IR_raw.sav'.
******************************************************************************.
*Part 3 - Run macros.
******************************************************************************.
**First macro: for dz11 and standardised rates.
INSERT FILE= !macros + "DZ11 raw data - standardised rates.sps".
!stdrate data=asthma_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2016 pop='DZ11_pop_allages_SR' epop_age=''.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/asthma_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
frequencies year.

save outfile='Output/asthma_dz11_formatted.sav'.

**First macro: for LA and standardised rates.
INSERT FILE= !macros + "LA raw data - standardised rates.sps".
!stdrate data=asthma_LA domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2005 
yearend=2016 pop='LA_pop_under16_SR' epop_age='<16'.

**************************************************
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE= !macros + "Analysis - standardisation.sps".

*For CYP.
!standardisation data =asthma_LA domain='Deaths, Injury and Disease' ind_id =13051 year_type = financial 
min_opt =21640  max_opt = 999999 profile = CP Epop_total=34200.

*For H&W.
!standardisation data =asthma_dz11 domain='Deaths, Injury and Disease' ind_id =20304 year_type = financial 
min_opt = 445993 max_opt = 999999 profile = HN Epop_total=200000.
***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .
