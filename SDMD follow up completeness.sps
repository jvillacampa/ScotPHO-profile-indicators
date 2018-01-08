*Syntax to create indicator data for: SDMD follow-up completeness
*Individuals on SDMD with 12 week follow up record. Raw file comes from ISD drugs team. 
*Jaime Villacampa 5-4-17

*Part 1 - Create basefile
*Part 2 - Call the macros
******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Drugs/'. 
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************.
*Part 1 - Create basefile.
***********************************************************.
get file='Raw Data/Received Data/SDMD follow up completeness basefile.sav'
/rename (SDMDpeople FOLLOWUPpeople = denominator numerator)    /drop name.

*Variables needed for analysis macro.
string type(A30) time(A30).
compute type="percent".
compute time="single years".
execute.

save outfile= 'Output/SDMD_follow_up_Apr17_formatted.sav'.

***********************************************************.
*Part 2 - Calling the macro
******************************************************************************.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and percentages.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data =SDMD_follow_up_Apr17 domain=Drugs ind_id =4138  year_type =financial 
min_opt = 155018 max_opt =999999 profile=du crude_rate=0.

**********.
*There needs to be some cleaning of the final file, to allow proper display of it.
get file = 'Output/SDMD_follow_up_Apr17_final.sav'.

*due to data issues and no value available for Scotland for 2013/14, to load and display data correctly in the OPT
for year 2013 & code 'S00000001' type 1 in number column, and leave the measure column blank.
if code="S00000001" and year=2013 numerator=1.
if code="S00000001" and year=2013 rate=$sysmis.
if code="S00000001" and year=2013 lowci=$sysmis.
if code="S00000001" and year=2013 upci=$sysmis.
execute.

 * Other rows with missing values - to be removed from CSV file before load.
select if not sysmis(numerator).
execute.

save translate outfile = 'OPT Data/SDMD_follow_up_Apr17_OPTdata.csv'
   /type = csv  /replace   /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

***********************************************************.
*Checking final output.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, lots of variability.

************************************END
