*   Syntax to create data for indicators: Child dental health at P1 and P7. 
*This syntax formats the child dental health data received from Dental Team - Primary Care. 
*It creates files for both P1 and P7 dental health for the CYP and H&W profiles.
*Jaime Villacampa November 2017

*Part 1 - Macro for reading raw data.
*Part 2 - P1 child dental health raw data.
*Part 3 - P7 child dental health raw data.
*Part 4 - Calling the macros 

******************************************************************************.
*Working directory and filepath to macros.
cd "/conf/phip/Projects/Profiles/Data/Indicators/Children and Young People/".
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine.
*********************************************************************************.
*********************************************************************************.
*Part 1 - Macro for reading raw data.
*********************************************************************************.
define !file_tab (sheet = !tokens(1) /range=!tokens(1) /name=!tokens(1))

GET DATA /TYPE=XLSX
  /FILE='Raw Data/Received Data/IR2017-01731_DZ2011 Child dental Health.xlsx'
  /SHEET=name !sheet
  /CELLRANGE=range !quote(!unquote(!range))
  /READNAMES=on /ASSUMEDSTRWIDTH=32767.
EXECUTE.

RENAME VARIABLES datazone2011 = datazone.

string year(a4).
compute year = substr(school_year,1,4).
execute.
alter type year(f4).

dataset name !name.

!enddefine.

*********************************************************************************.
*Part 1 - P1 Child dental raw data
*********************************************************************************.
!file_tab sheet="2013_P1_C_DZ2011" range= "A5:E13075" name=P12013.
!file_tab sheet="2014_P1_C_DZ2011" range= "A5:E13189" name=P12014.
!file_tab sheet="2015_P1_C_DZ2011" range= "A5:E13186" name=P12015.
!file_tab sheet="2016_P1_C_DZ2011" range= "A5:E13004" name=P12016.
!file_tab sheet="2017_P1_C_DZ2011" range= "A5:E12972" name=P12017.

ADD FILES file = P12017 
   /file = P12016
   /file = P12015
   /file = P12014
   /file = P12013.
execute.

DATASET CLOSE P12017.
DATASET CLOSE P12016.
DATASET CLOSE P12015.
DATASET CLOSE P12014.
DATASET CLOSE P12013.

select if datazone ne "unknown".
execute.

aggregate outfile = *
   /break year datazone
   /numerator denominator = sum(numerator denominator).

save outfile = 'Raw Data/Prepared Data/Child_dental_P1_raw.sav'.
get file = 'Raw Data/Prepared Data/Child_dental_P1_raw.sav'.
*********************************************************************************.
*Part 2 - P7 Child dental raw data
*********************************************************************************.
!file_tab sheet="2013_P7_C_DZ2011" range= "A5:E12816" name=P72013.
!file_tab sheet="2014_P7_C_DZ2011" range= "A5:E12775" name=P72014.
!file_tab sheet="2015_P7_C_DZ2011" range= "A5:E12721" name=P72015.
!file_tab sheet="2016_P7_C_DZ2011" range= "A5:E12836" name=P72016.
!file_tab sheet="2017_P7_C_DZ2011" range= "A5:E12955" name=P72017.

ADD FILES file = P72017
   /file = P72016
   /file = P72015
   /file = P72014
   /file = P72013.
execute.

DATASET CLOSE P72017.
DATASET CLOSE P72016.
DATASET CLOSE P72015.
DATASET CLOSE P72014.
DATASET CLOSE P72013.

aggregate outfile = *
   /break year datazone
   /numerator denominator = sum(numerator denominator).

save outfile = 'Raw Data/Prepared Data/Child_dental_P7_raw.sav'.

**********************************************************************.
*Part 3 - Calling the  macros 
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ level, and crude rates and percentages.
INSERT FILE=!macros + "DZ11 raw data - crude rate and percentage.sps".
****Child dental P1****.
!rawdata data=Child_dental_P1 domain='Children and Young People'  type='percent' time='single years' yearstart=2012 yearend=2016.
*Creating files for each profile.
get file ='Output/Child_dental_P1_formatted.sav'.
save outfile ='Output/Child_dental_P1_HW_formatted.sav'.
save outfile ='Output/Child_dental_P1_CYP_formatted.sav'.

****Child dental P7****.
!rawdata data=Child_dental_P7 domain='Children and Young People'  type='percent' time='single years' yearstart=2012 yearend=2016.
*Creating files for each profile.
get file ='Output/Child_dental_P7_formatted.sav'.
save outfile ='Output/Child_dental_P7_HW_formatted.sav'.
save outfile ='Output/Child_dental_P7_CYP_formatted.sav'.
*********************************************************************************************************************.
*Second macro. Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".
****Child dental P1****.
!crude_percent data =Child_dental_P1_HW domain='Children and Young People' ind_id = 21005 year_type = school  
min_opt =424260 max_opt =999999  crude_rate=0 profile=HN.
!crude_percent data =Child_dental_P1_CYP domain='Children and Young People' ind_id = 13014 year_type = school  
min_opt =8380 max_opt =999999  crude_rate=0 profile=CP.
*Checking results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

****Child dental P7****.
!crude_percent data =Child_dental_P7_HW domain='Children and Young People' ind_id = 21006 year_type = school  
min_opt =430890 max_opt =999999  crude_rate=0 profile=HN.
!crude_percent data =Child_dental_P7_CYP domain='Children and Young People' ind_id = 13015 year_type = school  
min_opt =15010 max_opt =999999 crude_rate=0 profile=CP.
*Checking results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END SYNTAX***.
