*Syntax for update of teenage pregnancy indicator data.

*   Part 1 - Formatting data
*   Part 2 - Calling the macros
*   Jaime Villacampa July 17

******************************************************************************.
*Working directory and filepath to macros.
cd "/conf/phip/Projects/Profiles/Data/Indicators/Children and Young People/".
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine.
*********************************************************************************.
****************************************************.
*Part 1 - Formatting data
****************************************************.
*All data is included, but to calculate the rates only 15-19 female pop is used, following ISD publication methodology.
get file = 'Raw Data/Received Data/IR2017-01100- teen preg.sav'.

*excluding non scottish residents. 
select if datazone2011 ne ' '.
execute.

*aggregate to get rid of ages.
aggregate outfile = *
   /break Yearcon datazone2011
   /numerator = sum(tp).

rename variables (Yearcon datazone2011= Year datazone).

save outfile =  'Raw Data/Prepared Data/teen_preg_dz11_raw.sav'.

***********************************************************.
*Part 2 - Calling the macros
*Check the correct process checking the final aggregations of both macros, but also the check files produced in the first macro.
******************************************************************************.
INSERT FILE=!macros + "DZ11 raw data-denominator added-crude rate and percentage.sps".

!rawdata data=teen_preg_dz11   domain='Children and Young People'  type=crude  time='3-year aggregate'    
yearstart=2002   yearend=2015 pop='DZ11_pop_fem15to19'.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
get file='Output/teen_preg_dz11_formatted.sav'.

select if not (substr(code, 1, 3) = 'S02' and range(year, 2002,2011)).
execute.

save  outfile='Output/teen_preg_dz11_formatted.sav'.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =teen_preg_dz11   domain='Children and Young People'     ind_id =21001  year_type =calendar  
min_opt =255141 max_opt =999999 profile=HN crude_rate=1000.

***********************************************************************
*Creating graph to check final output.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, island with large CI's

************************************END

