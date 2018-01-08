******************************************************************************
*   Syntax to create data for indicator: Low birth weight
*   Data comes from maternity team
* Jaime Villacampa - 18-4-17

*Part 1 - re-formating the recieved data ready for analysis.
*Part 2 - Calling macros that creates the standarized rates and their CI's.

******************************************************************************.
*Working directory and filepath to macros.
cd "/conf/phip/Projects/Profiles/Data/Indicators/Children and Young People/".
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine.
*********************************************************************************.
****************************************************.
*Part 1 Formatting the data
****************************************************.
GET DATA  /TYPE=TXT
  /FILE="Raw Data/Received Data/birthweight_dz11.csv"
  /DELCASE=LINE /DELIMITERS="," /ARRANGEMENT=DELIMITED /FIRSTCASE=2 /IMPORTCASE=ALL
  /VARIABLES= finyear F4.0 
   DataZone2011 A9
  numerator_low F1.0
  numerator_normal F3.0
  denominator F3.0.
CACHE.
EXECUTE.

*rename variables. Decide what weight you want to use (normal or low).
rename variables (finyear Datazone2011 numerator_low = year datazone numerator).

*fill in the sysmissing with zero's.
if sysmis(numerator) numerator = 0.
if sysmis(denominator) denominator = 0.
frequencies numerator denominator.

*file has been provided in Fyear coded by year ending Mar31. Have to change to match macros and profiles. 
Recode year  (2003=2002) (2004=2003) (2005=2004) (2006=2005) (2007=2006) (2008=2007) (2009=2008) 
     (2010=2009) (2011=2010) (2012=2011) (2013=2012) (2014=2013) (2015=2014) (2016=2015).
frequencies year.

save outfile =  'Raw Data/Prepared Data/low_birth11_raw.sav'
   /keep year datazone numerator denominator.
get file =  'Raw Data/Prepared Data/low_birth11_raw.sav'.

**********************************************************************.
*Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and crude rates and percentages.
INSERT FILE=!macros + "DZ11 raw data - crude rate and percentage.sps".
!rawdata data=low_birth11 domain='Children and Young People' type='percent' time='3-year aggregate' yearstart=2002 yearend=2015.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =low_birth11 domain='Children and Young People' ind_id = 21003 year_type = financial  
min_opt =1 max_opt =999999 profile=HN crude_rate=0.
***************************************************************************
* Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to v large ci in islands.

***END SYNTAX***.