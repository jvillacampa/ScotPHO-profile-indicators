*This syntax includes two macros included inside the other macros used to create the ScotPHO profiles indicator data.
*The first macro aggregates the data to the required time period (e.g. 3-year aggregate), while the second macro
   creates a variable with the correct label for the time period.
*Jaime Villacampa 7-2-17.

*Part 1 - Create required time periods for raw macros (time_period_raw macro)
Part 2 - Create required time periods for analysis macros  (time_period_analysis macro)

**********************************************************************.
*Part 1 - Create required time periods for raw macros
************************************************************************.
define !time_period_raw ().
*turn the numerator variable into column variables by year.
do repeat x = n2002 to n2016
      /y=2002 to 2016.
     compute x=0.
  if year = y x = numerator.
end repeat.

*turn the denominator variable into column variables by year.
do repeat x = d2002 to d2016
      /y=2002 to 2016.
     compute x=0.
  if year = y x = denominator.
end repeat.
execute.

**********************************************************************
*single years.
************************************************************************.
*the single year part does make them into columns then back to cases, this is so that each data set goes through each stage and is saved similarly.
do if (time = 'single years').

         *generate single year numerator averages.
         compute AVG_02 = n2002.
         compute AVG_03 = n2003.
         compute AVG_04 = n2004.
         compute AVG_05 = n2005.
         compute AVG_06 = n2006.
         compute AVG_07 = n2007.
         compute AVG_08 = n2008.
         compute AVG_09 = n2009.
         compute AVG_10 = n2010.
         compute AVG_11 = n2011.
         compute AVG_12 = n2012.
         compute AVG_13 = n2013.
         compute AVG_14 = n2014.
         compute AVG_15 = n2015.
         compute AVG_16 = n2016.

         *generate single year denominator averages.
         compute POP_AVG_02 = d2002.
         compute POP_AVG_03 = d2003.
         compute POP_AVG_04 = d2004.
         compute POP_AVG_05 = d2005.
         compute POP_AVG_06 = d2006.
         compute POP_AVG_07 = d2007.
         compute POP_AVG_08 = d2008.
         compute POP_AVG_09 = d2009.
         compute POP_AVG_10 = d2010.
         compute POP_AVG_11 = d2011.
         compute POP_AVG_12 = d2012.
         compute POP_AVG_13 = d2013.
         compute POP_AVG_14 = d2014.
         compute POP_AVG_15 = d2015.
         compute POP_AVG_16 = d2016.

**********************************************************************
**2-year periods.
**********************************************************************.
else if (time = '2-year aggregate').

         *Generate the rolling two year averages figures for the numerator.
         compute AVG_0203 = (n2002 + n2003)/2.
         compute AVG_0304 = (n2003 + n2004)/2.
         compute AVG_0405 = (n2004 + n2005)/2.
         compute AVG_0506 = (n2005 + n2006)/2.
         compute AVG_0607 = (n2006 + n2007)/2.
         compute AVG_0708 = (n2007 + n2008)/2.
         compute AVG_0809 = (n2008 + n2009)/2.
         compute AVG_0910 = (n2009 + n2010)/2.
         compute AVG_1011 = (n2010 + n2011)/2.
         compute AVG_1112 = (n2011 + n2012)/2.
         compute AVG_1213 = (n2012 + n2013)/2.
         compute AVG_1314 = (n2013 + n2014)/2.
         compute AVG_1415 = (n2014 + n2015)/2.
         compute AVG_1516 = (n2015 + n2016)/2.

         *Generate the rolling two year averages figures for the denominator.
         compute POP_AVG_0203 = (d2002 + d2003)/2.
         compute POP_AVG_0304 = (d2003 + d2004)/2.
         compute POP_AVG_0405 = (d2004 + d2005)/2.
         compute POP_AVG_0506 = (d2005 + d2006)/2.
         compute POP_AVG_0607 = (d2006 + d2007)/2.
         compute POP_AVG_0708 = (d2007 + d2008)/2.
         compute POP_AVG_0809 = (d2008 + d2009)/2.
         compute POP_AVG_0910 = (d2009 + d2010)/2.
         compute POP_AVG_1011 = (d2010 + d2011)/2.
         compute POP_AVG_1112 = (d2011 + d2012)/2.
         compute POP_AVG_1213 = (d2012 + d2013)/2.
         compute POP_AVG_1314 = (d2013 + d2014)/2.
         compute POP_AVG_1415 = (d2014 + d2015)/2.
         compute POP_AVG_1516 = (d2015 + d2016)/2.

**********************************************************************
**3-year periods.
************************************************************************.
else if (time = '3-year aggregate').
      
         *Generate the rolling three year averages figures for the numerator.
         compute AVG_0204 = (n2002 + n2003 + n2004)/3.
         compute AVG_0305 = (n2003 + n2004 + n2005)/3.
         compute AVG_0406 = (n2004 + n2005 + n2006)/3.
         compute AVG_0507 = (n2005 + n2006 + n2007)/3.
         compute AVG_0608 = (n2006 + n2007 + n2008)/3.
         compute AVG_0709 = (n2007 + n2008 + n2009)/3.
         compute AVG_0810 = (n2008 + n2009 + n2010)/3.
         compute AVG_0911 = (n2009 + n2010 + n2011)/3.
         compute AVG_1012 = (n2010 + n2011 + n2012)/3.
         compute AVG_1113 = (n2011 + n2012 + n2013)/3.
         compute AVG_1214 = (n2012 + n2013 + n2014)/3.
         compute AVG_1315 = (n2013 + n2014 + n2015)/3.
         compute AVG_1416 = (n2014 + n2015 + n2016)/3.

         *Generate the rolling three year averages figures for the denominator.
         compute POP_AVG_0204 = (d2002 + d2003 + d2004)/3.
         compute POP_AVG_0305 = (d2003 + d2004 + d2005)/3.
         compute POP_AVG_0406 = (d2004 + d2005 + d2006)/3.
         compute POP_AVG_0507 = (d2005 + d2006 + d2007)/3.
         compute POP_AVG_0608 = (d2006 + d2007 + d2008)/3.
         compute POP_AVG_0709 = (d2007 + d2008 + d2009)/3.
         compute POP_AVG_0810 = (d2008 + d2009 + d2010)/3.
         compute POP_AVG_0911 = (d2009 + d2010 + d2011)/3.
         compute POP_AVG_1012 = (d2010 + d2011 + d2012)/3.
         compute POP_AVG_1113 = (d2011 + d2012 + d2013)/3.
         compute POP_AVG_1214 = (d2012 + d2013 + d2014)/3.
         compute POP_AVG_1315 = (d2013 + d2014 + d2015)/3.
         compute POP_AVG_1416 = (d2014 + d2015 + d2016)/3.

***********************************************************************
**5-year periods.
************************************************************************.
else if (time = '5-year aggregate').

         *Generate the rolling five year averages figures for the numerator.
         compute AVG_0206 = (n2002 + n2003 + n2004 + n2005 + n2006)/5.
         compute AVG_0307 = (n2003 + n2004 + n2005 + n2006 + n2007)/5.
         compute AVG_0408 = (n2004 + n2005 + n2006 + n2007 + n2008)/5.
         compute AVG_0509 = (n2005 + n2006 + n2007 + n2008 + n2009)/5.
         compute AVG_0610 = (n2006 + n2007 + n2008 + n2009 + n2010)/5.
         compute AVG_0711 = (n2007 + n2008 + n2009 + n2010 + n2011)/5.
         compute AVG_0812 = (n2008 + n2009 + n2010 + n2011 + n2012)/5.
         compute AVG_0913 = (n2009 + n2010 + n2011 + n2012 + n2013)/5.
         compute AVG_1014 = (n2010 + n2011 + n2012 + n2013 + n2014)/5.
         compute AVG_1115 = (n2011 + n2012 + n2013 + n2014 + n2015)/5.
         compute AVG_1216 = (n2012 + n2013 + n2014 + n2015 + n2016)/5.

         *Generate the rolling five year averages figures for the denominator.
         compute POP_AVG_0206 = (d2002 + d2003 + d2004 + d2005 + d2006)/5.
         compute POP_AVG_0307 = (d2003 + d2004 + d2005 + d2006 + d2007)/5.
         compute POP_AVG_0408 = (d2004 + d2005 + d2006 + d2007 + d2008)/5.
         compute POP_AVG_0509 = (d2005 + d2006 + d2007 + d2008 + d2009)/5.
         compute POP_AVG_0610 = (d2006 + d2007 + d2008 + d2009 + d2010)/5.
         compute POP_AVG_0711 = (d2007 + d2008 + d2009 + d2010 + d2011)/5.
         compute POP_AVG_0812 = (d2008 + d2009 + d2010 + d2011 + d2012)/5.
         compute POP_AVG_0913 = (d2009 + d2010 + d2011 + d2012 + d2013)/5.
         compute POP_AVG_1014 = (d2010 + d2011 + d2012 + d2013 + d2014)/5.
         compute POP_AVG_1115 = (d2011 + d2012 + d2013 + d2014 + d2015)/5.
         compute POP_AVG_1216 = (d2012 + d2013 + d2014 + d2015 + d2016)/5.

end if.
execute.

*now change the total columns to cases. 
*however it labels the year2 column 1-49 depending on which kind of dataset is feed in.
varstocases 
   /make count from AVG_02 to AVG_16 AVG_0203 to AVG_1516 AVG_0204 to AVG_1416 AVG_0206 to AVG_1216
   /make AVG_pop from POP_AVG_02 to POP_AVG_16 POP_AVG_0203 to POP_AVG_1516 POP_AVG_0204 to POP_AVG_1416 POP_AVG_0206 to POP_AVG_1216
   /index year2.

*re label the year 2 column to the correct year label for the data.   
recode year2  
   (1 = 2002) (2 = 2003) (3 = 2004) (4 = 2005) (5 = 2006) (6 = 2007) (7 =2008) (8 = 2009) (9 = 2010) (10 =2011) (11 = 2012) (12 = 2013) (13 = 2014) (14 = 2015) (15 = 2016)
   (16 = 2003) (17 = 2004) (18 = 2005) (19 = 2006) (20 = 2007) (21 = 2008) (22 =2009) (23 = 2010) (24 = 2011) (25 = 2012) (26 = 2013) (27 = 2014) (28 = 2015) (29 = 2016)
   (30 = 2003) (31 = 2004) (32 = 2005) (33 = 2006) (34 = 2007) (35 = 2008) (36 =2009) (37 = 2010) (38 = 2011) (39 = 2012) (40 = 2013) (41 = 2014) (42 = 2015)
   (43 = 2004) (44 = 2005) (45 = 2006) (46 = 2007) (47 = 2008) (48 = 2009) (49 = 2010) (50 = 2011) (51 = 2012) (52 = 2013) (53 = 2014).
execute.
!enddefine.

**********************************************************************.
*Part 2 - Create required time periods for analysis macros
************************************************************************.

define !time_period_analysis ().

*if calendar year.
do if (year_type = 'calendar').

*if the data is single year data.
         do if (time = 'single years').

            do repeat a = 2002 to 2016 
                     /b = '2002 calendar year' '2003 calendar year' '2004 calendar year' '2005 calendar year' '2006 calendar year' '2007 calendar year' '2008 calendar year'
                               '2009 calendar year' '2010 calendar year' '2011 calendar year' '2012 calendar year' '2013 calendar year' '2014 calendar year' '2015 calendar year'
                               '2016 calendar year'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2002 to 2016
                     /b = '2002' '2003' '2004' '2005' '2006' '2007' '2008' '2009' '2010' '2011' '2012' '2013' '2014' '2015' '2016'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 2-year aggregates do this.
         else if (time = '2-year aggregate').

            do repeat a = 2003 to 2016 
                      /b = '2002 to 2003 calendar years; 2-year aggregates' '2003 to 2004 calendar years; 2-year aggregates' '2004 to 2005 calendar years; 2-year aggregates' 
            '2005 to 2006 calendar years; 2-year aggregates' '2006 to 2007 calendar years; 2-year aggregates' '2007 to 2008 calendar years; 2-year aggregates' 
              '2008 to 2009 calendar years; 2-year aggregates' '2009 to 2010 calendar years; 2-year aggregates' '2010 to 2011 calendar years; 2-year aggregates' 
                 '2011 to 2012 calendar years; 2-year aggregates' '2012 to 2013 calendar years; 2-year aggregates' '2013 to 2014 calendar years; 2-year aggregates'
                  '2014 to 2015 calendar years; 2-year aggregates' '2015 to 2016 calendar years; 2-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2016 
                     /b = '2002-2003' '2003-2004' '2004-2005' '2005-2006' '2006-2007' '2007-2008' '2008-2009' '2009-2010' '2010-2011'
                            '2011-2012' '2012-2013' '2013-2014' '2014-2015' '2015-2016'.
                     if (Year=a) trend_axis = b.   
            end repeat.

         *if the data is 3-year aggregates do this.
         else if (time = '3-year aggregate').

            do repeat a =  2003 to 2015
                     /b = '2002 to 2004 calendar years; 3-year aggregates' '2003 to 2005 calendar years; 3-year aggregates' '2004 to 2006 calendar years; 3-year aggregates' 
                              '2005 to 2007 calendar years; 3-year aggregates' '2006 to 2008 calendar years; 3-year aggregates' '2007 to 2009 calendar years; 3-year aggregates' 
                              '2008 to 2010 calendar years; 3-year aggregates' '2009 to 2011 calendar years; 3-year aggregates' '2010 to 2012 calendar years; 3-year aggregates' 
                              '2011 to 2013 calendar years; 3-year aggregates'  '2012 to 2014 calendar years; 3-year aggregates'  '2013 to 2015 calendar years; 3-year aggregates'
                              '2014 to 2016 calendar years; 3-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2015
                     /b = '2002-2004' '2003-2005' '2004-2006' '2005-2007' '2006-2008' '2007-2009' '2008-2010' '2009-2011' '2010-2012'
                            '2011-2013' '2012-2014' '2013-2015' '2014-2016'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 5-year aggregate do this.
         else if (time = '5-year aggregate').

            do repeat a = 2004 to 2014
                     /b = '2002 to 2006 calendar years; 5-year aggregates' '2003 to 2007 calendar years; 5-year aggregates' '2004 to 2008 calendar years; 5-year aggregates'
                              '2005 to 2009 calendar years; 5-year aggregates' '2006 to 2010 calendar years; 5-year aggregates' '2007 to 2011 calendar years; 5-year aggregates'
                              '2008 to 2012 calendar years; 5-year aggregates' '2009 to 2013 calendar years; 5-year aggregates' '2010 to 2014 calendar years; 5-year aggregates'
                              '2011 to 2015 calendar years; 5-year aggregates' '2012 to 2016 calendar years; 5-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2004 to 2014
                     /b = '2002-2006' '2003-2007' '2004-2008' '2005-2009' '2006-2010' '2007-2011' '2008-2012' '2009-2013' '2010-2014' '2011-2015' '2012-2016'.
                     if (Year=a) trend_axis = b.
            end repeat.
         end if.

*if financial year do this.
else if (year_type = 'financial').

      *if the data is single year data.
         do if (time = 'single years').

            do repeat a = 2002 to 2016 
                     /b = '2002/03 financial year' '2003/04 financial year' '2004/05 financial year' '2005/06 financial year' '2006/07 financial year' '2007/08 financial year' '2008/09 financial year'
                            '2009/10 financial year' '2010/11 financial year' '2011/12 financial year' '2012/13 financial year' '2013/14 financial year' '2014/15 financial year' '2015/16 financial year'
                            '2016/17 financial year'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2002 to 2016
                     /b = '2002/03' '2003/04' '2004/05' '2005/06' '2006/07' '2007/08' '2008/09' '2009/10' '2010/11' '2011/12' '2012/13' '2013/14' '2014/15' '2015/16' '2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 2-year aggregates do this.
         else if (time = '2-year aggregate').

            do repeat a = 2003 to 2016
                      /b = '2002/03 to 2003/04 financial years; 2-year aggregates' '2003/04 to 2004/05 financial years; 2-year aggregates' '2004/05 to 2005/06 financial years; 2-year aggregates' 
                              '2005/06 to 2006/07 financial years; 2-year aggregates' '2006/07 to 2007/08 financial years; 2-year aggregates' '2007/08 to 2008/09 financial years; 2-year aggregates' 
                              '2008/09 to 2009/10 financial years; 2-year aggregates' '2009/10 to 2010/11 financial years; 2-year aggregates' '2010/11 to 2011/12 financial years; 2-year aggregates' 
                              '2011/12 to 2012/13 financial years; 2-year aggregates' '2012/13 to 2013/14 financial years; 2-year aggregates' '2013/14 to 2014/15 financial years; 2-year aggregates'
                              '2014/15 to 2015/16 financial years; 2-year aggregates' '2015/16 to 2016/17 financial years; 2-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2016 
                     /b = '2002/03-2003/04' '2003/04-2004/05' '2004/05-2005/06' '2005/06-2006/07' '2006/07-2007/08' '2007/08-2008/09' 
                            '2008/09-2009/10' '2009/10-2010/11' '2010/11-2011/12' '2011/12-2012/13' '2012/13-2013/14' '2013/14-2014/15'
                            '2014/15-2015/16' '2015/16-2016/17'.
                     if (Year=a) trend_axis = b.   
            end repeat.

         *if the data is 3-year aggregates do this.
         else if (time = '3-year aggregate').

            do repeat a =  2003 to 2015
                     /b = '2002/03 to 2004/05 financial years; 3-year aggregates' '2003/04 to 2005/06 financial years; 3-year aggregates' '2004/05 to 2006/07 financial years; 3-year aggregates' 
                              '2005/06 to 2007/08 financial years; 3-year aggregates' '2006/07 to 2008/09 financial years; 3-year aggregates' '2007/08 to 2009/10 financial years; 3-year aggregates' 
                              '2008/09 to 2010/11 financial years; 3-year aggregates' '2009/10 to 2011/12 financial years; 3-year aggregates' '2010/11 to 2012/13 financial years; 3-year aggregates' 
                              '2011/12 to 2013/14 financial years; 3-year aggregates'  '2012/13 to 2014/15 financial years; 3-year aggregates'  '2013/14 to 2015/16 financial years; 3-year aggregates'
                              '2014/15 to 2016/17 financial years; 3-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2015
                     /b = '2002/03-2004/05' '2003/04-2005/06' '2004/05-2006/07' '2005/06-2007/08' '2006/07-2008/09' '2007/08-2009/10' '2008/09-2010/11' '2009/10-2011/12' '2010/11-2012/13' 
                            '2011/12-2013/14' '2012/13-2014/15' '2013/14-2015/16' '2014/15-2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 5-year aggregate do this.
         else if (time = '5-year aggregate').

            do repeat a = 2004 to 2014
                     /b = '2002/03 to 2006/07 financial years; 5-year aggregates' '2003/04 to 2007/06 financial years; 5-year aggregates' '2004/05 to 2008/09 financial years; 5-year aggregates'
                              '2005/06 to 2009/10 financial years; 5-year aggregates' '2006/07 to 2010/11 financial years; 5-year aggregates' '2007/08 to 2011/12 financial years; 5-year aggregates'
                              '2008/09 to 2012/13 financial years; 5-year aggregates' '2009/10 to 2013/14 financial years; 5-year aggregates' '2010/11 to 2014/15 financial years; 5-year aggregates'
                              '2011/12 to 2015/16 financial years; 5-year aggregates' '2012/13 to 2016/17 financial years; 5-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2004 to 2014
                     /b = '2002/03-2006/07' '2003/04-2007/08' '2004/05-2008/09' '2005/06-2009/10' '2006/07-2010/11' '2007/08-2011/12' '2008/09-2012/13' '2009/10-2013/14' '2010/11-2014/15' 
                           '2011/12-2015/16' '2012/13-2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.
         end if.

else if (year_type = 'school').

      *if the data is single year data.
         do if (time = 'single years').

            do repeat a = 2002 to 2016 
                     /b = '2002/03 school year' '2003/04 school year' '2004/05 school year' '2005/06 school year' '2006/07 school year' '2007/08 school year' '2008/09 school year'
                            '2009/10 school year' '2010/11 school year' '2011/12 school year' '2012/13 school year' '2013/14 school year' '2014/15 school year' '2015/16 school year'
                            '2016/17 school year'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2002 to 2016
                     /b = '2002/03' '2003/04' '2004/05' '2005/06' '2006/07' '2007/08' '2008/09' '2009/10' '2010/11' '2011/12' '2012/13' '2013/14' '2014/15' '2015/16' '2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 2-year aggregates do this.
         else if (time = '2-year aggregate').

            do repeat a = 2003 to 2016
                      /b = '2002/03 to 2003/04 school years; 2-year aggregates' '2003/04 to 2004/05 school years; 2-year aggregates' '2004/05 to 2005/06 school years; 2-year aggregates' 
                              '2005/06 to 2006/07 school years; 2-year aggregates' '2006/07 to 2007/08 school years; 2-year aggregates' '2007/08 to 2008/09 school years; 2-year aggregates' 
                              '2008/09 to 2009/10 school years; 2-year aggregates' '2009/10 to 2010/11 school years; 2-year aggregates' '2010/11 to 2011/12 school years; 2-year aggregates' 
                              '2011/12 to 2012/13 school years; 2-year aggregates' '2012/13 to 2013/14 school years; 2-year aggregates' '2013/14 to 2014/15 school years; 2-year aggregates'
                              '2014/15 to 2015/16 school years; 2-year aggregates' '2015/16 to 2016/17 school years; 2-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2016 
                     /b = '2002/03-2003/04' '2003/04-2004/05' '2004/05-2005/06' '2005/06-2006/07' '2006/07-2007/08' '2007/08-2008/09' 
                            '2008/09-2009/10' '2009/10-2010/11' '2010/11-2011/12' '2011/12-2012/13' '2012/13-2013/14' '2013/14-2014/15'
                            '2014/15-2015/16' '2015/16-2016/17'.
                     if (Year=a) trend_axis = b.   
            end repeat.

         *if the data is 3-year aggregates do this.
         else if (time = '3-year aggregate').

            do repeat a =  2003 to 2015
                     /b = '2002/03 to 2004/05 school years; 3-year aggregates' '2003/04 to 2005/06 school years; 3-year aggregates' '2004/05 to 2006/07 school years; 3-year aggregates' 
                              '2005/06 to 2007/08 school years; 3-year aggregates' '2006/07 to 2008/09 school years; 3-year aggregates' '2007/08 to 2009/10 school years; 3-year aggregates' 
                              '2008/09 to 2010/11 school years; 3-year aggregates' '2009/10 to 2011/12 school years; 3-year aggregates' '2010/11 to 2012/13 school years; 3-year aggregates' 
                              '2011/12 to 2013/14 school years; 3-year aggregates'  '2012/13 to 2014/15 school years; 3-year aggregates'  '2013/14 to 2015/16 school years; 3-year aggregates'
                              '2014/15 to 2016/17 school years; 3-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2003 to 2015
                     /b = '2002/03-2004/05' '2003/04-2005/06' '2004/05-2006/07' '2005/06-2007/08' '2006/07-2008/09' '2007/08-2009/10' '2008/09-2010/11' '2009/10-2011/12' '2010/11-2012/13' 
                            '2011/12-2013/14' '2012/13-2014/15' '2013/14-2015/16' '2014/15-2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.

         *if the data is 5-year aggregate do this.
         else if (time = '5-year aggregate').

            do repeat a = 2004 to 2014
                     /b = '2002/03 to 2006/07 school years; 5-year aggregates' '2003/04 to 2007/06 school years; 5-year aggregates' '2004/05 to 2008/09 school years; 5-year aggregates'
                              '2005/06 to 2009/10 school years; 5-year aggregates' '2006/07 to 2010/11 school years; 5-year aggregates' '2007/08 to 2011/12 school years; 5-year aggregates'
                              '2008/09 to 2012/13 school years; 5-year aggregates' '2009/10 to 2013/14 school years; 5-year aggregates' '2010/11 to 2014/15 school years; 5-year aggregates'
                              '2011/12 to 2015/16 school years; 5-year aggregates' '2012/13 to 2016/17 school years; 5-year aggregates'.
                     if (Year=a) def_period = b.
            end repeat.

            do repeat a = 2004 to 2014
                     /b = '2002/03-2006/07' '2003/04-2007/08' '2004/05-2008/09' '2005/06-2009/10' '2006/07-2010/11' '2007/08-2011/12' '2008/09-2012/13' '2009/10-2013/14' '2010/11-2014/15' 
                           '2011/12-2015/16' '2012/13-2016/17'.
                     if (Year=a) trend_axis = b.
            end repeat.
         end if.

end if.
execute.
!enddefine.
