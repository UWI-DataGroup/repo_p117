** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          20b_update previous years cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-OCT-2019
    // 	date last modified      01-OCT-2020
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008, 2013, 2014 data for inclusion in 2015 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\20b_update previous years cancer.smcl", replace
** HEADER -----------------------------------------------------
use "`datapath'\version09\1-input\2008_2013_2014_2015_iarchub_nonsurvival_nonreportable", clear
cross-check with below ds
use "`datapath'\version09\2-working\allyears_prepped cancer", clear

*******************************
** 2014 Non-survival Dataset **
*******************************
/*
JC 04nov2019: 2014 dataset prepared BEFORE 2013 dataset;
Records changed from 2014 to 2013 can be added to 2013_cancer_nonsurvival.dta
and removed from 2014_cancer_nonsurvival.dta
*/
** Load the dataset (2014)
use "`datapath'\version02\1-input\2014_cancer_sites_da", replace
count //927

** JC 07feb2022: Correct basis for PID 20130187 from 9 to 3 - picked up while doing NAACCR 2022 abstract
basis=3 if pid=="20130187" & cr5id=="T1S1"

** Updates to DCOs after checked by KWG 12jun2019 (see excel sheet: ...\Sync\Cancer\CanReg5\DCOs).
replace basis=2 if pid=="20130175"
replace dcostatus=1 if pid=="20130175"

replace basis=9 if pid=="20140027"
replace dcostatus=1 if pid=="20140027"
replace dot=d(08jan2013) if pid=="20140027"
replace dotyear=2013 if pid=="20140027"
replace dxyr=2013 if pid=="20140027"

replace basis=9 if pid=="20140032"
replace dcostatus=1 if pid=="20140032"
replace nsdate=d(11jul2019) if pid=="20140032"
replace dot=d(17jan2013) if pid=="20140032"
replace dotyear=2013 if pid=="20140032"
replace dxyr=2013 if pid=="20140032"

replace basis=9 if pid=="20140033"
replace dcostatus=1 if pid=="20140033"
replace dot=d(28nov2013) if pid=="20140033"
replace dotyear=2013 if pid=="20140033"
replace dxyr=2013 if pid=="20140033"

replace basis=9 if pid=="20140042"
replace basis=6 if pid=="20140042"
replace dcostatus=3 if pid=="20140042"
replace dot=d(03may2012) if pid=="20140042"
replace dotyear=2012 if pid=="20140042"
replace dxyr=2012 if pid=="20140042"
replace nsdate=d(09jul2019) if pid=="20140042"
replace cstatus=3 if pid=="20140042"
replace recstatus=3 if pid=="20140042"

replace resident=2 if pid=="20140049"
replace cstatus=3 if pid=="20140049"
replace recstatus=3 if pid=="20140049"
replace dcostatus=3 if pid=="20140049"

replace basis=9 if pid=="20140078"
replace dcostatus=1 if pid=="20140078"
replace dot=d(18dec2013) if pid=="20140078"
replace dotyear=2013 if pid=="20140078"
replace dxyr=2013 if pid=="20140078"

replace basis=9 if pid=="20140100"
replace dcostatus=1 if pid=="20140100"
replace dot=d(01dec2013) if pid=="20140100"
replace dotyear=2013 if pid=="20140100"
replace dxyr=2013 if pid=="20140100"

replace basis=9 if pid=="20140110"
replace dcostatus=1 if pid=="20140110"
replace dot=d(24feb2013) if pid=="20140110"
replace dotyear=2013 if pid=="20140110"
replace dxyr=2013 if pid=="20140110"

replace basis=9 if pid=="20140117"
replace dot=d(30jun2010) if pid=="20140117"
replace dotyear=2010 if pid=="20140117"
replace dxyr=2010 if pid=="20140117"
replace nsdate=d(05jul2019) if pid=="20140117"
replace cstatus=3 if pid=="20140117"
replace recstatus=3 if pid=="20140117"
replace dcostatus=3 if pid=="20140117"

replace basis=9 if pid=="20140127"
replace dcostatus=1 if pid=="20140127"
replace dot=d(20oct2013) if pid=="20140127"
replace dotyear=2013 if pid=="20140127"
replace dxyr=2013 if pid=="20140127"

replace basis=9 if pid=="20140136"
replace dcostatus=1 if pid=="20140136"
replace dot=d(27mar2013) if pid=="20140136"
replace dotyear=2013 if pid=="20140136"
replace dxyr=2013 if pid=="20140136"

replace basis=9 if pid=="20140154"
replace dcostatus=1 if pid=="20140154"
replace dot=d(15dec2013) if pid=="20140154"
replace dotyear=2013 if pid=="20140154"
replace dxyr=2013 if pid=="20140154"

replace basis=9 if pid=="20140168"
replace dot=d(09feb2012) if pid=="20140168"
replace dotyear=2012 if pid=="20140168"
replace dxyr=2012 if pid=="20140168"
replace nsdate=d(10jul2019) if pid=="20140168"
replace cstatus=3 if pid=="20140168"
replace recstatus=3 if pid=="20140168"
replace dcostatus=3 if pid=="20140168"

replace basis=9 if pid=="20140174"
replace dot=d(30jun2012) if pid=="20140174"
replace dotyear=2012 if pid=="20140174"
replace dxyr=2012 if pid=="20140174"
replace nsdate=d(04jul2019) if pid=="20140174"
replace cstatus=3 if pid=="20140174"
replace recstatus=3 if pid=="20140174"
replace dcostatus=3 if pid=="20140174"

replace basis=9 if pid=="20140192"
replace dcostatus=1 if pid=="20140192"
replace dot=d(14oct2013) if pid=="20140192"
replace dotyear=2013 if pid=="20140192"
replace dxyr=2013 if pid=="20140192"

replace basis=9 if pid=="20140202"
replace dcostatus=1 if pid=="20140202"
replace dot=d(26oct2013) if pid=="20140202"
replace dotyear=2013 if pid=="20140202"
replace dxyr=2013 if pid=="20140202"

replace basis=9 if pid=="20140203"
replace dot=d(26nov2010) if pid=="20140203"
replace dotyear=2010 if pid=="20140203"
replace dxyr=2010 if pid=="20140203"
replace nsdate=d(03jul2019) if pid=="20140203"
replace cstatus=3 if pid=="20140203"
replace recstatus=3 if pid=="20140203"
replace dcostatus=3 if pid=="20140203"

replace basis=9 if pid=="20140205"
replace dcostatus=1 if pid=="20140205"
replace dot=d(30mar2014) if pid=="20140205"
replace nsdate=d(05jul2019) if pid=="20140205"

replace basis=9 if pid=="20140215"
replace dot=d(30jun2007) if pid=="20140215"
replace dotyear=2007 if pid=="20140215"
replace dxyr=2007 if pid=="20140215"
replace nsdate=d(04jul2019) if pid=="20140215"
replace cstatus=3 if pid=="20140215"
replace recstatus=3 if pid=="20140215"
replace dcostatus=3 if pid=="20140215"

replace basis=9 if pid=="20140224"
replace dcostatus=1 if pid=="20140224"
replace dot=d(22oct2013) if pid=="20140224"
replace dotyear=2013 if pid=="20140224"
replace dxyr=2013 if pid=="20140224"

replace basis=9 if pid=="20140228"
replace dcostatus=1 if pid=="20140228"
replace dot=d(18feb2014) if pid=="20140228"
replace admdate=d(18feb2014) if pid=="20140228"
replace nsdate=d(05jul2019) if pid=="20140228"

replace basis=9 if pid=="20140234"
replace dcostatus=1 if pid=="20140234"
replace dot=d(26nov2013) if pid=="20140234"
replace dotyear=2013 if pid=="20140234"
replace dxyr=2013 if pid=="20140234"

replace basis=9 if pid=="20140256"
replace dcostatus=1 if pid=="20140256"
replace dot=d(15mar2014) if pid=="20140256"
replace nsdate=d(04jul2019) if pid=="20140256"

replace basis=1 if pid=="20140257"
replace dcostatus=1 if pid=="20140257"
replace dot=d(29mar2014) if pid=="20140257"
replace nsdate=d(29aug2018) if pid=="20140257"

replace basis=9 if pid=="20140258"
replace dcostatus=1 if pid=="20140258"
replace dot=d(30nov2013) if pid=="20140258"
replace dotyear=2013 if pid=="20140258"
replace dxyr=2013 if pid=="20140258"

replace basis=9 if pid=="20140265"
replace dot=d(14dec1988) if pid=="20140265"
replace dotyear=1988 if pid=="20140265"
replace dxyr=1988 if pid=="20140265"
replace nsdate=d(03jul2019) if pid=="20140265"
replace cstatus=3 if pid=="20140265"
replace recstatus=3 if pid=="20140265"
replace dcostatus=3 if pid=="20140265"

replace basis=9 if pid=="20140268"
replace dcostatus=1 if pid=="20140268"
replace dot=d(26may2013) if pid=="20140268"
replace dotyear=2013 if pid=="20140268"
replace dxyr=2013 if pid=="20140268"

replace basis=9 if pid=="20140269"
replace dcostatus=1 if pid=="20140269"
replace dot=d(21feb2014) if pid=="20140269"

replace basis=9 if pid=="20140270"
replace dcostatus=1 if pid=="20140270"
replace dot=d(29mar2014) if pid=="20140270"

replace basis=9 if pid=="20140283"
replace dcostatus=1 if pid=="20140283"
replace dot=d(10dec2013) if pid=="20140283"
replace dotyear=2013 if pid=="20140283"
replace dxyr=2013 if pid=="20140283"

replace basis=9 if pid=="20140311"
replace dot=d(30jun2009) if pid=="20140311"
replace dotyear=2009 if pid=="20140311"
replace dxyr=2009 if pid=="20140311"
replace nsdate=d(04jul2019) if pid=="20140311"
replace cstatus=3 if pid=="20140311"
replace recstatus=3 if pid=="20140311"
replace dcostatus=3 if pid=="20140311"

replace basis=9 if pid=="20140318"
replace dcostatus=1 if pid=="20140318"
replace dot=d(15may2014) if pid=="20140318"

replace basis=9 if pid=="20140330"
replace dcostatus=1 if pid=="20140330"
replace dot=d(28jun2014) if pid=="20140330"
replace nsdate=d(02jul2019) if pid=="20140330"

replace basis=9 if pid=="20140334"
replace dot=d(30jun2004) if pid=="20140334"
replace dotyear=2004 if pid=="20140334"
replace dxyr=2004 if pid=="20140334"
replace nsdate=d(04jul2019) if pid=="20140334"
replace cstatus=3 if pid=="20140334"
replace recstatus=3 if pid=="20140334"
replace dcostatus=3 if pid=="20140334"

replace basis=1 if pid=="20140353"
replace dcostatus=1 if pid=="20140353"
replace dot=d(11jun2008) if pid=="20140353"
replace dotyear=2008 if pid=="20140353"
replace dxyr=2008 if pid=="20140353"
replace age=96 if pid=="20140353"
replace nsdate=d(02jul2019) if pid=="20140353"

replace basis=9 if pid=="20140365"
replace dcostatus=1 if pid=="20140365"
replace dot=d(07may2014) if pid=="20140365"
replace nsdate=d(05jul2019) if pid=="20140365"

replace basis=9 if pid=="20140367"
replace dcostatus=1 if pid=="20140367"
replace dot=d(14feb2014) if pid=="20140367"

replace basis=9 if pid=="20140370"
replace dcostatus=1 if pid=="20140370"
replace dot=d(21may2014) if pid=="20140370"

replace basis=2 if pid=="20140380"
replace dcostatus=1 if pid=="20140380"
replace dot=d(15apr2013) if pid=="20140380"
replace dotyear=2013 if pid=="20140380"
replace dxyr=2013 if pid=="20140380"
replace nsdate=d(09jul2019) if pid=="20140380"

replace basis=9 if pid=="20140384"
replace dcostatus=1 if pid=="20140384"
replace dot=d(01jan2014) if pid=="20140384"
replace nsdate=d(04jul2019) if pid=="20140384"

replace basis=9 if pid=="20140385"
replace dcostatus=1 if pid=="20140385"
replace dot=d(19jul2014) if pid=="20140385"

replace primarysite="UTERUS" if pid=="20140389"
replace top="559" if pid=="20140389"
replace topography=559 if pid=="20140389"
replace morph=8890 if pid=="20140389"
replace site=16 if pid=="20140389"
replace siteiarc=34 if pid=="20140389"
replace sitecr5db=12 if pid=="20140389"
replace sitear=16 if pid=="20140389"
replace icd10="C55" if pid=="20140389"
replace siteicd10=9 if pid=="20140389"
replace basis=7 if pid=="20140389"
replace dcostatus=1 if pid=="20140389"
replace dot=d(26jun2013) if pid=="20140389"
replace dotyear=2013 if pid=="20140389"
replace dxyr=2013 if pid=="20140389"
replace nsdate=d(10jul2019) if pid=="20140389"
replace rx1=1 if pid=="20140389"
replace rx1d=d(26jun2013) if pid=="20140389"
replace topcat=48 if pid=="20140389"
replace morphcat=21 if pid=="20140389"
replace monset=4 if pid=="20140389"

replace basis=9 if pid=="20140393"
replace dcostatus=1 if pid=="20140393"
replace dot=d(26mar2014) if pid=="20140393"
replace nsdate=d(03jul2019) if pid=="20140393"
replace rx1=5 if pid=="20140393"
replace rx1d=d(29mar2014) if pid=="20140393"

replace basis=1 if pid=="20140404"
replace dcostatus=1 if pid=="20140404"

replace basis=9 if pid=="20140408"
replace dcostatus=1 if pid=="20140408"
replace dot=d(15jul2014) if pid=="20140408"

replace basis=1 if pid=="20140410"
replace dcostatus=1 if pid=="20140410"
replace dot=d(21may2014) if pid=="20140410"
replace nsdate=d(03jul2019) if pid=="20140410"
replace rx1=5 if pid=="20140410"
replace rx1d=d(21may2014) if pid=="20140410"

replace basis=4 if pid=="20140411"
replace dcostatus=1 if pid=="20140411"
replace dot=d(09jan2013) if pid=="20140411"
replace dotyear=2013 if pid=="20140411"
replace dxyr=2013 if pid=="20140411"
replace nsdate=d(03jul2019) if pid=="20140411"
replace rx1=5 if pid=="20140411"
replace rx1d=d(09jan2013) if pid=="20140411"

replace basis=9 if pid=="20140416"
replace dcostatus=1 if pid=="20140416"
replace dot=d(07feb2014) if pid=="20140416"

replace basis=9 if pid=="20140418"
replace dcostatus=1 if pid=="20140418"
replace dot=d(04jul2014) if pid=="20140418"

replace basis=5 if pid=="20140424"
replace dcostatus=1 if pid=="20140424"
replace dot=d(12may2014) if pid=="20140424"
replace hx="SQUAMOUS CELL CARCINOMA" if pid=="20140424"
replace morph=8070 if pid=="20140424"
replace morphcat=3 if pid=="20140424"
replace monset=5 if pid=="20140424"
replace nsdate=d(04jul2019) if pid=="20140424"

replace basis=2 if pid=="20140425"
replace dcostatus=1 if pid=="20140425"
replace dot=d(25jul2014) if pid=="20140425"
replace nsdate=d(03jul2019) if pid=="20140425"

replace basis=9 if pid=="20140430"
replace dcostatus=1 if pid=="20140430"
replace dot=d(01may2014) if pid=="20140430"

replace basis=2 if pid=="20140446"
replace dcostatus=1 if pid=="20140446"
replace dot=d(07aug2014) if pid=="20140446"
replace nsdate=d(05jul2019) if pid=="20140446"

replace basis=7 if pid=="20140452"
replace dot=d(22feb2002) if pid=="20140452"
replace dotyear=2002 if pid=="20140452"
replace dxyr=2002 if pid=="20140452"
replace nsdate=d(04jul2019) if pid=="20140452"
replace cstatus=3 if pid=="20140452"
replace recstatus=3 if pid=="20140452"
replace dcostatus=3 if pid=="20140452"

replace basis=9 if pid=="20140461"
replace dcostatus=1 if pid=="20140461"
replace dot=d(15sep2013) if pid=="20140461"
replace dotyear=2013 if pid=="20140461"
replace dxyr=2013 if pid=="20140461"

replace basis=9 if pid=="20140462"
replace dcostatus=1 if pid=="20140462"
replace dot=d(24jun2013) if pid=="20140462"
replace dotyear=2013 if pid=="20140462"
replace dxyr=2013 if pid=="20140462"

replace basis=7 if pid=="20140465"
replace dot=d(22may2009) if pid=="20140465"
replace dotyear=2009 if pid=="20140465"
replace dxyr=2009 if pid=="20140465"
replace nsdate=d(04jul2019) if pid=="20140465"
replace cstatus=3 if pid=="20140465"
replace recstatus=3 if pid=="20140465"
replace dcostatus=3 if pid=="20140465"

replace basis=9 if pid=="20140468"
replace dcostatus=1 if pid=="20140468"
replace dot=d(24aug2014) if pid=="20140468"
replace nsdate=d(02jul2019) if pid=="20140468"

replace basis=9 if pid=="20140471"
replace dcostatus=1 if pid=="20140471"
replace dot=d(01aug2014) if pid=="20140471"

replace primarysite="SKIN-NOS" if pid=="20140472"
replace top="449" if pid=="20140472"
replace topography=449 if pid=="20140472"
replace site=11 if pid=="20140472"
replace sitecr5db=26 if pid=="20140472"
replace sitear=11 if pid=="20140472"
replace topcat=39 if pid=="20140472"
replace basis=9 if pid=="20140472"
replace dcostatus=1 if pid=="20140472"
replace dot=d(06aug2014) if pid=="20140472"

drop if pid=="20140474" & cr5id=="T3S1" //1 deleted - a met not a MP

replace basis=9 if pid=="20140490" & cr5id=="T1S1"
replace dot=d(30jun2003) if pid=="20140490" & cr5id=="T1S1"
replace dotyear=2003 if pid=="20140490" & cr5id=="T1S1"
replace dxyr=2003 if pid=="20140490" & cr5id=="T1S1"
replace nsdate=d(04jul2019) if pid=="20140490" & cr5id=="T1S1"
replace cstatus=3 if pid=="20140490" & cr5id=="T1S1"
replace recstatus=3 if pid=="20140490" & cr5id=="T1S1"
replace dcostatus=3 if pid=="20140490" & cr5id=="T1S1"

replace basis=9 if pid=="20140490" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140490" & cr5id=="T2S1"
replace dot=d(01sep2014) if pid=="20140490" & cr5id=="T2S1"
replace nsdate=d(04jul2019) if pid=="20140490" & cr5id=="T2S1"

replace basis=4 if pid=="20140491"
replace dcostatus=1 if pid=="20140491"
replace dot=d(19nov2013) if pid=="20140491"
replace dotyear=2013 if pid=="20140491"
replace dxyr=2013 if pid=="20140491"
replace rx1=5 if pid=="20140491"
replace rx1d=d(16dec2013) if pid=="20140491"
replace nsdate=d(09jul2019) if pid=="20140491"

replace basis=1 if pid=="20140512"
replace dcostatus=1 if pid=="20140512"
replace dot=d(18aug2014) if pid=="20140512"
replace nsdate=d(04jul2019) if pid=="20140512"

replace basis=2 if pid=="20140514"
replace dcostatus=1 if pid=="20140514"
replace dot=d(21aug2014) if pid=="20140514"
replace nsdate=d(03jul2019) if pid=="20140514"

replace basis=2 if pid=="20140517"
replace dcostatus=1 if pid=="20140517"
replace dot=d(12sep2013) if pid=="20140517"
replace dotyear=2013 if pid=="20140517"
replace dxyr=2013 if pid=="20140517"
replace nsdate=d(02jul2019) if pid=="20140517"

replace basis=9 if pid=="20140535"
replace dcostatus=1 if pid=="20140535"
replace dot=d(09mar2014) if pid=="20140535"

replace basis=7 if pid=="20140537"
replace dot=d(04may2001) if pid=="20140537"
replace dotyear=2001 if pid=="20140537"
replace dxyr=2001 if pid=="20140537"
replace nsdate=d(02jul2019) if pid=="20140537"
replace cstatus=3 if pid=="20140537"
replace recstatus=3 if pid=="20140537"
replace dcostatus=3 if pid=="20140537"

replace basis=9 if pid=="20140543"
replace dcostatus=1 if pid=="20140543"
replace dot=d(06oct2014) if pid=="20140543"

replace basis=9 if pid=="20140557"
replace dcostatus=1 if pid=="20140557"
replace dot=d(19aug2014) if pid=="20140557"
replace nsdate=d(04jul2019) if pid=="20140557"

replace basis=9 if pid=="20140563"
replace dcostatus=1 if pid=="20140563"
replace dot=d(11mar2014) if pid=="20140563"

replace basis=9 if pid=="20140570" & cr5id=="T1S1"
replace dcostatus=1 if pid=="20140570" & cr5id=="T1S1"
replace dot=d(12feb2014) if pid=="20140570" & cr5id=="T1S1"

replace basis=9 if pid=="20140570" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140570" & cr5id=="T2S1"
replace dot=d(12nov2013) if pid=="20140570" & cr5id=="T2S1"
replace dotyear=2013 if pid=="20140570" & cr5id=="T2S1"
replace dxyr=2013 if pid=="20140570" & cr5id=="T2S1"

replace basis=9 if pid=="20140576"
replace dcostatus=1 if pid=="20140576"
replace dot=d(14mar2014) if pid=="20140576"

replace basis=2 if pid=="20140577"
replace dcostatus=1 if pid=="20140577"
replace dot=d(08oct2014) if pid=="20140577"
replace nsdate=d(05jul2019) if pid=="20140577"

replace basis=9 if pid=="20140578"
replace dcostatus=1 if pid=="20140578"
replace dot=d(03sep2014) if pid=="20140578"
replace nsdate=d(04jul2019) if pid=="20140578"

replace basis=9 if pid=="20140584"
replace dcostatus=1 if pid=="20140584"
replace dot=d(13jun2013) if pid=="20140584"
replace dotyear=2013 if pid=="20140584"
replace dxyr=2013 if pid=="20140584"

replace basis=2 if pid=="20140586"
replace dcostatus=1 if pid=="20140586"
replace dot=d(07aug2014) if pid=="20140586"
replace nsdate=d(04jul2019) if pid=="20140586"

replace basis=7 if pid=="20140590"
replace dot=d(24may2012) if pid=="20140590"
replace dotyear=2012 if pid=="20140590"
replace dxyr=2012 if pid=="20140590"
replace nsdate=d(02jul2019) if pid=="20140590"
replace cstatus=3 if pid=="20140590"
replace recstatus=3 if pid=="20140590"
replace dcostatus=3 if pid=="20140590"

replace basis=9 if pid=="20140595"
replace dcostatus=1 if pid=="20140595"
replace dot=d(15sep2014) if pid=="20140595"
replace nsdate=d(04jul2019) if pid=="20140595"

replace basis=2 if pid=="20140597"
replace dcostatus=1 if pid=="20140597"
replace dot=d(15nov2014) if pid=="20140597"
replace nsdate=d(05jul2019) if pid=="20140597"

replace basis=7 if pid=="20140616"
replace dcostatus=1 if pid=="20140616"
replace primarysite="ESOPHAGUS-32CM" if pid=="20140616"
replace top="155" if pid=="20140616"
replace topography=155 if pid=="20140616"
replace hx="ADENOCARCINOMA WITH ADENOSQUAMOUS CARCINOMA COMPONENT" if pid=="20140616"
replace morph=8560 if pid=="20140616"
replace morphcat=12 if pid=="20140616"
replace dot=d(03mar2014) if pid=="20140616"
replace nsdate=d(10jul2019) if pid=="20140616"

replace basis=2 if pid=="20140619"
replace dcostatus=1 if pid=="20140619"
replace dot=d(02dec2014) if pid=="20140619"
replace nsdate=d(02jul2019) if pid=="20140619"

replace basis=9 if pid=="20140635"
replace dcostatus=1 if pid=="20140635"
replace dot=d(21apr2014) if pid=="20140635"

replace basis=1 if pid=="20140641"
replace dcostatus=1 if pid=="20140641"
replace dot=d(30jun2008) if pid=="20140641"
replace dotyear=2008 if pid=="20140641"
replace dxyr=2008 if pid=="20140641"
replace age=77 if pid=="20140641"
replace nsdate=d(10jul2019) if pid=="20140641"

replace basis=9 if pid=="20140644"
replace dcostatus=1 if pid=="20140644"
replace dot=d(11aug2014) if pid=="20140644"
replace nsdate=d(04jul2019) if pid=="20140644"

replace basis=1 if pid=="20140644"
replace dcostatus=1 if pid=="20140644"
replace dot=d(23oct2014) if pid=="20140644"
replace nsdate=d(24jul2018) if pid=="20140644"

replace basis=2 if pid=="20140656"
replace dcostatus=1 if pid=="20140656"
replace dot=d(21aug2014) if pid=="20140656"
replace nsdate=d(04jul2019) if pid=="20140656"

replace basis=7 if pid=="20140659"
replace dcostatus=1 if pid=="20140659"
replace primarysite="LYMPH NODES-RETROPERITONEAL MASS" if pid=="20140659"
replace top="772" if pid=="20140659"
replace topography=772 if pid=="20140659"
replace hx="AGGRESSIVE B CELL LYMPHOMA, DIFFUSE LARGE B-CELL, NON-GERMINAL CENTER SUBTYPE" if pid=="20140659"
replace morph=9680 if pid=="20140659"
replace morphcat=43 if pid=="20140659"
replace topcat=69 if pid=="20140659"
replace icd10="C833" if pid=="20140659"
replace siteicd10=17 if pid=="20140659"
replace sitecr5db=21 if pid=="20140659"
replace siteiarc=53 if pid=="20140659"
replace site=10 if pid=="20140659"
replace sitear=10 if pid=="20140659"
replace dot=d(18jul2014) if pid=="20140659"

replace basis=9 if pid=="20140665"
replace dcostatus=1 if pid=="20140665"
replace dot=d(28nov2013) if pid=="20140665"
replace dotyear=2013 if pid=="20140665"
replace dxyr=2013 if pid=="20140665"

sort pid
/*
20140587 abstracted directly into dataset via Stata data editor as 2008 case;
See frmCaseFinding 4024 and main CR5db and DCO ptnames excel in version02/1-input
Saved in and as: version02\2-working\'2014_cancer_nonsurvival_extras.dta'

20150037 entered directly into Stata editor using 2015 CLEAN CR5db (2015BNR-C.xml)
*/
count //926 (1 deleted above)

clear
use "`datapath'\version02\2-working\2014_cancer_nonsurvival_extras", replace
count //928


** Create missed 2008 dataset
preserve
drop if dxyr!=2008
list pid dot
count //3

save "`datapath'\version02\2-working\2008_cancer_nonsurvival_extras", replace
label data "2014 BNR-Cancer analysed data - 2008 Cases"
note: This dataset was used for 2015 annual report
restore
//import 2008 cases to 2008_cancer_nonsurvival.dta below

** Create missed 2013 dataset
preserve
drop if dxyr!=2013
list pid dot
count //26

save "`datapath'\version02\2-working\2013_cancer_nonsurvival_extras", replace
label data "2014 BNR-Cancer analysed data - 2013 Cases"
note: This dataset was used for 2015 annual report
restore

** Remove cases before 2014 from 2014 dataset
tab dxyr ,m //3 missing
//list pid dot if dxyr==.
replace dxyr=2014 if dxyr==. //3 changes
drop if dxyr!=2014 //43 deleted

count //

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** mpseq was dropped so need to create
gen mpseq=0 if persearch==1
replace mpseq=1 if persearch!=1 & regexm(cr5id,"T1") //12 changes
replace mpseq=2 if persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //10 changes

export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp ///
using "`datapath'\version02\2-working\2014_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2014_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2014_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    885 records processed
	0 errors
        
	51 warnings
        - 6 unlikely hx/site
		- 3 unlikely grade/hx
        - 42 unlikely basis/hx
*/
/*	
Results of IARC MP Program:
	24 excluded (non-malignant)
	22 MPs (multiple tumours)
	 3 Duplicate registration
*/
** Below updates from warnings/errors report
replace grade=6 if pid=="20140394"
replace grade=6 if pid=="20140659"
replace grade=4 if pid=="20140525"
replace morph=8460 if pid=="20140707"

** Only report non-duplicate MPs (see IARC MP rules on recording and reporting)
display `"{browse "http://www.iacr.com.fr/images/doc/MPrules_july2004.pdf":IARC-MP}"'
tab persearch ,m
//list pid cr5id if persearch==3 //3
drop if pid=="20140555" & cr5id=="T2S1" //1 deleted
replace primarysite="SIGMOID COLON" if pid=="20140887" & cr5id=="T1S1"
replace top="187" if pid=="20140887" & cr5id=="T1S1"
replace topography=187 if pid=="20140887" & cr5id=="T1S1"
replace primarysite="CECUM" if pid=="20140887" & cr5id=="T2S1"
replace top="180" if pid=="20140887" & cr5id=="T2S1"
replace topography=180 if pid=="20140887" & cr5id=="T2S1"
replace persearch=1 if pid=="20140887" & cr5id=="T1S1"
drop if pid=="20140887" & cr5id=="T2S1" //1 deleted
replace primarysite="COLON-SIGMOID" if pid=="20141351" & cr5id=="T1S1"
replace top="187" if pid=="20141351" & cr5id=="T1S1"
replace topography=187 if pid=="20141351" & cr5id=="T1S1"
replace persearch=1 if pid=="20141351" & cr5id=="T1S1"
replace primarysite="COLON-CECUM" if pid=="20141351" & cr5id=="T2S1"
replace top="180" if pid=="20141351" & cr5id=="T2S1"
replace topography=180 if pid=="20141351" & cr5id=="T2S1"
drop if pid=="20141351" & cr5id=="T2S1" //1 deleted

** Updates from multiple primary report (define which is the MP so can remove in survival dataset):
replace persearch=1 if pid=="20140786" & eidmp==1 //1 change
replace persearch=1 if pid=="20140690" & cr5id=="T1S1" //1 change
replace persearch=2 if pid=="20140690" & cr5id=="T5S1" //1 change
replace persearch=1 if pid=="20140672" & eidmp==1 //1 change
replace persearch=1 if pid=="20140566" & eidmp==1 //1 change
replace persearch=1 if pid=="20140526" & eidmp==1 //1 change
replace persearch=1 if pid=="20140339" & eidmp==1 //1 change
replace persearch=1 if pid=="20140176" & eidmp==1 //1 change
replace persearch=1 if pid=="20140077" & eidmp==1 //1 change

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate/Non-IARC MP" 4 "Done: Exclude", modify
label values persearch persearch_lab
replace persearch=4 if morph==8077 //24 changes

tab persearch ,m
replace persearch=1 if pid=="20140474"
replace persearch=1 if pid=="20140570"
replace persearch=1 if pid=="20140490"

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m
replace basis=1 if pid=="20140672" & cr5id=="T2S1"
replace dcostatus=1 if pid=="20140672" & cr5id=="T2S1"
replace nsdate=d(24jul2018) if pid=="20140672" & cr5id=="T2S1"

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m 
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //47 changes
//list pid natregno nrn if resident==99
replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //16 changes
** Check electoral list and CR5db for those resident=99
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
replace natregno="500906-0061" if pid=="20130294"
replace dob=d(06sep1950) if pid=="20130294"
replace resident=1 if pid=="20130294"
replace resident=1 if pid=="20145040" //JC knows this pt was a resident
replace natregno="550416-7015" if pid=="20141414"
replace dob=d(16apr1955) if pid=="20141414"
replace resident=1 if pid=="20141414"
replace natregno="370117-8018" if pid=="20141510"
replace dob=d(17jan1937) if pid=="20141510"
replace resident=1 if pid=="20141510"
replace age=77 if pid=="20141510"

** Check parish
count if parish!=. & parish!=99 & addr=="" //4
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""
bysort pid (cr5id) : replace addr = addr[_n-1] if missing(addr) //1 change - 20140566
replace addr="OXNARD HGTS" if pid=="20149041"
replace addr="APPLE HALL" if pid=="20149042"
replace addr="WOODBOURNE" if pid=="20149090"

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 2 are 100+

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //5 changes
tab slc ,m 
** Check missing in CR5db
//list pid if slc==99
replace slc=1 if pid=="20140817"
replace dlc=d(10sep2015) if pid=="20140817"
replace slc=1 if pid=="20140808"
replace dlc=d(27aug2014) if pid=="20140808"
replace dot=d(27aug2014) if pid=="20140808"
replace slc=1 if pid=="20140186"
replace dlc=d(30jun2014) if pid=="20140186"
replace slc=1 if pid=="20140701"
replace dlc=d(15may2014) if pid=="20140701"
replace dot=d(15may2014) if pid=="20140701"
replace slc=1 if pid=="20140773"
replace dlc=d(20feb2014) if pid=="20140773"
replace dot=d(20feb2014) if pid=="20140773"
tab dlc ,m

** Check for ineligibles
tab recstatus ,m

** Check for non-malignant
tab beh ,m //24 in-situ
tab morph if beh!=3 //24 CIN III

** Check for duplicate tumours
tab persearch ,m //24 excluded

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //3
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))
replace dob=d(08aug1945) if pid=="20149090"
replace dob=d(17jul1940) if pid=="20149041"
replace dob=d(24aug1932) if pid=="20149042"
** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //8
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //8 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //882

** Save this corrected dataset with BNR reportable cases
save "`datapath'\version02\2-working\2014_cancer_nonsurvival_bnr_reportable", replace
label data "2014 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
duplicates tag pid, gen(dup_id)
list pid cr5id if persearch==1 & (resident==2|resident==99|recstatus==3|sex==9|beh!=3|siteiarc==25), nolabel sepby(pid)
drop if resident==2 //1 deleted - nonresident
drop if resident==99 //27 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //24 deleted - nonmalignant
drop if persearch>2 //24 to be deleted; already deleted from above line
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //830

** Save this corrected dataset with only internationally reportable cases
save "`datapath'\version02\2-working\2014_cancer_nonsurvival_intl_reportable", replace
label data "2014 BNR-Cancer analysed data - Non-survival International Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

clear

*******************************
** 2008 Non-survival Dataset **
*******************************

** Load the dataset (2008)
use "`datapath'\version02\1-input\2008_cancer_sites_da_v01", replace
count //1209

** Add 2008 cases (3) found in 2014 (DCO) dataset
append using "`datapath'\version02\2-working\2008_cancer_nonsurvival_extras"
count //1212

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp ///
using "`datapath'\version02\2-working\2008_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    1212 records processed
	0 errors
        
	26 warnings
        - 7 unlikely hx/site
		- 1 unlikely beh/hx
        - 18 unlikely grade/hx
*/
/*	
Results of IARC MP Program:
	101 excluded (non-malignant)
	148 MPs (multiple tumours)
	 65 Duplicate registration
*/
** No updates from warnings/errors report
** Updates from multiple primary report:
replace persearch=2 if pid=="20080967" & eidmp==2 //1 change
replace persearch=2 if pid=="20080966" & eidmp==2 //1 change
replace persearch=2 if pid=="20080586" & eidmp==2 //1 change
replace persearch=2 if pid=="20080536" & eidmp==2 //1 change
replace persearch=2 if pid=="20080405" & eidmp==2 //1 change
replace persearch=2 if pid=="20080295" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080215" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080215" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080215" & cr5id=="T3S1" //1 change
replace patient=1 if pid=="20080215" & cr5id=="T3S1" //1 change
replace persearch=2 if pid=="20080215" & eidmp==2 //1 change
replace persearch=3 if pid=="20080170" & eidmp==2 //1 change
replace recstatus=4 if pid=="20080170" & eidmp==2 //1 change
drop if pid=="20080170" & recstatus==4 //1 deleted - removed duplicate abs
replace persearch=3 if pid=="20081104" & eidmp==2 //1 change
replace persearch=3 if pid=="20081089" & eidmp==2 //1 change
replace persearch=3 if pid=="20081083" & eidmp==2 //2 changes
replace persearch=3 if pid=="20081076" & eidmp==2 //2 changes
replace persearch=3 if pid=="20080790" & eidmp==2 //1 change
replace persearch=3 if pid=="20080766" & eidmp==2 & cr5id!="T2S1" //2 changes
replace persearch=2 if pid=="20080766" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080740" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080739" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080739" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080739" & cr5id=="T3S1" //1 change
replace patient=1 if pid=="20080739" & cr5id=="T3S1" //1 change
replace persearch=3 if pid=="20080739" & eidmp==2 //3 changes
replace eidmp=2 if pid=="20080738" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080738" & cr5id=="T2S1" //1 change
replace patient=2 if pid=="20080738" & cr5id=="T1S1" //1 change
replace patient=1 if pid=="20080738" & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080738" & eidmp==2 //1 change
replace persearch=3 if pid=="20080734" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080733" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080733" & cr5id=="T4S1" //1 change
replace patient=2 if pid=="20080733" & cr5id=="T1S1" //1 change
replace patient=1 if pid=="20080733" & cr5id=="T4S1" //1 change
replace persearch=3 if pid=="20080733" & eidmp==2 //1 change
replace persearch=3 if pid=="20080731" & eidmp==2 //1 change
replace persearch=2 if pid=="20080730" & eidmp==2 //1 change
replace persearch=3 if pid=="20080728" & eidmp==2 & cr5id!="T2S1" //2 changes
replace persearch=2 if pid=="20080728" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080725" & eidmp==2 //1 change
replace persearch=3 if pid=="20080709" & eidmp==2 //1 change
replace persearch=2 if pid=="20080708" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080705" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080705" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080705" & cr5id=="T2S1" //1 change
replace patient=1 if pid=="20080705" & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080705" & eidmp==2 //1 change
replace persearch=3 if pid=="20080667" & cr5id=="T3S1" //1 change
replace persearch=2 if pid=="20080667" & cr5id=="T2S1" //1 change
replace eidmp=2 if pid=="20080662" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080662" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080662" & cr5id=="T2S1" //1 change
replace patient=1 if pid=="20080662" & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080662" & eidmp==2 //1 change
replace persearch=3 if pid=="20080655" & eidmp==2 //1 change
replace persearch=3 if pid=="20080626" & eidmp==2 & cr5id!="T2S1" //4 changes
replace persearch=2 if pid=="20080626" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080499" & eidmp==2 //1 change
replace persearch=2 if pid=="20080477" & eidmp==2 //1 change
replace persearch=3 if pid=="20080475" & eidmp==2 //1 change
replace persearch=3 if pid=="20080465" & eidmp==2 & cr5id!="T3S1" //2 changes
replace persearch=2 if pid=="20080465" & eidmp==2 & cr5id=="T3S1" //1 change
replace persearch=3 if pid=="20080464" & eidmp==2 //1 change
replace persearch=3 if pid=="20080463" & eidmp==2 & cr5id!="T3S1" //1 change
replace persearch=2 if pid=="20080463" & eidmp==2 & cr5id=="T3S1" //1 change
replace persearch=2 if pid=="20080462" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080460" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080460" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080460" & cr5id=="T2S1" //1 change
replace patient=1 if pid=="20080460" & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080460" & eidmp==2 //1 change
replace persearch=3 if pid=="20080457" & eidmp==2 //3 changes - T4S1=insitu not included in IARC MP check
replace persearch=3 if pid=="20080449" & eidmp==2 //3 changes
replace persearch=3 if pid=="20080446" & eidmp==2 //1 change
replace persearch=2 if pid=="20080443" & eidmp==2 //1 change
replace persearch=3 if pid=="20080441" & eidmp==2 //1 change
replace persearch=3 if pid=="20080440" & eidmp==2 //1 change
replace persearch=3 if pid=="20080432" & eidmp==2 //1 change
replace persearch=3 if pid=="20080386" & eidmp==2 //1 change
replace persearch=2 if pid=="20080383" & eidmp==2 //1 change
replace eidmp=2 if pid=="20080381" & cr5id=="T1S1" //1 change
replace patient=2 if pid=="20080381" & cr5id=="T1S1" //1 change
replace eidmp=1 if pid=="20080381" & cr5id=="T2S1" //1 change
replace patient=1 if pid=="20080381" & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080381" & eidmp==2 //1 change
replace persearch=3 if pid=="20080378" & eidmp==2 //1 change
replace persearch=3 if pid=="20080372" & eidmp==2 //1 change
replace persearch=3 if pid=="20080364" & eidmp==2 //1 change
replace persearch=3 if pid=="20080363" & eidmp==2 & cr5id!="T2S1" //3 changes - T5S1=insitu not included in IARC MP check
replace persearch=2 if pid=="20080363" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080362" & eidmp==2 & cr5id!="T2S1" //2 changes
replace persearch=2 if pid=="20080362" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080360" & eidmp==2 //1 change
replace persearch=3 if pid=="20080317" & eidmp==2 & cr5id!="T2S1" //4 changes
replace persearch=2 if pid=="20080317" & eidmp==2 & cr5id=="T2S1" //1 change
replace persearch=3 if pid=="20080310" & eidmp==2 //3 changes
replace persearch=3 if pid=="20080308" & eidmp==2 //2 changes
replace persearch=2 if pid=="20080167" & eidmp==2 //1 change
replace persearch=2 if pid=="20080139" & eidmp==2 //1 change
replace persearch=1 if persearch==0|persearch==. //1118 changes

** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate/Non-IARC MP" 4 "Done: Exclude", modify
label values persearch persearch_lab
tab beh ,m //102 non-malignant so check against exclusion report (101) to find extra
//list pid morph beh if beh!=3
replace beh=3 if pid=="20080695"
replace persearch=4 if beh!=3 //101 changes

tab persearch ,m

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m 
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //260 changes
//list pid natregno nrn if resident==99
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //173 changes
** Check electoral list and CR5db
//list pid natregno if resident==2
replace natregno=subinstr(natregno,"9999","0027",.) if pid=="20080981"
replace resident=1 if pid=="20080981"
** Check electoral list (those with dob-use filter text contains in NRN), CR5db, MasterDb, death data for those resident=99
count if resident==99 //88
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
replace natregno=subinstr(natregno,"9999","0120",.) if pid=="20081066"
replace resident=1 if pid=="20081066"
replace resident=1 if pid=="20081073" //see MasterDb frmCF path sample dates are 6 months apart
replace resident=1 if pid=="20081106" //see MasterDb frmCF path & RT dates
replace natregno=subinstr(natregno,"9999","0024",.) if pid=="20081058"
replace resident=1 if pid=="20081058"
replace addr="37 GAYS" if pid=="20081058"
replace natregno=subinstr(natregno,"9999","0085",.) if pid=="20081057"
replace resident=1 if pid=="20081057"
replace natregno=subinstr(natregno,"9999","0047",.) if pid=="20081107"
replace resident=1 if pid=="20081107"
replace natregno=subinstr(natregno,"9999","0081",.) if pid=="20081003"
replace resident=1 if pid=="20081003"
replace natregno=subinstr(natregno,"9999","0061",.) if pid=="20081124"
replace resident=1 if pid=="20081124"
replace natregno=subinstr(natregno,"9999","0181",.) if pid=="20080865"
replace resident=1 if pid=="20080865"
replace natregno=subinstr(natregno,"9999","7004",.) if pid=="20081075"
replace resident=1 if pid=="20081075"
replace natregno=subinstr(natregno,"9999","0122",.) if pid=="20081056"
replace resident=1 if pid=="20081056"
replace natregno=subinstr(natregno,"9999","0023",.) if pid=="20081118"
replace resident=1 if pid=="20081118"
replace natregno=subinstr(natregno,"9999","0143",.) if pid=="20081093"
replace resident=1 if pid=="20081093"
replace resident=1 if pid=="20080914"
replace natregno=subinstr(natregno,"9999","0022",.) if pid=="20080955"
replace resident=1 if pid=="20080955"
replace resident=1 if pid=="20081039"
replace resident=1 if pid=="20081115"
replace resident=1 if pid=="20081121"
replace natregno=subinstr(natregno,"9999","0145",.) if pid=="20080936"
replace resident=1 if pid=="20080936"
replace natregno=subinstr(natregno,"9999","8025",.) if pid=="20081065"
replace resident=1 if pid=="20081065"
replace natregno=subinstr(natregno,"9999","0046",.) if pid=="20081131"
replace resident=1 if pid=="20081131"
replace natregno=subinstr(natregno,"9999","0136",.) if pid=="20080882"
replace resident=1 if pid=="20080882"
replace natregno=subinstr(natregno,"9999","0076",.) if pid=="20080988"
replace resident=1 if pid=="20080988"
replace resident=1 if pid=="20080589"
replace slc=2 if pid=="20080589" //see CR5db comments; keep dlc as cannot find dod in death data
replace dod=dlc if pid=="20080589"
replace dodyear=2008 if pid=="20080589"
replace natregno=subinstr(natregno,"9999","0171",.) if pid=="20081014"
replace resident=1 if pid=="20081014"
replace natregno=subinstr(natregno,"9999","0198",.) if pid=="20080889"
replace resident=1 if pid=="20080889"
replace resident=1 if pid=="20080587"
replace slc=2 if pid=="20080587" //see CR5db comments; keep dlc as cannot find dod in death data
replace dod=dlc if pid=="20080587"
replace dodyear=2008 if pid=="20080587"
replace natregno=subinstr(natregno,"9999","0097",.) if pid=="20080969"
replace resident=1 if pid=="20080969"
replace resident=1 if pid=="20080588"
replace slc=2 if pid=="20080588" //see CR5db comments; keep dlc as cannot find dod in death data
replace dod=dlc if pid=="20080588"
replace dodyear=2008 if pid=="20080588"
swapval fname lname if pid=="20080588" //ssc install swapval
replace natregno="490212-0031" if pid=="20080588"
replace natregno="450805-0079" if pid=="20080877"
replace dob=d(05aug1945) if pid=="20080887"
replace resident=1 if pid=="20080877"
replace resident=1 if pid=="20080909"
replace natregno="410324-0018" if pid=="20080881"
replace dob=d(24mar1941) if pid=="20080881"
replace resident=1 if pid=="20080881"
replace addr="MONTGOMERY HILL CAVE HILL" if pid=="20080881"
replace parish=8 if pid=="20080881"
replace resident=1 if pid=="20080590"
replace natregno="351228-0011" if pid=="20080885"
replace dob=d(28dec1935) if pid=="20080885"
replace resident=1 if pid=="20080885"
replace addr="1ST AVENUE FAIR FIELD AVENUE BLACKROCK" if pid=="20080885"
replace parish=8 if pid=="20080885"
replace slc=2 if pid=="20080885"
replace dlc=d(16sep2018) if pid=="20080885"
replace dod=d(16sep2018) if pid=="20080885"
replace dodyear=2018 if pid=="20080885"
replace natregno=subinstr(natregno,"9999","0010",.) if pid=="20081011"
replace resident=1 if pid=="20081011"
replace natregno=subinstr(natregno,"9999","0019",.) if pid=="20080976"
replace resident=1 if pid=="20080976"
replace natregno=subinstr(natregno,"9999","0015",.) if pid=="20080901"
replace resident=1 if pid=="20080901"
replace natregno=subinstr(natregno,"9999","0015",.) if pid=="20081113"
replace resident=1 if pid=="20081113"
replace natregno=subinstr(natregno,"9999","0058",.) if pid=="20080998" //see MasterDb frmCF #4088
replace resident=1 if pid=="20080998"
replace natregno=subinstr(natregno,"9999","7033",.) if pid=="20080972"
replace resident=1 if pid=="20080972"
replace natregno=subinstr(natregno,"9999","0031",.) if pid=="20080949"
replace resident=1 if pid=="20080949"
replace natregno=subinstr(natregno,"9999","0018",.) if pid=="20080891"
replace resident=1 if pid=="20080891"
replace mname="seon" if pid=="20080891"
replace init="S" if pid=="20080891"
replace natregno=subinstr(natregno,"9999","0011",.) if pid=="20080977"
replace resident=1 if pid=="20080977"
replace mname="jethro" if pid=="20080977"
replace init="J" if pid=="20080977"
replace natregno=subinstr(natregno,"9999","0078",.) if pid=="20080923"
replace resident=1 if pid=="20080923"
replace natregno=subinstr(natregno,"9999","0044",.) if pid=="20081055"
replace resident=1 if pid=="20081055"
replace natregno=subinstr(natregno,"9999","0204",.) if pid=="20080637"
replace lname=subinstr(lname,"R","K",.) if pid=="20080637"
replace init="J" if pid=="20080637"
replace addr="GUINEA PLTN" if pid=="20080637"
replace parish=5 if pid=="20080637"
replace resident=1 if pid=="20080637"
replace natregno=subinstr(natregno,"9999","0022",.) if pid=="20081062"
replace resident=1 if pid=="20081062"
replace natregno=subinstr(natregno,"9999","0105",.) if pid=="20080993"
replace resident=1 if pid=="20080993"
replace natregno="270211-0103" if pid=="20081088"
replace resident=1 if pid=="20081088"
replace natregno=subinstr(natregno,"9999","0025",.) if pid=="20080895"
replace resident=1 if pid=="20080895"
replace natregno=subinstr(natregno,"9999","0028",.) if pid=="20081123"
replace resident=1 if pid=="20081123"
replace natregno=subinstr(natregno,"9999","0040",.) if pid=="20081090"
replace resident=1 if pid=="20081090"
replace natregno=subinstr(natregno,"9999","0071",.) if pid=="20081089"
replace resident=1 if pid=="20081089"
replace natregno=subinstr(natregno,"9999","0146",.) if pid=="20081127"
replace resident=1 if pid=="20081127"
replace natregno=subinstr(natregno,"9999","0160",.) if pid=="20081069"
replace resident=1 if pid=="20081069"
replace natregno=subinstr(natregno,"9999","8018",.) if pid=="20081102"
replace resident=1 if pid=="20081102"
replace natregno=subinstr(natregno,"9999","0078",.) if pid=="20081092"
replace resident=1 if pid=="20081092"
replace natregno="550119-0051" if pid=="20081081"
replace resident=1 if pid=="20081081"
replace natregno="621220-8018" if pid=="20081094"
replace resident=1 if pid=="20081094"
replace natregno="231231-0051" if pid=="20081078"
replace resident=1 if pid=="20081078"
replace natregno="330103-0098" if pid=="20081096"
replace resident=1 if pid=="20081096"
replace natregno="261118-0015" if pid=="20081083"
replace resident=1 if pid=="20081083"
replace natregno="310925-0013" if pid=="20081103"
replace resident=1 if pid=="20081103"
replace natregno="320626-0113" if pid=="20081082"
replace resident=1 if pid=="20081082"
replace resident=1 if pid=="20080935"
tab resident ,m //20 unk

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 2 are 100+

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //0 changes
tab slc ,m //none missing
tab dlc ,m //none missing
** Check missing in CR5db
//list pid if slc==99

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m

replace dcostatus=1 if slc==2 //652 changes
replace dcostatus=6 if slc!=2 //556 changes
replace dcostatus=2 if basis==0 //54 changes

** Check for ineligibles
tab recstatus ,m //none

** Check for non-malignant
tab beh ,m //83 in-situ
tab morph if beh!=3 //34 CIN III

** Check for duplicate tumours
tab persearch ,m //101 excluded; 64 duplicate

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //11
//list pid natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*-9999*"))
replace dob=d(11feb1927) if pid=="20081088" //1 change
replace dob=d(19jan1955) if pid=="20081081" //1 change
replace dob=d(20dec1962) if pid=="20081094" //1 change
replace dob=d(05aug1945) if pid=="20080877" //1 change
replace dob=d(31dec1923) if pid=="20081078" //1 change
replace dob=d(03jan1933) if pid=="20081096" //1 change
replace dob=d(18nov1926) if pid=="20081083" //3 changes
replace dob=d(25sep1931) if pid=="20081103" //1 change
replace dob=d(26jun1932) if pid=="20081082" //1 change
** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //4
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //2 correct as dod same day and month as dot
replace age=checkage2 if pid=="20080877"
replace age=checkage2 if pid=="20080887"
//replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //2 changes

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //1208 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //847 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //1369 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //1208 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m //0 missing

** JC 04mar2020: at ASIR analysis I discovered error in pid 20080695 so corrected below:
replace beh=3 if pid=="20080695" //0 changes
replace siteiarc=45 if pid=="20080695" //1 change
replace icd10="C679" if pid=="20080695" //1 change
replace siteicd10=12 if pid=="20080695" //1 change

count //1211

** Save this corrected dataset with BNR reportable cases
save "`datapath'\version02\2-working\2008_cancer_nonsurvival_bnr_reportable", replace
label data "2008 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
duplicates tag pid, gen(dup_id)
list pid cr5id if persearch==1 & (resident==2|resident==99|recstatus==3|sex==9|beh!=3|siteiarc==25), nolabel sepby(pid)
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //20 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //99 deleted - nonmalignant
drop if persearch>2 //61 to be deleted; already deleted from above line
drop if siteiarc==25 //228 deleted - nonreportable skin cancers

count //803

** Save this corrected dataset with only internationally reportable cases
save "`datapath'\version02\2-working\2008_cancer_nonsurvival_intl_reportable", replace
label data "2008 BNR-Cancer analysed data - Non-survival International Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

clear

*******************************
** 2013 Non-survival Dataset **
*******************************
** Load the dataset (2013)
use "`datapath'\version02\1-input\2013_cancer_sites_da_v01", replace
count //845

** Add 2013 cases (26) found in 2014 (DCO) dataset
append using "`datapath'\version02\2-working\2013_cancer_nonsurvival_extras"
count //871

** Convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //5056 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //1369 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //5056 changes

sort lname fname pid
** Check if 2013 cases from 2014 dataset are not already in this dataset - use Stata browse
list pid fname lname if pid=="20130175"|pid=="20140027"|pid=="20140032"|pid=="20140033" ///
                       |pid=="20140042"|pid=="20140049"|pid=="20140078"|pid=="20140100" ///
                       |pid=="20140110"|pid=="20140117"|pid=="20140127"|pid=="20140136" ///
                       |pid=="20140154"|pid=="20140168"|pid=="20140174"|pid=="20140192" ///
                       |pid=="20140202"|pid=="20140203"|pid=="20140215"|pid=="20140224" ///
                       |pid=="20140234"|pid=="20140258"|pid=="20140268"|pid=="20140283" ///
                       |pid=="20140380"|pid=="20140389"|pid=="20140411"|pid=="20140461" ///
                       |pid=="20140462"|pid=="20140491"|pid=="20140517"| ///
                       pid=="20140570" & cr5id=="T2S1"|pid=="20140584"|pid=="20140665"
//no matches

** Export dataset to run data in IARCcrg Tools (Check Programme)
gen INCIDYR=year(dot)
tostring INCIDYR, replace
gen INCIDMONTH=month(dot)
gen str2 INCIDMM = string(INCIDMONTH, "%02.0f")
gen INCIDDAY=day(dot)
gen str2 INCIDDD = string(INCIDDAY, "%02.0f")
gen INCID=INCIDYR+INCIDMM+INCIDDD
replace INCID="" if INCID=="..." //0 changes
drop INCIDMONTH INCIDDAY INCIDYR INCIDMM INCIDDD
rename INCID dot_iarc
label var dot_iarc "IARC IncidenceDate"

gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //17 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD dob_iarc
label var dob_iarc "IARC BirthDate"

** mpseq missing for 26 extra cases
replace mpseq=0 if mpseq==. & persearch==1 & regexm(cr5id,"T1") //25 changes - MP in 2014 ds
replace mpseq=1 if mpseq==. & persearch!=1 & regexm(cr5id,"T1") //0 changes
replace mpseq=2 if mpseq==. & persearch!=1 & !(strmatch(strupper(cr5id), "*T1*")) //1 change

export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp ///
using "`datapath'\version02\2-working\2013_nonsurvival_iarccrgtools.txt", nolabel replace

/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    871 records processed
	3 errors - invalid age
        
	33 warnings
        - 6 unlikely histology/site combination
        - 20 unlikely grade/histology combination
        - 7 unlikely basis/histology combination

*/
/*	
Results of IARC MP Program:
	9 excluded (non-malignant)
   22 MPs (multiple tumours)
	2 Duplicate registration
*/
** Updates from errors report
replace age=79 if pid=="20140584"
replace age=80 if pid=="20140380"
replace age=84 if pid=="20140411"
** No updates from warnings report
** Updates from multiple primary report:
replace persearch=2 if pid=="20130786" & eidmp==2 //1 change
replace persearch=2 if pid=="20130539" & eidmp==2 //1 change
replace persearch=2 if pid=="20130425" & eidmp==2 //1 change
replace persearch=2 if pid=="20130343" & eidmp==2 //1 change
replace persearch=3 if pid=="20130323" & eidmp==2 //1 change
replace persearch=2 if pid=="20130245" & eidmp==2 //1 change
replace persearch=3 if pid=="20130160" & eidmp==2 //1 change
replace persearch=2 if pid=="20130116" & eidmp==2 //1 change
replace persearch=2 if pid=="20130067" & eidmp==2 //1 change
replace persearch=2 if pid=="20130022" & eidmp==2 //1 change
replace persearch=2 if pid=="20130006" & eidmp==2 //1 change
replace persearch=1 if persearch==0|persearch==. //804 changes
** Updates from MP exclusion report (excludes in-situ/unreportable cancers)
label drop persearch_lab
label define persearch_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate/Non-IARC MP" 4 "Done: Exclude", modify
label values persearch persearch_lab
tab beh ,m //9 non-malignant so check against exclusion report (9) - no extra record
//list pid morph beh if beh!=3

tab persearch ,m

** Rename cod in prep for death data matching
rename cod codcancer

** Remove non-residents (see IARC validity presentation)
tab resident ,m 
label drop resident_lab
label define resident_lab 1 "Yes" 2 "No" 99 "Unknown", modify
label values resident resident_lab
replace resident=99 if resident==9 //139 changes
//list pid natregno nrn if resident==99
//replace natregno=nrn if natregno=="" & nrn!="" & resident==99 //3 changes
replace resident=1 if natregno!="" & !(strmatch(strupper(natregno), "*-9999*")) //26 changes
** Check electoral list and CR5db
//list pid natregno if resident==2
** Check electoral list (those with dob-use filter text contains in NRN), CR5db, MasterDb, death data for those resident=99
count if resident==99 //88
//list pid fname lname nrn natregno dob if resident==99
//list pid fname lname addr if resident==99
replace natregno="501028-0138" if pid=="20130700"
replace resident=1 if pid=="20130700"
replace addr="GARDEN LD COUNTRY RD" if pid=="20130700"
replace parish=8 if pid=="20130700"
replace natregno="461127-0077" if pid=="20130792"
replace resident=1 if pid=="20130792"
replace natregno="570604-0101" if pid=="20130295"
replace resident=1 if pid=="20130295"
replace addr="HENLEY" if pid=="20130295"
replace parish=5 if pid=="20130295"
replace natregno="440831-0169" if pid=="20130355"
replace resident=1 if pid=="20130355"
replace addr="2ND AVE BIBBY'S LN" if pid=="20130355"
replace natregno="480130-0130" if pid=="20130793"
replace resident=1 if pid=="20130793"
replace addr=subinstr(addr,"99 99","24",.) if pid=="20130793"
replace natregno="641018-0084" if pid=="20130331"
replace resident=1 if pid=="20130331"
replace addr="ENTERPRISE COAST ROAD AURORA DRIVE" if pid=="20130331"
replace parish=1 if pid=="20130331"
replace slc=2 if pid=="20130331"
replace dlc=d(12jun2013) if pid=="20130331"
replace natregno="451206-0023" if pid=="20130659"
replace resident=1 if pid=="20130659"
replace natregno="430306-7021" if pid=="20130701"
replace resident=1 if pid=="20130701"
replace addr="SCHOOL RD HINDSBURY RD" if pid=="20130701"
replace parish=8 if pid=="20130701"
replace natregno="370719-0025" if pid=="20130330"
replace resident=1 if pid=="20130330"
replace addr=subinstr(addr,"99 ","",.) if pid=="20130330"
replace natregno="620325-0177" if pid=="20130697"
replace resident=1 if pid=="20130697"
replace addr="LIGHTFOOT LN" if pid=="20130697"
replace parish=8 if pid=="20130697"
replace natregno="590419-7000" if pid=="20130684"
replace resident=1 if pid=="20130684"
replace addr=subinstr(addr,"99 ","",.) if pid=="20130684"
replace natregno="640321-0021" if pid=="20130642"
replace resident=1 if pid=="20130642"
replace addr="ST STEPHENS HILL BLACK ROCK" if pid=="20130642"
replace parish=8 if pid=="20130642"
replace natregno="630821-0043" if pid=="20130354"
replace resident=1 if pid=="20130354"
replace addr="RISK RD FITTS VLGE" if pid=="20130354"
replace parish=4 if pid=="20130354"
replace natregno="590614-0040" if pid=="20130360"
replace resident=1 if pid=="20130360"
replace addr="WILSON VLGE LODGE RD" if pid=="20130360"
replace parish=1 if pid=="20130360"
replace natregno="460201-7024" if pid=="20130280"
replace resident=1 if pid=="20130280"
replace addr="1 PANGOLA COURT FRERE PILGRM/159 REGENCY PK" if pid=="20130280"
replace parish=1 if pid=="20130280"
replace natregno="500906-0061" if pid=="20130294"
replace resident=1 if pid=="20130294"
replace addr="93 WANSTEAD TERR" if pid=="20130294"
replace parish=4 if pid=="20130294"
replace natregno="380107-0024" if pid=="20130304"
replace resident=1 if pid=="20130304"
replace addr="ELLERTON" if pid=="20130304"
replace parish=3 if pid=="20130304"
replace natregno="521117-0104" if pid=="20130804"
replace resident=1 if pid=="20130804"
replace addr="CHARNOCKS" if pid=="20130804"
replace parish=1 if pid=="20130804"
replace resident=1 if pid=="20130601"
replace natregno="590421-0076" if pid=="20130816"
replace resident=1 if pid=="20130816"
replace addr="KEW ROAD BANK HALL" if pid=="20130816"
replace parish=8 if pid=="20130816"
replace lname=subinstr(lname,"er","ar",.) if pid=="20130816"
replace natregno="790903-0129" if pid=="20130334"
replace resident=1 if pid=="20130334"
replace addr="CHECKER HALL" if pid=="20130334"
replace parish=7 if pid=="20130334"
replace natregno="790301-8005" if pid=="20130311"
replace resident=1 if pid=="20130311"
replace addr=subinstr(addr,"99 ","",.) if pid=="20130311"
replace natregno="541203-7029" if pid=="20130302"
replace resident=1 if pid=="20130302"
replace addr="MORAVIAN GDNS MAXWELL" if pid=="20130302"
replace parish=1 if pid=="20130302"
replace natregno="481220-0089" if pid=="20130810"
replace resident=1 if pid=="20130810"
replace addr="55 ROCK DUNDO PARK" if pid=="20130810"
replace parish=8 if pid=="20130810"
replace natregno="600425-0160" if pid=="20130329"
replace resident=1 if pid=="20130329"
replace addr=subinstr(addr,"99","134",.) if pid=="20130329"
replace natregno="350123-0019" if pid=="20130747"
replace resident=1 if pid=="20130747"
replace addr="FAIRWAYS GDNS #2" if pid=="20130747"
replace parish=1 if pid=="20130747"
replace natregno="531115-0055" if pid=="20130791"
replace resident=1 if pid=="20130791"
replace fname=subinstr(fname,"n","u",.) if pid=="20130791"
replace fname=subinstr(fname,"se","d",.) if pid=="20130791"
replace dxyr=2012 if pid=="20130791"
replace dot=d(30jun2012) if pid=="20130791"
replace recstatus=3 if pid=="20130791"
replace natregno="801128-0149" if pid=="20130698"
replace resident=1 if pid=="20130698"
replace addr="MOUNT HILLABY" if pid=="20130698"
replace parish=2 if pid=="20130698"
replace natregno="630830-0182" if pid=="20130414"
replace resident=1 if pid=="20130414"
replace addr="REDMAN'S VILLAGE" if pid=="20130414"
swapval fname lname if pid=="20130414" //ssc install swapval
replace resident=1 if pid=="20130333"
replace natregno="380228-0150" if pid=="20130882"
replace resident=1 if pid=="20130882"
replace addr="50 CHECKER HALL" if pid=="20130882"
replace parish=7 if pid=="20130882"
replace natregno="390906-0018" if pid=="20130306"
replace resident=1 if pid=="20130306"
replace natregno="390107-7002" if pid=="20130314"
replace resident=1 if pid=="20130314"
replace natregno="410502-7025" if pid=="20130794"
replace resident=1 if pid=="20130794"
replace natregno="160729-0028" if pid=="20130290"
replace resident=1 if pid=="20130290"
replace addr="BOTTOM CLOSE WILDEY" if pid=="20130290"
replace parish=8 if pid=="20130290"
replace resident=1 if pid=="20130399"
replace resident=1 if pid=="20130724"
replace basis=8 if pid=="20130724"
replace natregno="651207-0142" if pid=="20130364"
replace resident=1 if pid=="20130364"
replace addr="PARKS RD" if pid=="20130364"
replace parish=6 if pid=="20130364"
tab resident ,m //75 unk

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 2 are 100+

** Check for missing follow-up
label drop slc_lab
label define slc_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 99 "Unknown", modify
label values slc slc_lab
replace slc=99 if slc==9 //0 changes
tab slc ,m //none missing
tab dlc ,m //none missing
** Check missing in CR5db
//list pid if slc==99

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m

replace dcostatus=1 if slc==2 //457 changes
replace dcostatus=6 if slc!=2 //388 changes
replace dcostatus=2 if basis==0 //43 changes

** Check for ineligibles
tab recstatus ,m //1 ineligible

** Check for non-malignant
tab beh ,m //9 in-situ
tab morph if beh!=3 //9 CIN III

** Check for duplicate tumours
tab persearch ,m //101 excluded; 64 duplicate

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //47
//list pid age natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
gen birthd=substr(natregno,1,6) if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
destring birthd, replace
format birthd %06.0f
nsplit birthd, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring year, replace
replace year="19"+year
destring year, replace
gen dob2=mdy(month, day, year)
format dob2 %dD_m_CY
replace dob=dob2 if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //47 changes
drop birthd year month day dob2

** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //23
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //23 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m 

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //547 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

count //871

** Save this corrected dataset with BNR reportable cases
save "`datapath'\version02\2-working\2013_cancer_nonsurvival_bnr_reportable", replace
label data "2013 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
duplicates tag pid, gen(dup_id)
list pid cr5id if persearch==1 & (resident==2|resident==99|recstatus==3|sex==9|beh!=3|siteiarc==25), nolabel sepby(pid)
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //75 deleted - resident unknown
drop if recstatus==3 //1 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //7 deleted - nonmalignant
drop if persearch>2 //2 to be deleted
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //786

** Save this corrected dataset with only internationally reportable cases
save "`datapath'\version02\2-working\2013_cancer_nonsurvival_intl_reportable", replace
label data "2013 BNR-Cancer analysed data - Non-survival International Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

clear

*******************************************
** 2008, 2013, 2014 Non-survival Dataset **
*******************************************
** This done before 2015 data prepared so can be used by NS at CARPHA
** Load the dataset (2008)
use "`datapath'\version02\2-working\2008_cancer_nonsurvival_bnr_reportable", replace
count //803; 1211

append using "`datapath'\version02\2-working\2014_cancer_nonsurvival_bnr_reportable"
count //1633; 2093
append using "`datapath'\version02\2-working\2013_cancer_nonsurvival_bnr_reportable"
count //2419; 2964

tab dxyr ,m 

** Check for duplicates and/or MPs
sort natregno lname fname pid
quietly by natregno :  gen dupnrn = cond(_N==1,0,_n)
sort natregno
count if dupnrn>0 //87 - check pid in Stata results then primarysite & cod1a in Stata data editor
sort lname fname pid
order pid fname lname natregno sex age primarysite cod1a
list pid deathid fname lname natregno sex age persearch nm if dupnrn>0

sort lname fname pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //107 - check pid in Stata results then  primarysite & cod1a in Stata data editor for ones not matched in above list
sort lname fname pid
order pid fname lname natregno sex age primarysite cod1a
list pid deathid fname lname natregno sex age persearch nm if duppt>0
replace nm=1 if pid=="20080092"
replace nm=1 if pid=="20080959"
replace nm=1 if pid=="20080878"
replace nm=1 if pid=="20130187"
replace nm=1 if pid=="20080334"
replace nm=1 if pid=="20130886"
replace nm=1 if pid=="20080579"
replace nm=1 if pid=="20141553"
replace nm=1 if pid=="20130534"
replace nm=1 if pid=="20130836"
replace nm=1 if pid=="20130546"
replace nm=1 if pid=="20080081"
replace nm=1 if pid=="20081017"
replace nm=1 if pid=="20130171"
replace nm=1 if pid=="20130775"
replace nm=1 if pid=="20080296"
replace nm=1 if pid=="20080558"
replace nm=1 if pid=="20130426"
replace nm=1 if pid=="20130549"
replace nm=1 if pid=="20130232"
replace nm=1 if pid=="20130813"
replace nm=1 if pid=="20130695"
replace dlc=dod if pid=="20130886"

** Check deceased
tab deceased slc ,m 
count if deceased==2 & slc==2 //5 
count if deceased==1 & slc==1 //0
//list pid fname lname natregno dlc dod if deceased==2 & slc==2
replace dod=dlc if pid=="20130331" //1 change
replace deceased=1 if deceased==2 & slc==2 //5 changes

sort dot pid
export delimited pid mpseq sex topography morph beh grade basis dot_iarc dob_iarc age cr5id eidmp persearch ///
using "`datapath'\version02\2-working\2008_2013_2014_nonsurvival_iarccrgtools.txt", nolabel replace

** Perform MP check to identify MPs in 'multi-year' dataset and correctly assign persearch and mpseq
/*
IARC crg Tools - see SOP for steps on how to perform below checks:

(1) Perform file transfer using '2008_nonsuvival_iarccrgtools.txt'
(2) Perform check using '2008_iarccrgtools_to check.prn'
(3) Perform multiple primary check using ''

Results of IARC Check Program:
(Titles for each data column: pid sex top morph beh grade basis dot dob age)
    2419 records processed
	1 errors
        
	106 warnings
        - 19 unlikely hx/site
		- 38 unlikely grade/hx
        - 49 unlikely basis/hx
*/
/*	
Results of IARC MP Program:
	0 excluded (non-malignant)
	72 MPs (multiple tumours)
	 1 Duplicate registration
*/
** Updates from errors report
replace age=89 if pid=="20080887"
** Updates from warnings report

** Updates for multiple primary report:
replace patient=2 if pid=="20130294" & cr5id=="T2S1"
replace eidmp=2 if pid=="20130294" & cr5id=="T2S1"
replace persearch=2 if pid=="20130294" & cr5id=="T2S1"
replace patient=2 if pid=="20130275" & cr5id=="T3S1"
replace eidmp=2 if pid=="20130275" & cr5id=="T3S1"
replace persearch=2 if pid=="20130275" & cr5id=="T3S1"
replace patient=2 if pid=="20130175" & cr5id=="T2S1"
replace eidmp=2 if pid=="20130175" & cr5id=="T2S1"
replace persearch=2 if pid=="20130175" & cr5id=="T2S1"
replace patient=2 if pid=="20130162" & cr5id=="T2S1"
replace eidmp=2 if pid=="20130162" & cr5id=="T2S1"
replace persearch=2 if pid=="20130162" & cr5id=="T2S1"
replace patient=2 if pid=="20080690" & cr5id=="T3S1"
replace eidmp=2 if pid=="20080690" & cr5id=="T3S1"
replace persearch=2 if pid=="20080690" & cr5id=="T3S1"
replace patient=2 if pid=="20080636" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080636" & cr5id=="T2S1" //0 changes
replace persearch=2 if pid=="20080636" & cr5id=="T2S1"
replace patient=2 if pid=="20080539" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080539" & cr5id=="T2S1" //0 changes
replace persearch=2 if pid=="20080539" & cr5id=="T2S1"
replace patient=2 if pid=="20080401" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080401" & cr5id=="T2S1"
replace persearch=2 if pid=="20080401" & cr5id=="T2S1"
replace patient=2 if pid=="20080340" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080340" & cr5id=="T2S1" //0 changes
replace persearch=2 if pid=="20080340" & cr5id=="T2S1"
replace patient=2 if pid=="20080242" & cr5id=="T2S1"
replace eidmp=2 if pid=="20080242" & cr5id=="T2S1"
replace persearch=2 if pid=="20080242" & cr5id=="T2S1"
replace persearch=3 if pid=="20080196" & cr5id=="T2S1" //1 change

tab persearch ,m

** Check parish
count if parish!=. & parish!=99 & addr=="" //0
count if parish==. & addr!="" & addr!="99" //0
//list pid fname lname natregno parish addr if parish!=. & parish!=99 & addr==""

** Check missing sex
tab sex ,m //none missing

** Check for missing age & 100+
tab age ,m //none missing - 3 are 100+

** Check for missing follow-up
tab slc ,m //none missing
tab deceased ,m //none missing and parallels slc correctly
tab dlc ,m //none missing
** Check missing in CR5db
//list pid if slc==99

** Check DCOs
tab basis ,m
** Re-assign dcostatus for cases with updated death trace-back
tab dcostatus ,m
//list pid basis dcostatus if basis==0 & dcostatus!=2
replace dcostatus=2 if pid=="20140339" & cr5id=="T2S1"
replace dcostatus=2 if pid=="20140526" & cr5id=="T2S1"

replace dcostatus=1 if slc==2 & basis!=0 //0 changes
replace dcostatus=6 if slc!=2 //8 changes
replace dcostatus=2 if basis==0 //0 changes

** Check for ineligibles
tab recstatus ,m //1 ineligible

** Check for non-malignant
tab beh ,m //0 in-situ

** Check for duplicate tumours
tab persearch ,m //1 duplicate

** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //0
//list pid age natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
/*
gen birthd=substr(natregno,1,6) if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
destring birthd, replace
format birthd %06.0f
nsplit birthd, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring year, replace
replace year="19"+year
destring year, replace
gen dob2=mdy(month, day, year)
format dob2 %dD_m_CY
replace dob=dob2 if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //47 changes
drop birthd year month day dob2
*/

** Check age
gen age2 = (dot - dob)/365.25
drop checkage2
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //3
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //3 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m 

** Format dataset in prep for match with death data
replace natregno=subinstr(natregno,"-","",.)
rename address address_cancer
replace addr=subinstr(addr,"9999 ","",.)
replace addr=subinstr(addr,"99 ","",.)
count if regexm(address,"99") //0 - didn't replace true value for house #=99
rename cod1a cod1a_cancer
count if cancer==. & slc==2 //16
//list pid deathid fname lname natregno dod if cancer==. & slc==2
replace deathid=6410180084 if pid=="20130331"
replace cancer=2 if pid=="20130331"
replace deathid=6410180084 if pid=="20080885"
replace cancer=1 if pid=="20080885"
gen notindd=1 if cancer==. & slc==2 //14
replace notindd=2 if pid=="20130331"|pid=="20080885"
label var notindd "Not found in death data"
label define notindd_lab 1 "Searched, not found" 2 "Searched, found", modify
label values notindd notindd_lab
count if cancer!=. & slc!=2 //387
//list pid deathid fname lname natregno dod if cancer!=. & slc!=2
replace cancer=. if cancer!=. & slc!=2 //387 changes

drop dodyear
gen dodyear_cancer=year(dod)
tab dodyear ,m

drop dotyear
gen dotyear=year(dot)
tab dotyear ,m

** To match with 2014 format, convert names to lower case and strip possible leading/trailing blanks
replace fname = lower(rtrim(ltrim(itrim(fname)))) //0 changes
replace init = lower(rtrim(ltrim(itrim(init)))) //0 changes
replace mname = lower(rtrim(ltrim(itrim(mname)))) //0 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //0 changes

** Remove unnecessary variables
drop dotyear2 dupnrn duppt checkage2

count //2419; 2964

** Save this corrected dataset with BNR reportable cases
save "`datapath'\version02\2-working\2008_2013_2014_cancer_nonsurvival_bnr_reportable_prematch", replace
label data "2008 2013 2014 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report

** Removing cases not included for reporting: if case with MPs ensure record with persearch=1 is not dropped as used in survival dataset
//drop dup_id
sort pid
duplicates tag pid, gen(dup_id)
list pid cr5id patient eidmp persearch if dup_id>0, nolabel sepby(pid)
drop if resident==2 //0 deleted - nonresident
drop if resident==99 //0 deleted - resident unknown
drop if recstatus==3 //0 deleted - ineligible case definition
drop if sex==9 //0 deleted - sex unknown
drop if beh!=3 //0 deleted - nonmalignant
drop if persearch>2 //1 to be deleted
drop if siteiarc==25 //0 deleted - nonreportable skin cancers

count //2418

** Save this corrected dataset with only internationally reportable cases
save "`datapath'\version02\2-working\2008_2013_2014_cancer_nonsurvival_intl_reportable", replace
label data "2008 2013 2014 BNR-Cancer analysed data - Non-survival International Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs


********************
** Death Matching **
********************
** Match with most current death data (2017, 2018) - note some 2017 deaths found after previous 2017 matching

** LOAD the 2008-2014 cancer_prematch (multi-year) dataset
use "`datapath'\version02\2-working\2008_2013_2014_cancer_nonsurvival_bnr_reportable_prematch", replace

count //2964

drop _merge
drop nrn
rename natregno nrn
destring nrn,replace
format nrn %12.0g
tostring certifieraddr,replace
//list pid deathid fname lname slc redcap_event_name if slc==2
count if slc==2 & redcap_event_name!="" //997; 1091
gen matchdone=1 if slc==2 & redcap_event_name!=""
gen record_id=.

** Merge - best to merge without age!
merge m:1 lname fname sex dod using "`datapath'\version02\3-output\2017-2018_deaths_for_matching"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         7,354
        from master                     2,358  (_merge==1)
        from using                      4,996  (_merge==2)

    matched                                60  (_merge==3)
    -----------------------------------------
Below ran after change to non-reportable vs reportable datasets:
    Result                           # of obs.
    -----------------------------------------
    not matched                         7,893
        from master                     2,900  (_merge==1)
        from using                      4,993  (_merge==2)

    matched                                64  (_merge==3)
    -----------------------------------------
*/
//list pid deathid record_id fname lname slc matchdone if _merge==3
count if matchdone==1 & _merge==3 //30; 34

preserve
drop if slc==2 //1494 deleted

sort lname fname record_id pid
quietly by lname fname :  gen duppt = cond(_N==1,0,_n)
sort lname fname
count if duppt>0 //334; 483
sort lname fname pid
order pid fname lname nrn sex age primarysite dds2coddeath
//list pid record_id fname lname nrn addr dds2address if duppt>0, string(38)

** Check for matches
sort nrn lname fname pid
quietly by nrn :  gen dupnrn = cond(_N==1,0,_n)
sort nrn
count if dupnrn>0 //406; 649
sort lname fname pid
order pid fname lname nrn sex age primarysite dds2coddeath
//list pid record_id fname lname nrn addr dds2address if dupnrn>0 & nrn!=. & nrn!=9999999999, string(38)
restore

** Add record_id to cancer cases so records can be merged
** name match
replace record_id=22247 if pid=="20140844"
replace record_id=24588 if pid=="20141257"
replace record_id=24271 if pid=="20130678"
replace record_id=24658 if pid=="20141405"
replace record_id=24817 if pid=="20140872"
replace record_id=25223 if pid=="20130152"
replace record_id=25006 if pid=="20145095"
replace record_id=25055 if pid=="20130040"
replace record_id=25155 if pid=="20140889"
replace record_id=26707 if pid=="20130850"
replace record_id=25768 if pid=="20145020"
replace record_id=25211 if pid=="20080014"
replace record_id=26907 if pid=="20140911"
replace record_id=25560 if pid=="20080124"
replace record_id=24986 if pid=="20141521"
replace record_id=25408 if pid=="20145043"
replace record_id=25628 if pid=="20130137"
replace record_id=24446 if pid=="20140975"
replace record_id=26540 if pid=="20080028"
replace record_id=24534 if pid=="20080151"
replace record_id=24207 if pid=="20140993"
replace record_id=25100 if pid=="20140996"
replace record_id=25496 if pid=="20080035"
replace record_id=26323 if pid=="20140961"
replace record_id=24717 if pid=="20141203"
replace record_id=25088 if pid=="20140701"
replace record_id=26354 if pid=="20141180"
replace record_id=24200 if pid=="20080241"
replace record_id=25732 if pid=="20141359"
replace record_id=24544 if pid=="20130018"
replace record_id=24899 if pid=="20141195"
replace record_id=24972 if pid=="20141249"
replace record_id=26449 if pid=="20145171"
replace record_id=25656 if pid=="20140720"
replace record_id=24619 if pid=="20140684"
replace record_id=25921 if pid=="20130144"
replace record_id=26271 if pid=="20080248"
replace record_id=23556 if pid=="20130816"
replace record_id=23504 if pid=="20141316"
replace record_id=25853 if pid=="20130060"
replace record_id=24468 if pid=="20141058"
replace record_id=25858 if pid=="20141059"
replace record_id=25971 if pid=="20130126"
replace record_id=26150 if pid=="20130028"
replace record_id=24193 if pid=="20145015"
replace record_id=26600 if pid=="20130012"
replace record_id=25622 if pid=="20080069"
replace record_id=26672 if pid=="20141107"
replace record_id=22549 if pid=="20141114"
replace record_id=26333 if pid=="20141116"
replace record_id=25894 if pid=="20080555"
replace record_id=25751 if pid=="20130046"
replace record_id=25822 if pid=="20130820"
replace record_id=26636 if pid=="20140687"
replace record_id=24591 if pid=="20130866"
replace record_id=25331 if pid=="20130806"
** nrn match
replace record_id=25325 if pid=="20141451"
replace record_id=26241 if pid=="20145106"
replace record_id=26473 if pid=="20141361"
replace mname="donald" if pid=="20130272"
replace mname="donald" if record_id==25356
replace fname="" if pid=="20130272"
replace record_id=25356 if pid=="20130272"
bysort nrn (record_id) : replace fname = fname[_n-1] if missing(fname) //1 change
replace record_id=26342 if pid=="20080184"
replace record_id=26615 if pid=="20130045"
replace record_id=24774 if pid=="20141134"


** Remove merged death dataset
drop if _merge==2 //4996; 4993 deleted
rename nrn natregno
drop _merge
drop dds2*

count //2418; 2964

** Merge again - use record_id this time
merge m:1 record_id using "`datapath'\version02\3-output\2017-2018_deaths_for_matching"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         7,346
        from master                     2,355  (_merge==1)
        from using                      4,991  (_merge==2)

    matched                                63  (_merge==3)
    -----------------------------------------
Ran below after switching non-reportable vs reportable datasets

    Result                           # of obs.
    -----------------------------------------
    not matched                         7,892
        from master                     2,901  (_merge==1)
        from using                      4,991  (_merge==2)

    matched                                63  (_merge==3)
    -----------------------------------------
*/
replace slc=2 if _merge==3 //63 changes
replace dod=dds2dod if _merge==3 //63 changes
replace dlc=dod if _merge==3 //63 changes
replace deathid=record_id if _merge==3 //63 changes
replace cancer=dds2cancer if _merge==3 //63 changes
replace deceased=1 if _merge==3 //63 changes
replace dcostatus=1 if _merge==3 //63 changes
tab dcostatus ,m

*********************
** UNMATCHED DATA: **
**     CANCER      **
**     DEATHS	   **
*********************
** (1) CHECK FOR CANCER DEATHS 2017-2018 THAT HAVE NOT MERGED WTIH A NATIONAL DEATH
count if slc==2 //1557 (=1494+63 merged); 1657
count if deathid==. & slc==2 //19; 20
count if record_id!=. & slc==2 //63
count if deathid!=. & slc==2 //1538; 1637
replace deathid=. if record_id!=. & slc==2 //63 changes
replace deathid=record_id if record_id!=. & slc==2 //63 changes
tab _merge if deathid==. & slc==2 //19; 20 master only
count if record_id==. & pid!="" & slc==2 //1494; 1594
replace deathid=12931 if pid=="20130331" //1

** (2) Visually check unmerged cancer and deaths (not done as of 17nov2019)
sort lname fname pid record_id
//cancer list
count if slc!=2 & _merge==1 //861; 1307
//list pid fname lname natregno addr if slc!=2 & _merge==1, noobs
//death list
count if _merge==2 //4991
/*
list record_id fname lname nrn if _merge==2 //full list
list record_id fname lname nrn if regexm(lname, "^a") & _merge==2 | regexm(lname, "^b") & _merge==2 | regexm(lname, "^c") & _merge==2
list record_id fname lname nrn if regexm(lname, "^d") & _merge==2 | regexm(lname, "^e") & _merge==2 | regexm(lname, "^f") & _merge==2
list record_id fname lname nrn dds2address if regexm(lname, "^g") & _merge==2 | regexm(lname, "^h") & _merge==2 | regexm(lname, "^i") & _merge==2
list record_id fname lname nrn if regexm(lname, "^j") & _merge==2 | regexm(lname, "^k") & _merge==2 | regexm(lname, "^l") & _merge==2
list record_id fname lname nrn if regexm(lname, "^m") & _merge==2 | regexm(lname, "^n") & _merge==2 | regexm(lname, "^o") & _merge==2
list record_id fname lname nrn if regexm(lname, "^p") & _merge==2 | regexm(lname, "^q") & _merge==2 | regexm(lname, "^r") & _merge==2
list record_id fname lname nrn if regexm(lname, "^s") & _merge==2 | regexm(lname, "^t") & _merge==2 | regexm(lname, "^u") & _merge==2
list record_id fname lname nrn if regexm(lname, "^v") & _merge==2 | regexm(lname, "^w") & _merge==2 | regexm(lname, "^x") & _merge==2 ///
								| regexm(lname, "^y") & _merge==2 | regexm(lname, "^z") & _merge==2
*/
drop if _merge==2 //4991 deleted

count //2418; 2964

** Check analysis variables are correct
tab deceased ,m 
tab deceased if slc==2 //1557; 1657

count if dod==. & slc==2 //0
tab slc ,m //1557; 1657

** Check patient, eidmp, persearch
tab patient ,m 
tab persearch ,m 
tab eidmp ,m 
count if patient==2 & persearch==1 //1
//list pid fname lname if patient==2 & persearch==1
replace patient=1 if pid=="20140490" //1 change
replace eidmp=1 if pid=="20140490" //1 change

** Check NRN
count if natregno==. & nrn!=. //0
count if natregno!=. & nrn!=. & natregno!=nrn //4
list pid deathid natregno nrn if natregno!=. & nrn!=. & natregno!=nrn //3 are transcription errors so leave as mismatched
replace natregno=nrn if pid=="20140975" //1 change
gen nrn2=natregno
tostring natregno,replace
count if natregno!="" & length(natregno)!=10 //18; 19
//list pid deathid dot natregno nrn dob age if natregno!="" & length(natregno)!=10
replace natregno=subinstr(natregno,"9","09",.) if pid=="20140048"
replace natregno=subinstr(natregno,"9","09",.) if pid=="20080797"
replace natregno=subinstr(natregno,"8","08",.) if pid=="20130801"
replace natregno=subinstr(natregno,"9","09",.) if pid=="20140827"
replace natregno=subinstr(natregno,"3","03",.) if pid=="20130694"
replace natregno=subinstr(natregno,"5","05",.) if pid=="20140434"
replace natregno=subinstr(natregno,"8","08",.) if pid=="20140817"
replace natregno=subinstr(natregno,"9","09",.) if pid=="20080146"
replace natregno=subinstr(natregno,"505","0505",.) if pid=="20140699"
replace natregno=subinstr(natregno,"3","03",.) if pid=="20140826"
replace natregno=subinstr(natregno,"111","000111",.) if pid=="20130072"
replace natregno=subinstr(natregno,"8","08",.) if pid=="20080089"
replace natregno=subinstr(natregno,"909","0909",.) if pid=="20130084"
replace natregno=subinstr(natregno,"2","02",.) if pid=="20130373"
replace natregno=subinstr(natregno,"91","091",.) if pid=="20130369"
replace natregno=subinstr(natregno,"7","07",.) if pid=="20080315"
replace natregno=subinstr(natregno,"5","05",.) if pid=="20080867"
replace natregno=subinstr(natregno,"303","0303",.) if pid=="20080703"
replace natregno=subinstr(natregno,"99","112",.) if pid=="20080637"
replace natregno=subinstr(natregno,"041","611",.) if pid=="20080637"
replace natregno=subinstr(natregno,"26","56",.) if pid=="20080637"


** Check dob
count if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*")) //1
//list pid age natregno if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*9999*"))
gen birthd=substr(natregno,1,6) if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*"))
destring birthd, replace
format birthd %06.0f
nsplit birthd, digits(2 2 2) gen(year month day)
format year month day %02.0f
tostring year, replace
replace year="19"+year
destring year, replace
gen dob2=mdy(month, day, year)
format dob2 %dD_m_CY
replace dob=dob2 if dob==. & natregno!="" & !(strmatch(strupper(natregno), "*99-*")) //1 change
drop birthd year month day dob2

** Check age
gen age2 = (dot - dob)/365.25
gen checkage2=int(age2)
drop age2
count if dob!=. & dot!=. & age!=checkage2 //0
//list pid dot dob age checkage2 cr5id if dob!=. & dot!=. & age!=checkage2 //0 correct
replace age=checkage2 if dob!=. & dot!=. & age!=checkage2 //0 changes

** Check no missing dxyr so this can be used in analysis
tab dxyr ,m 

count if dodyear_cancer!=year(dod) //63
//list pid deathid dod dodyear_cancer if dodyear!=year(dod)
replace dodyear_cancer=year(dod) if dodyear_cancer!=year(dod) //63 changes

tab dotyear ,m

tab recstatus ,m //2 ineligible

drop if recstatus==3 //2 deleted

rename nm namematch
rename dodyear_cancer dodyear

** Picked up some cases corrections incidentally while reviewing 2015 data
replace dot=d(30jun2012) if pid=="20141523" //1 change
replace dxyr=2012 if pid=="20141523" //1 change
replace recstatus=3 if pid=="20141523" //1 change
drop if pid=="20141523" //1 deleted

replace dlc=d(08apr2015) if pid=="20080563" //1 change

replace slc=2 if pid=="20080169" //1 change
replace dlc=d(17jun2015) if pid=="20080169" //1 change

replace slc=2 if pid=="20080336" //0 changes
replace dlc=d(08mar2015) if pid=="20080336" //0 changes

** Remove variables not needed in final dataset
drop checkage2 nrn2 dds2recstatdc dds2tfdddoa dds2tfddda dds2tfregnumstart dds2tfdistrictstart dds2tfregnumend dds2tfdistrictend dds2tfddtxt dds2recstattf dds2duprec dds2dupname dds2dupdod dds2dodyear

count //2961

** Save this corrected dataset with only BNR reportable cases
save "`datapath'\version02\3-output\2008_2013_2014_cancer_nonsurvival_bnr_reportable", replace
label data "2008 2013 2014 BNR-Cancer analysed data - Non-survival BNR Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          45_prep cross-check.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      26-MAY-2021
    // 	date last modified      27-MAY-2021
    //  algorithm task          Matching uncleaned, current cancer dataset with cleaned cancer dataset
    //  status                  Completed
    //  objective               To have a uncleaned but prepared dataset with no duplicate sources to merge with cleaned dataset
	//							To check and update any changes to the cleaned data done by DAs post cleaning.
    //  methods                 Using same prep code from 15_clean cancer.do but appending "_2" to variable names

    ** General algorithm set-up
    version 16.1
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p117

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\45_prep cross-check.smcl", replace
** HEADER -----------------------------------------------------

* ************************************************************************
* PREP AND FORMAT
**************************************************************************

/*
 To prepare cancer dataset:
 (1) import into excel the .txt files exported from CanReg5 and change the format from General to Text for the below fields in excel:
		- TumourIDSourceTable
		- SourceRecordID
		- STDataAbstractor
		- NFType
		- STReviewer
		- TumourID
		- PatientIDTumourTable
		- TTDataAbstractor
		- Parish
		- Topography
		- TTReviewer
		- RegistryNumber
		- PTDataAbstractor
		- PatientRecordID
		- RetrievalSource
		- FurtherRetrievalSource
		- PTReviewer
 (2) import the .xlsx file into Stata using XML backup 2021-05-21_KWG already saved from 2016AnnualReportV02 branch
*/
import excel using "`datapath'\version05\1-input\2021-05-21_MAIN Source+Tumour+Patient_JC_excel.xlsx", firstrow

count //16,022

** Format incidence date to create tumour year
nsplit IncidenceDate, digits(4 2 2) gen(dotyear_2 dotmonth dotday)
gen dot_2=mdy(dotmonth, dotday, dotyear)
format dot_2 %dD_m_CY
gen dotyear2 = year(dot_2)
label var dot_2 "IncidenceDate"
label var dotyear_2 "Incidence year"
drop IncidenceDate

count //16,022

** Renaming CanReg5 variables
rename Personsearch persearch_2
rename PTDataAbstractor ptda_2
rename TTDataAbstractor ttda_2
rename STDataAbstractor stda_2
rename CaseStatus cstatus_2
rename RetrievalSource retsource_2
rename FurtherRetrievalSource fretsource_2
rename NotesSeen notesseen_2
rename BirthDate birthdate_2
rename Sex sex_2
rename MiddleInitials init_2
rename FirstName fname_2
rename LastName lname_2
rename NRN natregno_2
rename ResidentStatus resident_2
rename Comments comments_2
rename PTReviewer ptreviewer_2
rename TTReviewer ttreviewer_2
rename STReviewer streviewer_2
rename MPTot mptot_2
rename MPSeq mpseq_2
rename PatientIDTumourTable patientidtumourtable_2
rename PatientRecordID pid2_2
rename RegistryNumber pid
rename TumourID eid2_2
rename Recordstatus recstatus_2
rename Checkstatus checkstatus_2
rename TumourUpdatedBy tumourupdatedby_2
rename PatientUpdatedBy patientupdatedby_2
rename SourceRecordID sid2_2
rename StatusLastContact slc_2
rename Parish parish_2
rename Address addr_2
rename Age age_2
rename PrimarySite primarysite_2
rename Topography topography_2
rename BasisOfDiagnosis basis_2
rename Histology hx_2
rename Morphology morph_2
rename Laterality lat_2
rename Behaviour beh_2
rename Grade grade_2
rename TNMCatStage tnmcatstage_2
rename TNMAntStage tnmantstage_2
rename EssTNMCatStage esstnmcatstage_2
rename EssTNMAntStage esstnmantstage_2
rename SummaryStaging staging_2
rename Consultant consultant_2
rename HospitalNumber hospnum_2
rename CausesOfDeath cr5cod_2
rename DiagnosisYear dxyr_2
rename Treat*1 rx1_2
rename Treat*2 rx2_2
rename Treat*3 rx3_2
rename Treat*4 rx4_2
rename Treat*5 rx5_2
rename Oth*Treat*1 orx1_2
rename Oth*Treat*2 orx2_2
rename NoTreat*1 norx1_2
rename NoTreat*2 norx2_2
rename NFType nftype_2
rename SourceName sourcename_2
rename Doctor doctor_2
rename DoctorAddress docaddr_2
rename RecordNumber recnum_2
rename CFDiagnosis cfdx_2
rename LabNumber labnum_2
rename Specimen specimen_2
rename ClinicalDetails clindets_2
rename CytologicalFindings cytofinds_2
rename MicroscopicDescription md_2
rename ConsultationReport consrpt_2
rename DurationOfIllness duration_2
rename OnsetDeathInterval onsetint_2
rename Certifier certifier_2
rename TumourIDSourceTable tumouridsourcetable_2
rename SurgicalFindings SurgicalFindings_2
rename SurgicalFindingsDate SurgicalFindingsDate_2
rename ImagingResults ImagingResults_2
rename ImagingResultsDate ImagingResultsDate_2
rename PhysicalExam PhysicalExam_2
rename PhysicalExamDate PhysicalExamDate_2
rename cr5id cr5id_2
rename MultiplePrimary MultiplePrimary_2 
rename ObsoleteFlagTumourTable ObsoleteFlagTumourTable_2
rename PatientRecordIDTumourTable PatientRecordIDTumourTable_2
rename TumourUnduplicationStatus TumourUnduplicationStatus_2
rename DuplicateCheck DuplicateCheck_2
rename ICCCcode ICCCcode_2
rename ICD10 ICD10_2
rename ObsoleteFlagPatientTable ObsoleteFlagPatientTable_2
rename PatientRecordStatus PatientRecordStatus_2
rename PatientCheckStatus PatientCheckStatus_2

/*
Creating and formatting various record IDs auto-generated by CanReg5 which uniquely identify patients (pid), tumours (eid) and sources (sid)
Note: When records are merged in CanReg5, the following can take place:
1) the pid can be kept so in these cases patientrecordid will differentiate between the 2 patient records for the same patient and/or
2) the first 8 digits in tumourid remains the same as the defunct (i.e. no longer used) pid while the new pid will be the pid into which
   that tumour was merged e.g. 20130303 has 2 tumours with different tumourids - 201303030102 and 201407170101.
*/
gen top_2 = topography_2
destring topography_2, replace

gen str_sourcerecordid_2=sid2_2
gen sourcetotal_2 = substr(str_sourcerecordid_2,-1,1)
destring sourcetotal_2, gen (sourcetot_2)

gen str_pid2_2 = pid2_2
gen patienttotal_2 = substr(str_pid2_2,-1,1)
destring patienttotal_2, gen (patienttot_2)
gen str_patientidtumourtable_2=patientidtumourtable_2

gen mpseq2_2=mpseq_2
replace mpseq2_2=1 if mpseq2_2==0
tostring mpseq2_2, replace
gen eid_2 = str_patientidtumourtable_2 + "010" + mpseq2_2

gen sourceseq_2 = substr(str_sourcerecordid_2,13,2)
gen sid_2 = eid_2 + sourceseq_2


**********************************************************
** NAMING & FORMATTING - PATIENT TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 2_flag_cancer.do
**********************************************************

** Unique PatientID
label var pid "Registry Number"

** Person Search
label var persearch_2 "Person Search"
label define persearch_2_lab 0 "Not done" 1 "Done: OK" 2 "Done: MP" 3 "Done: Duplicate" 4 "Done: Non-IARC MP", modify
label values persearch_2 persearch_2_lab

** Patient record updated by
label var patientupdatedby_2 "PT updated by"

** Date patient record updated
nsplit PatientUpdateDate, digits(4 2 2) gen(year month day)
gen ptupdate_2=mdy(month, day, year)
format ptupdate_2 %dD_m_CY
drop day month year PatientUpdateDate
label var ptupdate_2 "Date PT updated"

** PT Data Abstractor
** contains non-numeric character so need to find and correct
generate byte non_numeric_ptda_2 = indexnot(ptda_2, "0123456789.-")
count if non_numeric_ptda_2 //2
//list pid ptda cr5id if non_numeric_ptda
replace ptda_2="09" if pid=="20145017"
destring ptda_2,replace
count if ptda_2==. //1
//list pid ptda cr5id if ptda==.
replace ptda_2=9 if ptda_2==.
label var ptda_2 "PTDataAbstractor"
label define ptda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ptda_2 ptda_2_lab

** Casefinding Date
replace PTCasefindingDate=20000101 if PTCasefindingDate==99999999
nsplit PTCasefindingDate, digits(4 2 2) gen(year month day)
gen ptdoa_2=mdy(month, day, year)
format ptdoa_2 %dD_m_CY
drop day month year PTCasefindingDate
label var ptdoa_2 "PTCasefindingDate"

** Case Status
label var cstatus_2 "CaseStatus"
label define cstatus_2_lab 0 "CF" 1 "ABS" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" 5 "Pending CD Review", modify
label values cstatus_2 cstatus_2_lab

** Retrieval Source
destring retsource_2, replace
label var retsource_2 "RetrievalSource"
label define retsource_2_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values retsource_2 retsource_2_lab

** Notes Seen
label var notesseen_2 "NotesSeen"
label define notesseen_2_lab 0 "Pending Retrieval" 1 "Yes" 2 "Yes-Pending Further Retrieval" 3 "No" 4 "Cannot retrieve-Year Closed" ///
						   5 "Cannot retrieve-3 attempts" 6 "Cannot retrieve-Permission not granted" 7 "Cannot retrieve-Not found by Clerk", modify
label values notesseen_2 notesseen_2_lab

** Notes Seen Date
replace NotesSeenDate=20000101 if NotesSeenDate==99999999
nsplit NotesSeenDate, digits(4 2 2) gen(year month day)
gen nsdate_2=mdy(month, day, year)
format nsdate_2 %dD_m_CY
drop day month year NotesSeenDate
label var nsdate_2 "NotesSeenDate"

** Further Retrieval Source
destring fretsource_2, replace
label var fretsource_2 "RetrievalSource"
label define fretsource_2_lab 1 "QEH Medical Records" 2 "QEH Death Records" 3 "QEH Radiotherapy Dept" 4 "QEH Colposcopy Clinic" ///
						   5 "QEH Haematology Dept" 6 "QEH Private Consulting" 7 "QEH Respiratory Unit" 8 "Bay View" ///
						   9 "Barbados Cancer Society" 10 "Private Physician" 11 "PP-I Lewis" 12 "PP-J Emtage" 13 "PP-B Lynch" ///
						   14 "PP-D Greaves" 15 "PP-S Smith Connell" 16 "PP-R Shenoy" 17 "PP-S Ferdinand" 18 "PP-T Shepherd" ///
						   19 "PP-G S Griffith" 20 "PP-J Nebhnani" 21 "PP-J Ramesh" 22 "PP-J Clarke" 23 "PP-T Laurent" ///
						   24 "PP-S Jackman" 25 "PP-W Crookendale" 26 "PP-C Warner" 27 "PP-H Thani" 28 "Polyclinic" ///
						   29 "Emergency Clinic" 30 "Nursing Home" 31 "None" 32 "Other", modify
label values fretsource_2 fretsource_2_lab

** First, Middle & Last Names
label var fname_2 "FirstName"
label var init_2 "MiddleInitials"
label var lname_2 "LastName"

** Birth Date
** Some errors in the data are preventing this date to be formatted so correct first
** Instead of using below code to correct, I manually did so 
** (removed all with unk code 99/9999/99999999, etc.) in the import excel file so this variable will import as long data type not string
/*
count if length(birthdate)<8 //22
list pid birthdate natregno if length(birthdate)<8
replace birthdate=subinstr(birthdate,"8","18",.) if pid=="20160465" & birthdate!=""
replace birthdate="" if length(birthdate)<8 //10 changes
count if birthdate=="99999999" //716
replace birthdate="" if birthdate=="99999999" //716 changes
replace birthdate = lower(rtrim(ltrim(itrim(birthdate)))) //0 changes
*/
nsplit birthdate_2, digits(4 2 2) gen(dobyear_2 dobmonth_2 dobday_2)
gen dob_2=mdy(dobmonth_2, dobday_2, dobyear_2)
format dob_2 %dD_m_CY
label var dob_2 "BirthDate"

** Sex
label var sex_2 "Sex"
label define sex_2_lab 1 "Male" 2 "Female" 9 "Unknown", modify
label values sex_2 sex_2_lab

** National Reg. No.
label var natregno_2 "NRN"

** Hospital Number
label var hospnum_2 "HospitalNumber"

** Resident Status
label var resident_2 "ResidentStatus"
label define resident_2_lab 1 "Yes" 2 "No" 9 "Unknown", modify
label values resident_2 resident_2_lab

** Status Last Contact
label var slc_2 "StatusLastContact"
label define slc_2_lab 1 "Alive" 2 "Deceased" 3 "Emigrated" 9 "Unknown", modify
label values slc_2 slc_2_lab

** Date Last Contact
replace DateLastContact=20000101 if DateLastContact==99999999
nsplit DateLastContact, digits(4 2 2) gen(year month day)
gen dlc_2=mdy(month, day, year)
format dlc_2 %dD_m_CY
drop day month year DateLastContact
label var dlc_2 "DateLastContact"

** Comments
label var comments_2 "Comments"

** PT Reviewer
destring ptreviewer_2, replace
label var ptreviewer_2 "PTReviewer"
label define ptreviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ptreviewer_2 ptreviewer_2_lab


**********************************************************
** NAMING & FORMATTING - TUMOUR TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique TumourID
label var eid_2 "TumourID"

** TT Record Status
label var recstatus_2 "TTRecordStatus"
label define recstatus_2_lab 0 "Pending" 1 "Confirmed" 2 "Deleted" 3 "Ineligible" 4 "Duplicate" , modify
label values recstatus_2 recstatus_2_lab

** TT Check Status
label var checkstatus_2 "TTCheckStatus"
label define checkstatus_2_lab 0 "Not done" 1 "Done: OK" 2 "Done: Rare" 3 "Done: Invalid" , modify
label values checkstatus_2 checkstatus_2_lab

** MP Sequence
label var mpseq_2 "MP Sequence"

** MP Total
label var mptot_2 "MP Total"

** Tumour record updated by
label var tumourupdatedby_2 "TT updated by"

** Date tumour record updated
nsplit UpdateDate, digits(4 2 2) gen(year month day)
gen ttupdate_2=mdy(month, day, year)
format ttupdate_2 %dD_m_CY
drop day month year UpdateDate
label var ttupdate_2 "Date TT updated"

** TT Data Abstractor
destring ttda_2, replace
label var ttda_2 "TTDataAbstractor"
label define ttda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values ttda_2 ttda_2_lab

** Abstraction Date
replace TTAbstractionDate=20000101 if TTAbstractionDate==99999999
nsplit TTAbstractionDate, digits(4 2 2) gen(year month day)
gen ttdoa_2=mdy(month, day, year)
format ttdoa_2 %dD_m_CY
drop day month year TTAbstractionDate
label var ttdoa_2 "TTAbstractionDate"

** Parish
destring parish_2, replace
label var parish_2 "Parish"
label define parish_2_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "Unknown", modify
label values parish_2 parish_2_lab

** Address
label var addr_2 "Address"

**	Age
label var age_2 "Age"

** Primary Site
label var primarysite_2 "PrimarySite"

** Topography
label var topography_2 "Topography"

** Histology
label var hx_2 "Histology"

** Morphology
label var morph_2 "Morphology"

** Laterality
label var lat_2 "Laterality"
label define lat_2_lab 0 "Not a paired site" 1 "Right" 2 "Left" 3 "Only one side, origin unspecified" 4 "Bilateral" ///
					 5 "Midline tumour" 8 "NA" 9 "Unknown", modify
label values lat_2 lat_2_lab

** Behaviour
label var beh_2 "Behaviour"
label define beh_2_lab 0 "Benign" 1 "Uncertain" 2 "In situ" 3 "Malignant", modify
label values beh_2 beh_2_lab

** Grade
label var grade_2 "Grade"
label define grade_2_lab 1 "(well) differentiated" 2 "(mod.) differentiated" 3 "(poor.) differentiated" ///
					   4 "undifferentiated" 5 "T-cell" 6 "B-cell" 7 "Null cell (non-T/B)" 8 "NK cell" ///
					   9 "Undetermined; NA; Not stated", modify
label values grade_2 grade_2_lab

** Basis of Diagnosis
label var basis_2 "BasisOfDiagnosis"
label define basis_2_lab 0 "DCO" 1 "Clinical only" 2 "Clinical Invest./Ult Sound" 3 "Exploratory surg./autopsy" ///
					   4 "Lab test (biochem/immuno.)" 5 "Cytology/Haem" 6 "Hx of mets" 7 "Hx of primary" ///
					   8 "Autopsy w/ Hx" 9 "Unknown", modify
label values basis_2 basis_2_lab

** TNM Categorical Stage
label var tnmcatstage_2 "TNM Cat Stage"

** TNM Anatomical Stage
label var tnmantstage_2 "TNM Ant Stage"

** Essential TNM Categorical Stage
label var esstnmcatstage_2 "Essential TNM Cat Stage"

** Essential TNM Anatomical Stage
label var esstnmantstage_2 "Essential TNM Ant Stage"

** Summary Staging
label var staging_2 "Staging"
label define staging_2_lab 0 "In situ" 1 "Localised only" 2 "Regional: direct ext." 3 "Regional: LNs only" ///
						 4 "Regional: both dir. ext & LNs" 5 "Regional: NOS" 7 "Distant site(s)/LNs" ///
						 8 "NA" 9 "Unknown; DCO case", modify
label values staging_2 staging_2_lab

** Incidence Date
** already formatted above

** Diagnosis Year
label var dxyr_2 "DiagnosisYear"
** Check for blanks as may accidentally drop 2014 cases in 2nd dofile
count if dxyr_2==. //3
list pid dot_2 ttda_2 stda_2 cr5id_2 if dxyr_2==.
replace dxyr_2=2015 if dxyr_2==. //3 changes

** Consultant
label var consultant_2 "Consultant"

** Treatments 1-5
label var rx1_2 "Treatment1"
label define rx_2_lab 0 "No treatment" 1 "Surgery" 2 "Radiotherapy" 3 "Chemotherapy" 4 "Immunotherapy" ///
					5 "Hormonotherapy" 8 "Other relevant therapy" 9 "Unknown" ,modify
label values rx1_2 rx2_2 rx3_2 rx4_2 rx5_2 rx_2_lab

label var rx2_2 "Treatment2"
label var rx3_2 "Treatment3"
label var rx4_2 "Treatment4"
label var rx5_2 "Treatment5"

** Treatments 1-5 Date
replace Treatment1Date=20000101 if Treatment1Date==99999999
nsplit Treatment1Date, digits(4 2 2) gen(rx1year_2 rx1month_2 rx1day_2)
gen rx1d_2=mdy(rx1month_2, rx1day_2, rx1year_2)
format rx1d_2 %dD_m_CY
drop Treatment1Date
label var rx1d_2 "Treatment1Date"

replace Treatment2Date=20000101 if Treatment2Date==99999999
nsplit Treatment2Date, digits(4 2 2) gen(rx2year_2 rx2month_2 rx2day_2)
gen rx2d_2=mdy(rx2month_2, rx2day_2, rx2year_2)
format rx2d_2 %dD_m_CY
drop Treatment2Date
label var rx2d_2 "Treatment2Date"

replace Treatment3Date=20000101 if Treatment3Date==99999999
nsplit Treatment3Date, digits(4 2 2) gen(rx3year_2 rx3month_2 rx3day_2)
gen rx3d_2=mdy(rx3month_2, rx3day_2, rx3year_2)
format rx3d_2 %dD_m_CY
drop Treatment3Date
label var rx3d_2 "Treatment3Date"

replace Treatment4Date=20000101 if Treatment4Date==99999999
nsplit Treatment4Date, digits(4 2 2) gen(rx4year_2 rx4month_2 rx4day_2)
gen rx4d_2=mdy(rx4month_2, rx4day_2, rx4year_2)
format rx4d_2 %dD_m_CY
drop Treatment4Date
label var rx4d_2 "Treatment4Date"

** Treatment 5 has no observations so had to slightly adjust code
replace Treatment5Date=20000101 if Treatment5Date==99999999
if Treatment5Date !=. nsplit Treatment5Date, digits(4 2 2) gen(rx5year_2 rx5month_2 rx5day_2)
if Treatment5Date !=. gen rx5d_2=mdy(rx5month_2, rx5day_2, rx5year_2)
if Treatment5Date !=. format rx5d_2 %dD_m_CY
if Treatment5Date==. rename Treatment5Date rx5d_2
label var rx5d_2 "Treatment5Date"

** Other Treatment 1
label var orx1_2 "OtherTreatment1"
label define orx_2_lab 1 "Cryotherapy" 2 "Laser therapy" 3 "Treated Abroad" ///
					 4 "Palliative therapy" 9 "Unknown" ,modify
label values orx1_2 orx_2_lab

** Other Treatment 2
label var orx2_2 "OtherTreatment2"

** No Treatments 1 and 2
label var norx1_2 "NoTreatment1"
label define norx_2_lab 1 "Alternative rx" 2 "Symptomatic rx" 3 "Died before rx" ///
					  4 "Refused rx" 5 "Postponed rx"  6 "Watchful waiting" ///
					  7 "Defaulted from care" 8 "NA" 9 "Unknown" ,modify
label values norx1_2 norx_2_lab

** No Treatment 2
** contains a nonnumeric character so field needs correcting!
label var norx2_2 "NoTreatment2"

** TT Reviewer
destring ttreviewer_2, replace
label var ttreviewer_2 "TTReviewer"
label define ttreviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values ttreviewer_2 ttreviewer_2_lab


**********************************************************
** NAMING & FORMATTING - SOURCE TABLE
** Note:
** (1)Label as they appear in CR5 record
** (2)Don't clean where possible as
**    corrections to be flagged in 3_cancer_corrections.do
**********************************************************

** Unique SourceID
label var sid_2 "SourceRecordID"

** ST Data Abstractor
destring stda_2, replace
** DOES NOT contain a nonnumeric character so no correction needed
label var stda_2 "STDataAbstractor"
label define stda_2_lab 1 "JC" 2 "RH" 3 "PM" 4 "WB" 5 "LM" 6 "NE" 7 "TD" 8 "TM" 9 "SAF" 10 "PP" 11 "LC" 12 "AJB" ///
					  13 "KWG" 14 "TH" 22 "MC" 88 "Doctor" 98 "Intern" 99 "Unknown", modify
label values stda_2 stda_2_lab

** Source Date
replace STSourceDate=20000101 if STSourceDate==99999999
nsplit STSourceDate, digits(4 2 2) gen(year month day)
gen stdoa_2=mdy(month, day, year)
format stdoa_2 %dD_m_CY
drop day month year STSourceDate
label var stdoa_2 "STSourceDate"

** NF Type
destring nftype_2, replace
label var nftype_2 "NFType"
label define nftype_2_lab 1 "Hospital" 2 "Polyclinic/Dist.Hosp." 3 "Lab-Path" 4 "Lab-Cyto" 5 "Lab-Haem" 6 "Imaging" ///
						7 "Private Physician" 8 "Death Certif./Post Mort." 9 "QEH Death Rec Bks" 10 "RT Reg. Bk" ///
						11 "Haem NF" 12 "Bay View Bk" 13 "Other" 14 "Unknown" 15 "NFs", modify
label values nftype_2 nftype_2_lab

** Source Name
label var sourcename_2 "SourceName"
label define sourcename_2_lab 1 "QEH" 2 "Bay View" 3 "Private Physician" 4 "IPS-ARS" 5 "Death Registry" ///
							6 "Polyclinic" 7 "BNR Database" 8 "Other" 9 "Unknown", modify
label values sourcename_2 sourcename_2_lab

** Doctor
label var doctor_2 "Doctor"

** Doctor's Address
label var docaddr_2 "DoctorAddress"

** Record Number
label var recnum_2 "RecordNumber"

** CF Diagnosis
label var cfdx_2 "CFDiagnosis"

** Lab Number
label var labnum_2 "LabNumber"

** Specimen
label var specimen_2 "Specimen"

** Sample Taken Date
replace SampleTakenDate=20000101 if SampleTakenDate==99999999
nsplit SampleTakenDate, digits(4 2 2) gen(stdyear_2 stdmonth_2 stdday_2)
gen sampledate_2=mdy(stdmonth_2, stdday_2, stdyear_2)
format sampledate_2 %dD_m_CY
drop SampleTakenDate
label var sampledate_2 "SampleTakenDate"

** Received Date
replace ReceivedDate=20000101 if ReceivedDate==99999999 | ReceivedDate==.
nsplit ReceivedDate, digits(4 2 2) gen(rdyear_2 rdmonth_2 rdday_2)
gen recvdate_2=mdy(rdmonth_2, rdday_2, rdyear_2)
format recvdate_2 %dD_m_CY
replace recvdate_2=d(01jan2000) if recvdate_2==.
drop ReceivedDate
label var recvdate_2 "ReceivedDate"

** Report Date
replace ReportDate=20000101 if ReportDate==99999999
nsplit ReportDate, digits(4 2 2) gen(rptyear_2 rptmonth_2 rptday_2)
gen rptdate_2=mdy(rptmonth_2, rptday_2, rptyear_2)
format rptdate_2 %dD_m_CY
drop ReportDate
label var rptdate_2 "ReportDate"

** Clinical Details
label var clindets_2 "ClinicalDetails"

** Cytological Findings
label var cytofinds_2 "CytologicalFindings"

** Microscopic Description
label var md_2 "MicroscopicDescription"

** Consultation Report
label var consrpt_2 "ConsultationReport"

** Cause(s) of Death
label var cr5cod_2 "CausesOfDeath"

** Duration of Illness
label var duration_2 "DurationOfIllness"

** Onset to Death Interval
label var onsetint_2 "OnsetDeathInterval"

** Certifier
label var certifier_2 "Certifier"

** Admission Date
replace AdmissionDate=20000101 if AdmissionDate==99999999
nsplit AdmissionDate, digits(4 2 2) gen(admyear_2 admmonth_2 admday_2)
gen admdate_2=mdy(admmonth_2, admday_2, admyear_2)
format admdate_2 %dD_m_CY
drop AdmissionDate
label var admdate_2 "AdmissionDate"

** Date First Consultation
replace DateFirstConsultation=20000101 if DateFirstConsultation==99999999
nsplit DateFirstConsultation, digits(4 2 2) gen(dfcyear_2 dfcmonth_2 dfcday_2)
gen dfc_2=mdy(dfcmonth_2, dfcday_2, dfcyear_2)
format dfc_2 %dD_m_CY
drop DateFirstConsultation
label var dfc_2 "DateFirstConsultation"

** RT Registration Date
replace RTRegDate=20000101 if RTRegDate==99999999
nsplit RTRegDate, digits(4 2 2) gen(rtyear_2 rtmonth_2 rtday_2)
gen rtdate_2=mdy(rtmonth_2, rtday_2, rtyear_2)
format rtdate_2 %dD_m_CY
drop RTRegDate
label var rtdate_2 "RTRegDate"

** ST Reviewer
destring streviewer_2, replace
label var streviewer_2 "STReviewer"
label define streviewer_2_lab 0 "Pending" 1 "JC" 2 "LM" 3 "PP" 4 "AR" 5 "AH" 6 "JK" 7 "TM" 8 "SAW" 9 "SAF" 99 "Unknown", modify
label values streviewer_2 streviewer_2_lab

** CanReg5 ID
label var cr5id_2 "CanReg5 ID"

count //16,022

** Change name format to match death data
replace fname_2=lower(fname_2) //16,022 changes
replace fname_2=lower(rtrim(ltrim(itrim(fname_2)))) //424 changes
replace lname_2=lower(lname_2) //16,022 changes
replace lname_2=lower(rtrim(ltrim(itrim(lname_2)))) //598 changes

** Look for matches
sort lname_2 fname_2 pid
quietly by lname_2 fname_2 pid : gen dupname_2 = cond(_N==1,0,_n)
sort lname_2 fname_2 pid
count if dupname_2>0 //10,955

order pid fname_2 lname_2 natregno_2

duplicates tag pid, gen(dup_pid_2)
count if dup_pid_2>0 //10,958
count if dup_pid_2==0 //5,064
//list pid dxyr_2 cr5id_2 dup_pid_2 if dup_pid_2>0, nolabel sepby(pid)
//list pid dxyr_2 cr5id_2 dup_pid_2 if dup_pid_2==0, nolabel sepby(pid)
count if ttupdate_2>=d(13feb2020) //8,054
gen crosschk=1 if ttupdate_2>=d(13feb2020) //13feb2020 date chosen based on date of CR5db .txt file used in 15_clean cancer.do
count if crosschk==1 & (dxyr_2==2008|dxyr_2==2013|dxyr_2==2014|dxyr_2==2015) //930 - to review in CR5db alongside iarc-hub ds opened in a 2nd Stata Browse/Edit window then added updates in 15_cancer.do in section before creating iarc-hub ds (drop non-reportable skin cancers from iarc-hub ds)
sort pid lname_2 fname_2

gen reviewed=1 if pid=="20080020"|pid=="20080154"|pid=="20080158"|pid=="20080171"|pid=="20080173"|pid=="20080196"|pid=="20080208" ///
				  |pid=="20080217"|pid=="20080232"|pid=="20080241"|pid=="20080252"|pid=="20080261"|pid=="20080274"|pid=="20080295" ///
				  |pid=="20080316"|pid=="20080326"|pid=="20080327"|pid=="20080348"|pid=="20080390"|pid=="20080428"|pid=="20080560" ///
				  |pid=="20080624"|pid=="20080626"|pid=="20080659"|pid=="20080674"|pid=="20080688"|pid=="20080696"|pid=="20080728" ///
				  |pid=="20080737"|pid=="20080753"|pid=="20080941"|pid=="20081031"|pid=="20081058"|pid=="20081097"|pid=="20130016" ///
				  |pid=="20130022"|pid=="20130032"|pid=="20130033"|pid=="20130038"|pid=="20130055"|pid=="20130063"|pid=="20130073" ///
				  |pid=="20130081"|pid=="20130087"|pid=="20130096"|pid=="20130103"|pid=="20130110"|pid=="20130119"|pid=="20130130" ///
				  |pid=="20130137"|pid=="20130152"|pid=="20130154"|pid=="20130162"|pid=="20130173"|pid=="20130234"|pid=="20130244" ///
				  |pid=="20130246"|pid=="20130272"|pid=="20130278"|pid=="20130325"|pid=="20130341"|pid=="20130345"|pid=="20130361" ///
				  |pid=="20130374"|pid=="20130552"|pid=="20130589"|pid=="20130618"|pid=="20130648"|pid=="20130670"|pid=="20130674" ///
				  |pid=="20130696"|pid=="20130768"|pid=="20130772"|pid=="20130816"|pid=="20130830"|pid=="20130865"|pid=="20130886" ///
				  |pid=="20140529"|pid=="20140545"|pid=="20140628"|pid=="20140659"|pid=="20140681"|pid=="20140697"|pid=="20140724" ///
				  |pid=="20140729"|pid=="20140733"|pid=="20140738"|pid=="20140739"|pid=="20140836"|pid=="20140837"|pid=="20140838" ///
				  |pid=="20140841"|pid=="20140843"|pid=="20140849"|pid=="20140855"|pid=="20140871"|pid=="20140890"|pid=="20140892" ///
				  |pid=="20140893"|pid=="20140907"|pid=="20140911"|pid=="20140923"|pid=="20140959"|pid=="20140975"|pid=="20140981" ///
				  |pid=="20141031"|pid=="20141063"|pid=="20141064"|pid=="20141067"|pid=="20141084"|pid=="20141095"|pid=="20141103" ///
				  |pid=="20141114"|pid=="20141115"|pid=="20141129"|pid=="20141130"|pid=="20141134"|pid=="20141145"|pid=="20141174" ///
				  |pid=="20141205"|pid=="20141240"|pid=="20141253"|pid=="20141258"|pid=="20141262"|pid=="20141283"|pid=="20141306" ///
				  |pid=="20141308"|pid=="20141320"|pid=="20141324"|pid=="20141348"|pid=="20141361"|pid=="20141365"|pid=="20141376" ///
				  |pid=="20141393"|pid=="20141412"|pid=="20141414"|pid=="20141425"|pid=="20141434"|pid=="20141448"|pid=="20141463" ///
				  |pid=="20141486"|pid=="20141493"|pid=="20141503"|pid=="20141575"|pid=="20145033"|pid=="20145038"|pid=="20145047" ///
				  |pid=="20145053"|pid=="20145054"|pid=="20145055"|pid=="20145106"|pid=="20150005"|pid=="20150013"|pid=="20150022" ///
				  |pid=="20150025"|pid=="20150045"|pid=="20150050"|pid=="20150062"|pid=="20150085"|pid=="20150099"|pid=="20150105" ///
				  |pid=="20150112"|pid=="20150114"|pid=="20150115"|pid=="20150140"|pid=="20150160"|pid=="20150165"|pid=="20150170" ///
				  |pid=="20150173"|pid=="20150174"|pid=="20150180"|pid=="20150188"|pid=="20150192"|pid=="20150194"|pid=="20150199" ///
				  |pid=="20150204"|pid=="20150208"|pid=="20150209"|pid=="20150215"|pid=="20150228"|pid=="20150229"|pid=="20150236" ///
				  |pid=="20150240"|pid=="20150242"|pid=="20150246"|pid=="20150247"|pid=="20150251"|pid=="20150288"|pid=="20150296" ///
				  |pid=="20150297"|pid=="20150302"|pid=="20150303"|pid=="20150314"|pid=="20150329"|pid=="20150333"|pid=="20150335" ///
				  |pid=="20150336"|pid=="20150337"|pid=="20150344"|pid=="20150359"|pid=="20150368"|pid=="20150375"|pid=="20150378" ///
				  |pid=="20150404"|pid=="20150408"|pid=="20150415"|pid=="20150417"|pid=="20150425"|pid=="20150434"|pid=="20150440" ///
				  |pid=="20150464"|pid=="20150482"|pid=="20150519"|pid=="20150520"|pid=="20150521"|pid=="20150522"|pid=="20150527" ///
				  |pid=="20150539"|pid=="20151000"|pid=="20151009"|pid=="20151010"|pid=="20151020"|pid=="20151029"|pid=="20151033" ///
				  |pid=="20151042"|pid=="20151103"|pid=="20151109"|pid=="20151113"|pid=="20151120"|pid=="20151150"|pid=="20151168" ///
				  |pid=="20151171"|pid=="20151189"|pid=="20151193"|pid=="20151197"|pid=="20151226"|pid=="20151248"|pid=="20151262" ///
				  |pid=="20151301"|pid=="20151302"|pid=="20151307"|pid=="20151309"|pid=="20151369"|pid=="20155002"|pid=="20155003" ///
				  |pid=="20155005"|pid=="20155006"|pid=="20155007"|pid=="20155008"|pid=="20155010"|pid=="20155012"|pid=="20155014" ///
				  |pid=="20155015"|pid=="20155016"|pid=="20155017"|pid=="20155018"|pid=="20155021"|pid=="20155027"|pid=="20155028" ///
				  |pid=="20155029"|pid=="20155030"|pid=="20155032"|pid=="20155033"|pid=="20155037"|pid=="20155039"|pid=="20155043" ///
				  |pid=="20155046"|pid=="20155049"|pid=="20155052"|pid=="20155061"|pid=="20155064"|pid=="20155070"|pid=="20155071" ///
				  |pid=="20155077"|pid=="20155079"|pid=="20155094"|pid=="20155095"|pid=="20155100"|pid=="20155150"|pid=="20155161" ///
				  |pid=="20155164"|pid=="20155175"|pid=="20155196"|pid=="20155208"|pid=="20155211"|pid=="20155216"|pid=="20155221" ///
				  |pid=="20155227"|pid=="20155228"|pid=="20155251"|pid=="20155255"|pid=="20155265"|pid=="20159000"|pid=="20159001" ///
				  |pid=="20159002"|pid=="20159003"|pid=="20159004"|pid=="20159005"|pid=="20159006"|pid=="20159007"|pid=="20159008"
//916 changes
replace reviewed=1 if pid=="20159015"|pid=="20159016"|pid=="20159019"|pid=="20159020"|pid=="20159021"|pid=="20159025"|pid=="20159026" ///
				  |pid=="20159027"|pid=="20159028"|pid=="20159029"|pid=="20159030"|pid=="20159031"|pid=="20159033"|pid=="20159034" ///
				  |pid=="20159036"|pid=="20159038"|pid=="20159041"|pid=="20159042"|pid=="20159046"|pid=="20159047"|pid=="20159048" ///
				  |pid=="20159051"|pid=="20159053"|pid=="20159055"|pid=="20159058"|pid=="20159059"|pid=="20159060"|pid=="20159061" ///
				  |pid=="20159062"|pid=="20159063"|pid=="20159064"|pid=="20159065"|pid=="20159068"|pid=="20159070"|pid=="20159071" ///
				  |pid=="20159072"|pid=="20159074"|pid=="20159075"|pid=="20159077"|pid=="20159080"|pid=="20159081"|pid=="20159082" ///
				  |pid=="20159084"|pid=="20159085"|pid=="20159086"|pid=="20159089"|pid=="20159090"|pid=="20159091"|pid=="20159092" ///
				  |pid=="20159093"|pid=="20159096"|pid=="20159097"|pid=="20159098"|pid=="20159102"|pid=="20159103"|pid=="20159104" ///
				  |pid=="20159105"|pid=="20159106"|pid=="20159108"|pid=="20159109"|pid=="20159110"|pid=="20159111"|pid=="20159112" ///
				  |pid=="20159115"|pid=="20159116"|pid=="20159117"|pid=="20159118"|pid=="20159120"|pid=="20159124"|pid=="20159125" ///
				  |pid=="20159126"|pid=="20159127"|pid=="20159128"|pid=="20159131"|pid=="20159132"|pid=="20159134"|pid=="20159135" ///
				  |pid=="20159136"|pid=="20159138"|pid=="20159139"|pid=="20159140"|pid=="20159141"|pid=="20159142"|pid=="20159143" ///
				  |pid=="20159144"|pid=="20159145"|pid=="20159146"|pid=="20159148"|pid=="20159150"|pid=="20160017"|pid=="20160032" ///
				  |pid=="20160537"|pid=="20160556"|pid=="20172150"|pid=="20180030"|pid=="20180587"|pid=="20180701"|pid=="20180707" ///
				  |pid=="20180731"|pid=="20180750"|pid=="20180867"|pid=="20180868"|pid=="20180871"|pid=="20181095"|pid=="20181151" ///
				  |pid=="20181162"|pid=="20200239"|pid=="20200243"
//144 changes				  

drop if dupname_2>1 //6,791 deleted

count //9,231

save "`datapath'\version02\2-working\2008-2020_cancer_crosschk_dp" ,replace
label data "BNR-Cancer prepared 2008-2020 cross-check data"
notes _dta :These data prepared for 2015 cross-check matching for data updated post-cleaning (2015 annual report)

AFTER COMBINING PREVIOUS AND CURRENT YEARS - PERFORM DUP PID SEARCH + IARC MP CHECK

CREATE IDENTIFIABLE AND DE-IDENTIFIED DS
** Save this corrected dataset with reportable cases and identifiable data
save "`datapath'\version09\3-output\2018_cancer_nonsurvival_identifiable", replace
label data "2018 BNR-Cancer identifiable data - Non-survival Identifiable Dataset"
note: TS This dataset was NOT used for 2018 annual report; it was used for PAB 07-June-2022
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis


** Create corrected dataset with reportable cases but de-identified data
drop fname lname natregno init dob resident parish recnum cfdx labnum SurgicalNumber specimen clindets cytofinds md consrpt sxfinds physexam imaging duration onsetint certifier dfc streviewer addr birthdate hospnum comments dobyear dobmonth dobday dob_yr dob_year dobchk sname nrnday nrnid dupnrntag

save "`datapath'\version09\3-output\2018_cancer_nonsurvival_deidentified", replace
label data "2018 BNR-Cancer de-identified data - Non-survival De-identified Dataset"
note: TS This dataset was NOT used for 2018 annual report; it was used for PAB 07-June-2022
note: TS Includes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs - these are removed in dataset used for analysis
note: TS Excludes identifiable data but contains unique IDs to allow for linking data back to identifiable data
