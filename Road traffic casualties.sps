*   Syntax to create data for indicator:Road traffic casualties indicator.
*   Jaime Villacampa April17 

*Part 1 - Format the data.
* Part 2 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************************************.
*Part 1 - Format the data.
******************************************************.
INSERT FILE="/home/jamiev01/SMRA_pass.sps". /*SMRA password.
*Extracting data on deaths of Scottish residents with a diagnosis of road traffic accident (RTA) 
and admissions with admission type of RTA(32), excluding records with unknown sex and age.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select link_no, year_of_registration year, age, SEX sex_grp, POSTCODE pc7, null as cis_marker "+
                  "from ANALYSIS.GRO_DEATHS_C "+ 
                     "where date_of_registration between '2002-01-01' and '2016-01-01' " +
                      "and country_of_residence='XS' "+
                       "and regexp_like(PRIMARY_CAUSE_OF_DEATH, 'V[0-8]') "+
                      "and age is not NULL "+
                      "and sex <> 9 "+
           "UNION ALL "+
             "select link_no, extract(year from admission_date) year, AGE_IN_YEARS age, SEX sex_grp, DR_POSTCODE pc7, cis_marker "+
              "from ANALYSIS.SMR01_PI z "+
              "where admission_date between '2002-01-01' and '2016-01-01'  "+
               "and exists(select * from ANALYSIS.SMR01_PI where link_no=z.link_no and cis_marker=z.cis_marker "+
                        "and admission_type=32 "+
                        "and admission_date between '2002-01-01' and '2016-01-01') "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Aggregating to select only one case per admission and year.
sort cases by link_no cis_marker year.
aggregate outfile=*
/break link_no cis_marker year
/AGE SEX_GRP PC7 = first(AGE SEX_GRP PC7).

*Recoding age.
recode age 
   (0 thru 4 = 1)(5 thru 9 = 2)(10 thru 14 = 3)(15 thru 19 = 4)(20 thru 24 = 5)(25 thru 29 = 6)(30 thru 34 = 7) (35 thru 39 = 8)(40 thru 44 = 9)
   (45 thru 49 = 10) (50 thru 54 = 11) (55 thru 59 = 12)(60 thru 64 = 13)(65 thru 69 = 14) (70 thru 74 = 15)(75 thru 79 =16)
   (80 thru 84 = 17)(85 thru 89 = 18)(90 thru hi =19)  into age_grp.
execute. 

*Bringing LA and datazone info.
sort cases by pc7.
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2016_2.sav'
/rename ca2011=  LA    /by pc7    /keep year age_grp sex_grp datazone2001 datazone2011 LA.
execute.

*Excluding non Scottish residents.
select if datazone2011 ne "".
execute.

dataset name basefile.

*aggregate to get the count by datazone2011.
aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = n.

rename variables (datazone2011 = datazone ).

save outfile = 'Raw Data/Prepared Data/road_traffic_dz11_raw.sav'.

*For datazone 2001.
dataset activate basefile.
*aggregate to get the count by datazone2011.
aggregate outfile = *
   /break year datazone2001 sex_grp age_grp
   /numerator = n.

rename variables (datazone2001 = datazone ).
select if year<2011.
execute.

save outfile = 'Raw Data/Prepared Data/road_traffic_dz01_raw.sav'.

dataset close basefile.

*For IR's.
add files file= 'Raw Data/Prepared Data/road_traffic_dz01_raw.sav'
/file= 'Raw Data/Prepared Data/road_traffic_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards.
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile=  'Raw Data/Prepared Data/DZ_road_traffic_IR_raw.sav'.

**********************************************************************.
* Part 2 - Calling the raw data macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and standardised rates.
INSERT FILE=!macros + "DZ11 raw data - standardised rates.sps".

!stdrate data=road_traffic_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2015 pop='DZ11_pop_allages_SR' epop_age=a.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/road_traffic_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
frequencies year.

save outfile='Output/road_traffic_dz11_formatted.sav'.

************************************************************************.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data =road_traffic_dz11 domain='Deaths, Injury and Disease' ind_id =20307 year_type = calendar 
min_opt = 155139 max_opt = 800000 profile = HN Epop_total=200000.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

******END
