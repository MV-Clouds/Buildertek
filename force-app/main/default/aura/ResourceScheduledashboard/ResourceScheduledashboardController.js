({
    doInit: function(component, event, helper) {

        //helper.getResources(component);
        var today = new Date();
        component.set("v.calendarView", "Dayview");
        // component.set("v.isConflictview", "Standard");
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 1);
        var now = new Date();
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        helper.currentWeekDates(component, Datevalue);
        helper.currentMonthsDates(component, Datevalue);
        helper.getprojectTaskscontacts(component);
        // helper.gettabname(component);

    },

    Standardview: function(component, event, helper) {
        component.set("v.isConflictview", "Standard");
        //var today = new Date();
        // component.set("v.isConflictview", "Standard");
        //var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        // var now = new Date();
        // component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));

        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }

        if (component.get("v.calendarView") == 'weekview') {
            var weekcurrentDate = component.get("v.beforeweekDate");
            var todayweek = new Date(weekcurrentDate);
            var beforeOfWeek = new Date(todayweek.getFullYear(), todayweek.getMonth() + 3, 0);
            // alert(beforeOfWeek);
            helper.groupbyWeekViewHelper(component, beforeOfWeek);
        }

        // helper.currentWeekDates(component,Datevalue);
        // helper.currentMonthsDates(component,Datevalue);
    },
    Conflictview: function(component, event, helper) {
        component.set("v.isConflictview", "Conflicts");

        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }


        if (component.get("v.calendarView") == 'weekview') {
            var weekcurrentDate = component.get("v.beforeweekDate");
            var todayweek = new Date(weekcurrentDate);
            var beforeOfWeek = new Date(todayweek.getFullYear(), todayweek.getMonth() + 3, 0);
            // alert(beforeOfWeek);
            helper.groupbyWeekViewHelper(component, beforeOfWeek);
        }


    },
    previousWeek: function(component, event, helper) {
        //component.set("v.showSpinner", true);
        helper.currentWeekDates(component, component.get("v.beforeweekDate"));
    },
    nextWeek: function(component, event, helper) {
        //component.set("v.showSpinner", true);
        helper.currentWeekDates(component, component.get("v.weeklastDate"));
    },
    previousgroupbyWeek: function(component, event, helper) {
        helper.groupbyWeekViewHelper(component, component.get("v.beforeweekDate"));
    },
    nextgroupbyWeek: function(component, event, helper) {
        helper.groupbyWeekViewHelper(component, component.get("v.weeklastDate"));
    },

    oneWeek: function(component, event, helper) {
        //component.set("v.showSpinner", true);
        component.set("v.calendarView", "week");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 1);
        helper.currentWeekDates(component, Datevalue);

    },
    groupbyweek: function(component, event, helper) {
        //component.set("v.showSpinner", true);
        component.set("v.calendarView", "weekview");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 1);
        helper.groupbyWeekViewHelper(component, Datevalue);

    },
    displayresources: function(component, event, helper) {
        //  alert('hii');
        console.log('display')
    },
    resourcedrawTable: function(component, event, helper) {

        //Start
        var conflictview = component.get("v.isConflictview");
        //alert('conflictview---'+conflictview);
        var weekDates = component.get("v.weekDates");
        var eventList = component.get("v.eventList");
        // console.log('Week Dates::', JSON.stringify(weekDates));
        // console.log('Event List::', JSON.stringify(eventList));

        var tbody = '';
        var datatable = '';
        tbody += '<table class="table table-hover" id="demo-1" style="border: 1px solid #ececec;">';
        tbody += '<thead><tr>';
        tbody += '<th style="color: #313131;font-weight: normal;border-right: 1px solid #ECECEC;border-bottom: none;background: #f8f8f8;width: 70%;">Name</th>';
        tbody += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;width: 30%;">Task</th>';
        tbody += '</tr></thead>';
        tbody += '<tbody>';
        console.log('EventList =======> ' + eventList.length);
        
        console.log('weekDates ====> ',{weekDates});

        console.log('-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-');
        for (var i = 0; i < eventList.length; i++) {

            var Event = eventList[i];
            console.log('Event '+ i + ' -> ',{Event});
            // document.getElementById("colorpad").style.color = dynamiccolor;

            tbody += '<tr style="height: 50px;">';
            tbody += '<td style="border-right: 1px solid #ECECEC !important;width: 70%;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;"><span class="colorpad" style="color: white;background-color: green;width: 30px;height: 30px;border-radius: 50%;font-size: 20px;text-align: center;position: absolute;margin-top: 4px;" >' + eventList[i].FirstLetterofContractresourceName + '</span>&nbsp;&nbsp;<b><a style="margin-left:31px;" target="_blank" href="/' + eventList[i].ContractresourceId + '">' + eventList[i].ContractresourceName + '</a></b><br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(' + eventList[i].Companyname + '-' + eventList[i].TradeType + ')</td>';
            tbody += '<td style="text-align: center;width: 30%;">' + eventList[i].tasks + '</td>';
            tbody += '</tr>';
            datatable += '<tr>';

            //for dataTable
            for (var k = 0; k < weekDates.length; k++) {
                //var SchedulerRecordList=eventList[i].SchedulerRecordList;
                //for(var m=0;m<SchedulerRecordList.length;m++){
                if (eventList[i].ProjectTaskRecordsList != undefined) {
                    var EquipmentRecordsList = eventList[i].ProjectTaskRecordsList;
                    var tasks = 0;

                    for (var p = 0; p < EquipmentRecordsList.length; p++) {
                        // console.log('aboveif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[p].day + 'record enddate-----&& <= ' + EquipmentRecordsList[p].endday);
                        // console.log(typeof weekDates[k].Date);
                        // console.log(typeof EquipmentRecordsList[p].day);
                        // console.log(typeof EquipmentRecordsList[p].endday);
                        if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[p].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[p].endday).valueOf()) {
                            tasks++;
                        }
                    }
                }

                if (tasks == 1) {
                    if (weekDates[k].Day != 'Sun' && conflictview != 'Conflicts') {
                        var backgroundColor = '#3a8ed8' ;
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].Completion == 100) {
                                    backgroundColor = '#2caa10' ;
                                }
                            }
                        }

                        datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;" data-account="' + eventList[i].ContractresourceName + '">';
                        datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto;background: ' + backgroundColor + ';padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}"/></span>';
                        // datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #3a8ed8;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image  src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}"/></span>';
                        datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                        datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left; margin-left: -32rem;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 509px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                        datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd;width: 700px;padding: 10px; margin-left: -32rem; float:left; background: #fff;">';
                        datatable += '<tbody><tr>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 90px">Project Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px">Schedule Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 84px">Task Description</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px">Duration</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 60px;">Start Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 60px;">End Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Completion %</th>'
                        datatable += '</tr>';
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].projectId == undefined) {
                                    EquipmentRecordsList[t].projectId = "";
                                }
                                datatable += '<tr>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                                datatable += '</tr>';

                            }
                        }
                        datatable += '</tbody></table>';
                        datatable += '</div>';
                        datatable += '</td></li>';
                    } else {

                        if (weekDates[k].Day != 'Sun' && conflictview == 'Conflicts') {
                            datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                            datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';

                            datatable += '</li></td>';
                        } else {
                            datatable += '<td style="text-align: center;padding: 0px !important;">';

                            datatable += '</td>';
                        }

                    }
                }
                if (tasks < 1) {
                    if (weekDates[k].Day != 'Sun') {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                        datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';

                        datatable += '</li></td>';
                    } else {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                        datatable += '</td>';
                    }
                }
                if (eventList[i].simultaneousTasksContractorResources != undefined) {
                    // console.log('Tasks::', tasks);
                    // console.log('Event List::', eventList[i].simultaneousTasksContractorResources);
                }
                if (tasks > 1 && eventList[i].simultaneousTasksContractorResources != undefined && tasks > eventList[i].simultaneousTasksContractorResources) {
                    var backgroundColor = '#3a8ed8' ;
                    for (var t = 0; t < EquipmentRecordsList.length; t++) {
                        if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                            if (EquipmentRecordsList[t].Completion == 100) {
                                backgroundColor = '#2caa10' ;
                            }
                        }
                    }
                    if (weekDates[k].Day != 'Sun') {
                        datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                        datatable += '<li style="display: inline-block;"data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: ' + backgroundColor + ';padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}" /></span>';
                        datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                        datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left; margin-left: -32rem;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 509px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                        datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px; margin-left: -32rem; float:left; background: #fff;">';
                        datatable += '<tbody><tr>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 90px">Project Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px">Schedule Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 84px">Task Description</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Duration</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 60px;">Start Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 60px;">End Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Completion %</th>'
                        datatable += '</tr>';
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].projectId == undefined) {
                                    EquipmentRecordsList[t].projectId = "";
                                }
                                datatable += '<tr>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                                datatable += '</tr>';

                            }
                        }
                        datatable += '</tbody></table>';

                        datatable += '</div>';
                        datatable += '</li></td>';
                    } else {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                        datatable += '</td>';
                    }
                } else if (tasks > 1 && eventList[i].simultaneousTasksContractorResources != undefined && tasks <= eventList[i].simultaneousTasksContractorResources) {
                    if (weekDates[k].Day != 'Sun') {
                        var backgroundColor = '#3a8ed8' ;
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].Completion == 100) {
                                    backgroundColor = '#2caa10' ;
                                }
                            }
                        }
                        datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                        datatable += '<li style="display: inline-block;"data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: ' + backgroundColor + ';padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';
                        datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                        datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;margin-left: -32rem; padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 509px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                        datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px; margin-left: -32rem; float:left; background: #fff;">';
                        datatable += '<tbody><tr>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 90px;">Project Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px;">Schedule Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 84px;">Task Description</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Duration </th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 60px;">Start Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 60px;">End Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;  width: 0px;">Completion %</th>'
                        datatable += '</tr>';
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].projectId == undefined) {
                                    EquipmentRecordsList[t].projectId = "";
                                }
                                datatable += '<tr>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                                datatable += '</tr>';

                            }
                        }
                        datatable += '</tbody></table>';

                        datatable += '</div>';
                        datatable += '</li></td>';
                    } else {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                        datatable += '</td>';
                    }
                } else if (tasks >= 2 && (eventList[i].simultaneousTasksContractorResources == undefined || eventList[i].simultaneousTasksContractorResources == 0)) {
                    if (weekDates[k].Day != 'Sun') {
                        datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                        datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: #d30f0f;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}"/></span>';
                        datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                        datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;  margin-left: -32rem; padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 509px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                        datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px; margin-left: -32rem; float:left; background: #fff;">';
                        datatable += '<tbody><tr>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 90px">Project Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px">Schedule Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 84px">Task Description</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Duration</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 60px;">Start Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 60px;">End Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 0px;">Completion %</th>'
                        datatable += '</tr>';
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                if (EquipmentRecordsList[t].projectId == undefined) {
                                    EquipmentRecordsList[t].projectId = "";
                                }
                                datatable += '<tr>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                                datatable += '</tr>';

                            }
                        }
                        datatable += '</tbody></table>';

                        datatable += '</div>';
                        datatable += '</li></td>';
                    } else {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 35px !important;">';
                        datatable += '</td>';
                    }
                }
                //}
            }
            datatable += '</tr>';
        }
        tbody += '</tbody></table>';
        if (tbody != null) {
            document.getElementById("work-div").innerHTML = tbody;
        }
        var dataDiv = '';
        var mnt1 = '';
        var mnt2 = '';
        var yy1 = '';
        var yy2 = '';
        var colspanmnt1 = 0;
        var colspanmnt2 = 0;
        var headerTr = '';
        var bodyTr = '';
        dataDiv += '<table class="table table-hover" id="demo-1" >';
        dataDiv += '<thead>';
        //dataDiv+='<tr><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th></tr>';
        //dataDiv+='<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center> september</center></th></tr>';
        bodyTr += '<tr>';
        for (var k = 0; k < weekDates.length; k++) {
            if (mnt1 == '' && weekDates[k].DayMonth != undefined) {
                mnt1 = weekDates[k].DayMonth;
                yy1 = weekDates[k].Date
                const date1 = new Date(yy1);
                yy1 = date1.getFullYear();
                colspanmnt1 = colspanmnt1 + 1;
            } else if (mnt1 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt1 = weekDates[k].DayMonth;
                yy1 = weekDates[k].Date;
                const date2 = new Date(yy1);
                yy1 = date2.getFullYear();
                colspanmnt1 = colspanmnt1 + 1;
            }

            if (mnt1 != '' && mnt2 == '' && weekDates[k].DayMonth != mnt1 && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
                yy2 = weekDates[k].Date
                const date1 = new Date(yy2);
                yy2 = date1.getFullYear();
                colspanmnt2 = colspanmnt2 + 1;
            } else if (mnt2 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
                yy2 = weekDates[k].Date
                const date1 = new Date(yy2);
                yy2 = date1.getFullYear();
                colspanmnt2 = colspanmnt2 + 1;
            }




            if (weekDates[k].Day != 'Sun') {
                if (weekDates[k].Dayview == '01') {
                    bodyTr += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;border-left: 2px solid #dbe4ee;">' + weekDates[k].Day + '&nbsp;' + weekDates[k].Dayview + '</th>';
                } else {
                    bodyTr += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;">' + weekDates[k].Day + '&nbsp;' + weekDates[k].Dayview + '</th>';
                }

            } else {
                bodyTr += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;"></th>';
            }
            // console.log(weekDates[k].DayMonth + '-----' + weekDates[k].Day + '--------' + weekDates[k].Dayview);
        }
        if (mnt2 == 0) {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + ' ' + yy1 + '</center></th></tr>';
        } else {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="' + colspanmnt1 + '" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + ' ' + yy1 + '</center></th><th colspan="' + colspanmnt2 + '" style="height: 40px;background: #f8f8f8;border-left: 2px solid #dbe4ee;"><center>' + mnt2 + ' ' + yy2 + '</center></th></tr>';
        }

        // console.log('yy1 ===> ' + yy1);
        // console.log('yy2 ===> ' + yy2);

        // console.log('-----' + weekDates.length);
        // console.log(mnt1 + '-----' + mnt2);
        // console.log(colspanmnt1 + '-----' + colspanmnt2);

        bodyTr += '</tr>';

        dataDiv += headerTr + bodyTr + datatable;

        dataDiv += '</thead>';
        dataDiv += '</table>';


        document.getElementById("data-div").innerHTML = dataDiv;

        function randomColor() {
            var letters = '0123456789ABCDEF';
            var dynamiccolor = '#';
            for (var i = 0; i < 6; i++) {
                dynamiccolor += letters[Math.floor(Math.random() * 16)];
            }
            return dynamiccolor;
        }
        setTimeout(function() {
            var elements = document.getElementsByClassName("colorpad");
            for (var i = 0; i < elements.length; i++) {
                elements[i].style.backgroundColor = randomColor();
            }
        });

    },
    displayPopup: function(component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues + "cnt").style.display = "";
    },

    hidePopup: function(component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues + "cnt").style.display = "none";
    },

    drawTablebyweek: function(component, event, helper) {

        //Start
        var conflictview = component.get("v.isConflictview");
        var weekDates = component.get("v.weekDates");

        var eventList = component.get("v.eventList");
        // console.log('Week Dates::', JSON.stringify(weekDates));
        // console.log('Event List::', JSON.stringify(eventList));

        var tbody = '';
        var datatable = '';
        tbody += '<table class="table table-hover" id="demo-1" style="border: 1px solid #ececec;">';
        tbody += '<thead><tr>';
        tbody += '<th style="color: #313131;font-weight: normal;border-right: 1px solid #ECECEC;border-bottom: none;background: #f8f8f8;width: 70%;">Name</th>';
        tbody += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;width: 30%;">Task</th>';
        tbody += '</tr></thead>';
        tbody += '<tbody>';
        console.log('EventList =======> ' + eventList.length);
        for (var i = 0; i < eventList.length; i++) {
            tbody += '<tr style="height: 50px;">';
            tbody += '<td style="border-right: 1px solid #ECECEC !important;width: 70%;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;"><span class="weeklycolorpad" style="color: white;background-color: green;width: 30px;height: 30px;border-radius: 50%;font-size: 20px;text-align: center;position: absolute;margin-top: 4px;" >' + eventList[i].FirstLetterofContractresourceName + '</span>&nbsp;&nbsp;<b><a style="margin-left: 31px;" target="_blank" href="/' + eventList[i].ContractresourceId + '">' + eventList[i].ContractresourceName + '</a></b><br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (' + eventList[i].Companyname + '-' + eventList[i].TradeType + ')</td>';
            tbody += '<td style="text-align: center;width: 30%;">' + eventList[i].tasks + '</td>';
            tbody += '</tr>';
            datatable += '<tr>';

            //for dataTable

            for (var k = 0; k < weekDates.length; k++) {

                // var SchedulerRecordList=eventList[i].SchedulerRecordList;
                // for(var m=0;m<SchedulerRecordList.length;m++){

                if (eventList[i].ProjectTaskRecordsList != undefined) {
                    var EquipmentRecordsList = eventList[i].ProjectTaskRecordsList;
                    var tasks = 0;
                    for (var p = 0; p < EquipmentRecordsList.length; p++) {
                        //console.log(weekDates[k].Date+'----startdate-----'+EquipmentRecordsList[p].day );
                        //console.log(weekDates[k].weekEndDate+'----enddate-----'+EquipmentRecordsList[p].endday);

                        if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[p].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[p].day).valueOf()) {

                            tasks++;
                        }
                    }
                }
                if (tasks == 1) {
                    if (conflictview != 'Conflicts') {
                        var backgroundColor = '#3a8ed8' ;
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                                if (EquipmentRecordsList[t].Completion == 100) {
                                    backgroundColor = '#2caa10' ;
                                }
                            }
                        }
                        datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                        datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto;background: ' + backgroundColor + ';padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;" ><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';
                        datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                        datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left; margin-left: -32rem;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 509px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                        datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd;width: 700px;padding: 10px; margin-left: -32rem; float:left;background: #fff;">';
                        datatable += '<tbody><tr>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 90px">Project Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px">Schedule Name</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 84px">Task Description</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px;">Duration</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Start Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">End Date</th>';
                        datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px; width: 80px;">Completion %</th>'
                        datatable += '</tr>';
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {

                            if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                                if (EquipmentRecordsList[t].projectId == undefined) {
                                    EquipmentRecordsList[t].projectId = "";
                                }
                                datatable += '<tr>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                                datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                                datatable += '</tr>';

                            }
                        }
                        datatable += '</tbody></table>';
                        datatable += '</div>';
                        datatable += '</td></li>';
                    } else {

                        if (weekDates[k].Day != 'Sun' && conflictview == 'Conflicts') {
                            datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                            datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';

                            datatable += '</li></td>';
                        } else {
                            datatable += '<td style="text-align: center;padding: 0px !important;">';

                            datatable += '</td>';
                        }

                    }
                }
                if (tasks < 1) {
                    // if( weekDates[k].Day != 'Sun'){
                    datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                    datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';

                    datatable += '</li></td>';
                    /* }else{
                         datatable+='<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                         datatable+='</td>';
                     }*/
                }
                if (tasks >= 2 && eventList[i].simultaneousTasksContractorResources != undefined && tasks < eventList[i].simultaneousTasksContractorResources) {
                    // if( weekDates[k].Day != 'Sun'){
                    datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                    datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: #d30f0f;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}" /></span>';
                    datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                    datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                    datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width:700px;padding: 10px;">';
                    datatable += '<tbody><tr>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Schedule Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                    datatable += '</tr>';
                    for (var t = 0; t < EquipmentRecordsList.length; t++) {
                        if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                            if (EquipmentRecordsList[t].projectId == undefined) {
                                EquipmentRecordsList[t].projectId = "";
                            }
                            datatable += '<tr>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                            datatable += '</tr>';

                        }
                    }
                    datatable += '</tbody></table>';

                    datatable += '</div>';
                    datatable += '</li></td>';
                    /* }else{
                         datatable+='<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                         datatable+='</td>';
                     }*/
                } else if (tasks >= 2 && eventList[i].simultaneousTasksContractorResources != undefined && tasks >= eventList[i].simultaneousTasksContractorResources) {
                    // if( weekDates[k].Day != 'Sun'){
                    var backgroundColor = '#3a8ed8' ;
                    for (var t = 0; t < EquipmentRecordsList.length; t++) {
                        if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                            if (EquipmentRecordsList[t].Completion == 100) {
                                backgroundColor = '#2caa10' ;
                            }
                        }
                    }
                    datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                    datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: ' + backgroundColor + ';padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';
                    datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                    datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                    datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width:700px;padding: 10px;">';
                    datatable += '<tbody><tr>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Schedule Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                    datatable += '</tr>';
                    for (var t = 0; t < EquipmentRecordsList.length; t++) {
                        if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                            if (EquipmentRecordsList[t].projectId == undefined) {
                                EquipmentRecordsList[t].projectId = "";
                            }
                            datatable += '<tr>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                            datatable += '</tr>';

                        }
                    }
                    datatable += '</tbody></table>';

                    datatable += '</div>';
                    datatable += '</li></td>';
                    /* }else{
                         datatable+='<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                         datatable+='</td>';
                     }*/
                } else if (tasks >= 2 && (eventList[i].simultaneousTasksContractorResources == undefined || eventList[i].simultaneousTasksContractorResources == 0)) {
                    datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                    datatable += '<li style="display: inline-block;" data-account="' + eventList[i].ContractresourceId + '"><span  data-account="' + eventList[i].ContractresourceId + '" style="display: block;margin: 0 auto; background: #d30f0f;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image  data-account="' + eventList[i].ContractresourceId + '" src="/resource/buildertek__buildingfa" height="20px" width="20px" onclick="{!c.displayresources}" /></span>';
                    datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                    datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                    datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width:700px;padding: 10px;">';
                    datatable += '<tbody><tr>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Schedule Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                    datatable += '</tr>';
                    for (var t = 0; t < EquipmentRecordsList.length; t++) {
                        if (new Date(weekDates[k].Date).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf() && new Date(weekDates[k].weekEndDate).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf()) {
                            if (EquipmentRecordsList[t].projectId == undefined) {
                                EquipmentRecordsList[t].projectId = "";
                            }
                            datatable += '<tr>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].Model + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                            datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                            datatable += '</tr>';

                        }
                    }
                    datatable += '</tbody></table>';

                    datatable += '</div>';
                    datatable += '</li></td>';
                }
                //}
            }
            datatable += '</tr>';
        }
        tbody += '</tbody></table>';
        document.getElementById("work-div").innerHTML = tbody;

        var dataDiv = '';
        var mnt1 = '';
        var mnt2 = '';
        var yy1 = '';
        var yy2 = '';
        var colspanmnt1 = 0;
        var colspanmnt2 = 0;
        var headerTr = '';
        var bodyTr = '';
        dataDiv += '<table class="table table-hover" id="demo-1" >';
        dataDiv += '<thead>';
        //dataDiv+='<tr><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th></tr>';
        //dataDiv+='<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center> september</center></th></tr>';
        bodyTr += '<tr>';
        for (var k = 0; k < weekDates.length; k++) {
            if (mnt1 == '' && weekDates[k].DayMonth != undefined) {
                mnt1 = weekDates[k].DayMonth;
                yy1 = weekDates[k].Date
                const date1 = new Date(yy1);
                yy1 = date1.getFullYear();
                colspanmnt1 = colspanmnt1 + 1;
            } else if (mnt1 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt1 = weekDates[k].DayMonth;
                yy1 = weekDates[k].Date;
                const date2 = new Date(yy1);
                yy1 = date2.getFullYear();
                colspanmnt1 = colspanmnt1 + 1;
            }

            if (mnt1 != '' && mnt2 == '' && weekDates[k].DayMonth != mnt1 && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
                yy2 = weekDates[k].Date
                const date1 = new Date(yy2);
                yy2 = date1.getFullYear();
                colspanmnt2 = colspanmnt2 + 1;
            } else if (mnt2 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
                yy2 = weekDates[k].Date
                const date1 = new Date(yy2);
                yy2 = date1.getFullYear();
                colspanmnt2 = colspanmnt2 + 1;
            }




            //  if(weekDates[k].Day != 'Sun'){
            if (weekDates[k].Dayview == '01') {
                bodyTr += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;border-left: 2px solid #dbe4ee;">' + weekDates[k].Day + '</th>';
            } else {
                bodyTr += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;">' + weekDates[k].Day + '</th>';
            }

            /* }
             else{
                 bodyTr+='<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;"></th>';
             }*/
            console.log(weekDates[k].DayMonth + '-----' + weekDates[k].Day + '--------' + weekDates[k].Dayview);
        }
        if (mnt2 == 0) {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + ' ' + yy1 + '</center></th></tr>';
        } else {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="' + colspanmnt1 + '" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + ' ' + yy1 + '</center></th><th colspan="' + colspanmnt2 + '" style="height: 40px;background: #f8f8f8;border-left: 2px solid #dbe4ee;"><center>' + mnt2 + ' ' + yy2 + '</center></th></tr>';
        }


        console.log('-----' + weekDates.length);
        console.log(mnt1 + '-----' + mnt2);
        console.log(colspanmnt1 + '-----' + colspanmnt2);

        bodyTr += '</tr>';

        dataDiv += headerTr + bodyTr + datatable;

        dataDiv += '</thead>';
        dataDiv += '</table>';


        document.getElementById("data-div").innerHTML = dataDiv;

        function randomColor() {
            var letters = '0123456789ABCDEF';
            var dynamiccolor = '#';
            for (var i = 0; i < 6; i++) {
                dynamiccolor += letters[Math.floor(Math.random() * 16)];
            }
            return dynamiccolor;
        }
        setTimeout(function() {
            var elements = document.getElementsByClassName("weeklycolorpad");
            for (var i = 0; i < elements.length; i++) {
                elements[i].style.backgroundColor = randomColor();
            }
        });

    },

    handleComponentEvent: function(component, event, helper) {
        // get the selected Account record from the COMPONETN event

        //var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //component.set("v.selectedContact", selectedAccountGetFromEvent.Id);
        var slectedcontactId = JSON.stringify(component.get("v.selectedContact").Id);
        var slectedprojectId = JSON.stringify(component.get("v.selectedproject").Id);
        var slectedTradetypeId = JSON.stringify(component.get("v.selectedTradetype").Id);


        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }
        if (component.get("v.calendarView") == 'weekview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            // alert(today);
            var beforeOfWeek = new Date(today.getFullYear(), today.getMonth() + 3, 0);
            // alert(beforeOfWeek);
            helper.groupbyWeekViewHelper(component, beforeOfWeek);
        }

    },
    ClearhandleComponentEvent: function(component, event, helper) {
        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }
        if (component.get("v.calendarView") == 'weekview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            var beforeOfWeek = new Date(today.getFullYear(), today.getMonth() + 3, 0);
            helper.groupbyWeekViewHelper(component, beforeOfWeek);
        }
    },

    clickedDiv: function(component, event, helper) {
        console.log(event);
        event.stopPropagation();
        event.preventDefault()
        if (event.target.tagName == 'IMG' && event.target.dataset.account) {
            console.log(event.target.dataset.account);
            var action = component.get('c.getScheduleItemsByResource');
            action.setParams({
                'contactId': event.target.dataset.account
            });
            action.setCallback(this, function(response) {
                console.log(response.getState());
                if (response.getState() == 'SUCCESS') {
                    console.log(response.getReturnValue());
                    component.set("v.showModal", true);
                    component.set("v.showModal1", false);
                    component.set("v.contactScheduleItemList", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },


    clickedDiv1: function(component, event, helper) {
        event.stopPropagation();
        console.log(event);
        event.preventDefault()
        if (event.target.tagName == 'IMG' && event.target.dataset.account) {
            console.log(event.target.dataset.account);
            var action = component.get('c.getScheduleItemsByContact');
            // alert(event.target.dataset.account);
            action.setParams({
                'contactId': event.target.dataset.account
            });
            action.setCallback(this, function(response) {
                console.log(response.getState());
                if (response.getState() == 'SUCCESS') {
                    //   alert(response.getState());
                    console.log(response.getReturnValue());

                    component.set("v.showModal1", true);
                    component.set("v.showModal", false);
                    component.set("v.tradeTypeScheduleItemList", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },

    SaveItems: function(component, event, helper) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.tradeTypeScheduleItemList');
        var action = component.get("c.updateRecords");

        action.setParams({
            'resourceRecords': listOfRecords
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);

                component.set('v.isLoading', false);

            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },



    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
    },

    closeModal1: function(component, event, helper) {
        component.set("v.showModal1", false);
    }

})