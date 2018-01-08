
*Syntax to prepare All-cause mortality among the 15 – 44 year old indicator.
*Vicky Elliott December 2017 

*Part 1 - Extract data from SMRA deaths.
*Part 2 - Create the different geographies basefiles
* Part 3 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
*Part 1 - Extract data from SMRA.
******************************************************************************.
*Insert file that provides your access permissions to SMRA tables without disclosing your password.
INSERT FILE="/home/victoe01/SMRA_pass.sps".

*Extracting data on deaths of Scottish residents aged between 15 and 44 years, excluding records with unknown sex and age.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select year_of_registration year, age, SEX sex_grp, POSTCODE pc7 "+
    "FROM ANALYSIS.GRO_DEATHS_C "+
    "where date_of_registration between '2002-01-01' and '2016-12-31' " +
    "and country_of_residence = 'XS' "+
   "and age between '15' and '44' "+
   "and sex <> 9 "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Creating age groups for standardization.
recode age 
   (0 thru 4 = 1)(5 thru 9 = 2)(10 thru 14 = 3)(15 thru 19 = 4)(20 thru 24 = 5)(25 thru 29 = 6)(30 thru 34 = 7) (35 thru 39 = 8)(40 thru 44 = 9)
   (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)(60 thru 64 = 13)(65 thru 69 = 14) (70 thru 74 = 15)(75 thru 79 =16)
   (80 thru 84 = 17)(85 thru 89 = 18)(90 thru hi =19)  into age_grp.
execute. 

*Match on datazone info (use latest available postcode directory).
sort cases by pc7.
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7   /keep year age_grp sex_grp datazone2001 datazone2011.
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

save outfile = 'Raw Data/Prepared Data/deaths_15to44_dz11_raw.sav'.


*For datazone 2001, used for IRs.
dataset activate basefile.

aggregate outfile = *
   /break year datazone2001 sex_grp age_grp
   /numerator = n.

rename variables (datazone2001 = datazone ).
select if year< 2011.
execute.

save outfile = 'Raw Data/Prepared Data/deaths_15to44_dz01_raw.sav'.

dataset close basefile.

add files file='Raw Data/Prepared Data/deaths_15to44_dz01_raw.sav'
/file='Raw Data/Prepared Data/deaths_15to44_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards (since for 2011 datazones we don't usually present back dated trends).
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile= 'Raw Data/Prepared Data/DZ_deaths_15to44_IR_raw.sav'.

******************************************************************************.
*Part 3 - Run macros.
******************************************************************************.

**First macro: for dz11 and standardised rates.
INSERT FILE= !macros + "DZ11 raw data - standardised rates.sps".

!stdrate data=deaths_15to44_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2016 pop='DZ11_pop_15-44_SR' epop_age=a.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/deaths_15to44_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
frequencies year.

save outfile='Output/deaths_15to44_dz11_formatted.sav'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE= !macros + "Analysis - standardisation.sps".

*Datazone 2011.
!standardisation data =deaths_15to44_dz11 domain='Deaths, Injury and Disease' ind_id =20104 year_type = calendar 
min_opt = 474685 max_opt = 999999 profile = HN Epop_total=76000.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland should look roughly in the middle, some outlying values due to large ci in islands.

***END***  .
