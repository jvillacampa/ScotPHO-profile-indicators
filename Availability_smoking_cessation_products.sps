*A syntax to prepare the indicators data: Availability of smoking cessation products.
*For over 12's.

*Salomi Barkat, 25/01/2016.
*Jaime Villacampa December-17

*Part 1 - Create basefile
*Part 2 - Call the macros

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
  /VARIABLES=
  LA A9
  CouncilArea2011Name A21.

sort cases by CouncilArea2011Name.
dataset name lookup.

*Reading raw data from prescribing team.
GET DATA /TYPE=XLSX
  /FILE='Raw Data/Received Data/IR2017-01756-smoking cessation products.xlsx'
  /SHEET=name Data /CELLRANGE=range "B6:J160804"
  /READNAMES=on /ASSUMEDSTRWIDTH=32767.
EXECUTE.

RENAME VARIABLES (v1 v3 v9 = year CouncilArea2011Name DDDdose).
select if CouncilArea2011Name ne "".
execute.

sort cases by CouncilArea2011Name.
match files file =*
   /table = lookup
   /by CouncilArea2011Name.
execute.

dataset close lookup.

*aggregate to get total DDDs for each datazone/year.
aggregate outfile=*
   /break LA year
   /totDDD=sum(DDDdose).

*value is defined *daily* doses, so needs to be divided by 365.
compute numerator=totDDD/365.
execute.

save outfile='Raw Data/Prepared Data/cessation_products_raw.sav'
/drop totDDD.

***********************************************************.
*Part 2 - Calling the macros
******************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, crude rates.
INSERT FILE=!macros + "LA raw data-denominator added-crude rate and percentage.sps".
!rawdata data=cessation_products domain=Smoking type=crude time='single years' yearstart=2002 yearend=2016 pop=LA_pop_over12.

*******Second macro
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and standardised rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".
!crude_percent data = cessation_products domain=Smoking ind_id =1544 year_type = financial 
min_opt =106149 max_opt = 999999  profile=tp crude_rate =1000.

* Checking final output
*To be done as a lat part of the checking process to ensure rates and CIs look sensible. 
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle.

************************************END

