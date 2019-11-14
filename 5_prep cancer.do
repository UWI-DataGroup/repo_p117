** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_prep cancer.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-OCT-2019
    // 	date last modified      28-OCT-2019
    //  algorithm task          Preparing 2015 cancer dataset for cleaning; Preparing previous years for combined dataset
    //  status                  Completed
    //  objective               To have one dataset with cleaned and grouped 2008 & 2013 data for inclusion in 2014 cancer report.
    //  methods                 Clean and update all years' data using IARCcrgTools Check and Multiple Primary

    ** General algorithm set-up
    version 15
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
    log using "`logpath'\5_prep cancer.smcl", replace
** HEADER -----------------------------------------------------

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
** Below updates needed for warnings/errors report
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

** Updates for multiple primary report (define which is the MP so can remove in survival dataset):
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

count //882

** Save this corrected dataset with non-reportable cases
save "`datapath'\version02\2-working\2014_cancer_nonsurvival_nonreportable", replace
label data "2014 BNR-Cancer analysed data - Non-survival Non-reportable Dataset"
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

** Save this corrected dataset with only reportable cases
save "`datapath'\version02\2-working\2014_cancer_nonsurvival", replace
label data "2014 BNR-Cancer analysed data - Non-survival Reportable Dataset"
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
** No updates needed for warnings/errors report
** Updates for multiple primary report:
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
replace lname = lower(rtrim(ltrim(itrim(lname)))) //1208 changes

count //1211

** Save this corrected dataset with non-reportable cases
save "`datapath'\version02\2-working\2008_cancer_nonsurvival_nonreportable", replace
label data "2008 BNR-Cancer analysed data - Non-survival Non-reportable Dataset"
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

** Save this corrected dataset with only reportable cases
save "`datapath'\version02\2-working\2008_cancer_nonsurvival", replace
label data "2008 BNR-Cancer analysed data - Non-survival Reportable Dataset"
note: TS This dataset was used for 2015 annual report
note: TS Excludes ineligible case definition, non-residents, unk sex, non-malignant tumours, IARC non-reportable MPs

clear
STOP
*******************************
** 2013 Non-survival Dataset **
*******************************

** Load the dataset (2013)
use "`datapath'\version02\1-input\2013_cancer_sites_da_v01", replace
count //845

** Remove non-reportable skin cancers
drop if siteiarc==25 //0 deleted

** Remove non-malignant and non-insitu tumours
drop if beh!=2 & beh!=3 //0 deleted

** Check if 2013 cases from 2014 dataset are not already in this dataset
list pid fname lname if pid=="20130175"|pid=="20140027"|pid=="20140032"|pid=="20140033" ///
                       |pid=="20140042"|pid=="20140049"|pid=="20140078"|pid=="20140100" ///
                       |pid=="20140110"|pid=="20140117"|pid=="20140127"|pid=="20140136" ///
                       |pid=="20140154"|pid=="20140168"|pid=="20140174"|pid=="20140192" ///
                       |pid=="20140202"|pid=="20140203"|pid=="20140215"|pid=="20140224" ///
                       |pid=="20140234"|pid=="20140258"|pid=="20140268"|pid=="20140283" ///
                       |pid=="20140380"|pid=="20140389"|pid=="20140411"|pid=="20140461" ///
                       |pid=="20140462"|pid=="20140491"|pid=="20140517"|pid=="20140570" & cr5id=="T2S1" ///
                       |pid=="20140584"|pid=="20140665"|pid==""|pid==""|pid==""|pid==""|pid==""|pid==""

** Add 2013 cases from 2014_cancer_2013only.dta

tab dcostatus ,m

tab resident ,m 
drop if resident==9 //... deleted

** Age check for newly-added cases (IARC crg Tools will do this!)
** Save this corrected dataset
save "`datapath'\version02\2-working\2013_cancer_nonsurvival", replace
label data "2013 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report

clear

*******************************************
** 2008, 2013, 2014 Non-survival Dataset **
*******************************************
** This done before 2015 data prepared so can be used by NS at CARPHA
** Load the dataset (2008)
use "`datapath'\version02\2-working\2008_cancer_nonsurvival", replace
count //802

append using "`datapath'\version02\2-working\2014_cancer_nonsurvival"
STOP
append using "`datapath'\version02\2-working\2013_cancer_nonsurvival"

save "`datapath'\version02\2-working\2008_2013_2014_cancer_nonsurvival", replace
label data "2008, 2013, 2014 BNR-Cancer analysed data - Non-survival Dataset"
note: This dataset was used for 2015 annual report
clear

********************
** Death Matching **
********************
** Match with most current death data (2017, 2018) - note some 2017 deaths found after previous 2017 matching
** LOAD the national registry deaths 2008-2018 dataset

count //


*******************************
** 2015 Non-survival Dataset **
*******************************
VALIDITY PRESENTATION
Below items should be assessed for missing values:
age (not >3%)
primarysite
stage
follow up (slc, dlc)
(Missing sex, resident and dotyear not acceptable)

tab resident ,m 
drop if resident==9 //... deleted

create var (sourcetot?) with total sources by using duplicate sepby pid
** 2015 quality report (see 15_review_2015_dc.do and incorporate into this dofile)
SOURCES
DCI/DCN/DCO
MAJOR/MINOR DISAGREEMENTS
Total recoded (recodetop recodemorph) - % total changed/total records

Analysis dofiles: For every data output, use putdocx and add in a methods section describing how data output was generated!