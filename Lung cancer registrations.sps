*Syntax to format data for ScotPHO HW profiles indicator: 'Lung cancer registrations'.
*Jaime Villacampa May-17       

*   Part 1 - Extract and format data from SMRA.
*   Part 3 - Run macros
******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************************************.
*Part 1 - Extract and format data from SMRA.
******************************************************************************.                 
*Extracting data on people over 16, with a diagnosis of lung cancer (ICD10 codes C33-C34) abd excluding records with unknown sex .
*It counts tumours, not different patients, e.g. a patient can have several tumours over the years.
*If we were to use SMRA geographical information, the syntax could be simplified.
INSERT FILE="/home/jamiev01/SMRA_pass.sps". /*SMRA password.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select count(*), extract (year from INCIDENCE_DATE) year, SEX sex_grp, POSTCODE pc7, floor(((incidence_date-date_of_birth)/365)) age "+
    "FROM ANALYSIS.SMR06_PI "+
    "where INCIDENCE_DATE between '2002-01-01' and '2015-12-31' " +
   "and regexp_like(ICD10S_CANCER_SITE, 'C3[34]') "+
   "and sex <> 9 "+
   "and ((incidence_date-date_of_birth)/365)>=16 "+
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

*Bringing LA  info.
sort cases by pc7.
alter type pc7(a21).
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7    /keep count year age_grp sex_grp  ca2011.
execute.

rename variables ( ca2011=  LA ).

*aggregate to get the count by local authority.
aggregate outfile = *
   /break year LA sex_grp age_grp
   /numerator = sum(count).

*Select out non-Scottish residents.
select if LA ne "".
execute.

save outfile = Raw Data/Prepared Data/lung_cancer_LA_raw.sav'.
get file = Raw Data/Prepared Data/lung_cancer_LA_raw.sav'.
***********************************************************.
*Part 2 - Calling the macros
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, uses population 16+ and standardised rates.
INSERT FILE=!macros + "LA raw data - standardised rates.sps".

!stdrate data=lung_cancer_LA domain='Deaths, Injury and Disease'  type=stdrate time='3-year aggregate'  yearstart=2002 yearend=2015
pop='LA_pop_16+_SR' epop_age='16+'.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data=lung_cancer_LA domain='Deaths, Injury and Disease' ind_id = 1549 year_type = calendar 
min_opt = 100556 max_opt = 999999  Epop_total = 165800 profile = tp.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle.

************************************END
