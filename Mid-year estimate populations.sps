*Syntax to prepare the population indicators. It uses the files created by the population syntax in the Lookups folder.
*Jaime Villacampa September-17

*The following population indicators are formatted in this syntax (followed by initials of their profiles):
*Population all ages. A, Dr, HW, T
*Population 0-15 years HW
*Population 16-64 years HW
*Population 65-74 years HW
*Population 75+ HW
*Population 85+ HW
*Population 16+ HW, T
*Population 18+ A, Dr
*Population <18 A, Dr
*Population 16-39 T
*Population 40-64 T
*Population 0-25 CYP
*Population under 1 CYP
*Population 16-25 CYP
*Population 1-4 CYP
*Population 5-15 CYP

*Part 1 - Formatting population files
*Part 2 - Calling the analysis macro
*Part 3 - All ages indicator

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Life Expectancy and Populations/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
*********************************************************.
*Part 1 - Formatting population files
*********************************************************.
*Macro to read in file from lookup and prepare the data for analysis macro.
define !pop (num=!tokens(1) /den=!tokens(1) /name=!tokens(1)).

get file =  !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/',!unquote(!num),'.sav'))
/rename denominator=numerator.

*temporarily save dataset.
dataset name num.

*add in denominator (total pop).
match files file=num
   /file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/',!unquote(!den),'.sav')) 
  /by year code.
execute.

dataset close num.

*add in a variable to let the next macro know which type of CI's needed.
*add in a variable to state the time period e.g. single year or 3-year aggregate.
string type (A30) time (A30).
compute type = 'percent'.
compute time ='single years'.
execute.

save outfile =  !quote(!concat('Output/',!unquote(!name),'_formatted.sav')).

*save a csv version for checking.
save translate outfile= !quote(!concat('Output/',!unquote(!name),'_check3.csv'))
   /type=csv
   /replace.

!enddefine.

!pop num=DZ11_pop_0to15 den=DZ11_pop_allages name=pop_0to15_dz11.
!pop num=DZ11_pop_16to64 den=DZ11_pop_allages name=pop_16to64_dz11.
!pop num=DZ11_pop_65to74 den=DZ11_pop_allages name=pop_65to74_dz11. 
!pop num='DZ11_pop_75+' den=DZ11_pop_allages name='pop_75+_dz11'.
!pop num='DZ11_pop_85+' den=DZ11_pop_allages name='pop_85+_dz11'.
!pop num='DZ11_pop_16+' den=DZ11_pop_allages name='pop_16+_dz11'. 

!pop num=DZ11_pop_0to25 den=DZ11_pop_allages name=pop_0to25_dz11. 
!pop num=DZ11_pop_16to25 den=DZ11_pop_allages name=pop_16to25_dz11. 
!pop num=DZ11_pop_under1 den=DZ11_pop_allages name=pop_under1_dz11. 
!pop num=DZ11_pop_1to4 den=DZ11_pop_allages name=pop_1to4_dz11. 
!pop num=DZ11_pop_5to15 den=DZ11_pop_allages name=pop_5to15_dz11. 

!pop num='LA_pop_16to39' den=LA_pop_allages name='pop_16to39_LA'. 
!pop num='LA_pop_40to64' den=LA_pop_allages name='pop_40to64_LA'.
!pop num='LA_pop_65+' den=LA_pop_allages name='pop_65+_LA'. 
!pop num='LA_pop_16+' den=LA_pop_allages name='pop_16+_LA'. 
!pop num='ADP_pop_0to17' den=ADP_pop_allages name='pop_0to17_drugs_ADP'. 
!pop num='ADP_pop_18+' den=ADP_pop_allages name='pop_18+_drugs_ADP'. 
!pop num='ADP_pop_0to17' den=ADP_pop_allages name='pop_0to17_alcohol_ADP'. 
!pop num='ADP_pop_18+' den=ADP_pop_allages name='pop_18+_alcohol_ADP'. 


*Not needed anymore, but kept just in case (september-17).
 * !pop num=DZ01_pop_0to15 den=DZ01_pop_allages name=pop_0to15_DZ01.
 * !pop num=DZ01_pop_16to64 den=DZ01_pop_allages name=pop_16to64_DZ01.
 * !pop num=DZ01_pop_65to74 den=DZ01_pop_allages name=pop_65to74_DZ01.
 * !pop num='DZ01_pop_75+' den=DZ01_pop_allages name='pop_75+_DZ01'.
 * !pop num='DZ01_pop_85+' den=DZ01_pop_allages name='pop_85+_DZ01'.
 * !pop num='DZ01_pop_16+' den=DZ01_pop_allages name='pop_16+_DZ01'.

**********************************************************************.
*Part 2 - Calling the analysis macro
************************************************************************.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".
*Population 0-15.
!crude_percent data =pop_0to15_dz11 domain= 'Life Expectancy and Populations' ind_id =20002 profile='HN' 
year_type =calendar min_opt =303983  max_opt =900000 crude_rate=0.
*Population 0-17 (under 18).
!crude_percent data =pop_0to17_drugs_ADP domain= 'Life Expectancy and Populations' ind_id =4162 profile='DU' 
year_type =calendar min_opt =155588  max_opt =900000 crude_rate=0.
!crude_percent data =pop_0to17_alcohol_ADP domain= 'Life Expectancy and Populations' ind_id =4159 profile='AL' 
year_type =calendar min_opt =187573  max_opt =900000 crude_rate=0.
*Population 0-25.
!crude_percent data =pop_0to25_dz11 domain= 'Life Expectancy and Populations' ind_id =13101 profile='cyp' 
year_type =calendar min_opt =37374  max_opt =900000 crude_rate=0.
*Population 16-25.
!crude_percent data =pop_16to25_dz11 domain= 'Life Expectancy and Populations' ind_id =13105 profile='cyp' 
year_type =calendar min_opt =37374  max_opt =900000 crude_rate=0.
*Population under 1.
!crude_percent data =pop_under1_dz11 domain= 'Life Expectancy and Populations' ind_id =13102 profile='cyp' 
year_type =calendar min_opt =37374  max_opt =900000 crude_rate=0.
*Population 1-4.
!crude_percent data =pop_1to4_dz11 domain= 'Life Expectancy and Populations' ind_id =13103 profile='cyp' 
year_type =calendar min_opt =37374  max_opt =900000 crude_rate=0.
*Population 5-15.
!crude_percent data =pop_5to15_dz11 domain= 'Life Expectancy and Populations' ind_id =13104 profile='cyp' 
year_type =calendar min_opt =37374  max_opt =900000 crude_rate=0.
*Population 18 plus.
!crude_percent data ='pop_18+_drugs_ADP' domain= 'Life Expectancy and Populations' ind_id =4161 profile='DU' 
year_type =calendar min_opt =156263  max_opt =900000 crude_rate=0.
!crude_percent data ='pop_18+_alcohol_ADP' domain= 'Life Expectancy and Populations' ind_id =4158 profile='AL' 
year_type =calendar min_opt =188248  max_opt =900000 crude_rate=0.
*Population 16 plus.
!crude_percent data ='pop_16+_dz11' domain= 'Life Expectancy and Populations' ind_id =20004 profile='HN' 
year_type =calendar min_opt =312362  max_opt =900000 crude_rate=0.
!crude_percent data ='pop_16+_LA' domain= 'Life Expectancy and Populations' ind_id =1501 profile='TP' 
year_type =calendar min_opt =101261  max_opt =900000 crude_rate=0.
*Population 16-39.
!crude_percent data =pop_16to39_LA domain= 'Life Expectancy and Populations' ind_id =1502 profile='TP' 
year_type =calendar min_opt =101966  max_opt =900000 crude_rate=0.
*Population 40-64.
!crude_percent data =pop_40to64_LA domain= 'Life Expectancy and Populations' ind_id =1503 profile='TP' 
year_type =calendar min_opt =102671  max_opt =900000 crude_rate=0.
*Population 16-64.
!crude_percent data =pop_16to64_dz11 domain= 'Life Expectancy and Populations' ind_id =20003 profile='HN' 
year_type =calendar min_opt =320741  max_opt =900000 crude_rate=0.
*Population 65 to 74.
!crude_percent data =pop_65to74_dz11 domain= 'Life Expectancy and Populations' ind_id =20005 profile='HN' 
year_type =calendar min_opt =329120  max_opt =900000 crude_rate=0.
*Population 65 plus.
!crude_percent data ='pop_65+_LA' domain= 'Life Expectancy and Populations' ind_id =1504 profile='TP' 
year_type =calendar min_opt =103376  max_opt =900000 crude_rate=0.
*Population 75 plus.
!crude_percent data ='pop_75+_dz11' domain= 'Life Expectancy and Populations' ind_id =20006 profile='HN' 
year_type =calendar min_opt = 337499 max_opt =1000000 crude_rate=0.
*Population 85 plus.
!crude_percent data ='pop_85+_dz11' domain= 'Life Expectancy and Populations' ind_id =20007 profile='HN' 
year_type =calendar min_opt =345878 max_opt =900000 crude_rate=0.

**********************************************************************.
*Part 3 - All ages indicator
************************************************************************.
*Macro to format the data for each profile were is needed..
define !all_pop (data=!tokens(1) 
/min_opt=!tokens(1) 
/profile=!tokens(1)
 /year_start=!tokens(1) 
 /year_end=!tokens(1) 
 /ind_id=!tokens(1) 
/name=!tokens(1)).

get file =  !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/',!unquote(!data),'.sav'))
/rename Denominator=Numerator.

*Selecting years of interest.
select if year ge !year_start and year le !year_end.
execute.

*add in indicator ID.
compute in_id = !ind_id.
execute.

*add in 3 blank columns.
string blank1 (A3).
string blank2 (A3).
string blank3 (A3).

*modify year to compute periods and trends.
alter type year(a4).

*add in definition period and trend_axis.
string def_period (A70) trend_axis (A9).
compute def_period = concat(year , " mid-year estimate").
compute trend_axis = year.
execute.

numeric uni_id2 (f6.0).
loop #i=!min_opt to 999999.
   compute uni_id1=#i.
   end case.
end loop.
execute.

string uni_id (A8).
compute uni_id = concat(replace(!quote(!unquote(!profile)),' ',''),string(uni_id1,f6.0)).
compute uni_id = replace(uni_id, ' ','').
execute.

save outfile =!quote(!concat('Output/pop_allages_',!unquote(!name),'.sav'))
    /keep uni_id code in_id year numerator blank1 blank2 blank3 def_period trend_axis.

*save a csv version for checking.
save translate outfile=!quote(!concat('OPT Data/pop_allages_',!unquote(!name),'_OPTdata.csv')) 
   /type=csv /replace /keep uni_id code in_id year numerator blank1 blank2 blank3 def_period trend_axis.

!enddefine.

*Calling macro.
*!all_pop data=DZ01_pop_allages min_opt=50000 profile=H ind_id=10000 name=HW2001 year_start=2002 year_end=2014.
!all_pop data=DZ11_pop_allages min_opt=354257 profile=HN ind_id=20001 name=HW2011 year_start=2002 year_end=2016.
!all_pop data=LA_pop_allages min_opt=104081 profile=TP ind_id=1500 name=tobacco year_start=2002 year_end=2016.
!all_pop data=ADP_pop_allages min_opt=188923 profile=AL ind_id=4157 name=alcohol year_start=2002 year_end=2016.
!all_pop data=ADP_pop_allages min_opt=156938 profile=DU ind_id=4160 name=drugs year_start=2002 year_end=2016.

***END.
