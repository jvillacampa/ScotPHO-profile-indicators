*Syntax to create a graph at the end of the indicator update process. It is used as part of the checking process.
*Jaime Villacampa July17

***********************************************************.
*Checking final output
***********************************************************.
*Selecting HB and Scotland level.
select if any(substr(code,1,3),'S08', 'S00').
execute.
*Selecting last year available, fiddly way to do it, computing case number and then selecting the first(last) 15.
sort cases by year(d).
compute casenumber=$casenum.
select if casenumber<16.
execute.

*plot a chart that plots the rate and the CIs.
* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Code upci lowci rate MISSING=LISTWISE REPORTMISSING=NO /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Code=col(source(s), name("Code"), unit.category())
  DATA: upci=col(source(s), name("upci"))
  DATA: lowci=col(source(s), name("lowci"))
  DATA: rate=col(source(s), name("rate"))
  GUIDE: axis(dim(1), label("Health Board code (from 1st April 2014)"))
  SCALE: cat(dim(1), include("S08000015", "S08000016", "S08000017", "S08000018", "S08000019"
, "S08000020", "S08000021", "S08000022", "S08000023", "S08000024", "S08000025"
, "S08000026", "S08000027", "S08000028"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position(region.spread.range(Code*(lowci+upci))), shape(shape.ibeam))
  ELEMENT: point(position(Code*rate), shape(shape.circle))
END GPL.

*END
