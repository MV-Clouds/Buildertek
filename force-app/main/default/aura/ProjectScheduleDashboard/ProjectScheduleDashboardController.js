({
    /*doInit: function (component, event, helper) {
        var today = new Date();
        component.set("v.calendarView", "Dayview");
        var todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 12);
        var now = new Date();
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        helper.currentWeekDates(component, todayDate);
        helper.currentMonthsDates(component, todayDate);
    },

    Standardview: function (component, event, helper) {
        component.set("v.isConflictview", "Standard");
        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }
    },

    Conflictview: function (component, event, helper) {
        component.set("v.isConflictview", "Conflicts");
        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }
    },

    previousWeek: function (component, event, helper) {
        helper.currentWeekDates(component, component.get("v.beforeweekDate"));
    },
    nextWeek: function (component, event, helper) {
        helper.currentWeekDates(component, component.get("v.weeklastDate"));
    },

    taskdrawTable: function (component, event, helper) {
        var conflictview = component.get("v.isConflictview");
        //alert('conflictview---'+conflictview);
        var weekDates = component.get("v.weekDates");
        var eventList = component.get("v.eventList");
        console.log('Week Dates::', JSON.stringify(weekDates));
        console.log('Event List::', JSON.stringify(eventList));

        var tbody = '';
        var datatable = '';
        tbody += '<table class="table table-hover" id="demo-1" style="border: 1px solid #ececec;">';
        tbody += '<thead><tr>';
        tbody += '<th style="color: #313131;font-weight: normal;border-right: 1px solid #ECECEC;border-bottom: none;background: #f8f8f8;width: 70%;">Name</th>';
        tbody += '<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;width: 30%;">Days</th>';
        tbody += '</tr></thead>';
        tbody += '<tbody>';
        console.log('EventList =======> ' + eventList.length);
        for (var i = 0; i < eventList.length; i++) {
            tbody += '<tr>';
            tbody += '<td style="border-right: 1px solid #ECECEC !important;width: 70%;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;"><image src="/resource/HeadIcon" height="20px" width="20px"/>&nbsp;&nbsp;' + eventList[i].title + '</td>';
            tbody += '<td style="text-align: center;width: 30%;">' + eventList[i].taskdays + '</td>';
            tbody += '</tr>';
            datatable += '<tr>';

            for (var k = 0; k < weekDates.length; k++) {
                if (weekDates[k].Day != 'Sun' && conflictview != 'Conflicts') {
                    datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                    datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #3a8ed8;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildingfa" height="20px" width="20px"/></span>';
                    datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                    datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                    datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd;width: 700px;padding: 10px;">';
                    datatable += '<tbody><tr>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Start Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">End Date</th>';
                    datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                    datatable += '</tr>';
                    datatable += '<tr>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + eventList[i].projectId + '</td>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + eventList[i].taskdescription + '</td>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + eventList[i].taskdays + '</td>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + eventList[i].startdate + '</td>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + eventList[i].enddate + '</td>';
                    datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + eventList[i].Completion + '</td>';
                    datatable += '</tr>';

                    datatable += '</tbody></table>';
                    datatable += '</div>';
                    datatable += '</td></li>';
                } else {
                    if (weekDates[k].Day != 'Sun') {
                        datatable += '<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                        datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildingfa" height="20px" width="20px"/></span>';
                        datatable += '</li></td>';
                    } else {
                        datatable += '<td style="text-align: center;padding: 0px !important;">';
                        datatable += '</td>';
                    }
                }
                //}
                // if (tasks > 1 && eventList[i].simultaneousTasksContractorResources != undefined && tasks > eventList[i].simultaneousTasksContractorResources) {
                //     if (weekDates[k].Day != 'Sun') {
                //         datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                //         datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto; background: #21649e;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildingfa" height="20px" width="20px"/></span>';
                //         datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                //         datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                //         datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px;">';
                //         datatable += '<tbody><tr>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                //         datatable += '</tr>';
                //         for (var t = 0; t < EquipmentRecordsList.length; t++) {
                //             if (weekDates[k].Date >= EquipmentRecordsList[t].day && weekDates[k].Date <= EquipmentRecordsList[t].endday) {
                //                 datatable += '<tr>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                //                 datatable += '</tr>';

                //             }
                //         }
                //         datatable += '</tbody></table>';

                //         datatable += '</div>';
                //         datatable += '</li></td>';
                //     } else {
                //         datatable += '<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                //         datatable += '</td>';
                //     }
                // } else if (tasks > 1 && eventList[i].simultaneousTasksContractorResources != undefined && tasks <= eventList[i].simultaneousTasksContractorResources) {
                //     if (weekDates[k].Day != 'Sun') {
                //         datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                //         datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto; background: #3a8ed8;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildingfa" height="20px" width="20px"/></span>';
                //         datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                //         datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                //         datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px;">';
                //         datatable += '<tbody><tr>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                //         datatable += '</tr>';
                //         for (var t = 0; t < EquipmentRecordsList.length; t++) {
                //             if (weekDates[k].Date >= EquipmentRecordsList[t].day && weekDates[k].Date <= EquipmentRecordsList[t].endday) {
                //                 datatable += '<tr>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                //                 datatable += '</tr>';

                //             }
                //         }
                //         datatable += '</tbody></table>';

                //         datatable += '</div>';
                //         datatable += '</li></td>';
                //     } else {
                //         datatable += '<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                //         datatable += '</td>';
                //     }
                // } else if (tasks >= 2 && (eventList[i].simultaneousTasksContractorResources == undefined || eventList[i].simultaneousTasksContractorResources == 0)) {
                //     if (weekDates[k].Day != 'Sun') {
                //         datatable += '<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                //         datatable += '<li style="display: inline-block;"><span style="display: block;margin: 0 auto; background: #21649e;padding: 3px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 30px;width: 30px;"><image src="/resource/buildingfa" height="20px" width="20px"/></span>';
                //         datatable += '<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;">';
                //         datatable += '<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px"><image src="/resource/playbutton" style="float:left;width: 17px;margin-left: 0px;position: absolute;top: -12px;" />' + eventList[i].ContractresourceName + ' </h2>';
                //         datatable += '<table class="tabel table-bordered" style="border: 1px solid #ddd !important;width: 700px;padding: 10px;">';
                //         datatable += '<tbody><tr>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Project Name</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Task Description</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Duration</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">Start Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;width: 80px;">End Date</th>';
                //         datatable += '<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Completion %</th>'
                //         datatable += '</tr>';
                //         for (var t = 0; t < EquipmentRecordsList.length; t++) {
                //             if (weekDates[k].Date >= EquipmentRecordsList[t].day && weekDates[k].Date <= EquipmentRecordsList[t].endday) {
                //                 datatable += '<tr>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">' + EquipmentRecordsList[t].projectId + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdescription + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].taskdays + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].startdate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].enddate + '</td>';
                //                 datatable += '<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">' + EquipmentRecordsList[t].Completion + '</td>';
                //                 datatable += '</tr>';

                //             }
                //         }
                //         datatable += '</tbody></table>';

                //         datatable += '</div>';
                //         datatable += '</li></td>';
                //     } else {
                //         datatable += '<td style="text-align: center;vertical-align: middle;padding: 0px !important;">';
                //         datatable += '</td>';
                //     }
                // }
                //}
            }
            datatable += '</tr>';
        }
        tbody += '</tbody></table>';
        if (tbody != null) {
            document.getElementById("project-div").innerHTML = tbody;
        }
        var dataDiv = '';
        var mnt1 = '';
        var mnt2 = '';
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
                colspanmnt1 = colspanmnt1 + 1;
            } else if (mnt1 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt1 = weekDates[k].DayMonth;
                colspanmnt1 = colspanmnt1 + 1;
            }

            if (mnt1 != '' && mnt2 == '' && weekDates[k].DayMonth != mnt1 && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
                colspanmnt2 = colspanmnt2 + 1;
            } else if (mnt2 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined) {
                mnt2 = weekDates[k].DayMonth;
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
            console.log(weekDates[k].DayMonth + '-----' + weekDates[k].Day + '--------' + weekDates[k].Dayview);
        }
        if (mnt2 == 0) {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + '</center></th></tr>';
        } else {
            headerTr += '<tr style="background: #f8f8f8;"><th colspan="' + colspanmnt1 + '" style="height: 40px;background: #f8f8f8;"><center>' + mnt1 + '</center></th><th colspan="' + colspanmnt2 + '" style="height: 40px;background: #f8f8f8;border-left: 2px solid #dbe4ee;"><center>' + mnt2 + '</center></th></tr>';
        }


        console.log('-----' + weekDates.length);
        console.log(mnt1 + '-----' + mnt2);
        console.log(colspanmnt1 + '-----' + colspanmnt2);

        bodyTr += '</tr>';

        dataDiv += headerTr + bodyTr + datatable;

        dataDiv += '</thead>';
        dataDiv += '</table>';


        document.getElementById("taskdata-div").innerHTML = dataDiv;
    },

    displayPopup: function (component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues + "cnt").style.display = "";
    },

    expandScheduleItem: function (component, event, helper) {

    },

    hidePopup: function (component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues + "cnt").style.display = "none";
    },



    handleComponentEvent: function (component, event, helper) {
        var slectedcontactId = JSON.stringify(component.get("v.selectedContact").Id);
        var slectedprojectId = JSON.stringify(component.get("v.selectedproject").Id);
        var slectedTradetypeId = JSON.stringify(component.get("v.selectedTradetype").Id);


        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }


    },
    ClearhandleComponentEvent: function (component, event, helper) {
        if (component.get("v.calendarView") == 'Dayview') {
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component, today);
        }

    }*/

})