({
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "BT Resources",
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:contact",
                iconAlt: "BT Resources"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    /*  getResources: function (component) {
        var action = component.get("c.getAllResourcess");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.contactList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },*/




    buildCalendarWithTasks:  function (component, helper,calendarTaskList,selectedResourceIndex) {
        component.set("v.rerendermonthly",true);
        var monthlyArray = [];
        var projColors= component.get("v.projectColors");
        if(Number(selectedResourceIndex) >= 0){
            //for selected contract resource or internal resource
            var resourceIdx = Number(selectedResourceIndex);
            var item = calendarTaskList[resourceIdx];
            for(var j=0;j<item.ProjectTaskRecordsList.length;j++){
                var task = item.ProjectTaskRecordsList[j];
                var taskObj = {};
                taskObj["id"] = task.Id;
                var name =  task.title ? task.title : task.taskdescription
                name += task.UnitId ? '-'+task.UnitId :  '-'+task.contractresourceId
                taskObj['name'] = name;
                taskObj["startdate"]= task.startdate;
                taskObj["enddate"]= task.enddate;
                taskObj["starttime"]= "";
                taskObj["endtime"]= "";
                if(task.colorName !='' && task.colorName){
                    taskObj["color"]= task.colorName;
                }else{
                    taskObj["color"]= "#99CCCC";
                }

                //taskObj["color"]= "#99CCCC";
                //taskObj["color"]= projColors[i%10];//"#99CCCC";"#99CCCC";
                taskObj["url"]= '/lightning/r/buildertek__Project_Task__c/' + escape(task.Id) + '/view'; //need to add full url along with baseurl
                monthlyArray.push(taskObj);
            }
        }else{
            //for selected project only
            var contractResourceIdList = [];
            //contractResourceIdList.push(calendarTaskList[i].ContractresourceId);
            var evetList = component.get("v.eventList");
            /* if(component.get("v.isConflictview") == "Conflicts"){
                evetList =
            }*/

            for(var i=0; i<evetList.length; i++){

                var task = evetList[i];
                var taskObj = {};
                taskObj["id"] = task.Id;
                var name =  task.title ? task.title : task.taskdescription
                name += task.UnitId ? '-'+task.UnitId :  '-'+task.contractresourceId
                taskObj['name'] = name;
                taskObj["startdate"]= task.startdate;
                taskObj["enddate"]= task.enddate;
                taskObj["starttime"]= "";
                taskObj["endtime"]= "";
                if(task.colorName !='' && task.colorName){
                    taskObj["color"]= task.colorName;
                }else{
                    taskObj["color"]= "#99CCCC";
                }
                //taskObj["color"]= "#99CCCC";
                // taskObj["color"]= projColors[i%10];//"#99CCCC";
                taskObj["url"]= '/lightning/r/buildertek__Project_Task__c/' + escape(task.Id) + '/view'; //need to add full url along with baseurl
                monthlyArray.push(taskObj);
            }
            //component.set("v.contractResourceListIds",contractResourceIdList);
        }
        var sampleEvents = {
            "monthly": monthlyArray
        }

        component.set("v.calendarEvents",sampleEvents);

        if(Object.keys(sampleEvents).length){
            if(typeof $ == 'function'){
                var viewDate = new Date(component.get("v.dateval"));
                var currentDate = new Date();
                $('#mycalendar').empty();
                var monthNamesList = component.get("v.monthnames");
                if(currentDate.getMonth() ==  viewDate.getMonth() && currentDate.getFullYear() == viewDate.getFullYear()){
                    $('#mycalendar').append('<div class="weekly-header" style="display:none;"><div class="weekly-header-title"><a class="monthly-weekly-header-title-date"  style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">'+monthNamesList[currentDate.getMonth()]+'&nbsp;'+currentDate.getFullYear()+'</a><a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a></div><a class="weekly-prev"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a><a class="weekly-next"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div>')
                }else{
                    // for today reset button
                    $('#mycalendar').append('<div class="weekly-header" style="display:none;"><div class="weekly-header-title"><a class="monthly-weekly-header-title-date"  style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">'+monthNamesList[viewDate.getMonth()]+'&nbsp;'+viewDate.getFullYear()+'</a><a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a><a class="monthly-reset"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div><a class="weekly-prev"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a><a class="weekly-next"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div>')
                }

                if( $('#mycalendar').length){
                    //document.getElementById('mycalendar').innerHTML = '';

                   /* window.setTimeout(function(){
                         $('#mycalendar').monthly({
                                mode: 'event',
                                dataType: 'json',
                                events: sampleEvents,
                                isFirst: component.get("v.isFirst"),
                                viewMonth: viewDate.getMonth(),
                                viewYear: viewDate.getFullYear()
                            });
                    },100);*/

                    $('#mycalendar').monthly({
                                mode: 'event',
                                dataType: 'json',
                                events: sampleEvents,
                                isFirst: component.get("v.isFirst"),
                                viewMonth: viewDate.getMonth(),
                                viewYear: viewDate.getFullYear()
                            });

                    component.set("v.isFirst",false);
                }

            }
        }
        var activeEle = document.getElementsByClassName('viewChange active')[0];
        if(activeEle){
            activeEle.classList.remove('active');
        }
        var monthBtnEle = document.getElementsByClassName('viewChange')[2];
        if(monthBtnEle){
            monthBtnEle.classList.add('active');
        }

        component.resetEventListeners();
        console.log(sampleEvents);

    },


    getTasksByProjects : function(component,helper,Datevalue){
        component.set("v.showSpinner", true);
        var today = new Date(Datevalue);
        //alert('current date===='+today);
        var actionCal = component.get("c.getScheduleItemsByProject");
        var newfromdate = new Date(today.getFullYear(), today.getMonth(),1);
        //newfromdate = new Date(newfromdate.getFullYear(), newfromdate.getMonth(),newfromdate.getDate()-newfromdate.getDay());
        var newtodate;
        if(today.getMonth() == 11){
            newtodate = new Date(today.getFullYear()+1, 0,0);
        }else{
            newtodate = new Date(today.getFullYear(), today.getMonth()+1,0);
        }
        //newtodate = new Date(newtodate.getFullYear(), newtodate.getMonth(),newtodate.getDate()+6-newtodate.getDay());

        var newFromstr,newTostr;
        /*newFromstr = $A.localizationService.formatDate(newfromdate, 'MM/dd/yyyy');
        newTostr = $A.localizationService.formatDate(newtodate, 'MM/dd/yyyy')*/
       /* newFromstr = $A.localizationService.formatDate(newfromdate, 'dd/MM/yyyy');
        newTostr = $A.localizationService.formatDate(newtodate, 'dd/MM/yyyy')*/
       // "yyyy MM dd"
       //
        newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
        newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd")

        console.log('currentWeekDates 4 ========> ');
        //alert(JSON.stringify(component.get("v.selectedTradetype")));
        //alert(fromdateStr+'<-------from-----todate---->'+todateStr);
        actionCal.setParams({
            fromDate: newFromstr,//newFromstr.toString(),//fromdateStr,newfromdate
            toDate: newTostr,//newTostr.toString(),//todateStr,newtodate
            slectedTradetypeId: component.get("v.selectedTradetype").Id,
            slectedprojectId: component.get("v.newSelectedProjectId"),
            slectedcontactId: component.get("v.newContractResource"),
            projectSearch: component.get("v.searchProjectFilter"),
            resourceSearch: component.get("v.searchResourceFilter"),
            alltypeSearch: component.get("v.allFilter")
        });
        actionCal.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state ----------' + state + ' ' + JSON.stringify(response.getReturnValue()));
            if (component.isValid() && state === "SUCCESS") {
                console.log('response.getReturnValue()::',response.getReturnValue());
                component.set("v.showSpinner", false);
                component.set("v.projectList", response.getReturnValue().projectList);
                var evetList = [];
                var projColorMap = new Map();
                var projColors = component.get("v.projectColors");
                for(var itemIdx=0; itemIdx < response.getReturnValue().projectList.length;itemIdx++){
                    for(var j=0;j<response.getReturnValue().projectList[itemIdx].CalendarWrapList.length;j++){
                        var weekName = response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['weekName'];
                        var startDate = response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['startdate'];
                        var endDate = response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['enddate'];
                        if(weekName != null && weekName != undefined){
                            var weeks = component.get("v.dayNames")
                            response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['weekSubStr'] = weeks[new Date(Date.parse(startDate)).getDay()].substring(0,3); //weekName.substring(0,3);
                        }

                        response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                        response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['startdateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(startDate)), 'MM-dd-yyyy');//new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                        response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['enddateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(endDate)), 'MM-dd-yyyy'); //new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                        response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColors[itemIdx%10];
                        if(!projColorMap.has(response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['projectId'])){
                            projColorMap.set(response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]['projectId'],projColors[itemIdx%10]);
                        }
                        evetList.push(response.getReturnValue().projectList[itemIdx].CalendarWrapList[j]);
                    }

                }
                component.set("v.eventList", evetList);
                component.set("v.dateEventList",evetList);
                component.set("v.standardEventList",evetList);
                component.set("v.resourcesList",response.getReturnValue().calendarTaskList);

                component.set("v.projectColorMap",projColorMap);

                var contractResourceIdList = [];
                for(var i=0;i<response.getReturnValue().calendarTaskList.length;i++){
                    contractResourceIdList.push(response.getReturnValue().calendarTaskList[i].ContractresourceId);
                }
                component.set("v.contractResourceListIds",contractResourceIdList);
                //component.set("v.eventList", response.getReturnValue());
                //component.set("v.projectList", response.getReturnValue().projectList);
                //component.set("v.eventList", response.getReturnValue().calendarTaskList);



                //reset selected values
                component.set("v.newContractResource","");
                //if(component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null){
                //    component.set("v.newSelectedProjectId",component.get("v.newSelectedProjectIdClone"));
               // }else{
               //     component.set("v.newSelectedProjectId","");
                //}
                component.set("v.newSelectedProjectId","");
                component.set("v.selectedContractResourceIndex",-1);
                component.set("v.currentCalendarView","monthView");

                var monthlyArray = [];

                var baseURL = component.get("v.BaseURLs");
                for(var i=0; i<evetList.length; i++){
                    var task = evetList[i];
                    var taskObj = {};
                    taskObj["id"] = task.Id;
                    var name =  task.title ? task.title : task.taskdescription
                    name += task.UnitId ? '-'+task.UnitId :  '-'+task.contractresourceId
                    taskObj['name'] = name; //task.title ? task.title + '-' +task.UnitId : task.taskdescription+ '-' +task.UnitId;
                    taskObj["startdate"]= task.startdate;
                    taskObj["enddate"]= task.enddate;
                    taskObj["starttime"]= "";
                    taskObj["endtime"]= "";
                    taskObj["color"]= task.colorName;
                    //taskObj["color"]= "#99CCCC";
                    //taskObj["color"]= projColors[i%10];//"#99CCCC";
                    taskObj["url"]= '/lightning/r/buildertek__Project_Task__c/' + escape(task.Id) + '/view'; //need to add full url along with baseurl
                    monthlyArray.push(taskObj);
                }

                var sampleEvents = {
                    "monthly": monthlyArray
                }

                component.set("v.calendarEvents",sampleEvents);

                if(Object.keys(sampleEvents).length){
                    if(typeof $ == 'function'){
                        var viewDate = new Date(component.get("v.dateval"));
                        var currentDate = new Date();
                        $('#mycalendar').empty();
                        var monthNamesList = component.get("v.monthnames");
                        if(currentDate.getMonth() ==  viewDate.getMonth() && currentDate.getFullYear() == viewDate.getFullYear()){
                            $('#mycalendar').append('<div class="weekly-header" style="display:none;"><div class="weekly-header-title"><a class="monthly-weekly-header-title-date" style="pointer-events: none;"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">'+monthNamesList[currentDate.getMonth()]+'&nbsp;'+currentDate.getFullYear()+'</a><a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a></div><a class="weekly-prev" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a><a class="weekly-next" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div>')
                        }else{
                            // for today reset button
                            $('#mycalendar').append('<div class="weekly-header" style="display:none;"><div class="weekly-header-title"><a class="monthly-weekly-header-title-date"   style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">'+monthNamesList[viewDate.getMonth()]+'&nbsp;'+viewDate.getFullYear()+'</a><a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a><a class="monthly-reset"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div><a class="weekly-prev" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a><a class="weekly-next" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a></div>')
                        }


                        if( $('#mycalendar').length){

                            /*window.setTimeout(function(){
                                $('#mycalendar').monthly({
                                    mode: 'event',
                                    dataType: 'json',
                                    events: sampleEvents,
                                    isFirst: component.get("v.isFirst"),
                                    viewMonth: viewDate.getMonth(),
                                    viewYear: viewDate.getFullYear()
                                });
                            },100);*/

                             $('#mycalendar').monthly({
                                    mode: 'event',
                                    dataType: 'json',
                                    events: sampleEvents,
                                    isFirst: component.get("v.isFirst"),
                                    viewMonth: viewDate.getMonth(),
                                    viewYear: viewDate.getFullYear()
                                });

                            component.set("v.isFirst",false);
                        }

                        /* if(monthlyArray.length){

                            if( $('#mycalendar').length){
                                //document.getElementById('mycalendar').innerHTML = '';

                                $('#mycalendar').monthly({
                                    mode: 'event',
                                    dataType: 'json',
                                    events: sampleEvents,
                                    isFirst: component.get("v.isFirst"),
                                    viewMonth: viewDate.getMonth(),
                                    viewYear: viewDate.getFullYear()
                                });

                                component.set("v.isFirst",false);
                            }
                        }else{
                            $('#mycalendar').monthly({
                                mode: 'event',
                                dataType: 'json',
                                events: sampleEvents,
                                isFirst: component.get("v.isFirst"),
                                viewMonth: viewDate.getMonth(),
                                viewYear: viewDate.getFullYear()
                            });

                            component.set("v.isFirst",false);
                        }*/
                    }
                }

                var activeEle = document.getElementsByClassName('viewChange active')[0];
                if(activeEle){
                    activeEle.classList.remove('active');
                }
                var monthBtnEle = document.getElementsByClassName('viewChange')[2];
                if(monthBtnEle){
                    monthBtnEle.classList.add('active');
                }

                component.set("v.showSpinner", false);
                component.resetEventListeners();
                /*if(component.get("v.isConflictview") == "Conflicts"){
                    component.conflictData();
                }*/

                console.log(sampleEvents);
            } else {
                component.set("v.showSpinner", false);
            }
        });
        window.setTimeout(
            $A.getCallback(function() {
                if(actionCal){
                    $A.enqueueAction(actionCal);
                }

            }), 1000
        );

    },



    currentMonthsDates: function (component, Datevalue) {
        var today = new Date(Datevalue);
    },

    /*  getprojectTaskscontacts: function (component,helper) {
        var action = component.get("c.getAllResourcess");
        var SelectedOptions = component.get("v.SelectedOptions");
        action.setParams({
            selected: SelectedOptions
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.projecttaskcontactlist", response.getReturnValue());
            }

        });
        $A.enqueueAction(action);
    },*/

    handleAfterScriptsLoaded : function(component, helper) {
        if(typeof $ == 'function'){

            jQuery("document").ready(function(){
                console.log('jQuery Loaded');
                /* var sampleEvents = {
                    "monthly": [
                        {
                            "id": 1,
                            "name": "Whole month event",
                            "startdate": "2021-06-01",
                            "enddate": "2021-06-10",
                            "starttime": "12:00",
                            "endtime": "2:00",
                            "color": "#99CCCC",
                            "url": ""
                        },
                        {
                            "id": 2,
                            "name": "Test encompasses month",
                            "startdate": "2021-06-29",
                            "enddate": "2021-07-02",
                            "starttime": "12:00",
                            "endtime": "2:00",
                            "color": "#CC99CC",
                            "url": ""
                        },
                        {
                            "id": 3,
                            "name": "Test single day",
                            "startdate": "2021-07-04",
                            "enddate": "",
                            "starttime": "",
                            "endtime": "",
                            "color": "#666699",
                            "url": "https://www.google.com/"
                        },
                        {
                            "id": 8,
                            "name": "Test single day",
                            "startdate": "2021-06-05",
                            "enddate": "",
                            "starttime": "",
                            "endtime": "",
                            "color": "#666699",
                            "url": "https://www.google.com/"
                        },
                        {
                            "id": 4,
                            "name": "Test single day with time",
                            "startdate": "2021-07-07",
                            "enddate": "",
                            "starttime": "12:00",
                            "endtime": "02:00",
                            "color": "#996666",
                            "url": ""
                        },
                        {
                            "id": 5,
                            "name": "Test splits month",
                            "startdate": "2021-08-25",
                            "enddate": "2016-12-04",
                            "starttime": "",
                            "endtime": "",
                            "color": "#999999",
                            "url": ""
                        },
                        {
                            "id": 6,
                            "name": "Test events on same day",
                            "startdate": "2016-11-25",
                            "enddate": "",
                            "starttime": "",
                            "endtime": "",
                            "color": "#99CC99",
                            "url": ""
                        },
                        {
                            "id": 7,
                            "name": "Test events on same day",
                            "startdate": "2016-11-25",
                            "enddate": "",
                            "starttime": "",
                            "endtime": "",
                            "color": "#669966",
                            "url": ""
                        },
                        {
                            "id": 9,
                            "name": "Test events on same day",
                            "startdate": "2016-11-25",
                            "enddate": "",
                            "starttime": "",
                            "endtime": "",
                            "color": "#999966",
                            "url": ""
                        }
                    ]
                };*/

                /*var sampleEvents = component.get("v.calendarEvents");
                if( $('#mycalendar').length){
                    $('#mycalendar').monthly({
                        mode: 'event',
                        dataType: 'json',
                        events: sampleEvents
                    });
                   // document.getElementById('mycalendar').monthlyCustom({ mode: 'event', dataType: 'json', events: sampleEvents });
                }*/
                // delete $.fn.monthlyCustom ;
                console.log(document.getElementById('mycalendar'));
            });
        }
    },
})