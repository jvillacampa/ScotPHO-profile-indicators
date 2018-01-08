*Syntax to create raw data needed for quit attempts from pregnant smokers indicator for rolling updates on ScotPHO profiles.
*Numerator data - Quit attempts from pregnant smokers (smoking cessation team).
*Denominator data - Number of all women recoded as a 'current smoker' at antenatal booking appointment (maternity team).

*Neil Davies, 15/02/2016.

*Part 1. Formatting numerator values.
*Part 2. Formatting denominator values.
*Part 3. Combine the numerator and denominator files into one file.
*Part 4 - run macros.

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Smoking/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
********************************************************.
*Part 1. Formatting numerator values.
********************************************************.
*read in data for quit attempts from pregnant smokers provided by smoking cessation team.
GET DATA /TYPE=XLSX
  /FILE='Raw Data/Received Data/IR2017-00232 - Quit attempts preg-numerator(2).xlsx'
  /SHEET=name 'Data'  /CELLRANGE=range 'B6:J39'  /READNAMES=on /ASSUMEDSTRWIDTH=32767.
EXECUTE.

*convert from wide to long making a new variable for years.
varstocases 
   /make numerator from @2008 to @2015
   /index year.

*reformat year variable from varstocases to make actual years.
do repeat x = 1 to 20
   /y = 2008 to 2027.
if year = x year = y.
end repeat.
execute.

RENAME VARIABLES LA = CA_Desc.

*rename values to help with matching on LA lookup.
recode CA_Desc
('City of Edinburgh' = 'Edinburgh, City of')
('Unknown local authority' = '').
execute.

*replace " and " with " & ", again to help matching on LA lookup.
compute CA_Desc = replace(CA_Desc,' and ',' & ').
execute.

*sort cases ready for matching with population data.
sort cases by CA_Desc.
dataset name data.

*get LA_ADP lookup file from Profiles lookup folder. This is used to add on LA codes using LA names.
get file = '/conf/phip/Projects/Profiles/Data/Lookups/LA_ADP_lookup.sav'.

*sort ready for matching.
sort cases by CA_Desc.
alter type CA_Desc(a23).

*match on LA codes.
match files file = data
   /table = *
   /by CA_Desc
   /keep LAcode numerator year.
execute.

*rename ready for matching on pregnancy data.
RENAME VARIABLES LAcode = CA2011.
alter type CA2011(a27).

sort cases by year CA2011.
dataset name numerator.
dataset close data.

********************************************************.
*Part 2. Formatting denominator values.
********************************************************.
*get population file provided by maternity team (also used for smoking during pregnancies numerator). 
*This is the number of women recorded as being a current smoker at first antenatal booking appointment. 
GET DATA  /TYPE=TXT
  /FILE="Raw Data/Received Data/IR2016-02159(smoking during pregnancies).csv"
  /ENCODING='UTF8'  /DELCASE=LINE  /DELIMITERS=","    /ARRANGEMENT=DELIMITED  /FIRSTCASE=2  /IMPORTCASE=ALL
  /VARIABLES=
  year F4.0
  DataZone2011 A9
  smoker F2.0.
CACHE.
EXECUTE.

*alter type ready to match on numerator.
alter type DataZone2011(a27).
sort cases by DataZone2011.

dataset name data.

*get lookup file from GPD team to match on LA codes using the Datazone codes.
get file = '/conf/linkage/output/lookups/geography/DataZone2011/DataZone2011.sav'
   /keep DataZone2011 CA2011.

sort cases by Datazone2011.

*match on LA codes.
match files file = data
   /table = *
   /by DataZone2011  /drop DataZone2011.
execute.

*reformat year because data given to us uses the latter year as the financial year e.g. 2008/09 = 2009 but we record it as 2008.
compute year = year-1.
select if year ge 2008.
execute.

*aggregate to get sum of denominator by local authority.
aggregate outfile = *
   /break CA2011 year
   /denominator = sum(smoker).

sort cases by year CA2011.

dataset name denominator.
dataset close data.

******************************************************.
*Part 3. Combine the numerator and denominator files into one file.
******************************************************.
*match together the numerator and denominator temporary files.
MATCH FILES /FILE=denominator
  /FILE=numerator /BY year CA2011.
EXECUTE.

VARIABLE LABELS year 'Financial year' 
numerator 'Quit attempts from pregnant smokers' 
denominator 'Number of current smokers at first antenatal booking appointment'.

VALUE LABELS year
2008 '2008/09' 2009 '2009/10' 2010 '2010/11' 2011 '2011/12' 
2012 '2012/13' 2013 '2013/14' 2014 '2014/15' 2015 '2015/16'.

RENAME VARIABLES CA2011 = LA.

save outfile = 'Raw Data/Prepared Data/quit_attempts_preg_Feb17_raw.sav'.

dataset close numerator.
dataset close denominator.

******************************************************************************.
*Part 4 - run macros.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level and percentage rates.
INSERT FILE=!macros + "LA raw data - crude rate and percentage.sps".
!rawdata data=quit_attempts_preg_Feb17 domain = 'Smoking' type=percent time='3-year aggregate'  yearstart=2008 yearend=2015.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and percentage.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data=quit_attempts_preg_Feb17 domain = 'Smoking' ind_id = 1526 year_type = financial 
min_opt = 96140 max_opt = 999999 profile = tp crude_rate=0.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .

