*Syntax to manipulate the raw data for the ScotPHO profiles indicators, where the data is available at LA level and 
   the output is a crude rate or a percentage. Denominator is NOT present in the raw data.
*This syntax is a macro that adds population (denominator) data, aggregates the data to the different geographical levels 
required (IZ, LA, HB and Scotland), and in the time period you input (e.g. 3-year aggregates).

*Notes:
*When reading in your data, it needs to be standard format, so make sure it has the following variables:
 - year
 -LA
 -numerator
*If it is not in the correct format, do this first before running it through the macro.

*Variables to input in the macro:
*data=indicator name
*domain=the topic the indicator falls under.
*type=e.g. percent/crude/stdrate
*time=time period, e.g. single year, 2-year aggregate.
*yearstart=first year of data that you have, e.g. if you had data for 2004-2013, yearstart would be 2004.
*yearend= last year of the data that you have, e.g. if you had data for 2004-2013, yearend would be 2013.
*pop=population file used as denominator in lookup folder.

*CHECKING: 
*As the macro runs everything at once, we have built in 3 checks to make sure the data is correct before it gets to the analysis stage.
*CHECK 1 - check the raw data when you receive it, make sure the figures seem sensible. You can also check against publications if the data is published.
*CHECK 2 - occurs between parts 2 and 3 of the macro, check the populations and lookups we have added on, and that we have not altered the numerator.
*CHECK 3 -occurs at the end of the syntax. Check that the aggregations seem sensible and again that the populations and codes look sensible, e.g. LAs should be
**                 greater than IZs, and HBs should be greater than LAs as we aggregate up from the smallest level.
** If you are happy with all of the checks, then run the analysis syntax for your indicators**.

*Salomi Barkat, 12th February 2015.
*Jaime Villacampa 7-1-17 

*Part 1 - read in raw data and add in lookup info.
*Part 2 - Aggregate up to get figures for each geographical area (i.e. IZ, LA, HB).
*Part 3 - Create required time periods (e.g. single years, 3-year aggregates, etc.)
************************************************************************.
set UNICODE on.

define !rawdata (data = !tokens(1) 
/domain= !tokens(1)
/ type = !tokens(1)
/time= !tokens(1)
/pop= !tokens(1)
/yearstart=!tokens(1)
/yearend=!tokens(1)).

************************************************************************.
*Part 1 - Read in raw data and add in lookup info
************************************************************************.
*read in raw data.
get file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Raw Data/Prepared Data/',!unquote(!data),'_raw.sav')).

*standardise area variables to enable merge.
alter type LA (a27).
rename variables (LA = CA).
sort cases by CA.

match files file = *
   /table =  '/conf/linkage/output/lookups/geography/other_ref_files/CA_HB2014.sav'
   /by CA.
execute. 

rename variables (CA = LA).

dataset name raw.

************************************************************************.
*Part 2 - Aggregate up to get figures for each area.
************************************************************************.
*aggregate the file to get the data by LA level.
aggregate outfile = *
   /break year LA
   /numerator = sum(numerator).

*rename variable so all areas can be matched together.
rename variables LA = code.

*temporarily save data set.
dataset name LA.

*re-read in the dataset to get the data for HB.
dataset activate raw.

*aggregate the data for the numerator at HB level.
aggregate outfile = *
   /break year HB2014
   /numerator = sum(numerator).

*rename the HB variable so all areas can be matched on together.
rename variables HB2014 = code.

*temporarily save the dataset.
dataset name HB.

*re-read in the dataset to get the data for Scotland.
dataset activate raw.

string Code (a27).
compute Code='S00000001'.
execute.

*aggregate the data for the numerator at Scotland level.
aggregate outfile = *
   /break year Code
   /numerator = sum(numerator).

dataset name SC.

*merge all geographies together.
add files file=SC
   /file = HB
   /file = LA.
execute.

*close all temporary datasets.
dataset close SC.
dataset close HB.
dataset close LA.
dataset close raw.

*sort cases by area year ahead of merge with lookup.
sort cases by year code.

*standardise area variables to enable merge.
alter type code (a9).

*remove all blanks that are left over from the IZ, LA and HB aggregations.
select if code ne ' '.
execute.

*merge with lookup by area.
match files file=*
   /file= !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/', !unquote(!pop),'.sav'))
   /by year code.
execute.

*add in a variable to let the next macro which type of CIs needed.
*add in a variable to state the time period e.g. single year or 3-year aggregate.
string type (A30) time (A30).
compute type = !quote(!unquote(!type)).
compute time = !quote(!unquote(!time)).
execute.

*save as csv to enable checking.
save translate outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_check2.csv'))
   /type=csv /replace.

**********************************************************************.
*Part 3 - Create required time periods
************************************************************************.
*Inserting and running Macro to create time periods.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/time_period.sps".
!time_period_raw.

*aggregate the data to get it back into the correct format. 
aggregate outfile=*
  	/break year2 code type time
  /numerator denominator = sum(count AVG_pop).

rename variables year2 = year.

*for some data we do not have all of the years - they will appear as 0, so take out missing years.
do if (time = 'single years').
select if range(year,!yearstart,!yearend).

else if (time = '2-year aggregate').
select if range(year,!yearstart+1, !yearend).

else if (time = '3-year aggregate').
select if range(year,!yearstart+1, !yearend-1).

else if (time = '5-year aggregate').
select if range(year,!yearstart+2, !yearend-2).

end if.

*save ready for analysis.
save outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_formatted.sav'))
   /keep Code year Numerator Denominator type time.

*save as csv to enable checking.
save translate outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_check3.csv'))
   /type=csv /replace.

!enddefine.


***END***  .

