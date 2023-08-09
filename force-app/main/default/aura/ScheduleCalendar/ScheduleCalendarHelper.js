({
    gettabname : function(component, event, helper) {
        var workspaceAPI = component.find("workspacecalendar");
        workspaceAPI.openTab({
            url : '/lightning/n/buildertek__Schedule_Calendar',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response ,
                label: "Schedule Calendar"
            })
        })
     },
    getActiveProjects : function(component, event, helper){
        component.set("v.Spinner", true);
        var projectInputVal; //= document.getElementById('projectId').value;
        var tradeTypeInputVal //= document.getElementById('tradeTypeId').value;
        var vendorInputVal; //= document.getElementById('vendorId').value;

        var tradeTypeId = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedTradetype")))) ? JSON.parse(JSON.stringify(component.get("v.selectedTradetype"))).Id  : '';
        var vendorId = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedVendor")))) ? JSON.parse(JSON.stringify(component.get("v.selectedVendor"))).Id : '';
        var projectId = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedproject")))) ? JSON.parse(JSON.stringify(component.get("v.selectedproject"))).Id : '';


        projectInputVal = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedproject")))) ? JSON.parse(JSON.stringify(component.get("v.selectedproject"))).Name : '';
        tradeTypeInputVal = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedTradetype")))) ? JSON.parse(JSON.stringify(component.get("v.selectedTradetype"))).Name  : '';
        vendorInputVal = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedVendor")))) ? JSON.parse(JSON.stringify(component.get("v.selectedVendor"))).Name : '';

        component.set("v.selectedProjectId",projectId);
        component.set("v.selectedTradeTypeId",tradeTypeId);
        component.set("v.selectedVendorId",vendorId);



        component.set("v.selectedVendorIdName",vendorInputVal);
        component.set("v.selectedTradeTypeIdName",tradeTypeInputVal);
        component.set("v.selectedProjectIdName",projectInputVal);

        /*if(projectInputVal == ""){
            component.set("v.selectedProjectId","All");
            component.set("v.selectedProjectIdName",'All');
        }
        if(tradeTypeInputVal == ""){
            component.set("v.selectedTradeTypeId",'All');
            component.set("v.selectedTradeTypeIdName",'All');
        }
        if(vendorInputVal == ""){
            component.set("v.selectedVendorId",'All');
            component.set("v.selectedVendorIdName",'All');
        }*/

        //if without selecting from dropdown and click filter, then check for value and set.


        /*for(var i=0;i<component.get("v.projectsList").length;i++){
            var project = component.get("v.projectsList")[i];
            if(project.Name == projectInputVal){
                component.set("v.selectedProjectId",project.Id);
                component.set("v.selectedProjectIdName",projectInputVal);
            }else if(projectInputVal.toLowerCase() == "all"){
                component.set("v.selectedProjectId",'All');
                component.set("v.selectedProjectIdName",'All');
                break;
            }
        }
        for(var i=0;i<component.get("v.tradeTypesList").length;i++){
            var tradeType = component.get("v.tradeTypesList")[i];
            if(tradeType.Name == tradeTypeInputVal){
                component.set("v.selectedTradeTypeId",tradeType.Id);
                component.set("v.selectedTradeTypeIdName",tradeTypeInputVal);
            }else if(tradeTypeInputVal.toLowerCase() == "all"){
                component.set("v.selectedTradeTypeId",'All');
                component.set("v.selectedTradeTypeIdName",'All');
                break;
            }
        }
        for(var i=0;i<component.get("v.vendorsList").length;i++){
            var vendor = component.get("v.vendorsList")[i];
            if(vendor.Name == vendorInputVal){
                component.set("v.selectedVendorId",vendor.Id);
                component.set("v.selectedVendorIdName",vendorInputVal);
            }else if(vendorInputVal.toLowerCase() == "all"){
                component.set("v.selectedVendorId",'All');
                component.set("v.selectedVendorIdName",'All');
                break;
            }
        }*/

        // var status = component.get("v.selectedScheduleStatus");
        var projectId = component.get("v.selectedProjectId");
        var tradeTypeId = component.get("v.selectedTradeTypeId");
        var vendorId = component.get("v.selectedVendorId");
        //alert('status -------> '+status);
        //alert('projectId -------> '+projectId);
       // alert('tradeTypeId -------> '+tradeTypeId);
       // alert('vendorId -------> '+vendorId);

       var projectIdList = [];
       var ProjectRecordList = component.get("v.ProjectRecordList");
       ProjectRecordList.forEach(element => {
            projectIdList.push(element.Id);
       });

       console.log('projectIdList ==> ',{projectIdList});
        var defaultDate = component.get("v.defaultDate");
    	var action = component.get("c.getProjects");
        action.setParams({
            // 'scheduleItemsStatus' : status,
            'projectIdList' : projectIdList,
            // 'projectId' : projectId ? projectId : '' /*!= "" ? projectId:"All"*/,
            'tradeTypeId' : tradeTypeId ? tradeTypeId : '' /*!= "" ? tradeTypeId:"All"*/,
            'vendorId' : vendorId ? vendorId : ''/*!= "" ? vendorId:"All"*/,
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('Result ==> ',{result});
               // alert('hhhhhhhhh'+JSON.stringify(result));
              //  console.log('result -------> '+JSON.stringify(result));
                //console.log('length -------> '+result.ScheduleWrapperList.length);
                setTimeout(
                    $A.getCallback(
                        function() {
                         //   console.log(document.getElementById('projectId').value);
                            if(component.get("v.selectedProjectIdName") != null){
                                //document.getElementById('projectId').value = component.get("v.selectedProjectIdName");
                            }
                            if(component.get("v.selectedTradeTypeIdName") != null){
                             // document.getElementById('tradeTypeId').value = component.get("v.selectedTradeTypeIdName");
                            }
                            if(component.get("v.selectedVendorIdName") != null){
                           	 //document.getElementById('vendorId').value = component.get("v.selectedVendorIdName");
                            }
                            component.set("v.selectedProjectId", component.get("v.selectedProjectId"));
                            component.set("v.selectedTradeTypeId", component.get("v.selectedTradeTypeId"));
                            component.set("v.selectedVendorId", component.get("v.selectedVendorId"));
                        }
                    )
                );
                var projectsList = [];
                var scheduleItemsList = [];
                /*for(var i=0;i<result.ScheduleWrapperList.length;i++){
                    console.log('Id -------> '+result.ScheduleWrapperList[i].projectList.Id);
                    console.log('Name -------> '+result.ScheduleWrapperList[i].projectList.Name);
                    projectsList.push({
                        'Id' : result.ScheduleWrapperList[i].projectList.Id,
                        'Name' : result.ScheduleWrapperList[i].projectList.Name
                    });
                    if(result.ScheduleWrapperList[i].scheduleItemList.length > 0){
                        for(var j=0;j<result.ScheduleWrapperList[i].scheduleItemList.length;j++){
                        	scheduleItemsList.push(result.ScheduleWrapperList[i].scheduleItemList[j]);
                        }
                    }
                }*/
                //component.set("v.projectsList", projectsList);
                component.set("v.scheduleItemsList", result);
                var eventArr = [];
                var color;
                console.log('projectsList in sch ------> '+JSON.stringify(component.get("v.projectsList")));
                var projectsList = component.get("v.projectsList")
                result.forEach(function(key) {
                    for (var i = 0; i < projectsList.length; i++) {
                        if(key.buildertek__Schedule__r.buildertek__Project__c == projectsList[i].Id){
                            color =  projectsList[i].Color;
                            console.log('color::',color);
                        }
                    }
                    console.log('new color::',color);
                    var vendorName;
                    var projectName;
                    if(key.buildertek__Contractor__c != undefined){
                    	vendorName =  key.buildertek__Contractor__r.Name;
                    }else{
                    	vendorName = '';
                    }
                    if(key.buildertek__Schedule__r.buildertek__Project__c != undefined){
                    	projectName = key.buildertek__Schedule__r.buildertek__Project__r.Name;
                    }else{
                    	projectName = '';
                    }
                    key.buildertek__Start__c = key.buildertek__Start__c+' 00:00:00';
                    key.buildertek__Finish__c = key.buildertek__Finish__c+' 01:00:00';
                    var startdatetime = new Date(key.buildertek__Start__c);
					startdatetime.setHours(startdatetime.getHours()+23);
                    var datetime = new Date(key.buildertek__Finish__c);
					datetime.setHours(datetime.getHours()+23);
                    eventArr.push({
                        'id':key.Id,
                        'start':key.buildertek__Start__c,
                        'end':datetime,
                        'title':projectName + ' - '+vendorName+' - '+ key.Name,
                        'color': color,
                        'allDay': true
                    });
                });
                console.log(eventArr);
                function addDays(date, days) {
                  var result = new Date(date);
                  result.setDate(result.getDate() + days);
                  return result;
                }
                //component.set("v.selectedEvents", eventArr);
                $('#calendar').fullCalendar('addEventSource', eventArr, true);
                this.loadCalendar(component,event,helper,eventArr,defaultDate);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getAllActiveProjects : function(component, event, helper){
        component.set("v.Spinner", true);
    	var action = component.get("c.getAllProjects");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	//component.set("v.projectsList", response.getReturnValue());
                var result = response.getReturnValue();
                var projectsList = [];
                var red, green, blue, col;
                for(var i=0;i<result.length;i++){
                    // var max = 250;
        			// var min = 150;
        			// var green = Math.floor(Math.random() * (max - min + 1)) + min;
                    red = Math.floor(Math.random() * 150) + 100; 
                    green = Math.floor(Math.random() * 150) + 100;
                    blue = Math.floor(Math.random() * 150) + 100; 
                    col = 'rgb(' + red + ', ' + green + ', ' + blue + ')'
                    console.log('color:::',col);
                    projectsList.push({
                        'Id': result[i].Id,
                        'Name': result[i].Name,
                        'Color': col
                    });
       
                }
                console.log('projectsList ---------> '+JSON.stringify(projectsList));
                component.set("v.projectsList", projectsList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getAllVendors : function(component, event, helper){
        component.set("v.Spinner", true);
    	var action = component.get("c.getVendors");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	component.set("v.vendorsList", response.getReturnValue());
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getAllTradeTypes : function(component, event, helper){
        component.set("v.Spinner", true);
    	var action = component.get("c.getTradeTypes");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	component.set("v.tradeTypesList", response.getReturnValue());
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    loadCalendar :function(component, events, helper,data, eventItemDate){
        //alert('load calendar');
        var defaultDate;
        if(eventItemDate != null){
        	defaultDate = eventItemDate;
        }else{
            defaultDate = new Date();
        }
        var recordId;
        var scheduleFinishDate;
        //$(document).ready(function(){
            //(function($) {
             	var m = moment();
                $('#calendar').fullCalendar({
                    buttonText: {
                        month:    'Month',
                        week:     'Week'
                    },
                    header: {
                       right: 'prev, title, next, prevYear, nextYear, month,agendaWeek'
                    },
                    views: {
                        month: {
                          columnFormat:'dddd'
                        },
                        agendaWeek:{
                          columnFormat:'ddd M/D',
                          eventLimit: false
                        },
                        agendaDay:{
                          columnFormat:'dddd',
                          eventLimit: false
                        },
                        listWeek:{
                          columnFormat:''
                        }
                    },
                    eventAfterAllRender: function(view) {
                       if(view.name == "month"){
                          $(".fc-content").css('height','auto');
                        }
                    },
                    eventClick: function(event, jsEvent, view) {
                      window.open('/'+event.id);
                    },
                    eventResize: function(event, delta, revertFunc, jsEvent, ui, view) {
                        $('.popover.fade.top').remove();
                        var recordId = event.id;
                        var eventDate;
                        if(event.end != null){
                        	eventDate = event.end.toString();
                        }
                        var droppedDate = convert(eventDate);
                        droppedDate = addDays(droppedDate, 0);
                        var timezoneValue = getTimeZone(droppedDate);
                        var datetime = new Date(droppedDate);
                        var offsetValue = timezoneValue.split(':');
                        if(offsetValue[0].includes('+')){
                        	offsetValue[0] = offsetValue[0].replace('+', '');
                        	datetime.setHours(datetime.getHours()-parseInt(offsetValue[0]));
                            datetime.setHours(datetime.getMinutes()-parseInt(offsetValue[1]));
                        }
                        var currentDay = getDayOfWeek(datetime);
                        console.log('currentDay -------> '+currentDay);
                        if(currentDay != 'Sunday' && currentDay != 'Saturday'){
                        	helper.updateScheduleItemEndDate(component,events,helper,recordId,datetime);
                        }else{
                            var startDate;
                            if(currentDay == 'Saturday'){
                            	startDate = addDays(datetime, 2);
                            }else if(currentDay == 'Sunday'){
                            	startDate = addDays(datetime, 1);
                            }
                            console.log('startDate --------> '+startDate);
                            helper.updateScheduleItemEndDate(component,events,helper,recordId,startDate);
                        }
                    },
                    eventDragStart: function(event, jsEvent, ui, view) {
                        var draggedEventIsAllDay;
                        draggedEventIsAllDay = event.allDay;
                    },
                    eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
                        $('.popover.fade.top').remove();
                        //component.set("v.recordId", event.id);
                        var recordId = event.id;
                        var eventDate;
                        console.log('endDate --------> '+event.start);
                        if(event.start != null){
                        	eventDate = event.start.toString();
                        }

                        var droppedDate = convert(eventDate);
                        droppedDate = addDays(droppedDate, 1);
                        var timezoneValue = getTimeZone(droppedDate);
                        var datetime = new Date(droppedDate);
                        var offsetValue = timezoneValue.split(':');
                        if(offsetValue[0].includes('-')){
                            offsetValue[0] = offsetValue[0].replace('-', '');
                        	datetime.setHours(datetime.getHours()+parseInt(offsetValue[0]));
                            datetime.setMinutes(datetime.getHours()+offsetValue[1]);
                        }else{
                        	datetime.setHours(datetime.getHours()-parseInt(offsetValue[0]));
                        }
                        //component.set("v.finishDate", droppedDate);
                        var currentDay = getDayOfWeek(datetime);
                        console.log('currentDay -------> '+currentDay);
                        if(currentDay != 'Sunday' && currentDay != 'Saturday'){
                        	helper.updateScheduleItemDate(component,events,helper,recordId,datetime);
                        }else{
                            var startDate;
                            if(currentDay == 'Saturday'){
                            	startDate = addDays(datetime, 0);
                            }else if(currentDay == 'Sunday'){
                            	startDate = addDays(datetime, 1);
                            }
                            helper.updateScheduleItemDate(component,events,helper,recordId,startDate);
                        }
                    },
                    timeZone: 'UTC',
                    weekNumbers: false,
                    selectable: true,
                    navLinks: true,
                    editable: true,
                    dragScroll: false,
                    droppable: true,
                    weekends: false,
                    nowIndicator: true,
                    eventOverlap: true,
                    defaultDate: moment(defaultDate),
                    events:data
                });
                var activeInactiveWeekends = false;
                checkCalendarWeekends();

                $('.showHideWeekend').on('change',function () {
                    checkCalendarWeekends();
                });

                function checkCalendarWeekends(){

                    if ($('.showHideWeekend').is(':checked')) {
                        activeInactiveWeekends = true;
                        $('#calendar').fullCalendar('option', {
                            weekends: activeInactiveWeekends
                        });
                    } else {
                        activeInactiveWeekends = false;
                        $('#calendar').fullCalendar('option', {
                            weekends: activeInactiveWeekends
                        });
                    }

                }
                function convert(str) {
                  var date = new Date(str),
                    mnth = ("0" + (date.getMonth() + 1)).slice(-2),
                    day = ("0" + date.getDate()).slice(-2);
                  return [date.getFullYear(), mnth, day].join("-");
                }
        		function getDayOfWeek(date) {
                  const dayOfWeek = new Date(date).getDay();
                  return isNaN(dayOfWeek) ? null :
                    ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayOfWeek];
                }
        		function addDays(date, days) {
                  var result = new Date(date);
                  result.setDate(result.getDate() + days);
                  return result;
                }
        		function getTimeZone(newDate) {
                    var offset = newDate.getTimezoneOffset(), o = Math.abs(offset);
                    return (offset < 0 ? "+" : "-") + ("00" + Math.floor(o / 60)).slice(-2) + ":" + ("00" + (o % 60)).slice(-2);
                }

            //})(jQuery);
        //});
        console.log('recordId -------> '+component.get("v.recordId"));
        console.log('scheduleFinishDate -------> '+component.get("v.finishDate"));
        component.set("v.Spinner", false);
    },

    updateScheduleItemDate : function(component, event, helper, recordId, eventDate){
        console.log('update fired');
        console.log(recordId);
        console.log(eventDate);
        component.set("v.recordId", recordId);
        component.set("v.finishDate", eventDate);

    },

    updateScheduleItemEndDate : function(component, event, helper, recordId, eventDate){
        console.log('update fired');
        console.log(recordId);
        console.log(eventDate);
        component.set("v.recordId", recordId);
        component.set("v.endDate", eventDate);

    }
})