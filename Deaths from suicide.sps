*Syntax to prepare deaths from suicide indicators.
* One for Health and Wellbeing profiles and two by gender for the MH profile.
*Using old coding rules until period 2010-2014, and new ones for period 2011-2016.
*To decide if worth showing period with old coding rules.
*ICD9: E950-E959, E980-E989  
 * ICD10: X60-X84, Y87.0, Y10-Y34, Y87.2
*Jaime Villacampa April17 

*Part 1 - Format the data.
* Part 2 - Calling the macros
* Part 3 -To look at old versus new coding

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************.
*Part 1 - Format the data.
******************************************************.
INSERT FILE="/home/jamiev01/SMRA_pass.sps".
*Extracting data on deaths of Scottish residents, excluding records with unknown sex and age and with any icd10 code of suicide in any cause.
* If extracting this way, you will get old coding figures up to 2010 and new coding ones from 2011 and onwards.
* Numbers will not macth perfectly with publication as we exclude non-Scottish residents.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select year_of_registration year, age, SEX sex_grp, POSTCODE pc7,  "+
       "case when (year_of_registration >2010 "+
             "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'Y1')  "+
             "and (regexp_like(CAUSE_OF_DEATH_CODE_0, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_1, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_2, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_3, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_4, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_5, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_6, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_7, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_8, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_9, 'F1[123456789]'))) "+
            "then '1' else '0' END added_new_coding "+
   "FROM ANALYSIS.GRO_DEATHS_C "+
    "where  year_of_registration between '2002' and '2016' " +
   "and country_of_residence = 'XS' "+
   "and sex <> 9 "
    "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'X[67]|X8[01234]|Y1|Y2|Y3[01234]|Y870|Y872') "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.
 
recode age 
   (0 thru 4 = 1)(5 thru 9 = 2)(10 thru 14 = 3)(15 thru 19 = 4)(20 thru 24 = 5)(25 thru 29 = 6)(30 thru 34 = 7) (35 thru 39 = 8)(40 thru 44 = 9)
   (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)(60 thru 64 = 13)(65 thru 69 = 14) (70 thru 74 = 15)(75 thru 79 =16)
   (80 thru 84 = 17)(85 thru 89 = 18)(90 thru hi =19)  into age_grp.
execute. 

*Bringing LA and datazone11 info.
sort cases by pc7.
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7 /keep year age_grp sex_grp  datazone2011 ca2011 added_new_coding.
execute.

dataset name basefile.

*aggregate to get the count by local authority, for old coding data.
dataset copy basefile.
select if added_new_coding ne '1' and year <2015.
execute.

rename variables ( ca2011=  LA).

aggregate outfile = *
   /break year LA sex_grp age_grp 
   /numerator = n.

save outfile ='Raw Data/Prepared Data/suicide_LA_oldcoding_raw.sav'.

*For datazone 2011.
dataset activate basefile.

*aggregate to get the count by datazone2011.
aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = n.

rename variables datazone2011=datazone.

select if year>2010.
execute.

save outfile ='Raw Data/Prepared Data/suicide_deaths_dz11_raw.sav'.

**********************************************************************.
* Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and standarized rates.
INSERT FILE= !macros + "DZ11 raw data - standardised rates.sps".
*First for the new coding data, from 2011 including IZ level.
!stdrate data=suicide_deaths_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='5-year aggregate' yearstart=2011 
yearend=2016 pop='DZ11_pop_allages_SR' epop_age=a.

*Now for the old coding data, up to 2014, for LA.
INSERT FILE = !macros + "LA raw data - standardised rates.sps".
!stdrate data=suicide_LA_oldcoding domain='Deaths, Injury and Disease'   type=stdrate time='5-year aggregate' yearstart=2002 
yearend=2014 pop='LA_pop_allages_SR' epop_age=a.

*Joining together old and new coding data.
add files file='Output/suicide_deaths_dz11_formatted.sav'
/file = 'Output/suicide_LA_oldcoding_formatted.sav'.
execute.

save outfile ='Output/suicide_deaths_all_formatted.sav'.

*Creating files for each gender only with local authority level for MH profile.
get file ='Output/suicide_deaths_all_formatted.sav'.
select if sex_grp=1 and  (substr(code,1,3) = 'S12' or code= 'S00000001').
execute.

save outfile ='Output/suicide_males_mh_formatted.sav'.

*Females.
get file ='Output/suicide_deaths_all_formatted.sav'.
select if sex_grp=2 and (substr(code,1,3) = 'S12' or code= 'S00000001').
execute.

save outfile ='Output/suicide_females_mh_formatted.sav'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data =suicide_deaths_all domain='Deaths, Injury and Disease' ind_id =20403 year_type = calendar 
min_opt = 362636 max_opt = 999999 profile = HN Epop_total=200000.

* Checking final results.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/final_graph_check.sps".
***************************************************************************.

!standardisation data =suicide_males_mh domain='Deaths, Injury and Disease' ind_id =12538 year_type = calendar 
min_opt = 4952 max_opt = 999999 profile = MH Epop_total=200000.

* Checking final results.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/final_graph_check.sps".

***************************************************************************.
!standardisation data =suicide_females_mh domain='Deaths, Injury and Disease' ind_id =12539 year_type = calendar 
min_opt = 5315 max_opt = 999999 profile = MH Epop_total=200000.

* Checking final results.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/final_graph_check.sps".

***************************************************************************
* Part 3 -To look at old versus new coding
***************************************************************************.
*Not really needed to create indicator data, just to understand how the dataset works.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select year_of_registration year, count(*) suicides_count, "+
       "count(case when not (year_of_registration >2010 "+
             "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'Y1')  "+
             "and (regexp_like(CAUSE_OF_DEATH_CODE_0, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_1, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_2, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_3, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_4, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_5, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_6, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_7, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_8, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_9, 'F1[123456789]'))) "+
            "then UNDERLYING_CAUSE_OF_DEATH END) old_coding, " +
       "count(case when year_of_registration >2010 then UNDERLYING_CAUSE_OF_DEATH END) new_coding, "+
       "count(case when  (year_of_registration >2010 "+
             "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'Y1')  "+
             "and (regexp_like(CAUSE_OF_DEATH_CODE_0, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_1, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_2, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_3, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_4, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_5, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_6, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_7, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_8, 'F1[123456789]') "+
             "or regexp_like(CAUSE_OF_DEATH_CODE_9, 'F1[123456789]'))) "+
            "then UNDERLYING_CAUSE_OF_DEATH END) added_new_coding " +
   "FROM ANALYSIS.GRO_DEATHS_C "+
    "where  year_of_registration between '2002' and '2016' " +
       "and regexp_like(UNDERLYING_CAUSE_OF_DEATH, 'X[67]|X8[01234]|Y1|Y2|Y3[01234]|Y870|Y872') "+
   "group by  year_of_registration "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.


******END
