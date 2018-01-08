*   Syntax to create data for indicator:   Single adult dwellings indicator 
*Data extracted from statistic.gov.scot for total dwellings (denominator) and for those with single adult discount (numerator). 
*Data it has been slightly formatted in excel and both totals and single data has been put together.
*Jaime Villacampa June 17

* Part 1 - Raw data 
* Part 2 - Calling the  macros
* Part 3 - Adding time trend for LA and HB for H&W2011
******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Economy/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
*********************************************************************************************************************************.
*Part 1 - Raw data 
*********************************************************************************************************************************.
GET DATA /TYPE=XLSX 
  /FILE= 'Raw Data/Received Data/Single dwellings estimates 2016.xlsx' 
  /SHEET=name 'Formatted'  /CELLRANGE=full /READNAMES=on /ASSUMEDSTRWIDTH=32767. 

*Convert variables to cases to get the numerator and denominator in the format needed for macros.
VARSTOCASES
   /make numerator from n2007 TO n2016
   /make denominator from d2007 TO d2016
   /INDEX year.

*Recode the year values into the appropriate years.
loop #i = 1 to 50.
if year=0+#i year = 2006+#i.
end loop.
execute.

*Bringing LA  info, first for dz01 and then for dz11.
sort cases by datazone.
rename variables datazone=datazone2001.
alter type datazone2001(a27).
match files file=*
/table='/conf/linkage/output/lookups/geography/other_ref_files/DataZone2001.sav'
/by datazone2001
/keep year numerator denominator datazone2001 ca2011.
execute.

rename variables ca2011=la.
rename variables datazone2001=datazone2011.
match files file=*
/table='/conf/linkage/output/lookups/geography/DataZone2011/DataZone2011.sav'
/by datazone2011
/keep year numerator denominator datazone2011 la ca2011.
execute.

*merging both variables.
if la ="" la=ca2011.
execute.

rename variables datazone2011=datazone.

*Identifying what datazone type is.
string dz(a4).
if range(datazone,'S01000001', 'S01006505') dz="dz01".
if range(datazone,'S01006506', 'S01013481') dz="dz11".
execute.

dataset name basefile.

**********************************************************************.
*Now preparing files for each required geographic level.
*Preparing file for LA level, only used to get time trend data from 2007 to 2013.
aggregate outfile=*
/break la year dz
/numerator denominator=sum(numerator denominator).

*Excluding duplicated year.
select if not (year=2014 and dz="dz01").
execute.

save outfile = 'Raw Data/Prepared Data/Single_Dwellings_LA_raw.sav'
/drop dz.
get file = 'Raw Data/Prepared Data/Single_Dwellings_LA_raw.sav'.

**********************************************************************.
*Preparing file for DZ11 level.
dataset activate basefile.

aggregate outfile=*
/break datazone year dz
/numerator denominator=sum(numerator denominator).

temporary.
select if dz="dz11".
save outfile = 'Raw Data/Prepared Data/Single_Dwellings_dz11_raw.sav'
/drop dz.

**********************************************************************.
*And now for IRs, combining both dz01 and dz11.
select if not (year=2014 and dz="dz01").
execute.

save outfile=  'Raw Data/Prepared Data/DZ_single_dwellings_IR_raw.sav'
/drop dz.

dataset close basefile.

**********************************************************************.
* Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles,  and crude rates and percentages.
****LA level.
INSERT FILE=!macros + "LA raw data - crude rate and percentage.sps".
!rawdata data='Single_Dwellings_LA'    domain='Economy'     type=percent       time='single years'      yearstart=2007       yearend=2013.     
*for datazone 2011.
INSERT FILE=!macros + "DZ11 raw data - crude rate and percentage.sps".
!rawdata data='Single_Dwellings_dz11'    domain='Economy'     type=percent       time='single years'      yearstart=2014       yearend=2016.     

**********************************************************************.
* Calling the analysis macros
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".
****LA level***.
!crude_percent data = 'Single_Dwellings_LA' domain='Economy' ind_id =11003 year_type = calendar 
min_opt = 741811 max_opt = 999999 profile = H crude_rate=0.
*Datazone 2011.
!crude_percent data = 'Single_Dwellings_dz11' domain='Economy' ind_id =20504 year_type = calendar 
min_opt = 245240 max_opt = 999999 profile = HN crude_rate=0.

***************************************************************************
* Part 3 - Adding time trend for LA and HB for H&W2011
***************************************************************************.
*Incorporating 2002-2010 data for Scotland, HB and LA level to the final opt file.
add files file= 'Output/Single_Dwellings_dz11_final.sav'
/file='Output/Single_Dwellings_LA_final.sav'.
execute.
************************************************************************.
*create unique id number.
define !optnumber (min_opt = !tokens(1)  /profile = !tokens(1) /ind_id = !tokens(1)). 

compute ind_id = !ind_id.
execute.

loop #i=!min_opt to 999999.
   compute uni_id1=#i.
   end case.
end loop.
execute.

string uni_id (A8).
compute uni_id = concat(replace(!quote(!unquote(!profile)),' ',''),string(uni_id1,f6.0)).
compute uni_id = replace(uni_id, ' ','').
execute.
!enddefine.

!optnumber min_opt = 245240 profile = HN ind_id =20504.

*save into the OPT file. 
save translate outfile = 'OPT Data/Single_Dwellings_dz11_OPTdata.csv'
   /type = csv /replace /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

***************************************************************************
* Checking final results .
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle

****END
