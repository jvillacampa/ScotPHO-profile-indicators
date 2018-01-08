*   Syntax to create data for indicator: 15% access deprived indicator for the scotpho profiles.
*it uses 2001 based populations up to 2013 and 2011 for 2014 onwards.
*to get 15% the first 3 vigintiles have to be calculated from the simd ranks.
*however this changes year to year depending on the population and this syntax takes that into account.

*Anna Mackinnon.25th March 2015.
*Salomi Barkat, 05/01/16 - updating to include 2014 data.
*Jaime Villacampa, 6-3-17 - updating to include 2015 data and SIMD 2016, simplification through loops/macros.

*Part 1 - create a 3rd vigintile population file.
*Part 2 - create the total population file by datazone, with years as variables.
*Part 3 - create the simd rank (all simds) file by datazone, with simd rank as variables.
*Part 4 - match together total populations and simd rank files and create cumulative populations.
*Part 5 - calculate the population for the access deprived areas.
*Part 6 - Match with datazone lookups
*Part 7 - Calling the macros.
******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Deprivation and Crime/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
***********************************************************.
*Part 1 - create a 3rd vigintile population file.
***********************************************************.
*read in the 2001 based populations at datazone level.
get file= '/conf/linkage/output/lookups/populations/estimates/DataZone2001_pop_est_2001_2014.sav'
   /keep  year total_pop.

select if year<2014.
execute.

dataset name dz01.

*Now 2011 pop for 2015.
get file= '/conf/linkage/output/lookups/populations/estimates/DataZone2011_pop_est_2011_2016.sav'
   /keep  year total_pop.

select if year>2013.
execute.

*Adding both files together.
add files file=*
/file=dz01.
EXECUTE.

dataset close dz01.

*aggregate to get total population count.
aggregate outfile = *
   /break year
   /total_pop = sum(total_pop).

*compute the 3rd vigintile.
compute v3 = total_pop/20 * 3.
execute.

*remove total pop as no longer needed.
delete variables total_pop.

*reshape data to enable calculations and matching later.
casestovars
   /index year
   /groupby = variable.

*create scotland variable for matching on later.
string scotland (A8).
compute scotland = 'scotland'.
execute.

save outfile = 'Output/temp_Scotland_pops.tmp'.

***********************************************************.
*Part 2 - create the total population file by datazone, with years as variables.
***********************************************************.
*match on the total population.
get file= '/conf/linkage/output/lookups/populations/estimates/DataZone2001_pop_est_2001_2014.sav'
   /keep DataZone2001 year total_pop
   /rename DataZone2001=datazone.

select if year<2014.
execute.

dataset name dz01.

*Now 2011 pop for 2014 onwards.
get file= '/conf/linkage/output/lookups/populations/estimates/DataZone2011_pop_est_2011_2016.sav'
   /keep DataZone2011 year total_pop
   /rename DataZone2011=datazone.

select if year>2013.
execute.

*Adding both files together.
add files file=*
/file=dz01.
EXECUTE.

dataset close dz01.

*aggregate to get totals for each year.
aggregate outfile = *
   /break year datazone
   /total_pop = sum(total_pop).

*reformat so that years go along the top.
sort cases by datazone Year.
casestovars
  /id=datazone
  /index=Year
  /groupby=variable.

rename variables ( total_pop.2001 total_pop.2002 total_pop.2003 total_pop.2004 total_pop.2005 total_pop.2006 total_pop.2007 total_pop.2008 
                              total_pop.2009 total_pop.2010 total_pop.2011 total_pop.2012 total_pop.2013 total_pop.2014 total_pop.2015 total_pop.2016
                              = @2001 @2002 @2003 @2004 @2005 @2006 @2007 @2008 @2009 @2010 @2011 @2012 @2013 @2014 @2015 @2016).

sort cases by datazone.

dataset name populations.

***********************************************************.
*Part 3 - create the simd rank (all simds) file by datazone, with simd rank as variables.
***********************************************************.
*match all simd rank files together.
get file='/conf/linkage/output/lookups/deprivation/DataZone2001_all_simd.sav'
   /keep DataZone2001 simd2012_access_rank simd2009v2_access_rank simd2006_access_rank simd2004_access_rank
   /rename DataZone2001=datazone.

*rename variables so that it is easy to type and clear.
rename variables (simd2012_access_rank simd2009v2_access_rank simd2006_access_rank simd2004_access_rank = access_rank_2012 access_rank_2009 access_rank_2006 access_rank_2004).

*replicate the simd 2004 rank for 2001 to 2003.
compute access_rank_2001=access_rank_2004.
compute access_rank_2002 = access_rank_2004.
*rename as 2004 rank is not needed for 2004.
rename variables access_rank_2004 = access_rank_2003.
execute.

*replicate the simd 2006 rank for 2004 to 2006.
compute access_rank_2004 = access_rank_2006.
compute access_rank_2005 = access_rank_2006.
*replicate the simd 2009 rank for 2007 to 2009.
compute access_rank_2007 = access_rank_2009.
compute access_rank_2008 = access_rank_2009.
*replicate the simd 2012 rank for 2010 to 2014.
compute access_rank_2010 = access_rank_2012.
compute access_rank_2011 = access_rank_2012.
compute access_rank_2013 = access_rank_2012.
execute.

dataset name dz01.

*Now simd2016  for 2015.
get file='/conf/linkage/output/lookups/deprivation/DataZone2011_simd2016.sav'
   /keep DataZone2011 simd2016_access_rank 
   /rename (DataZone2011 simd2016_access_rank =datazone access_rank_2016).

compute access_rank_2014=access_rank_2016.
compute access_rank_2015=access_rank_2016.
compute access_rank_2016=access_rank_2016.
execute.

*Adding both files together.
add files file=*
/file=dz01.
EXECUTE.

dataset close dz01.

*standardise variable format.
formats access_rank_2001 access_rank_2002 access_rank_2003 access_rank_2004 access_rank_2005 access_rank_2006 access_rank_2007 
      access_rank_2008 access_rank_2009 access_rank_2010 access_rank_2011 access_rank_2012 access_rank_2013 access_rank_2014  
      access_rank_2015 access_rank_2016 (f4.0).

*sort ahead of merge with populations.
sort cases by datazone.

dataset name ranks.

***********************************************************.
*Part 4 - match together total populations and simd rank files and create cumulative populations.
***********************************************************.
*match on the populations to the data set and re-order.
match files file = ranks
   /file = populations  /by datazone.
execute.

*close temporary datasets.
dataset close ranks.
dataset close populations.

*Small macro to add in a cumulative pop column.
define !cumulative(rank = !tokens(1) /cumul = !tokens(1) /pop = !tokens(1)).
sort cases by !rank.
create !cumul= csum(!pop).
execute.
!enddefine.
*Calling macro for each year.
!cumulative rank=access_rank_2001 cumul=csum_2001 pop=@2001.
!cumulative rank=access_rank_2002 cumul=csum_2002 pop=@2002.
!cumulative rank=access_rank_2003 cumul=csum_2003 pop=@2003.
!cumulative rank=access_rank_2004 cumul=csum_2004 pop=@2004.
!cumulative rank=access_rank_2005 cumul=csum_2005 pop=@2005.
!cumulative rank=access_rank_2006 cumul=csum_2006 pop=@2006.
!cumulative rank=access_rank_2007 cumul=csum_2007 pop=@2007.
!cumulative rank=access_rank_2008 cumul=csum_2008 pop=@2008.
!cumulative rank=access_rank_2009 cumul=csum_2009 pop=@2009.
!cumulative rank=access_rank_2010 cumul=csum_2010 pop=@2010.
!cumulative rank=access_rank_2011 cumul=csum_2011 pop=@2011.
!cumulative rank=access_rank_2012 cumul=csum_2012 pop=@2012.
!cumulative rank=access_rank_2013 cumul=csum_2013 pop=@2013.
!cumulative rank=access_rank_2014 cumul=csum_2014 pop=@2014.
!cumulative rank=access_rank_2015 cumul=csum_2015 pop=@2015.
!cumulative rank=access_rank_2016 cumul=csum_2016 pop=@2016.

*match on the 3rd vigintile population file.
*match on the scotland populations.
*create a variable for scotland pops to match on to.
string scotland (A8).
compute scotland = 'scotland'.
execute.

match files file = *
   /table = 'Output/temp_Scotland_pops.tmp'
   /by scotland.
execute.

***********************************************************.
*Part 5 - calculate the population for the access deprived areas
***********************************************************.
*Creating variables needed for the calculations.
numeric access_flag_2001 to access_flag_2016 (f1).
*flag if the population difference between the 3rd vigintile population and the cumlative population for each year is positive.
do repeat
   a=v3.2001 to v3.2016
   /b=csum_2001 to csum_2016
   /c=access_flag_2001 to access_flag_2016.
if (a-b)>=0 c = 1.
end repeat.
execute.

*check frequencies to see if flagged figures seem sensible.
frequencies access_flag_2001 access_flag_2002 access_flag_2003 access_flag_2004 access_flag_2005 access_flag_2006 access_flag_2007
         access_flag_2008 access_flag_2009 access_flag_2010 access_flag_2011 access_flag_2012 access_flag_2013 access_flag_2014 
         access_flag_2015 access_flag_2016.

*fill in the total population for the access deprvied data zones.
numeric acc_dep_pop_2001 to acc_dep_pop_2016 (f20).
do repeat
   a= acc_dep_pop_2001 to acc_dep_pop_2016
   /b=@2001 to @2016
   /c=access_flag_2001 to access_flag_2016.
compute a=0.
if c=1 a=b.
end repeat.
execute.

*aggregate to get rid of blanks and get everything in correct format.
aggregate outfile = *
   /break datazone
   /acc_dep_pop_2001 to acc_dep_pop_2016
   = sum(acc_dep_pop_2001 to acc_dep_pop_2016).

*change variables to cases.
varstocases 
   /make numerator from acc_dep_pop_2001 to acc_dep_pop_2016 
   /index year.

recode year
   (1 = 2001) (2 = 2002) (3 = 2003) (4 = 2004) (5 = 2005) (6 = 2006) (7 = 2007) (8 = 2008) (9 = 2009) (10 = 2010) 
   (11 = 2011) (12 = 2012) (13=2013) (14=2014) (15=2015) (16=2016).

*Creating files for IR's.
save outfile = 'Raw Data/Prepared Data/acc_dep_dz01_raw.sav'.
save outfile = 'Raw Data/Prepared Data/acc_dep_dz11_raw.sav'.

***********************************************************.
*Part 6 - Match with datazone lookups
***********************************************************.
*Prepare for merging with dz11 lookup.
rename variables (datazone=datazone2011).
sort cases by datazone2011.

*Matching with lookup file for dz11.
match files file = *
   /table = '/conf/linkage/output/lookups/geography/DataZone2011/DataZone2011.sav'
   /by datazone2011  /keep CA2011 datazone2011 numerator year.
execute.

*Prepare for merging with dz01 lookup.
rename variables (datazone2011 Ca2011=datazone2001 LA).
alter type datazone2001(a27) LA(a9).
sort cases by datazone2001.

*Matching with lookup file for dz01.
match files file = *
   /table = '/conf/linkage/output/lookups/geography/other_ref_files/DataZone2001.sav'
   /by datazone2001  /keep CA2011 datazone2001 LA numerator year.
execute.

*To get only one local authority variable.
if LA="" LA=CA2011.
frequencies LA.

*Aggregating by council area to create raw file for Health and Wellbeing profile .
aggregate outfile=*
/break LA year
/numerator=sum(numerator).

save outfile=  'Raw Data/Prepared Data/acc_dep_LA_raw.sav'.

erase file = 'Output/temp_Scotland_pops.tmp'.
**********************************************************************.
* Part 7  - Calling the macros 
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at LA level, and crude rates/percentages/standardised rates.
INSERT FILE=!macros + "LA raw data-denominator added-crude rate and percentage.sps".
!rawdata data=acc_dep_LA domain ='Deprivation and Crime' type=percent time='single years' yearstart= 2002 yearend=2013 pop = LA_pop_allages.

*For Datazones 2011.
INSERT FILE=!macros + "DZ11 raw data-denominator added-crude rate and percentage.sps".
!rawdata data=acc_dep_dz11 domain ='Deprivation and Crime' type=percent time='single years' 
yearstart= 2014 yearend=2016 pop = DZ11_pop_allages.

*Adding time trend for LA and HB for H&W profile.
add files file='Output/acc_dep_dz11_formatted.sav'
/file = 'Output/acc_dep_LA_formatted.sav'.
execute.

save outfile ='Output/acc_dep_all_formatted.sav'.

*********************************************************************************
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data = acc_dep_all domain='Deprivation and Crime' ind_id =20902 year_type = calendar 
min_opt =392832 max_opt = 999999 profile = HN crude_rate=0.

***************************************************************************
*Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, quite a lot of variability.

***END***  .

