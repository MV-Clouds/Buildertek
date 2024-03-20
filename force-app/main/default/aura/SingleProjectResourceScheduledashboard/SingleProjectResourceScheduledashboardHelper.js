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

    buildCalendarWithTasks:  function (component, helper,calendarTaskList,selectedResourceIndex) {
        console.log('buildCalendarWithTasks calling : ');
        component.set("v.showSpinner", true);
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

                taskObj["url"]= '/lightning/r/buildertek__Project_Task__c/' + escape(task.Id) + '/view'; //need to add full url along with baseurl
                monthlyArray.push(taskObj);
            }
        }else{
            //for selected project only
            var contractResourceIdList = [];
            var evetList = component.get("v.eventList");

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

                taskObj["url"]= '/lightning/r/buildertek__Project_Task__c/' + escape(task.Id) + '/view'; //need to add full url along with baseurl
                monthlyArray.push(taskObj);
            }
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
                    $('#mycalendar').append(`<div class="weekly-header" style="display:none;">
                                                <div class="weekly-header-title">
                                                    <a class="monthly-weekly-header-title-date"  style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">${monthNamesList[currentDate.getMonth()]}&nbsp;${currentDate.getFullYear()}</a>
                                                    <a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a></div><a class="weekly-prev"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                    <a class="month-header-title-datee" id="datepickerAnchor" style="position: relative !important;" onclick="(function(event){event.preventDefault();return false;})();return false;">Select Date </a>
                                                    <a class="weekly-next"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                </div>`);

                }else{
                    // for today reset button
                    $('#mycalendar').append(`<div class="weekly-header" style="display:none;">
                                                <div class="weekly-header-title">
                                                    <a class="monthly-weekly-header-title-date"  style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">${monthNamesList[viewDate.getMonth()]}&nbsp;${viewDate.getFullYear()}</a>
                                                    <a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a>
                                                    <a class="month-header-title-datee" id="datepickerAnchor" style="position: relative !important;" onclick="(function(event){event.preventDefault();return false;})();return false;">Select Date </a>
                                                    <a class="monthly-reset"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                </div>
                                                    <a class="weekly-prev"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a><a class="weekly-next"  href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                            </div>`)

                }

                if( $('#mycalendar').length){

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

        var selectDateEle = document.getElementsByClassName('month-header-title-datee');

        if(selectDateEle.length){
            console.log('addEventListener snow 1.0--> ');
            for(var i=0; i<selectDateEle.length; i++){
                console.log('ele >> ', selectDateEle[i]);
                selectDateEle[i].addEventListener("click",function(event){
                    helper.openDatePickerHelper(component, event, helper);
                });
            }
        }

        // Changes for BUIL-3936
        const activeEles = document.querySelectorAll(`.viewChange`);
        if(activeEles.length){
            for(var i=0; i< activeEles.length; i++){
                if(activeEles[i].dataset.name == component.get('v.currentCalendarView')){
                    if(!activeEles[i].classList.contains('active')){
                        activeEles[i].classList.add('active');
                    }
                }
                else{
                    activeEles[i].classList.remove('active');
                }
            }
        }

        // Changes for BUIL-3936
        // When date choosen from Week view set calander and heard according to week...
        // When date choosen from Day view set calander and heard according to Dat...
        // else by default it will set to month view...
        if(component.get("v.currentCalendarView") == 'weekView'){
            component.setWeekView();
        }
        else if(component.get("v.currentCalendarView") == 'dayView'){
            // component.setDayView();
            document.getElementById('mycalendar').style.display = 'none';

            /*Show day view div*/
            document.getElementById('mycalendar2').style.display = 'block';
            /*show day view header*/
            document.getElementsByClassName('daily-header')[0].style.display = 'block';
        }

         // Changes for BUIL-3936
        // To set yellow circle on selected date;
        var selectDate = new Date(component.get("v.startDt"));
        var seletedDateClass = 'dateV'+selectDate.getFullYear() +'-'+ String(selectDate.getMonth() + 1).padStart(2,'0')+ '-' + String(selectDate.getDate() -1).padStart(2,'0');

        var monthDate = document.getElementsByClassName('m-d monthly-day monthly-day-event');
        console.log('monthDate.length : ', monthDate.length);
        if(monthDate.length){
            for(var i=0; i<monthDate.length; i++){
                if(monthDate[i].classList.contains(seletedDateClass)){
                    var numberDiv = monthDate[i].querySelector('.monthly-day-number');
                    if(!numberDiv.classList.contains('selected-Date') && !monthDate[i].classList.contains('monthly-today')){
                        numberDiv.classList.add('selected-Date');
                        console.log(`monthDate ${[i]} : `, monthDate[i].classList);
                    }
                }
                else{
                    if(monthDate[i].querySelector('.monthly-day-number').classList.contains('selected-Date')){
                        monthDate[i].querySelector('.monthly-day-number').classList.remove('selected-Date');
                    }
                }
            }
        }

        component.resetEventListeners();
        component.set("v.showSpinner", false);
    },

    buildCalendar: function (component, helper) {
        var resources = component.get('v.resourcesList');
        var contractResourceIdList = [];
        for (var i = 0; i < resources.length; i++) {
            contractResourceIdList.push(resources[i].ContractresourceId);
        }
        component.set("v.contractResourceListIds", contractResourceIdList);
        console.log('calling buildCalendar helper');
        helper.buildCalendarWithTasks(component, helper, component.get('v.resourcesList'), component.get("v.selectedContractResourceIndex"));
    },

    getTasksByProjects : function(component,helper,Datevalue){
        component.set("v.showSpinner", true);
        var today = new Date(Datevalue);
        var newfromdate = new Date(today.getFullYear(), today.getMonth(),1);

        var newtodate;
        if(today.getMonth() == 11){
            newtodate = new Date(today.getFullYear()+1, 0,0);
        }else{
            newtodate = new Date(today.getFullYear(), today.getMonth()+1,0);
        }

        var newFromstr,newTostr;

        newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
        newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd");
        console.log('component.get("v.project").Id ',component.get("v.project").Id);

        helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), component.get("v.project").Name, component.get("v.searchResourceFilter"), component.get("v.allFilter"))
        .then(response => {
            console.log('response.getReturnValue()::',response);
            component.set("v.showSpinner", false);
            component.set("v.projectList", response.projectList);
            var evetList = [];
            var projColorMap = new Map();
            var projColors = component.get("v.projectColors");
            for(var itemIdx=0; itemIdx < response.projectList.length;itemIdx++){
                for(var j=0;j<response.projectList[itemIdx].CalendarWrapList.length;j++){
                    var weekName = response.projectList[itemIdx].CalendarWrapList[j]['weekName'];
                    var startDate = response.projectList[itemIdx].CalendarWrapList[j]['startdate'];
                    var endDate = response.projectList[itemIdx].CalendarWrapList[j]['enddate'];
                    if(weekName != null && weekName != undefined){
                        var weeks = component.get("v.dayNames")
                        response.projectList[itemIdx].CalendarWrapList[j]['weekSubStr'] = weeks[new Date(Date.parse(startDate)).getDay()].substring(0,3); //weekName.substring(0,3);
                    }

                    response.projectList[itemIdx].CalendarWrapList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                    response.projectList[itemIdx].CalendarWrapList[j]['startdateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(startDate)), 'MM-dd-yyyy');//new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                    response.projectList[itemIdx].CalendarWrapList[j]['enddateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(endDate)), 'MM-dd-yyyy'); //new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                    response.projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColors[itemIdx % 10];
                    if(!projColorMap.has(response.projectList[itemIdx].CalendarWrapList[j]['projectId'])){
                        projColorMap.set(response.projectList[itemIdx].CalendarWrapList[j]['projectId'],projColors[itemIdx%10]);
                    }
                    evetList.push(response.projectList[itemIdx].CalendarWrapList[j]);
                }
            }
            component.set("v.eventList", evetList);
            component.set("v.dateEventList",evetList);
            component.set("v.standardEventList",evetList);
            component.set("v.resourcesList",response.calendarTaskList);
            component.set("v.areExternalResource", response.areExternalResource);
            component.set("v.areInternalResource", response.areInternalResource);

            component.set("v.projectColorMap",projColorMap);

            var contractResourceIdList = [];
            for(var i=0;i<response.calendarTaskList.length;i++){
                contractResourceIdList.push(response.calendarTaskList[i].ContractresourceId);
            }
            component.set("v.contractResourceListIds",contractResourceIdList);

            //reset selected values
            component.set("v.newContractResource","");

            component.set("v.newSelectedProjectId","");
            component.set("v.selectedContractResourceIndex",-1);

            var monthlyArray = [];

            for(var i=0; i<evetList.length; i++){
                var task = evetList[i];
                console.log('task : ', task);
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
                        $('#mycalendar').append(`<div class="weekly-header" style="display:none;">
                                                    <div class="weekly-header-title">
                                                        <a class="monthly-weekly-header-title-date" style="pointer-events: none;"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">${monthNamesList[currentDate.getMonth()]}&nbsp;${currentDate.getFullYear()}</a>
                                                        <a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a>
                                                        <a class="month-header-title-datee" id="datepickerAnchor" style="position: relative !important;" onclick="(function(event){event.preventDefault();return false;})();return false;">Select Date </a>
                                                    </div>
                                                        <a class="weekly-prev" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                        <a class="weekly-next" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                </div>`)

                    }else{
                        // for today reset button
                        $('#mycalendar').append(`<div class="weekly-header" style="display:none;">
                                                    <div class="weekly-header-title">
                                                        <a class="monthly-weekly-header-title-date"   style="pointer-events: none;" href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">${monthNamesList[viewDate.getMonth()]}&nbsp;${viewDate.getFullYear()}</a>
                                                        <a class="weekly-header-title-date"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;">Week 1-7</a>
                                                        <a class="month-header-title-datee" id="datepickerAnchor" style="position: relative !important;" onclick="(function(event){event.preventDefault();return false;})();return false;">Select Date </a>
                                                        <a class="monthly-reset"  href="#" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                    </div>
                                                        <a class="weekly-prev" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                        <a class="weekly-next" href="javascript:void(0);" onclick="(function(event){event.preventDefault();return false;})();return false;"></a>
                                                </div>`)

                    }

                    if( $('#mycalendar').length){

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

                var selectDateEle = document.getElementsByClassName('month-header-title-datee');

                if(selectDateEle.length){
                    console.log('addEventListener jon 1.0--> ');
                    for(var i=0; i<selectDateEle.length; i++){
                        console.log('ele >> ', selectDateEle[i]);
                        selectDateEle[i].addEventListener("click",function(event){
                            helper.openDatePickerHelper(component, event, helper);
                        });
                    }
                }
            }

            // Changes for BUIL-3936
            const activeEles = document.querySelectorAll(`.viewChange`);
            if(activeEles.length){
                for(var i=0; i< activeEles.length; i++){
                    if(activeEles[i].dataset.name == component.get('v.currentCalendarView')){
                        if(!activeEles[i].classList.contains('active')){
                            activeEles[i].classList.add('active');
                        }
                    }
                    else{
                        activeEles[i].classList.remove('active');
                    }
                }
            }

            // Changes for BUIL-3936
            // When date choosen from Week view set calander and heard according to week...
            // When date choosen from Day view set calander and heard according to Dat...
            // else by default it will set to month view...
            if(component.get("v.currentCalendarView") == 'weekView'){
                component.setWeekView();
            }
            else if(component.get("v.currentCalendarView") == 'dayView'){
                // component.setDayView();
                document.getElementById('mycalendar').style.display = 'none';

                /*Show day view div*/
                document.getElementById('mycalendar2').style.display = 'block';
                /*show day view header*/
                document.getElementsByClassName('daily-header')[0].style.display = 'block';

                if(currentDate.getMonth() ==  viewDate.getMonth() && currentDate.getFullYear() == viewDate.getFullYear()){

                }

            }


            // Changes for BUIL-3936
            // To set yellow circle on selected date;
            var seletedDateClass = 'dateV'+today.getFullYear() +'-'+ String(today.getMonth() + 1).padStart(2,'0')+ '-' + String(today.getDate() -1).padStart(2,'0');
            var monthDate = document.getElementsByClassName('m-d monthly-day monthly-day-event');

            if(monthDate.length){
                for(var i=0; i<monthDate.length; i++){
                    if(monthDate[i].classList.contains(seletedDateClass)){
                        var numberDiv = monthDate[i].querySelector('.monthly-day-number');
                        if(!numberDiv.classList.contains('selected-Date') && !monthDate[i].classList.contains('monthly-today')){
                            numberDiv.classList.add('selected-Date');
                        }
                    }
                    else{
                        if(monthDate[i].querySelector('.monthly-day-number').classList.contains('selected-Date')){
                            monthDate[i].querySelector('.monthly-day-number').classList.remove('selected-Date');
                        }
                    }
                }
            }


            helper.colorFullTasks(component, helper, response);
            helper.buildCalendar(component, helper);

            component.set("v.showSpinner", false);
            component.resetEventListeners();

        })
        .catch(error => {
            console.log('error in getTasksByProjects : ', {error});
            component.set("v.showSpinner", false);
        });
    },

    handleAfterScriptsLoaded : function(component, helper) {
        if(typeof $ == 'function'){

            jQuery("document").ready(function(){
                console.log('jQuery Loaded');
                console.log(document.getElementById('mycalendar'));
            });
        }
    },

    handleSaveDates: function(component, event, helper) {
        var startDate = component.get("v.startDt");
        console.log('selected stard date : ', startDate);
        var startDateObj = new Date(startDate);
        console.log(typeof(startDateObj));
        if(startDate != null){
            document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
            document.getElementById('resourceInitials').innerText = 'R';
            document.getElementById('selectedContractResource').innerText = 'Resource';
            document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';

            component.set("v.showSpinner", true);
            component.set("v.newContractResource","");
            if(component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null){
                component.set("v.newSelectedProjectId",component.get("v.newSelectedProjectIdClone"));
            }else{
                component.set("v.newSelectedProjectId","");
            }
            component.set("v.selectedContractResourceIndex",-1);
            var Datevalue =  startDateObj;

            component.set("v.dateval",Datevalue);
            component.set("v.datevalString",Datevalue.toLocaleDateString());
            component.set("v.todayDateHeader",Datevalue.toDateString());
            console.log("Datevalue.toDateString() :--->" , Datevalue.toDateString());
            component.set("v.todayDate",Datevalue.toLocaleDateString());
            component.set("v.SelectedDate" ,startDate);
            helper.getTasksByProjects(component,helper, Datevalue);

        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Start date cannot be empty."
            });
            toastEvent.fire();
        }

    },

    openDatePickerHelper: function(component, event, helper){
        try {
            console.log('inside openDatePickerHelper');
            if(!component.get("v.isDatePickerLoaded")){
                console.log('Initialize the date picker');
                // Initialize the date picker
                $(`#datepickerPlaceholder`).datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: 'button',
                // buttonImageOnly: true,
                // buttonImage: 'images/calendar.gif',
                dateFormat: 'yy-MM-dd',
                yearRange: '-20:+20',
                showAnim: 'fold',
                    onSelect: function(dateText, inst) {
                        // Handle the selected date
                        component.set("v.startDt" ,dateText);
                        $(`#datepickerPlaceholder`).hide();
                        helper.handleSaveDates(component,event,helper);
                    }
                });

                // Hide the date picker initially
                $(`#datepickerPlaceholder`).hide();

                component.set("v.isDatePickerLoaded", true);
            }

            $(`#datepickerPlaceholder`).toggle();
            component.set("v.isBackShadow", $(`#datepickerPlaceholder`).is(":visible"));
        } catch (error) {
            console.log('error in  openDatePickerHelper : ', error.stack);

        }
    },

    handleSelectedProject: function (component, event, helper) {

        event.stopPropagation();
        component.set("v.showSpinner", true);

        if (event.currentTarget.dataset.projid) {
            component.set("v.newSelectedProjectId", event.currentTarget.dataset.projid);
            component.set("v.newSelectedProjectIdClone", event.currentTarget.dataset.projid);
        } else {
            component.set("v.newSelectedProjectId", "");
        }

        component.set("v.newContractResource", "");
        component.set("v.selectedContractResourceIndex", "-1");
        var todayDate = new Date(component.get("v.dateval"));
        var newfromdate = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
        var newtodate;
        if (todayDate.getMonth() == 11) {
            newtodate = new Date(todayDate.getFullYear() + 1, 0, 0);
        } else {
            newtodate = new Date(todayDate.getFullYear(), todayDate.getMonth() + 1, 0);
        }

        var newFromstr, newTostr;

        newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
        newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd")
        console.log('ans 2--->', component.get("v.newSelectedProjectId"));
        console.log('component.get("v.project").Id ',component.get("v.project").Name);

        helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), component.get("v.project").Name, component.get("v.searchResourceFilter"), component.get("v.allFilter"))
        .then(function (response) {
            console.log('response.getReturnValue()::', response);

            var evetList = [];
            var resourceColor = component.get("v.resourceColors");

            for (var k = 0; k < response.calendarTaskList.length; k++) {
                if (response.calendarTaskList[k].ProjectTaskRecordsList) {
                    for (var j = 0; j < response.calendarTaskList[k].ProjectTaskRecordsList.length; j++) {
                        var weekName = response.calendarTaskList[k].ProjectTaskRecordsList[j]['weekName'];
                        var startDate = response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdate'];
                        if (weekName != null && weekName != undefined) {
                            var dayNames = component.get("v.dayNames");
                            response.calendarTaskList[k].ProjectTaskRecordsList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3); //weekName.substring(0,3);
                        }

                        response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                        var endDate = response.calendarTaskList[k].ProjectTaskRecordsList[j]['enddate'];
                        response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdateFormatted'] = $A.localizationService.formatDate(startDate, 'MM-dd-yyyy');// new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getMonth().toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                        response.calendarTaskList[k].ProjectTaskRecordsList[j]['enddateFormatted'] = $A.localizationService.formatDate(endDate, 'MM-dd-yyyy');//new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getMonth().toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                        response.calendarTaskList[k].ProjectTaskRecordsList[j]['colorName'] = resourceColor[k % 10];
                        evetList.push(response.calendarTaskList[k].ProjectTaskRecordsList[j]);

                    }
                }
            }
            component.set("v.eventList", evetList);
            component.set("v.dateEventList", evetList);
            component.set("v.standardEventList", evetList);
            component.set("v.resourcesList", response.calendarTaskList);
            component.set("v.areExternalResource", response.areExternalResource);
            component.set("v.areInternalResource", response.areInternalResource);

            document.getElementById('mycalendar').style.display = 'block';
            document.getElementById('mycalendar2').style.display = 'none';

            /*reset selected resource  */
            document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
            document.getElementById('resourceInitials').innerText = 'R';
            document.getElementById('selectedContractResource').innerText = 'Resource';
            document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';

            helper.buildCalendar(component, helper);
        })
        .catch(function (error) {
            component.set("v.showSpinner", false);
            console.log('error', error);
        });

    },

    getScheduleItems: function(component, fromDate, toDate, slectedTradetypeId, slectedprojectId, slectedcontactId, projectSearch, resourceSearch, alltypeSearch) {

        return new Promise((resolve, reject) => {
            var action = component.get("c.getScheduleItemsByProject");
            action.setParams({
                "fromDate": fromDate,
                "toDate": toDate,
                "slectedTradetypeId": slectedTradetypeId,
                "slectedprojectId": slectedprojectId,
                "slectedcontactId": slectedcontactId,
                "projectSearch": projectSearch,
                "resourceSearch": resourceSearch,
                "alltypeSearch": alltypeSearch
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    console.log('result in promise : ', result);
                    resolve(response.getReturnValue());
                } else if (state === "ERROR") {
                    let error = response.getError();
                    console.log('erorr in promise : ', error);
                    reject(response.getError());
                }
            });

            $A.enqueueAction(action);
        });
    },

    colorFullTasks: function(component, helper, response) {
        var evetList = [];
        var resourceColor = component.get("v.resourceColors");

        for (var k = 0; k < response.calendarTaskList.length; k++) {
            if (response.calendarTaskList[k].ProjectTaskRecordsList) {
                for (var j = 0; j < response.calendarTaskList[k].ProjectTaskRecordsList.length; j++) {
                    var weekName = response.calendarTaskList[k].ProjectTaskRecordsList[j]['weekName'];
                    var startDate = response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdate'];
                    if (weekName != null && weekName != undefined) {
                        var dayNames = component.get("v.dayNames");
                        response.calendarTaskList[k].ProjectTaskRecordsList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3); //weekName.substring(0,3);
                    }

                    response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                    var endDate = response.calendarTaskList[k].ProjectTaskRecordsList[j]['enddate'];
                    response.calendarTaskList[k].ProjectTaskRecordsList[j]['startdateFormatted'] = $A.localizationService.formatDate(startDate, 'MM-dd-yyyy');// new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getMonth().toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                    response.calendarTaskList[k].ProjectTaskRecordsList[j]['enddateFormatted'] = $A.localizationService.formatDate(endDate, 'MM-dd-yyyy');//new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getMonth().toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                    response.calendarTaskList[k].ProjectTaskRecordsList[j]['colorName'] = resourceColor[k % 10];
                    evetList.push(response.calendarTaskList[k].ProjectTaskRecordsList[j]);
                }
            }
        }
        component.set("v.eventList", evetList);
        component.set("v.dateEventList", evetList);
        component.set("v.standardEventList", evetList);
        component.set("v.resourcesList", response.calendarTaskList);
        component.set("v.areExternalResource", response.areExternalResource);
        component.set("v.areInternalResource", response.areInternalResource);

        document.getElementById('mycalendar').style.display = 'block';
        document.getElementById('mycalendar2').style.display = 'none';

        /*reset selected resource  */
        document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
        document.getElementById('resourceInitials').innerText = 'R';
        document.getElementById('selectedContractResource').innerText = 'Resource';
        document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';
    },

})