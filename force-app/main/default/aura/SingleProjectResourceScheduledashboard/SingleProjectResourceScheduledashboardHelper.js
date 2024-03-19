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
            console.log('addEventListener 1.0--> ');
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

        console.log('addEventListener 2.0--> ');

         // Changes for BUIL-3936
        // To set yellow circle on selected date;
        var selectDate = new Date(component.get("v.startDt"));
        var seletedDateClass = 'dateV'+selectDate.getFullYear() +'-'+ String(selectDate.getMonth() + 1).padStart(2,'0')+ '-' + String(selectDate.getDate() -1).padStart(2,'0');
        console.log('selected date : ', seletedDateClass);

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
        console.log(sampleEvents);

    },

    getTasksByProjects : function(component,helper,Datevalue){
        component.set("v.showSpinner", true);
        var today = new Date(Datevalue);
        var actionCal = component.get("c.getScheduleItemsByProject");
        var newfromdate = new Date(today.getFullYear(), today.getMonth(),1);

        var newtodate;
        if(today.getMonth() == 11){
            newtodate = new Date(today.getFullYear()+1, 0,0);
        }else{
            newtodate = new Date(today.getFullYear(), today.getMonth()+1,0);
        }

        var newFromstr,newTostr;

        newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
        newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd")

        console.log('currentWeekDates from ========> ' ,newFromstr);
        console.log('currentWeekDates to ========> ',newTostr);


        var helper = this;
        // Create a promise wrapper around setTimeout
        var timeoutPromise = new Promise(function(resolve, reject) {
            setTimeout(function() {
                resolve(); // Resolve the promise after the timeout
            }, 1000); // 1000 milliseconds = 1 second
        });

        timeoutPromise.then(function() {
            helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), '', component.get("v.searchResourceFilter"), component.get("v.allFilter"))
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
                        response.projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColors[itemIdx%10];
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

                var baseURL = component.get("v.BaseURLs");
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
                        console.log('addEventListener 1.0--> ');
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
                var selectDate = new Date(component.get("v.startDt"));
                var seletedDateClass = 'dateV'+today.getFullYear() +'-'+ String(today.getMonth() + 1).padStart(2,'0')+ '-' + String(today.getDate() -1).padStart(2,'0');
                console.log('selected date : ', seletedDateClass);

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

                component.set("v.showSpinner", false);
                component.resetEventListeners();

            })
            .catch(error => {
                console.log('error in getTasksByProjects : ', {error});
                component.set("v.showSpinner", false);
            });
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
                        console.log('Selected date:', dateText);
                        component.set("v.startDt" ,dateText);
                        $(`#datepickerPlaceholder`).hide();
                        helper.handleSaveDates(component,event,helper);
                    }
                });

                // Hide the date picker initially
                $(`#datepickerPlaceholder`).hide();

                component.set("v.isDatePickerLoaded", true);
            }

            // Toggle the visibility of the date picker
            console.log('is date picker visible :  ', $(`#datepickerPlaceholder`).is(":visible"));

            $(`#datepickerPlaceholder`).toggle();
            component.set("v.isBackShadow", $(`#datepickerPlaceholder`).is(":visible"));
        } catch (error) {
            console.log('error in  openDatePickerHelper : ', error.stack);

        }
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
    }

})