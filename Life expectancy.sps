*   Syntax to create data for indicators:   Male and female life expectancy
 * Data file prepared here:\\stats\phip\PH_Topics\Healthy_life_expectancy\HLE_2017\Life Expectancy by Intermediate Zone.
* Comes from a manipulation and analysis process in a macro excelsheet of deaths in Scotland.
 * Jaime Villacampa June 17

*Part 1 - IZ level data
*Part 2 - Scotland, HB and LA data.
*Part 3 - Macro to create final OPT files.
******************************************************************************.
*Working directory.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Life Expectancy and Populations/'.
******************************************************************************.
******************************************************************************.
*Part 1 - IZ level data
******************************************************************************.
GET DATA  /TYPE=TXT
  /FILE="Raw Data/Received Data/Life expectancy IZ level 5yragg.csv"
  /ENCODING='UTF8'  /DELCASE=LINE /DELIMITERS="," /ARRANGEMENT=DELIMITED /FIRSTCASE=2 /VARIABLES=
  sex_grp F1.0
  code A9
  pop F5.0
  deaths F6.2
  rate F5.2
  upci F5.2
  lowci F5.2.

*To avoid the least robust situations for the intermediate zones, LE for a sex and area is not calculated where: 
the five-year total population for that sex was less than 5,000 people; and/or there were fewer than 40 deaths for that sex over the 5-year period.
*Also excluding Scotland level as it is provided for 3 year midpoint by NRS.
select if pop>=5000 and deaths>=40 and code ne 'Scotland'.
execute.

string def_period (A60) trend_axis (A60) numerator(a1).
compute year=2013.
compute def_period='2013 midpoint year'.
compute trend_axis='2013'.
execute.

delete variables pop deaths.

dataset name iz.

******************************************************************************.
*Part 2 - Scotland, Hb and LA data.
******************************************************************************.
*First council area data.
GET DATA /TYPE=XLSX
  /FILE="Raw Data/Received Data/Confidence intervals for LE at birth - table.xlsx"
  /SHEET=name 'Council areas' /CELLRANGE=full /READNAMES=on  /ASSUMEDSTRWIDTH=32767.

delete variables v7 to v12.
sort cases by area.

dataset name council.

*Bringing lookup file for council area codes.
GET DATA  /TYPE=TXT
  /FILE="/conf/linkage/output/lookups/geography/Codes_and_Names/Council Area 2011 Lookup.csv"
   /DELCASE=LINE /DELIMITERS=","   /QUALIFIER='"' /ARRANGEMENT=DELIMITED /FIRSTCASE=2 /VARIABLES=
  Code A9
  Area A21
  name2 A30.

*Matching with council data.
sort cases by area.		
match files file = council
   /table = *   /by Area    /drop name2 area.
execute. 

dataset name council.

*************************************************
*Now Health Board level.
GET DATA /TYPE=XLSX
  /FILE="Raw Data/Received Data/Confidence intervals for LE at birth - table.xlsx"
  /SHEET=name 'health boards'  /CELLRANGE=full  /READNAMES=on  /ASSUMEDSTRWIDTH=32767.

sort cases by v3.

dataset name board.

*Bringing lookup file for council area codes.
GET DATA  /TYPE=TXT
  /FILE="/conf/linkage/output/lookups/geography/Codes_and_Names/Health Board Area 2014 Lookup.csv"
   /DELCASE=LINE /DELIMITERS=","   /QUALIFIER='"' /ARRANGEMENT=DELIMITED /FIRSTCASE=2 /VARIABLES=
  Code A9
  v3 A25
  name2 A30.

*Matching with council data.
sort cases by v3.		
match files file = board
   /table = *   /by v3    /drop name2 v3.
execute. 

dataset name board.

***************************************
Scotland level.
GET DATA /TYPE=XLSX
  /FILE="Raw Data/Received Data/Confidence intervals for LE at birth - table.xlsx"
  /SHEET=name 'Scotland' /CELLRANGE=full /READNAMES=on  /ASSUMEDSTRWIDTH=32767.

*To allow matching files.
rename variables (v3 v4 v5=v4 v5 v6).

string Code(a9).
compute code="S00000001".
execute.

dataset name scot.

****************************************
Merging the three together.
add files file=board
/file=council
/file=scot.
execute.

dataset name hbla.
dataset close board.
dataset close scot.
dataset close council.

rename variables (v4 v5 v6= rate lowci upci).

*creating variables for OPT based on period variable.
string def_period (A60) trend_axis (A60) numerator(a1) .
do if v1="2001-2003".
   compute year=2002.
   compute def_period='2002 midpoint year'.
   compute trend_axis='2002'.
else if v1="2002-2004".
   compute year=2003.
   compute def_period='2003 midpoint year'.
   compute trend_axis='2003'.
else if v1="2003-2005".
   compute year=2004.
   compute def_period='2004 midpoint year'.
   compute trend_axis='2004'.
else if v1="2004-2006".
   compute year=2005.
   compute def_period='2005 midpoint year'.
   compute trend_axis='2005'.
else if v1="2005-2007".
   compute year=2006.
   compute def_period='2006 midpoint year'.
   compute trend_axis='2006'.
else if v1="2006-2008".
   compute year=2007.
   compute def_period='2007 midpoint year'.
   compute trend_axis='2007'.
else if v1="2007-2009".
   compute year=2008.
   compute def_period='2008 midpoint year'.
   compute trend_axis='2008'.
else if v1="2008-2010".
   compute year=2009.
   compute def_period='2009 midpoint year'.
   compute trend_axis='2009'.
else if v1="2009-2011".
   compute year=2010.
   compute def_period='2010 midpoint year'.
   compute trend_axis='2010'.
else if v1="2010-2012".
   compute year=2011.
   compute def_period='2011 midpoint year'.
   compute trend_axis='2011'.
else if v1="2011-2013".
   compute year=2012.
   compute def_period='2012 midpoint year'.
   compute trend_axis='2012'.
else if v1="2012-2014".
   compute year=2013.
   compute def_period='2013 midpoint year'.
   compute trend_axis='2013'.
else if v1="2013-2015".
   compute year=2014.
   compute def_period='2014 midpoint year'.
   compute trend_axis='2014'.
end if.
execute.

*Recoding sex.
recode sex ('M'=1) ('F'=2) into sex_grp.
execute.

delete variables v1 sex.

*************************************************
*Merging with Iz level data.
add files file=hbla
/file=iz.
execute.

dataset name base.
dataset close iz.
dataset close hbla.

******
*To keep in line with the definition, only keeping data every two years.
select if not any(year, 2002,2004,2006,2008,2010,2012,2014).
execute.

******************************************************************************.
*Part 3 - Macro to create final OPT files.
******************************************************************************.
define !opt(sex=!tokens(1) /ind_id=!tokens(1)  /data=!tokens(1) /min_opt=!tokens(1)  /profile=!tokens(1) /file=!tokens(1) ).
dataset activate !file.
dataset copy gender.
dataset activate gender.

*Selecting gender of interest.
select if sex_grp=!sex.
execute.

*Creating OPT number.
numeric uni_id1 (f6.0).
loop #i=!min_opt to 999999.
   compute uni_id1=#i.
   end case.
end loop.
execute.

string uni_id (A8).
compute uni_id = concat(!quote(!unquote(!profile)),string(uni_id1,f6.0)).
compute uni_id = replace(uni_id, ' ','').
execute.

*Indicator ID number.
compute ind_id = !ind_id.
execute.

save translate outfile =  !quote( !concat( 'OPT Data/', !unquote(!data),'_OPTdata.csv'))
   /type = csv /replace /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

!enddefine.

***For H&W profile 2011.
!opt sex=1 ind_id=20101 min_opt=249547 data=Male_LE_dz11 profile=HN file=base.
dataset close gender.
!opt sex=2 ind_id=20102 min_opt=251403 data=Female_LE_dz11 profile=HN file=base.
dataset close gender.

dataset close base.

***END SYNTAX***.
