**  Syntax to create data for indicator: Live births.
*Data comes from NRS.
*Jaime Villacampa - October 17

*   - Part 1 - Preparing the data for macros
*   - Part 2 - Calling macros

******************************************************************************.
*Working directory and filepath to macros.
cd "/conf/phip/Projects/Profiles/Data/Indicators/Children and Young People/".
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine.
*********************************************************************************.
****************************************************.
*Part 1 - Preparing the data
****************************************************.
GET DATA /TYPE=XLSX
  /FILE='Raw Data/Received Data/Live births by datazone_2011 - 2002-2016.xlsx'
  /SHEET=name 'Births'
  /CELLRANGE=full /READNAMES=on /ASSUMEDSTRWIDTH=32767.

*Excluding error from the data set. Their numbers are 0.
select if datazone_2011 ne "S02001534".
execute.

*filling gaps with the right datazone.
if datazone_2011 =  "" datazone_2011=lag(datazone_2011).
execute.

rename variables (calendar_year=year)(datazone_2011=datazone) (number= numerator).

aggregate outfile=*
/break year datazone
/numerator=sum(numerator).

save outfile='Raw Data/Prepared Data/livebirths11_raw.sav'.

****************************************************.
*Part 2 - calling the macros
****************************************************.
INSERT FILE=!macros + "DZ11 raw data-denominator added-crude rate and percentage.sps".
!rawdata data=livebirths11 domain='Children and Young People' type='crude' time='single years' 
yearstart=2002 yearend=2016 pop=DZ11_pop_allages.

*Taking out IZ2011 for years where it does not have population.
get file ='Output/livebirths11_formatted.sav'.
select if not (substr(code,1,3) = 'S02' and year < 2011).
frequencies year.

save outfile ='Output/livebirths11_HW_formatted.sav'.
save outfile ='Output/livebirths11_CYP_formatted.sav'.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

****Run the macro***.
!crude_percent data =livebirths11_HW  domain='Children and Young People'   ind_id =20008  year_type=calendar  
min_opt =408828 max_opt =999999 crude_rate=1000 profile=HN.

!crude_percent data =livebirths11_CYP  domain='Children and Young People'   ind_id =13106  year_type=calendar  
min_opt =1 max_opt =999999 crude_rate=1000 profile=CP.

****************************************************.
*Checking graph.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland is in the middle.

*****************************
*******END
*****************************

