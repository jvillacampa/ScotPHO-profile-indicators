*************************************************************************************************************************.
*Syntax to format data for ScotPHO HW profiles indicator: 'New cancer registrations'.
*Simon Quirk July 17.
*Jaime Villacampa August-17        

*   Part 1 - Extract data from SMRA.
*   Part 2 - Calling the macros                          
******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************************************.
*Part 1 - Extract data from SMRA.
******************************************************************************.
INSERT FILE="/home/jamiev01/SMRA_pass.sps". /*SMRA password.
*Extracting data on cancer registry, excluding records with unknown sex, and with a diagnosis of cancer (ICD10 codes C, excluding C44).
*It counts tumours, not different patients, e.g. a patient can have several tumours over the years.
*If we were to use SMRA geographical information, the syntax could be simplified.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select count(*), extract (year from INCIDENCE_DATE) year, SEX sex_grp, POSTCODE pc7, floor(((incidence_date-date_of_birth)/365)) age "+
    "FROM ANALYSIS.SMR06_PI "+
    "where INCIDENCE_DATE between '2002-01-01' and '2015-12-31' " +
   "and regexp_like(ICD10S_CANCER_SITE, 'C') "+
   "and not (regexp_like(ICD10S_CANCER_SITE, 'C44')) "+
   "and sex <> 9 "+
   "group by extract (year from INCIDENCE_DATE), sex, postcode, floor(((incidence_date-date_of_birth)/365)) "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Recoding age.
recode age 
   (0 thru 4 = 1)(5 thru 9 = 2)(10 thru 14 = 3)(15 thru 19 = 4)(20 thru 24 = 5)(25 thru 29 = 6)(30 thru 34 = 7) (35 thru 39 = 8)(40 thru 44 = 9)
   (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)(60 thru 64 = 13)(65 thru 69 = 14) (70 thru 74 = 15)(75 thru 79 =16)
   (80 thru 84 = 17)(85 thru 89 = 18)(90 thru hi =19)  into age_grp.
execute. 

*Bringing LA and datazone11 info.
sort cases by pc7.
alter type pc7(a21).
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7   /keep count year age_grp sex_grp  datazone2001 datazone2011.
execute.

*Select out non-Scottish residents.
select if datazone2011 ne "".
execute.

dataset name basefile.

*aggregate to get the count by datazone 2011.
aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = sum(count).

rename variables (datazone2011 = datazone ).

save outfile = 'Raw Data/Prepared Data/cancer_reg_dz11_raw.sav'.

*For datazone 2001, used for IRs.
dataset activate basefile.

*aggregate to get the count by datazone2001.
aggregate outfile = *
   /break year datazone2001 sex_grp age_grp
   /numerator = sum(count).

rename variables (datazone2001 = datazone ).
select if year< 2011.
execute.

save outfile = 'Raw Data/Prepared Data/cancer_reg_dz01_raw.sav'.

dataset close basefile.

add files file= 'Raw Data/Prepared Data/cancer_reg_dz01_raw.sav'
/file= 'Raw Data/Prepared Data/cancer_reg_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards.
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile=  'Raw Data/Prepared Data/DZ_cancer_reg_IR_raw.sav'.
***********************************************************.
*Part 2 - Calling the macros
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, uses population 16+ and standardised rates.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/DZ11 raw data - standardised rates.sps".

!stdrate data=cancer_reg_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2015 pop='DZ11_pop_allages_SR' epop_age=a.

*Excluding IZ level from 2002-2010 as no population available for that period.
get file="Output/cancer_reg_dz11_formatted.sav".

select if not (substr(code,1,3)="S02" and year<2012).
execute.

save outfile="Output/cancer_reg_dz11_formatted.sav".

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/Analysis - standardisation.sps".

!standardisation data=cancer_reg_dz11 domain='Deaths, Injury and Disease' ind_id = 20301 year_type = calendar 
min_opt = 240839 max_opt = 999999  Epop_total = 200000 profile = HN.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle.

************************************END
