******************************************************************************
*   Syntax to create data for indicator: Lung cancer deaths
*   Jaime Villacampa - September 2017

*Part 1 - Extract and format data for macros
*Part 2 - Calling macros that creates the standarized rates and their CI's.
******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************************************.
*Part 1 - Extract and format data for macros
******************************************************************************.
INSERT FILE="/home/jamiev01/SMRA_pass.sps".
*Extracting data on deaths of people over 16, Scottish residents, excluding records with unknown sex and age, and with a diagnosis of lung cancer (ICD10 codes C33-C34).
*It differs slightly from what is reported nationally by ISD, as their death figures include all ages and non-Scotland residents.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select year_of_registration year, AGE, SEX sex_grp, POSTCODE pc7 "+
    "FROM ANALYSIS.GRO_DEATHS_C "+
    "where date_of_registration between '2002-01-01' and '2016-12-31' " +
    "and country_of_residence= 'XS' "+
   "and regexp_like(PRIMARY_CAUSE_OF_DEATH, 'C3[34]') "+
    "and age>=16 " 		+
   "and sex <> 9 "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Bring council information. Not using SMRA variable as it is not up to date.
sort cases by pc7.
alter type pc7(a21).
match files file =*
   /table = '/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
   /rename CA2011 = LA /by pc7 /keep year age sex_grp LA.
execute.

*age groups.
recode age
   (0 thru 4 = 1) (5 thru 9 = 2) (10 thru 15 = 3) (16 thru 19 = 4) (20 thru 24 = 5) 	(25 thru 29 = 6)
   (30 thru 34 = 7) (35 thru 39 = 8) (40 thru 44 = 9) (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)
   (60 thru 64 = 13) (65 thru 69 = 14) (70 thru 74 = 15) (75 thru 79 = 16) (80 thru 84 = 17) (85 thru 89 = 18) (90 thru highest = 19)
   into age_grp.
execute.

*aggregate to local authority to get totals for each area.
aggregate outfile=*
   /break Year LA sex_grp age_grp
   /Numerator=n.

save outfile='Raw Data/Prepared Data/lungcancer_deaths_raw.sav'.

******************************************************************************.
*Part 2 - Run macros.
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, uses population 16+ and standardised rates.
INSERT FILE= !macros + "LA raw data - standardised rates.sps".

!stdrate data=lungcancer_deaths domain='Deaths, Injury and Disease' type=stdrate time='3-year aggregate' yearstart=2002 yearend=2016 
                     pop= 'LA_pop_16+_SR'  epop_age='16+'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data=lungcancer_deaths domain='Deaths, Injury and Disease'  ind_id = 1546 year_type = calendar 
min_opt = 104786 max_opt = 999999  Epop_total = 165800 profile = 'tp'.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
   *Island boards have very wide CIs and slightly outlying, but Scotland looks roughly in the middle.

***END SYNTAX***.
