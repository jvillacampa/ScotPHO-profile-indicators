*Syntax to prepare indicator data for: deaths from COPD.
*Jaime Villacampa December 17 

*Part 1 - Extract and format the data.
* Part 2 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************.
*Part 1 - Extract and format the data.
******************************************************.
INSERT FILE="/home/jamiev01/SMRA_pass.sps". /*SMRA password.
*Extracting data on deaths of Scottish residents, excluding records with unknown sex, 16+ and 
with a icd10 code ((ICD-10: J40-J44) ) of copd as the main cause.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="SELECT YEAR_OF_REGISTRATION year, AGE, SEX sex_grp, POSTCODE pc7 "+
   "FROM ANALYSIS.GRO_DEATHS_C "+
   "where DATE_OF_REGISTRATION  between '2002-01-01' and '2016-12-31' " +
   "and sex <> 9 "+
   "and age>=16 "
    "and country_of_residence= 'XS' "+
   "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'J4[0-4]')"
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.
 
recode age 
   (0 thru 4 = 1)(5 thru 9 = 2)(10 thru 14 = 3)(15 thru 19 = 4)(20 thru 24 = 5)(25 thru 29 = 6)(30 thru 34 = 7) (35 thru 39 = 8)(40 thru 44 = 9)
   (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)(60 thru 64 = 13)(65 thru 69 = 14) (70 thru 74 = 15)(75 thru 79 =16)
   (80 thru 84 = 17)(85 thru 89 = 18)(90 thru hi =19)  into age_grp.
execute. 

*Bringing LA info.
sort cases by pc7.
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
 /rename ( ca2011=  LA)     /by pc7    /keep year age_grp sex_grp LA.
execute.

aggregate outfile = *
   /break year LA sex_grp age_grp 
   /numerator = n.

save outfile ='Raw Data/Prepared Data/COPD_deaths_LA_raw.sav'.

**********************************************************************.
* Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and standarized rates.
INSERT FILE = !macros + "LA raw data - standardised rates.sps".
!stdrate data=COPD_deaths_LA domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2016 pop='LA_pop_allages_SR' epop_age='16+'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data =COPD_deaths_LA domain='Deaths, Injury and Disease' ind_id =1547 year_type = calendar 
min_opt = 106854 max_opt = 999999 profile = tp Epop_total=165800.
***************************************************************************.
* Checking final results.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/final_graph_check.sps".

******END
