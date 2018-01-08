*Syntax to create the final file used for the ScotPHO profiles indicators, where the output is a standardised rate. 
*This syntax is a macro that computes the rates and creates a series of variables needed so the file
   can be uploaded to the ScotPHO Online Profile Tool (OPT).

*Notes:
*When reading in your data, it needs to be standard format, so make sure it has the following variables:
 - year
 - code
 - age 
 - sex 
 - numerator
 - denominator
 - European population (Epop)
 - type 
 - time
*If it is not in the correct format, do this first before running it through the macro.

*If your data do not use standardised rates, use the syntax 'Analysis - crude rate and percentage' instead.

*RUNNING THE MACRO:
*Input the information needed into macro, to do this go to the section 'calling the macro':
*data=dataset name
*domain=indicator folder (e.g Drugs)
*ind_id= indicator ID number that is used to upload to the profiles
*year_type = either calendar or financial year.
*min_opt = the minimum number for the OPT numbers
*max_opt = the maximun number for the OPT numbers
*Epop_total = the total european population for the ages needed. For all ages the Epop_total = 200000
*profile = the letters at the start of the OPT numbers that identify which is the indicator.

*Anna Mackinnon 7th October 2015.
*Updates (audit trail):
*Date: Joanna Targosz, 26/10/2015
          Neil Davies, 22/06/2016 - updated to include labeling of 2015 data
          Dave Walker, 29/10/2016
          Jaime Villacampa 7-2-17 changing it to make it usable for any indicator (domain and profile tokens)

*Part 1 - analysis on standardisation macro.

************************************************************************.
*Part 1 - analysis on standardisation macro.
************************************************************************.
*define the macro and the data name and the indicator ID needs to be feed in.
set unicode on.

define !standardisation (data = !tokens(1)
                                       /domain=!tokens(1)
                                       /ind_id = !tokens(1)
                                       /year_type = !tokens(1)
                                       /min_opt = !tokens(1)
                                       /max_opt = !tokens(1)
                                       /Epop_total = !tokens(1)
                                       /profile = !tokens(1)). 

*read in the data needed to preform the standardisation on.
get file = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/', !unquote(!data),'_formatted.sav')).

***********************************************************************.
*standardisation.
************************************************************************.
*compute easr. 
compute easr=numerator*Epop/denominator.

*Calculate variance.
compute var_o=numerator.
compute var_dsr=(numerator*Epop**2)/denominator**2.

*aggregate to get the total counts via year code.
aggregate outfile =*
   /break year code time
   /numerator easr var_o var_dsr = sum(numerator easr var_o var_dsr).

*format the numbers for the profiles.
formats numerator var_o (f8.0).

*the number below needs to be changed for different age group population. For all age groups the total standard European population is 200000.
compute Epop_total = !Epop_total.

* Confidence Intervals.
compute easr=easr/Epop_total.
compute o_lower=numerator*(1-(1/(9*numerator)) - (1.96/(3*sqrt(numerator))))**3.
compute o_upper=(numerator+1)*(1-(1/(9*(numerator+1))) + (1.96/(3*sqrt(numerator+1))))**3.
compute var_dsr=(1/Epop_total**2)*var_dsr.
compute lci=easr+sqrt(var_dsr/var_o)*(o_lower - numerator).
compute uci=easr+sqrt(var_dsr/var_o)*(o_upper - numerator).
compute rate = easr*100000.
compute lowci=lci*100000.
compute upci=uci*100000.

***********************************************************************
*add in the indicator ID number for tool upload.
************************************************************************.
compute ind_id = !ind_id.

***********************************************************************
*add in the definition period and trend axis labels.
************************************************************************.
string def_period (A60) trend_axis (A60) year_type (a15).
compute year_type = !quote(!year_type).
execute.

*Inserting and running Macro to create time periods.
INSERT FILE="/conf/phip/Projects/Profiles/Data/Indicators/Macros/time_period.sps".
!time_period_analysis.

************************************************************************.
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

************************************************************************.
*fill in sysmis values and if any have negative lower CI change that to zero.
************************************************************************.
*fill in system missing. 
if sysmis(rate) rate = 0.
if sysmis(lowci) lowci = 0.
if sysmis(upci) upci = 0.
if (lowci<0) lowci=0.
execute.

************************************************************************.
*save the data with the correct variables needed.
************************************************************************.
save outfile = !quote(!concat('/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/Output/', !unquote(!data),'_final.sav'))
   /keep code ind_id year numerator rate lowci upci def_period trend_axis.

*save into the OPT file. 
save translate outfile = !quote( !concat( '/conf/phip/Projects/Profiles/Data/Indicators/', !unquote(!domain),'/OPT Data/', !unquote(!data),'_OPTdata.csv'))
   /type = csv /replace /keep uni_id code ind_id year numerator rate lowci upci def_period trend_axis.

!enddefine.
