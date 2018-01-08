*Syntax to create raw data needed for population prescribed drugs for anxiety/depression/psychosis indicator for rolling updates on ScotPHO profiles.
*Numerator data - population prescribed drugs for anxiety/depression/psychosis (prescribing team).
*Denominator data - DZ population all ages.
*Vicky Elliott, 15/02/2016.

*Part 1. Formatting numerator values.
*Part 2. Formatting denominator values.
*Part 3. Combine the numerator and denominator files into one file.

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Health Interventions/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
********************************************************.
*Part 1. Formatting numerator values.
********************************************************.
*For Datazones 2011 H&W profile.
get file='Raw Data/Received Data/IR2017-prescriptions_anxiety_dep_2011DZ.sav'.

*aggregate up to get required variables.
aggregate outfile=*
   /break year datazone2011 
   /numerator=sum(patients).

rename variables (datazone2011=Datazone).

save outfile= 'Raw Data/Prepared Data/prescriptions_anxiety_dep_dz11_raw.sav'.

***********************************************************.
*Part 2 - Calling the macros
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, crude rates.
INSERT FILE=!macros + "DZ11 raw data-denominator added-crude rate and percentage.sps".

!rawdata data= prescriptions_anxiety_dep_dz11 domain='Health Interventions' type=percent time='single years' 
yearstart=2010 yearend=2015 pop=DZ11_pop_allages.

*Excluding IZ level from 2002 to 2010 as there is no population data available.
get file='Output/prescriptions_anxiety_dep_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2010)).
frequencies year.

save outfile='Output/prescriptions_anxiety_dep_dz11_formatted.sav'.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE= !macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =prescriptions_anxiety_dep_dz11  domain='Health Interventions'    ind_id =20401  year_type =financial  
min_opt =179467 max_opt =999999 profile=HN crude_rate=0.

***********************************************************.
*Checking final output.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle.

************************************END
