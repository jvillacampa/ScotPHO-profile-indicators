*Syntax to manipulate the raw data for the ScotPHO profiles indicators Emergency Admissions (EA) and Multiple admissions (MA)
where the data is available at DZ2011 level and  the output is a standardised rate. 
*This syntax is a macro that adds population (denominator) data, aggregates the data to the different geographical levels 
required (IZ, LA, HB and Scotland), and in the time period you input (e.g. 3-year aggregates).

*Notes:
*When reading in your data, it needs to be standard format, so make sure it has the following variables:
- year
- sex_grp
- age_grp
 -datazone
 -numerator
*If it is not in the correct format, do this first before running it through the macro.

*Variables to input in the macro
*data=dataset name
*domain=indicator folder (e.g Drugs)
*type=e.g. percent/crude/stdrate
*pop=population lookup file used as denominator.
*yearstart=first year of data that you have, e.g. if you had data for 2004-2013, yearstart would be 2004.
*yearend= last year of the data that you have, e.g. if you had data for 2004-2013, yearend would be 2013.
*time=time period, e.g. single year, 2-year aggregate.

*CHECKING: 
*As the macro runs everything at once, we have built in 3 checks to make sure the data is correct before it gets to the analysis stage.
*CHECK 1 - check the raw data when you receive it, make sure the figures seem sensible. You can also check against publications if the data is published.
*CHECK 2 - occurs between parts 2 and 3 of the macro, check the populations and lookups we have added on, and that we have not altered the numerator.
*CHECK 3 -occurs at the end of the syntax. Check that the aggregations seem sensible and again that the populations and codes look sensible, e.g. LAs should be
**                 greater than IZs, and HBs should be greater than LAs as we aggregate up from the smallest level.
** If you are happy with all of the checks, then run the analysis syntax for your indicators**.

*Jaime Villacampa May17.

*Part 1 - Aggregate up to get figures for each geographical area (i.e. IZ, LA, HB).
*Part 2 - Create required time periods (e.g. single years, 3-year aggregates, etc.)

*Calling the macro.
************************************************************************.
define !rawdata (data = !tokens(1) 
/domain= !tokens(1)
/ type = !tokens(1)
/time= !tokens(1)
/pop=!tokens(1)
/yearstart=!tokens(1)
/yearend=!tokens(1)).

*read in the data.
get file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Raw Data/Prepared Data/',!unquote(!data),'_raw.sav')).

*Taking out non Scottish residents.
select if code ne "".
execute.

*match on the data.
sort cases by year code sex_grp age_grp.
match files file=*
   /file=  !quote(!concat('/conf/phip/Projects/Profiles/Data/Lookups/',!unquote(!pop),'.sav'))
   /by year code sex_grp age_grp.
execute.

*add in a variable to let the next macro which type of CI's needed.
*add in a variable to state the time period e.g. single year or 3-year aggregate.
string time (A30).
string type (A30).
compute type = !quote(!unquote(!type)).
compute time =!quote(!unquote(!time)).
execute.

*save as csv to enable checking.
save translate outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/Output/',!unquote(!data),'_check2.csv'))
   /type=csv   /replace.

**********************************************************************.
*Part 2 - Create required time periods
************************************************************************.
*Inserting and running Macro to create time periods.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/time_period.sps".
!time_period_raw.

*aggregate the data to get it back into the correct format. 
aggregate outfile=*
  	/break year2 code type time sex_grp age_grp
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
recode age_grp
   (1=5000) (2=5500) (3=5500) (4=5500) (5=6000) (6=6000) (7=6500) (8=7000) (9=7000) (10=7000)
   (11=7000) (12=6500) (13=6000) (14=5500) (15=5000) (16=4000) (17=2500) (18=1500) (19=1000)
   into Epop.
execute.

*save ready for analysis.
save outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/Output/',!unquote(!data),'_formatted.sav'))
   /keep Code year  sex_grp age_grp Numerator Denominator Epop type time.

*save as csv to enable checking.
save translate outfile= !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/Deaths, Injury and Disease/Output/',!unquote(!data),'_check3.csv'))
   /type=csv   /replace.

!enddefine.

