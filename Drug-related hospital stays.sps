*   Syntax to create data for indicator: Drug-related hospital stays. 
* To match the HIT DRHS publication, Scotland & HB levels are not produced by aggregating smaller geographies up.
*Joanna Targosz, 14/09/2016.
*Jaime Villacampa, May17 - adding dz11 H&W part.

*Part 1 - Creating raw file for Drugs profile.
*Part 2 - Creating raw file for H&W 2011 profile
*Part 3 - Calling the raw data macros

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Drugs/'. 
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
************************************************************************.
*Part 1 - Creating raw file for Drugs profile.
************************************************************************.
*For the data done at LA, HB or ADP level a seperate file needs to be created so that it match the Drug related hospital stats publication.
*to do this the CIS base file from the Drug analysis is needed and a count of stays by LA is needed.
*drop the ADP variable as this is the order needed for the publications and the lookups will not match.
get file = '/conf/phip/Projects/Drug Related Hospital Statistics/FY2016_17/Data/SMR01_drugs_CIS_file.sav'
/keep council sex age_grp year
/rename sex=sex_grp.

*recode council numbers into SG codes.
string LA (a9).
do repeat a= 6 8 10 12 13 32 15
                     16 18 19 20 21 22 24
                     25 5 27 28 29 30 1
                     2 4 14 26 7 31 3
                     9 23 11 17
                /b ='S12000005' 'S12000006'  'S12000008'  'S12000010'  'S12000011'  'S12000013'  'S12000014' 
                     'S12000015'  'S12000017'  'S12000018'  'S12000019'  'S12000020'  'S12000021'  'S12000023'  
                     'S12000024'  'S12000026'  'S12000027'  'S12000028'  'S12000029'  'S12000030'  'S12000033'  
                     'S12000034'  'S12000035'   'S12000036' 'S12000038'  'S12000039'  'S12000040'  'S12000041'  
                     'S12000042'  'S12000044'  'S12000045'  'S12000046'. 
          if (council = a) LA = b.
end repeat. 
execute.

*aggregate the file to get the data by LA level.
aggregate outfile = *
   /break year LA sex_grp age_grp
   /numerator = n.

*Select only scottish residents i.e. valid LA code.
select if LA ne ''.
execute.

save outfile = 'Raw Data/Prepared Data/drug_stay_LA_raw.sav'.

**********************************************************************.
*Part 2 - Creating raw file for H&W 2011 profile
************************************************************************.
get file = '/conf/phip/Projects/Drug Related Hospital Statistics/FY2016_17/Data/SMR01_drugs_CIS_file.sav'
/keep pc7 year sex age_grp /rename sex=sex_grp.

*Matching with geographies.
sort cases by pc7.
alter type pc7(a21).
match files file=*
/table='/conf/linkage/output/lookups/geography/Scottish_Postcode_Directory_2017_2.sav'
/by pc7   /keep year age_grp sex_grp datazone2001 datazone2011.
execute.

*Select if Scottish resident.
select if datazone2011 ne "".
execute.

dataset name basefile.

aggregate outfile = *
   /break year datazone2011 sex_grp age_grp
   /numerator = n.

save outfile='Raw Data/Prepared Data/drug_stays_dz11_raw.sav'
/rename datazone2011=datazone.

dataset activate basefile.

*Getting dz01 file, only used for IRs.
aggregate outfile = *
   /break year datazone2001 sex_grp age_grp
   /numerator = n.

save outfile='Raw Data/Prepared Data/drug_stays_dz01_raw.sav'.

dataset close basefile.

*Merging dz01 and dz11 together.
add files file= 'Raw Data/Prepared Data/drug_stays_dz01_raw.sav'
/file= 'Raw Data/Prepared Data/drug_stays_dz11_raw.sav'.
execute.

*Excluding datazone2001 from 2011 and onwards.
select if (datazone ne "" or year<2011) and not (datazone2001 = ""  and year<2011).
execute.

if datazone = "" datazone=datazone2001.
execute.

save outfile=  'Raw Data/Prepared Data/DZ_drug_stays_IR_raw.sav'
/drop datazone2001.

**********************************************************************.
*Part 3 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ/LA level, and crude rates/percentages/standardised rates.
INSERT FILE=!macros + "LA raw data - standardised rates.sps".
!stdrate data=drug_stay_LA domain='Drugs'   type=stdrate time='single years' yearstart=2002 
yearend=2016 pop='LA_pop_allages_SR' epop_age=''.

*******************
*Now for ADP level.
rename variables code = LAcode.
alter type LAcode(a9).
sort cases by LAcode.
match files file = *
   /table = '/conf/phip/Projects/Profiles/Data/Lookups/LA_ADP_lookup.sav'    /by LAcode.
execute.

if ADPcode ="" ADPcode=LAcode.
execute.

aggregate outfile=*
/break year adpcode age_grp sex_grp type time epop_age Epop
/numerator denominator= sum(numerator denominator).
rename variables adpcode=code.

save outfile='Output/drug_stays_ADPnew_formatted.sav'.

*for datazone 2011.
INSERT FILE=!macros + "DZ11 raw data - standardised rates.sps".
!stdrate data=drug_stays_dz11 domain='Drugs'   type=stdrate time='3-year aggregate' yearstart=2002 
yearend=2016 pop='DZ11_pop_allages_SR' epop_age=''.

*Taking out IZ where population data not available or incomplete.
get file='Output/drug_stays_dz11_formatted.sav'.

*Excluding IZ level from 2002 to 2011 as there is no population data available or is not complete for the 3yr aggregate.
select if not ( year<2012 and substr(code,1,3)='S02').
execute.

save outfile='Output/drug_stays_dz11_formatted.sav'.

**********************************************************************.
*Calling the analysis macro.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - standardisation.sps".

*For Drugs profile.
!standardisation data=drug_stays_ADPnew domain='Drugs' ind_id = 4120 year_type =financial 
min_opt = 157613 max_opt = 900000  Epop_total = 200000 profile = 'du'.

*For Health and Wellbeing profile.
!standardisation data =drug_stays_dz11 domain='Drugs' ind_id =20205 year_type = financial 
min_opt = 365805 max_opt = 800000 profile = HN Epop_total=200000.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, lots of variation, some outlying values due to large ci in islands.

***END***  .