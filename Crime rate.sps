*Rolling updates, syntax to correctly format data for 'Crime Rate' indicator.
*Raw data comes from deprivation lookup created by GPD team: \\stats\cl-out\lookups\deprivation
*Required data is number of SIMD crimes in each LA 
*Different SIMD used for different years, as per ISD guidelines on deprivation.
*Jaime Villacampa September 2017

* Part 1 - Format raw data ready for macros.
* Part 2  - Calling the macros

******************************************************************************.
*Working directory and filepath to macros.
cd '/conf/phip/Projects/Profiles/Data/Indicators/Deprivation and Crime/'.
define !macros () "/conf/phip/Projects/Profiles/Data/Indicators/Macros/" !enddefine. 
******************************************************************************.
*************************************************************.
*Part 1 - Format raw data ready for macros.
*************************************************************.
*Small macro to standarize each years info. Macro parameters:
*Data is for what basefile to use, Datazone is for what dz type using, simd for which simd variables-year to look at, year for what year is the data created.
define !simd_inc (year=!tokens(1) /simd=!tokens(1) /data=!tokens(1) /datazone=!tokens(1)).

get file=!quote(!concat('/conf/linkage/output/lookups/deprivation/',!unquote(!data),'.sav'))
   /keep !datazone !simd
   /rename (!datazone !simd=datazone numerator).

compute year=!year.
execute.

dataset name !concat("@",!year).

!enddefine.

****run macro for each year***.
!simd_inc year=2004 simd= simd2006_crime_N data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2005 simd= simd2006_crime_N data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2006 simd= simd2006_crime_N data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2007 simd= simd2009v2_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2008 simd= simd2009v2_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2009 simd= simd2009v2_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2010 simd= simd2012_crime_N data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2011 simd= simd2012_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2012 simd= simd2012_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.
!simd_inc year=2013 simd= simd2012_crime_N  data=DataZone2001_all_simd datazone=DataZone2001.

*add all years together.
add files file=@2004
   /file=@2005
   /file=@2006
   /file=@2007
   /file=@2008
   /file=@2009
   /file=@2010
   /file=@2011
   /file=@2012
   /file=@2013.
execute.

*close datasets no longer needed.
 dataset close @2004.
 dataset close @2005.
 dataset close @2006.
 dataset close @2007.
 dataset close @2008.
 dataset close @2009.
 dataset close @2010.
 dataset close @2011.
 dataset close @2012.
 dataset close @2013.

*check all years are present.
frequencies year.

***Creating LA file for H&W.
*Match on CA2011 for years 2004-2013 using DZ2001.
rename variables datazone = datazone2001.
sort cases by datazone2001.
match files file = *
   /table = '/conf/linkage/output/lookups/geography/other_ref_files/DataZone2001.sav'
   /rename CA2011=LA    /by datazone2001    /keep year numerator LA.
execute.

*aggregate to get countr per council area per year.
aggregate outfile = *
   /break LA year
   /numerator = sum(numerator).

save outfile='Raw Data/Prepared Data/crime_rate_LA_raw.sav'.

*****************************************************
*For Datazone 2011 H&W profile.
!simd_inc year=2014 simd= simd2016_crime_N  data=DataZone2011_simd2016 datazone=DataZone2011.
!simd_inc year=2015 simd= simd2016_crime_N  data=DataZone2011_simd2016 datazone=DataZone2011.
!simd_inc year=2016 simd= simd2016_crime_N  data=DataZone2011_simd2016 datazone=DataZone2011.

*add all years together.
add files file=@2014
   /file=@2015
   /file=@2016.
execute.

 dataset close @2014.
 dataset close @2015.
 dataset close @2016.

save outfile='Raw Data/Prepared Data/crime_rate_dz11only_raw.sav'.

**********************************************************************.
* Part 2 - Calling the macros
************************************************************************.
**Syntax to call the macro that creates raw data for the Profiles, where the data is available at DZ/LA level, and crude rates/percentages/standardised rates.
INSERT FILE=!macros + "LA raw data-denominator added-crude rate and percentage.sps".
****Calling the macros****.
!rawdata data=crime_rate_LA domain ='Deprivation and Crime' type='crude' time='single years' yearstart=2004 yearend=2013 pop = LA_pop_allages.

*For Datazones 2011.
INSERT FILE=!macros + "DZ11 raw data-denominator added-crude rate and percentage.sps".
!rawdata data=crime_rate_dz11only domain ='Deprivation and Crime' type=crude time='single years' 
yearstart= 2014 yearend=2016 pop = DZ11_pop_allages.

*Joining the LA data before 2014 and the DZ11 data of 2014 and onwards.
add files file='Output/crime_rate_dz11only_formatted.sav'
/file='Output/crime_rate_LA_formatted.sav'.
execute.

save outfile='Output/crime_rate_dz11_formatted.sav'.

************************************************************************.
*Syntax to call the macro that does the analysis for the Profiles Rolling updates and crude rates.
INSERT FILE=!macros + "Analysis - crude rate and percentage.sps".

!crude_percent data = crime_rate_dz11 domain='Deprivation and Crime' ind_id =20801 year_type = calendar 
min_opt =375980 max_opt = 999999 profile = HN crude_rate=1000.

***************************************************************************.
* Checking final results.
INSERT FILE=!macros + "final_graph_check.sps".
*Scotland looks roughly in the middle, some outlying values due to large ci in islands.

***END***  .
