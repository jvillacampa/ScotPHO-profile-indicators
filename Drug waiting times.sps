*   Syntax to create data for indicator: Drugs waiting times.
*Data has been extracted from the Waiting times publication and formatted slightly in excel.
*Jaime Villacampa June 17.

*Part 1 - Create raw basefile
*Part 2 - Format the data for the macro.
*Part 3- Calling the macros.

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Drugs/'. 
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***************************************************************************************.
* Part 1 - Create raw basefile 
***************************************************************************************.
GET DATA /TYPE=XLSX
  /FILE= 'Raw Data/Received Data/Drugs_waiting_times_2017.xlsx'
  /SHEET=name 'Drugs'  /CELLRANGE=full /READNAMES=on /ASSUMEDSTRWIDTH=32767.

*round numerator.
compute numerator=rnd(numerator).
*get rid of the spaces in front of the area names.    
compute area = ltrim(area).
frequencies area.

*add in the SG codes.
string code (a9).
recode area 
   ('Clackmannanshire ADP' = 'S11000005') ('Falkirk ADP' = 'S11000013') ('Stirling ADP' = 'S11000029')
   ('Dumfries & Galloway ADP' = 'S11000006') ('East Ayrshire ADP' = 'S11000008') ('North Ayrshire ADP' = 'S11000020')
   ('South Ayrshire ADP' = 'S11000027')('Midlothian and East Lothian' = 'S11000051')  ('West Lothian ADP' = 'S11000031')
   ('Edinburgh City ADP' = 'S11000012') ('East Renfrewshire ADP' = 'S11000011') ('East Dunbartonshire ADP' = 'S11000009')  
   ('Inverclyde ADP' = 'S11000017') ('Renfrewshire ADP' = 'S11000024')   ('West Dunbartonshire ADP' = 'S11000030')  
   ('Midlothian and East Lothian ADP (MELDAP)' = 'S11000051')('Glasgow City ADP' = 'S11000015')  ('Outer Hebrides ADP' = 'S11000032')  
    ('Fife ADP' = 'S11000014')  ('Highland ADP' = 'S11000016')   ('Argyll & Bute ADP' = 'S11000004')  
   ('Moray ADP' = 'S11000019')  ('Aberdeen City ADP' = 'S11000001')   ('Aberdeenshire ADP' = 'S11000002')
   ('Orkney ADP' = 'S11000022')  ('Perth & Kinross ADP' = 'S11000023')   ('Angus ADP' = 'S11000003')
   ('Dundee City ADP' = 'S11000007')  ('Borders ADP' = 'S11000025')   ('Shetland ADP' = 'S11000026')   
   ('Lanarkshire ADP' = 'S11000052')   ('Scotland' = 'S00000001') ('Ayrshire & Arran NHS' = 'S08000015')
   ('Borders NHS' = 'S08000016')  ('Dumfries & Galloway NHS' = 'S08000017') ('Fife NHS' = 'S08000018')
   ('Forth Valley NHS' = 'S08000019')   ('Grampian NHS' = 'S08000020')  ('Greater Glasgow & Clyde NHS' = 'S08000021')
   ('Highland NHS' = 'S08000022') ('Lanarkshire NHS' = 'S08000023')  ('Lothian NHS' = 'S08000024')
   ('Orkney NHS' = 'S08000025') ('Shetland NHS' = 'S08000026') ('Tayside NHS' = 'S08000027') ('Outer Hebrides NHS' = 'S08000028')
   into code.
frequencies code.

save outfile = 'Raw Data/Prepared Data/Drugs_waiting_times_raw.sav'
/drop area.

***************************************************************************************.
*Part 2 - Format the data for the macro.
***************************************************************************************.
get file = 'Raw Data/Prepared Data/Drugs_waiting_times_raw.sav'.

*Going for Scotland totals, excluding ADP's to avoid double counting.
select if substr(code,1,3)='S08'.
compute code = 'S00000001'.
execute.

*Aggregate to create Scotland's totals.
aggregate outfile=*
/break year code
/denominator numerator=sum(denominator numerator).

add files file = *
   /file = 'Raw Data/Prepared Data/Drugs_waiting_times_raw.sav'.
execute.

*add in a variable to let the next macro which type of CI's needed.
*add in a variable to state the time period e.g. single year or 3-year aggregate.
string type (A30)  time (A30).
compute type = 'percent'.
compute time ='single years'.
execute.

save outfile = 'Output/Drugs_waiting_times_formatted.sav'.

**********************************************************************.
*Part 3- Calling the  macros.
************************************************************************.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data=Drugs_waiting_times domain='Drugs' ind_id = 4136 year_type = financial 
min_opt = 155318  max_opt = 999999 profile = 'du' crude_rate=0.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, lots of variation, some outlying values due to large ci in islands.

**END**
