Identifying Gaps and Overlaps insurance coverage among multiple plan types episode analysis
 
Github
https://tinyurl.com/6sruwtaw
https://github.com/rogerjdeangelis/utl-Identifying-Gaps-and-Overlaps-insurance-coverage-among-multiple-plan-types-episode-analysis
 
This type of logic is not trivial.
 
Mike Rhoades
Please see this excellent paper for documentation.
https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/260-29.pdf
 
 
*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;
 
%LET FirstDateOfInterest = '01JAN2002'D;
%LET LastDateOfInterest  = '31DEC2002'D;
 
Data Have(LABEL =
    "Insurance coverage data. One record for each reported period of coverage.");
 
    INFORMAT PersID 3. PlanType $9.
             PlanStart PlanEnd YYMMDD10.;
 
    FORMAT PlanStart PlanEnd MMDDYY5.;
 
    INPUT PersID PlanType PlanStart PlanEnd;
 
CARDS4;
1 Medicare 2002-01-01 2002-12-31
2 Medicaid 2002-01-01 2002-01-31
2 Medicaid 2002-09-01 2002-11-30
3 Private  2002-01-01 2002-12-31
3 Medicare 2002-10-01 2002-12-31
4 Military 2002-07-01 2002-12-31
5 Private  2002-01-01 2002-10-31
5 Private  2002-10-01 2002-11-30
5 Private  2002-12-01 2002-12-31
6 Private  2002-01-01 2002-08-22
6 Medicaid 2002-11-01 2002-12-31
7 Military 2002-01-01 2002-02-15
7 Private  2002-02-01 2002-06-30
7 Medicaid 2002-09-01 2002-11-30
7 Private  2002-12-15 2002-12-31
7 Private  2002-12-17 2002-12-31
;;;;
run;quit;
 
/*
 
YEAR IS NOT SHOWN BECAUSE WE ARE ONLY CONCERNED 2002 EPISODES
 
MYLIB.INSCOVDATA total obs=16
                                                              RULES
 PERSID   PLANTYPE    PLANSTART  PLANEND   UNCOVERED COVERED  COVERED (UNCOVERED=365-COVERED)
 
    1     Medicare      01/01     12/31   |     0     365    |  365
 
    2     Medicaid      01/01     01/31   |                  |
    2     Medicaid      09/01     11/30   |   243     122    |  122   31+91
 
    3     Private       01/01     12/31   |                  |        full year private
    3     Medicare      10/01     12/31   |     0     365    |  365   with partial medicare
 
    4     Military      07/01     12/31   |   181     184    |  184   ~half year coverage
 
    5     Private       01/01     10/31   |                  |
    5     Private       10/01     11/30   |                  |
    5     Private       12/01     12/31   |     0     365    |  365   304+30+31
 
    6     Private       01/01     08/22   |                  |
    6     Medicaid      11/01     12/31   |    70     295    |  295   234+61
 
    7     Military      01/01     02/15   |                  |
    7     Private       02/01     06/30   |                  |
    7     Medicaid      09/01     11/30   |                  |
    7     Private       12/15     12/31   |                  |
    7     Private       12/17     12/31   |    76     289    |  289   46+135+91+17+0
*/
 
*
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
;
 
* See Mikes Paper for details;
DATA want
     (KEEP = PersID DaysCovered DaysUncovered);
     set have;
     by persID;
 
     RETAIN DaysCovered LatestCoverageDate;
 
    /* 1.2 Beginning-of-person processing */
    IF FIRST.PersID THEN DO;
       DaysCovered = 0;
       LatestCoverageDate = .;
    END;
 
    /* 1.3 Coverage record processing */
    IF PlanStart > LatestCoverageDate THEN DO;
       DaysCovered = DaysCovered +  (PlanEnd - PlanStart + 1);
    END;
 
    /* Add additional days since LatestCoverageDate if there are some */
    ELSE IF PlanEnd > LatestCoverageDate THEN DO;
         DaysCovered = DaysCovered +  (PlanEnd - (LatestCoverageDate + 1) + 1);
    END;
 
    LatestCoverageDate =
    MAX(LatestCoverageDate,PlanEnd);
 
    /* 1.4 End-of-record processing */
    IF LAST.PersID THEN DO;
       DaysUncovered = (&LastDateOfInterest - &FirstDateOfInterest + 1) - DaysCovered;
       OUTPUT;
    end;
 
 run;quit;
 
*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;
 
 
/*
Up to 40 obs WORK.WANT total obs=7
 
  PERSID    DAYSCOVERED    DAYSUNCOVERED
 
     1          365               0
     2          122             243
     3          365               0
     4          184             181
     5          365               0
     6          295              70
     7          289              76
*/
 
 
