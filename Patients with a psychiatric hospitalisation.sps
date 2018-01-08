*   Syntax to create data for indicator:   Patients with a psychiatric hospitalisation.
*   Raw data comes from ISD Mental Health Team
*   Neil Davies 21/04/2017.
*   Jaime Villacampa May17 - Adding IR and DZ11, simplifying.

* Part 1 - Formatting data based on datazone 2001
* Part 2 - Formatting data based on datazone 2011
* Part 3 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************************.
* Part 1 - Formatting data based on datazone 2001
***********************************************************************.
*This file is only used to create the Information request basefile.
get file='Raw Data/Received Data/IR2017-00566 - Psychiatric discharges DZ2001.sav'.

*Bringing LA info.
sort cases by datazone2001.
alter type datazone2001(a27).
match files file=*
/table='/conf/linkage/output/lookups/geography/other_ref_files/DataZone2001.sav'
/by datazone2001    /keep year sex agegroup5 number datazone2001 ca2011.
execute.

rename variables (year sex agegroup5 number datazone2001 CA2011=Year sex_grp age_grp Numerator datazone LA).

*some sex groups coded as 0; take these out.
select if sex_grp ne 0.
execute.

dataset name basefile.

*Aggregating at DZ level.
aggregate outfile = *
   /break year sex_grp age_grp datazone
   /Numerator = sum(numerator).

*Selecting out non-Scottish and period for which we have dz11 population data.
select if datazone ne '' and year<2011.
execute.

alter type datazone(a9).

save outfile='Raw Data/Prepared Data/psychiatric_discharges_dz01_raw.sav'.

***********************************************************************.
* Part 1 - Formatting data based on datazone 2011
***********************************************************************.
get file='Raw Data/Received Data/IR2017-00566 - Psychiatric discharges DZ2011.sav'.

*rename variables to standard format.
rename variables (year sex agegroup5 number datazone2011 =Year sex_grp age_grp Numerator datazone ).

*some sex groups coded as 0; take these out. Select out blank datazone codes as we can not add a denominator value to these. 
select if sex_grp ne 0 and datazone ne ''.
execute.

*aggregate to get figures by local authority.
aggregate outfile = *
   /break year sex_grp age_grp datazone
   /Numerator = sum(numerator).

save outfile='Raw Data/Prepared Data/psychiatric_discharges_dz11_raw.sav'.

*For IRs.
add files file= 'Raw Data/Prepared Data/psychiatric_discharges_dz01_raw.sav'
/file= 'Raw Data/Prepared Data/psychiatric_discharges_dz11_raw.sav'.
execute.

*Selecting datazones 2011 only for 2011 and onwards.
select if not(year<2011 and datazone > "S01006505").
execute.

save outfile=  'Raw Data/Prepared Data/DZ_psychiatric_discharges_IR_raw.sav'.
**********************************************************************.
* Part 3 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and standardised rates.
INSERT FILE = !macros + "DZ11 raw data - standardised rates.sps".

!stdrate data=psychiatric_discharges_dz11 domain='Deaths, Injury and Disease'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2015 pop='DZ11_pop_allages_SR' epop_age=a.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/psychiatric_discharges_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
frequencies year.

save outfile='Output/psychiatric_discharges_dz11_formatted.sav'.

************************************************************************.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

!standardisation data =psychiatric_discharges_dz11 domain='Deaths, Injury and Disease' ind_id =20402 year_type = financial 
min_opt = 159540 max_opt = 800000 profile = HN Epop_total=200000.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .
