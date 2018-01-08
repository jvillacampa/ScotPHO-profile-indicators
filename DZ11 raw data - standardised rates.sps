*Syntax to manipulate the raw data for the ScotPHO profiles indicators, where the data is available at DZ 2011 level and 
   the output is a standardised rate.
*This syntax is a macro that aggregates the data to the different geographical levels required (IZ, LA, HB and Scotland),
   and in the time period you input (e.g. 3-year aggregates).

*Notes:
*When reading in your data, it needs to be standard format, so make sure it has the following variables:
- year
- sex_grp
- age_grp
 -datazone
 -numerator
*If it is not in the correct format, do this first before running it through the macro.

 * Macro parameters input:
*data=dataset name
*domain=indicator folder (e.g Drugs)
*type=e.g. percent/crude/stdrate
*time=time period, e.g. single year, 3-year aggregate.
*yearstart=first year of data that you have, e.g. if you had data for 2004-2013, yearstart would be 2004.
*yearend= last year of the data that you have, e.g. if you had data for 2004-2013, yearend would be 2013.
*pop = write here the name of the population lookup file, within the profiles lookup folder, you are using. e.g. 'LA_pop_16+_SR' - note when calling the macro use apostrophes 
if the file name contains spaces or special characters e.g. +.
*epop_age=if population is 16+ write '16+' here so the correct epop totals are assigned to the age_grp=4 category. i.e epop=4400 instead of epop=5500
                 if population is under 16 write '<16' here so the correct epop totals are assigned to the age_grp=4 category. i.e epop=1100 instead of epop=5500
                    for any other case write something different (e.g. 'a')

*CHECKING: 
*As the macro runs everything at once, we have built in 3 checks to make sure the data is correct before it gets to the analysis stage.
*CHECK 1 - check the raw data when you receive it, make sure the figures seem sensible. You can also check against publications if the data is published.
*CHECK 2 - occurs between parts 2 and 3 of the macro, check the populations and lookups we have added on, and that we have not altered the numerator.
*CHECK 3 -occurs at the end of the syntax. Check that the aggregations seem sensible and again that the populations and codes look sensible, e.g. LAs should be
**                 greater than IZs, and HBs should be greater than LAs as we aggregate up from the smallest level.
** If you are happy with all of the checks, then run the analysis syntax for your indicators**.

*Anna Mackinnon, 7th October 2015.
*Updates (audit trail): Joanna Targosz, 23 October 2015. 
*Updates: Neil Davies (patients hospitalised with asthma.), 28 January 2016.
*Update: Joanna Targosz (all cancers, deaths from suicide) - change in geography lookup - CA coding; syntax ameneded; 27 May 2016.
*Update: Neil Davies - updated to allow for averages using 2015 data. 22 June 2016.
*Jaime Villacampa 7-2-17. Updated with macro for time period, taking out calls to the macro from syntax and adding domain, pop and epop tokens.
*Jaime Villacampa Dec17. Adding <16 population case.
 
*Part 1 - read in raw data and add in lookup info.
*Part 2 - Aggregate up to get figures for each geographical area (i.e. IZ, LA, HB).
*Part 3 - Create required time periods (e.g. single years, 3-year aggregates, etc.)

************************************************************************.
set unicode on.

define !stdrate (data = !tokens(1) 
/domain= !tokens(1)
/ type = !tokens(1)
/time= !tokens(1)
/yearstart=!tokens(1)
/yearend=!tokens(1)                        
/pop=!tokens(1) 
/epop_age=!tokens(1)).

************************************************************************.
*Part 1 - Read in raw data and add in lookup info
************************************************************************.
*read in raw data.
get file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Raw Data/Prepared Data/',!unquote(!data),'_raw.sav')).

*sort cases by area year ahead of merge with lookup.
sort cases by year datazone sex_grp age_grp.

*standardise area variables to enable merge.
alter type datazone (a27) sex_grp (f8) age_grp (f2).
rename variables (datazone = Datazone2011).
sort cases by Datazone2011.

*match on geography lookup to give codes for each level of geography.
match files file = *
   /table = '/conf/linkage/output/lookups/geography/DataZone2011/DataZone2011.sav'
   /by Datazone2011.
execute. 

rename variables (Datazone2011 Intzone2011 = datazone IZ). 

RENAME VARIABLES CA2011 = LA.
Alter type LA (a27).

dataset name raw.

************************************************************************.
*Part 2 - Aggregate up to get figures for each area.
************************************************************************.
*aggregate the file to get the data by IZ level.
aggregate outfile = *
   /break year IZ sex_grp age_grp
   /numerator = sum(numerator).

*rename variable so all areas can be matched together.
rename variables IZ = code.

*temporarily save data set.
dataset name IZ.

*re-read in the data for LA information.
dataset activate raw.

*aggregate the data to get the numerator for the data at LA.
aggregate outfile = *
   /break year LA sex_grp age_grp
   /numerator = sum(numerator).

*rename the variable so all areas can be matched on together.
rename variables LA = code.

*temporarily save the data set.
dataset name LA.

*re-read in the dataset to get the data for HB.
dataset activate raw.

*aggregate the data for the numerator at HB level.
aggregate outfile = *
   /break year HB2014 sex_grp age_grp
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
   /break year Code sex_grp age_grp
   /numerator = sum(numerator).

dataset name SC.

*merge all geographies together.
add files file=SC
   /file = HB
   /file = LA
   /file = IZ.
execute.

*close all temporary datasets.
dataset close SC.
dataset close HB.
dataset close LA.
dataset close IZ.

dataset close raw.

aggregate outfile = *
   /break year code sex_grp age_grp
   /numerator = sum(numerator). 

*sort cases by area year ahead of merge with lookup.
sort cases by year code sex_grp age_grp.

*standardise area variables to enable merge.
alter type code (a9).

*merge with lookup to give population figures by area.
match files file=*
   /file= !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/',!unquote(!pop),'.sav'))
   /by year code sex_grp age_grp.
execute.

*remove all blanks that are left over from the IZ, LA and HB aggregations.
select if code ne ' '.
execute.

*add in a variable to let the next macro which type of CI's needed.
*add in a variable to state the time period e.g. single year or 3-year aggregate.
string type (A30) time (A30).
compute type = !quote(!unquote(!type)).
compute time =!quote(!unquote(!time)).
execute.

*save as csv to enable checking.
save translate outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_check2.csv'))
   /type=csv   /replace /fieldnames.

**********************************************************************.
*Part 3 - Create required time periods
************************************************************************.
*Inserting and running Macro to create time periods.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/time_period.sps".
!time_period_raw.

*aggregate the data to get it back into the correct format. 
aggregate outfile=*
  	/break year2 code sex_grp age_grp type time
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

* Add European Standard Populations for each age group (based on the new European Standard Population 2013).
string epop_age (A32).
compute epop_age = !quote(!unquote(!epop_age)).
execute.

* Add European Standard Populations for each age group (based on the new European Standard Population 2013).
do if epop_age = '16+'.
   recode age_grp
      (4=4400) (5=6000) (6=6000) (7=6500) (8=7000) (9=7000) (10=7000) (11=7000) (12=6500)
      (13=6000) (14=5500) (15=5000)  (16=4000) (17=2500) (18=1500) (19=1000)
   into Epop.
else if epop_age = '<16'.
   recode age_grp
           (1=5000) (2=5500) (3=5500) (4=1100)
   into Epop.
else.
   recode age_grp
      (1=5000) (2=5500) (3=5500) (4=5500) (5=6000) (6=6000) (7=6500) (8=7000) (9=7000) (10=7000) (11=7000) (12=6500)
      (13=6000) (14=5500) (15=5000)  (16=4000) (17=2500) (18=1500) (19=1000)
   into Epop.
end if.
execute.

*save ready for analysis.
save outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_formatted.sav'))
   /keep Code year  sex_grp age_grp Numerator Denominator Epop type time.

*save as csv to enable checking.
save translate outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_check3.csv'))
   /type=csv  /replace   /fieldnames.

!enddefine.

***END***  .
