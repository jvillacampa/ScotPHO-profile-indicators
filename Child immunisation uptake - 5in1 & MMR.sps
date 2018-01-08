*   Syntax to create data for indicators: immunisation uptake (MMR and 5in1). 
*   Neil Davies, 06/04/2017.

*    -Part 1 - Formatting data Immunisation uptake at 24 months - 5in1 .
*    -Part 2 - Formatting Immunisation uptake at 24 months - MMR.
*    -Part 3 - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd /conf/phip/Projects/Profiles/Data/Indicators/Children and Young People/.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine.
******************************************************************************.
****************************************************.
*Part 1 - Formatting Immunisation uptake at 24 months - 5in1 ready for macros.
****************************************************.
get file = 'Raw Data/Received Data/Immunisation MMR & 5in1 DZ2001.sav'.

aggregate outfile = *
   /break year datazone2001
   /denominator numerator = sum(total24 five24).

rename variables datazone2001=datazone.

save outfile =  'Raw Data/Prepared Data/Immunisation_5in1_Apr17_raw.sav'.

*For datazones 2011.
get file = 'Received Data/Immunisation MMR & 5in1 DZ2011.sav'.

aggregate outfile = *
   /break year datazone2011
   /denominator numerator = sum(total24 five24).

rename variables datazone2011=datazone.

save outfile =  'Raw Data/Prepared Data/Immunisation_5in1_dz11_raw.sav'.

****************************************************.
*Part 2 - Formatting Immunisation uptake at 24 months - MMR ready for macros.
****************************************************.
get file = 'Raw Data/Received Data/Immunisation MMR & 5in1 DZ2001.sav'.

aggregate outfile = *
   /break year datazone2001
   /denominator numerator = sum(total24 mmr24).

rename variables datazone2001=datazone.

save outfile =  'Raw Data/Prepared Data/Immunisation_MMR_Apr17_raw.sav'.

*For datazones 2011.
get file = 'Raw Data/Received Data/Immunisation MMR & 5in1 DZ2011.sav'.

aggregate outfile = *
   /break year datazone2011
   /denominator numerator = sum(total24 mmr24).

rename variables datazone2011=datazone.

save outfile =  'Raw Data/Prepared Data/Immunisation_MMR_dz11_raw.sav'.

**********************************************************************.
* Part 3 - Calling the macros
************************************************************************.
INSERT FILE = !macros + "DZ11 raw data - crude rate and percentage.sps".

!rawdata data=Immunisation_5in1_dz11 domain ='Children and Young People' type='percent' time='3-year aggregate' yearstart= 2003 yearend= 2016.
!rawdata data=Immunisation_MMR_dz11 domain ='Children and Young People' type='percent' time='3-year aggregate' yearstart= 2003 yearend= 2016.

*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

****Immunisation uptake at 24 months - 5in1***.
!crude_percent data =Immunisation_5in1_dz11 domain='Children and Young People' ind_id = 21103 year_type = calendar  min_opt =93240 max_opt =999999 profile = HN crude_rate = 0.
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

****Immunisation uptake at 24 months - MMR***.
!crude_percent data =Immunisation_MMR_dz11 domain='Children and Young People' ind_id = 21104 year_type = calendar  min_opt =109152 max_opt =999999 profile = HN crude_rate = 0.
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .
