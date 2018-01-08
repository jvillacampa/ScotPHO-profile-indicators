*   Syntax to create data for indicator:  Total quit attempts 
*Raw data comes from the Smoking cessation publication. 
*We excluded unknowns so total figures will not match perfectly with publication total figures.
*Also we use HB of residence instead as the publications HB of treatment.
 * November 17 Jaime Villacampa

 * Part 1 Creating basefile
 * Part 2 Aggregating the different geographies
*  Part 3 - add in the extra columns needed for the profiles.

******************************************************************************.
*Working directory and filepath to macros.
cd   '/conf/phip/Projects/Profiles/Data/Indicators/Smoking/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************.
*Part 1 - Create basefile.
***********************************************************.
*Bringing code information for LA.
GET DATA  /TYPE=TXT
  /FILE="/conf/linkage/output/lookups/geography/Codes_and_Names/Council Area 2011 Lookup.csv"
  /ENCODING='UTF8' /DELCASE=LINE /DELIMITERS="," /ARRANGEMENT=DELIMITED  /FIRSTCASE=2
  /VARIABLES=
  CouncilArea2011Code A9
  CouncilArea2011Name A21.

sort cases by CouncilArea2011Name.
dataset name lookup.

*Raw data file to be merged with lookup.
GET DATA  /TYPE=TXT
  /FILE="Raw Data/Received Data/quit_attemtps_total_2017.csv"
  /ENCODING='UTF8' /DELCASE=LINE /DELIMITERS=","/QUALIFIER='"' /ARRANGEMENT=DELIMITED /FIRSTCASE=2 
 /VARIABLES = CouncilArea2011Name A21
  @200910 COMMA6.0  @201011 COMMA6.0  @201112 COMMA6.0  @201213 COMMA6.0
  @201314 COMMA6.0  @201415 COMMA6.0  @201516 COMMA6.0  @201617 COMMA6.0.

sort cases by CouncilArea2011Name.
match files file =*
   /table = lookup
   /by CouncilArea2011Name.
execute.

dataset close lookup.

*Now going for long data format, years as cases.
VARSTOCASES
/MAKE numerator FROM @200910 TO @201617
/index year (numerator).

*Recoding years.
recode year ("@200910"="2009") ("@201011"="2010") ("@201112"="2011")  ("@201213"="2012") 
("@201314"="2013") ("@201415"="2014") ("@201516"="2015") ("@201617"="2016") . 
execute.

*match on health boards on the data extract.
RENAME VARIABLES   CouncilArea2011Code=CA.
alter type ca(a27).
sort cases by ca.
match files file =*
   /table =  '/conf/linkage/output/lookups/geography/other_ref_files/CA_HB2014.sav'
   /by CA.
execute.

save outfile = 'Raw Data/Prepared Data/total_quit_attempts_raw.sav'.

***********************************************************.
*Part 2 - Aggregate for each geography and join them together.
***********************************************************.
rename variables CA = code.
delete variables CouncilArea2011Name HB2014.
dataset name LA.

*re-read in the dataset to get the data for HB.
get file = 'Raw Data/Prepared Data/total_quit_attempts_raw.sav'.

aggregate outfile = *
   /break year HB2014
   /numerator = sum(numerator).

rename variables HB2014 = code.
dataset name HB.

*re-read in the dataset to get the data for Scotland.
get file = 'Raw Data/Prepared Data/total_quit_attempts_raw.sav'.

string Code (a27).
compute Code='S00000001'.
execute.

aggregate outfile = *
   /break year Code
   /numerator = sum(numerator).

*merge all geographies together.
add files file=*
   /file = HB
   /file = LA.
execute.

dataset close HB.
dataset close LA.

***************************************************************************************.
*Part 3 - add in the extra columns needed for the profiles.
***************************************************************************************.
*add in the definition period and trend axis labels, alsto time period and year types.
string def_period (a50) trend_axis (a50) time (A30) year_type(a15).
alter type year(f4).
compute time = 'single years'.
compute year_type = 'financial'.
execute.

*Time period macro. Come with a warning, but seems to work fine.
INSERT FILE=!macros + "time_period.sps".
!time_period_analysis ().

*add in the OPT numbers for the tool.
loop #i=105397 to 999999.
   compute uni_id1=#i.
   end case.
end loop.
execute.

string uni_id (A8).
compute uni_id = concat(replace('tp',' ',''),string(uni_id1,f6.0)).
compute uni_id = replace(uni_id, ' ','').
execute.

*add in the indicator ID number for tool upload.
compute ind_id = 1505.
execute.

*add in blank columns for the rate and the confidence intervals. 
string rate (a30) lci (a30) uci (a30).
execute.

save translate outfile = 'OPT Data/quit_attempts_total_OPTdata.csv'
   /type = csv /replace /keep uni_id code ind_id year numerator rate lci uci def_period trend_axis.

**END**