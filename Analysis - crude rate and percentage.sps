*Syntax to create the final file used for the ScotPHO profiles indicators, where the output is a crude rate or a percentage. 
*This syntax is a macro that computes the rates or percentages, and creates a series of variables needed so the file
   can be uploaded to the ScotPHO Online Profile Tool (OPT).

*Notes:
*When reading in your data, it needs to be standard format, so make sure it has the following variables:
 - year
 - code
 - numerator
 - denominator
 - type 
 - time
*If it is not in the correct format, do this first before running it through the macro.

*If your data produces standardised rates, use the syntax 'Analysis - standardisation' instead.

*RUNNING THE MACRO:
*Variables to input in the macro:
*data=indicator name.
*domain=indicator folder (e.g Drugs)
*ind_id= indicator ID number that is used to upload to the profiles
*year_type = either calendar, financial or school year.
*min_opt = the minium number for the OPT numbers
*max_opt = the maximun number for the OPT numbers
*profile = the letters at the start of the OPT numbers that identify which is the indicator.
*crude_rate = Include what population is the rate by (e.g. cases by 100.000).  If a percentage just write any number, it will ignore it.

*Anna Mackinnon 17th February 2015.
*Updates (audit trail): Salomi Barkat - updating the macro for rolling updates - added in topic and population tokens, and changed filepaths for rolling updates.
*Date: 03/02/16.
 *    Jaime Villacampa 7-2-17 changing it to make it usable for any indicator

*Part 1 - analysis on crude rate and percentage macro.

************************************************************************.
*Part 1 - analysis on crude rate and percentage macro.
************************************************************************.
*define the macro and the data name and the indicator ID needs to be feed in.
set unicode on.

define !crude_percent (data = !tokens(1)
                           /domain=!tokens(1)
                           /ind_id = !tokens(1)
                           /year_type = !tokens(1)
                           /min_opt = !tokens(1)
                           /max_opt = !tokens(1)
                           /profile = !tokens(1)
                           /crude_rate = !tokens(1))

*open the data file.
get file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_formatted.sav')).

*create a do if loop, so if it is a crude rate is does one thing and if it is a percentage another thing.
***********************************************************************.
*crude rate.
************************************************************************.
do if (type = 'crude').

      *compute the rate per pre defined number of people. 
      compute rate = numerator/denominator*!crude_rate.

      *compute the confidence intervals for crude rates.
      compute O_lower = numerator *(1-1/9/numerator-1.96/3/sqrt(numerator))**3.
      compute O_upper = (numerator+1) *(1-1/9/(numerator+1)+1.96/3/sqrt(numerator+1))**3.
      compute lowci = O_lower/(denominator)*!crude_rate.
      compute upci = O_upper/(denominator)*!crude_rate.

***********************************************************************
**percentage.
************************************************************************.
else if (type = 'percent').

      *compute the percentage.
      compute rate = numerator/denominator*100.

      *compute the lower and upper confidence interval.
      compute lowci=(2*Numerator+1.96*1.96-1.96*sqrt(1.96*1.96+4*Numerator*(1-rate/100))) / (2*(Denominator+1.96*1.96))*100.
      compute upci=(2*Numerator+1.96*1.96+1.96*sqrt(1.96*1.96+4*Numerator*(1-rate/100))) / (2*(Denominator+1.96*1.96))*100.

end if.
execute.

***********************************************************************
*add in the definition period and trend axis labels.
************************************************************************.
string def_period (A60) trend_axis (A60) year_type (a15).
compute year_type = !quote(!year_type).
execute.

*Inserting and running Macro to create time periods.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/time_period.sps".
!time_period_analysis.

***********************************************************************
*add in the indicator ID number for tool upload.
************************************************************************.
compute ind_id = !ind_id.
execute.

***********************************************************************
*create unique id number.
************************************************************************.
numeric uni_id1 (f6.0).
loop #i=!min_opt to !max_opt.
   compute uni_id1=#i.
   end case.
end loop.
execute.

string uni_id (A8).
compute uni_id = concat(replace(!quote(!unquote(!profile)),' ',''),string(uni_id1,f6.0)).
compute uni_id = replace(uni_id, ' ','').
execute.

*fill in system missing. 
if sysmis(rate) rate = 0.
if sysmis(lowci) lowci = 0.
if sysmis(upci) upci = 0.

*set negative CIs to 0 as they will not load into the tool.
if lowci<0 lowci=0.
execute.

*save the file with the correct variables needed.
save outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/',!unquote(!data),'_final.sav'))
   /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

*save into the OPT file. 
save translate outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/OPT Data/', !unquote(!data),'_OPTdata.csv'))
   /type = csv /replace /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

!enddefine.

