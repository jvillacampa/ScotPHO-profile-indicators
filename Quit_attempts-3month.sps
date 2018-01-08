*   Syntax to create data for indicator:12 weeks quit attempts. 
*Data comes from Smoking cessation annual publication.
*Numerator is quit attemps succesful at 3 monhts, denominator total quit attempts.
*Jaime Villacampa November 17

* Part 1 - Create general basefile
* Part 2 -Call Macros.

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Smoking/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************.
*Part 1 - Create basefile.
***********************************************************.
*Bringing code information for LA.
GET DATA  /TYPE=TXT
  /FILE="/conf/linkage/output/lookups/geography/Codes_and_Names/Council Area 2011 Lookup.csv"
  /ENCODING='UTF8' /DELCASE=LINE /DELIMITERS="," /ARRANGEMENT=DELIMITED  /FIRSTCASE=2
  /VARIABLES=  CouncilArea2011Code A9  CouncilArea2011Name A21.

sort cases by CouncilArea2011Name.
dataset name lookup.

*Raw data file to be merged with lookup.
GET DATA  /TYPE=TXT
  /FILE="Raw Data/Received Data/quit_attempts_12week_2017.csv"
  /ENCODING='UTF8' /DELCASE=LINE /DELIMITERS=","/QUALIFIER='"' /ARRANGEMENT=DELIMITED /FIRSTCASE=2 
 /VARIABLES = CouncilArea2011Name A21
  @200910_num COMMA6.0  @201011_num  COMMA6.0 @201112_num  COMMA6.0
  @201213_num  COMMA6.0 @201314_num  COMMA6.0  @201415_num  COMMA6.0
  @201516_num  COMMA6.0  @201617_num  COMMA6.0  @200910_tot COMMA6.0
  @201011_tot COMMA6.0  @201112_tot COMMA6.0  @201213_tot COMMA6.0  @201314_tot COMMA6.0
  @201415_tot COMMA6.0  @201516_tot COMMA6.0  @201617_tot COMMA6.0.

sort cases by CouncilArea2011Name.
match files file =*
   /table = lookup
   /by CouncilArea2011Name.
execute.
dataset close lookup.

*Now going for long data format, years as cases.
VARSTOCASES
/MAKE numerator FROM @200910_num  TO @201617_num 
/MAKE denominator FROM @200910_tot  TO @201617_tot 
/index year (numerator).

*Recoding years.
recode year ("@200910_num"="2009") ("@201011_num"="2010") ("@201112_num"="2011")  ("@201213_num"="2012") 
("@201314_num"="2013") ("@201415_num"="2014") ("@201516_num"="2015") ("@201617_num"="2016") . 
execute.

*formatting dataset to be used by macro.
RENAME VARIABLES   (CouncilArea2011Code=LA).
delete variables CouncilArea2011Name.
alter type year(f4).

save outfile = 'Raw Data/Prepared Data/quit_attempt_3month_raw.sav'.

******************************************************************************.
*Part 2 - Call macros.
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, uses population 16+ and standardised rates.
INSERT FILE=!macros + "LA raw data - crude rate and percentage.sps".
!rawdata data = quit_attempt_3month domain=Smoking type = percent time= 'single years' yearstart = 2009 yearend= 2016.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".
!crude_percent data = quit_attempt_3month domain=Smoking ind_id =1537 year_type = financial 
min_opt =105773 max_opt = 999999  profile=tp crude_rate=0.

*******.
*Checking results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***End***
