*   Syntax to create data for indicator: Bowel screening uptake.
*Data comes from screening team.
* Jaime Villacampa September 17.

*Part 1 - Format the data.
* Part 2 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Health Interventions/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
******************************.
*Part 1 - bowel. 
******************************.
GET FILE='Raw Data/Received Data/IR2017-01436_bowel.zsav'
/rename Datazone2011 = datazone.

*aggregate to get the count, removing age groups.
aggregate outfile = *
   /break year datazone
   /denominator numerator = sum(denominator numerator).

*Excluding 2007 and 2016 as they are not complete.
*Not all boards started in 2008, some started late in 2009.
*However as we present percentages, and the total numbers are correct we present the whole period for all HBs.
select if year >2007 and year <2016.
frequencies year.

save OUTFILE  = 'Raw Data/Prepared Data/bowel_dz11_raw.sav'.

**********************************************************************.
* Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and percentage.
INSERT FILE=!macros + "DZ11 raw data - crude rate and percentage.sps".

!rawdata data=bowel_dz11 domain='Health Interventions'   type='percent'  time='3-year aggregate' yearstart=2008 yearend=2015.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =bowel_dz11 domain='Health Interventions' ind_id =21102 year_type = calendar 
min_opt = 384876 max_opt = 999999 profile = HN crude_rate=0.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".

****END
