*Syntax to create indicator data for Post-partum smoking rate
*Raw data comes from child health team.
*Salomi Barkat, 25/01/2016.
*Jaime Villacampa 26-1-17

*Part 1 - Create raw basefile
*Part 2 - Call the macros

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Smoking/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************.
*Part 1 - Create basefile.
***********************************************************.
get file='Raw Data/Received Data/IR2017-00050-smoking at first visit_postpartumrates_dz2011.sav'
/rename (Datazone2011 smoker total_valid_status=datazone numerator denominator).

*add in a year column.
do repeat
   a=2003 to 2015
   /b='0304' '0405' '0506' '0607' '0708' '0809' '0910' '1011' '1112' '1213' '1314' '1415' '1516'.
if fin_year=b year=a.
end repeat.
execute.

save outfile='Raw Data/Prepared Data/postpartum_smoking_raw.sav'
   /keep datazone year numerator denominator.

***********************************************************.
*Part 2 - Calling the macros
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ and uses percentages.
INSERT FILE=!macros + "DZ11 raw data - crude rate and percentage.sps".

!rawdata data=postpartum_smoking   domain=Smoking  type=percent  time='3-year aggregate'    yearstart=2003   yearend=2015.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and percentages.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =postpartum_smoking  domain=Smoking    ind_id =1552  year_type =financial 
 min_opt =95623 max_opt =99999 profile=tp crude_rate=0.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle.

************************************END