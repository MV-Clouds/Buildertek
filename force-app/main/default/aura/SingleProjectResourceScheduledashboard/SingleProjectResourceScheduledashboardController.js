({
    doInit: function (component, event, helper) {

        var today = new Date();
        component.set("v.calendarView", "Dayview");
        var now = new Date();
        component.set("v.isFirst", true);
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), 1);
        let todayDateVal = new Date(today.getFullYear(), today.getMonth(), today.getDate())
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.BaseURLs", baseURL);

        component.set("v.currentDateValString", now.toLocaleDateString());
        component.set("v.todayDate", Datevalue.toLocaleDateString());
        component.set("v.datevalString", Datevalue.toLocaleDateString());
        component.set("v.todayDateHeader", now.toDateString());
        component.set("v.dateval", todayDateVal);

        var SelectedDate = `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
        component.set("v.SelectedDate", SelectedDate);

        if (component.get("v.recordId")) {
            var action = component.get("c.getProjectId");
            action.setParams({
                scheduleId: component.get("v.recordId")
            });

            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    debugger
                    let result = JSON.parse(response.getReturnValue());
                    if (result.Id != undefined && result.Id != null) {
                        component.set("v.project", result);
                        component.set("v.newSelectedProjectId", result.Id);
                        component.set("v.newSelectedProjectIdClone", result.Id);
                        component.set("v.isDisable", false);
                        helper.getTasksByProjects(component, helper, Datevalue);
                    } else {
                        component.set("v.isDisable", true);
                    }
                } else {
                    component.set("v.isDisable", true);
                    // helper.getTasksByProjects(component, helper, Datevalue);
                }
            });
            $A.enqueueAction(action);

        } else {
            helper.setFocusedTabLabel(component, event, helper);
            helper.getTasksByProjects(component, helper, Datevalue);
        }
    },

    handleAfterLoad: function (component, event, helper) {
        helper.handleAfterScriptsLoaded(component, helper);
    },

    selectedResource: function (component, event, helper) {
        event.stopPropagation();
        var toggleText = event.currentTarget;

        console.log(event.currentTarget);
        var activeEle = document.getElementsByClassName('list-group-item activeResource')[0]
        if (activeEle) {
            activeEle.classList.remove('activeResource');
        }
        toggleText.blur();

        $A.util.toggleClass(toggleText, "activeResource");
        var projects = component.get("v.projectList");
        var resources = component.get("v.resourcesList");
        var projIndex = Number(toggleText.dataset.projindex);
        var resourceIndex = Number(toggleText.dataset.resourceindex);
        var resourceId = toggleText.dataset.contractresourceid;
        var profileSymbol = toggleText.dataset.profilesbl;

        component.set("v.selectedContractResourceIndex", resourceIndex);

        //contacts from event list
        if (resources.length) {
            if (resourceId) {
                component.set("v.newContractResource", resourceId);
            } else {
                component.set("v.newContractResource", "");
            }
            document.getElementById('profileBgSymbol').className = "profile_name me-3 " + profileSymbol;
            document.getElementById('resourceInitials').innerText = resources[resourceIndex].FirstLetterofContractresourceName;
            document.getElementById('selectedContractResource').innerText = resources[resourceIndex].ContractresourceName;
            document.getElementById('selectedContractResourceTradeType').innerText = resources[resourceIndex].TradeType ? resources[resourceIndex].TradeType : 'None';

            var todayDate = new Date(component.get("v.dateval"));
            var newfromdate = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
            var newtodate;
            if (todayDate.getMonth() == 11) {
                newtodate = new Date(todayDate.getFullYear() + 1, 0, 0);
            } else {
                newtodate = new Date(todayDate.getFullYear(), todayDate.getMonth() + 1, 0);
            }

            var newFromstr, newTostr;

            component.set("v.showSpinner", true);

            console.log('PROJECT-->', component.get("v.newSelectedProjectIdClone"));
            if (component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null) {
                component.set("v.newSelectedProjectId", component.get("v.newSelectedProjectIdClone"));
            }

            newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
            newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd");
            console.log('component.get("v.project").Id ',component.get("v.project").Id);

            helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), component.get("v.project").Name, component.get("v.searchResourceFilter"), component.get("v.allFilter"))
            .then(response => {
                console.log('selectedResource response.getReturnValue()::', response);
                    component.set("v.showSpinner", false);

                    var evetList = [];
                    var projColors = component.get("v.projectColors");
                    var projColorMap = component.get("v.projectColorMap");
                    var resourceColors = component.get("v.resourceColors");
                    var selResourceColorIndex = Number(profileSymbol.split("prof_bg")[1]) - 1;
                    console.log(component.get("v.projectColorMap"))
                    for (var itemIdx = 0; itemIdx < response.projectList.length; itemIdx++) {
                        for (var j = 0; j < response.projectList[itemIdx].CalendarWrapList.length; j++) {
                            var weekName = response.projectList[itemIdx].CalendarWrapList[j]['weekName'];
                            var startDate = response.projectList[itemIdx].CalendarWrapList[j]['startdate'];
                            var endDate = response.projectList[itemIdx].CalendarWrapList[j]['enddate'];
                            if (weekName != null && weekName != undefined) {
                                var dayNames = component.get("v.dayNames");
                                response.projectList[itemIdx].CalendarWrapList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3); // weekName.substring(0,3);
                            }
                            response.projectList[itemIdx].CalendarWrapList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                            response.projectList[itemIdx].CalendarWrapList[j]['startdateFormatted'] = $A.localizationService.formatDate(startDate, 'MM-dd-yyyy');//new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                            response.projectList[itemIdx].CalendarWrapList[j]['enddateFormatted'] = $A.localizationService.formatDate(endDate, 'MM-dd-yyyy');//new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();

                            if (projColorMap.get(response.projectList[itemIdx].CalendarWrapList[j]['projectId'])) {
                                response.projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColorMap.get(response.projectList[itemIdx].CalendarWrapList[j]['projectId']);
                            }
                            evetList.push(response.projectList[itemIdx].CalendarWrapList[j]);
                        }

                    }


                    var selectedResourceEventList = [];
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
                                response.calendarTaskList[k].ProjectTaskRecordsList[j]['colorName'] = resourceColors[selResourceColorIndex % 10];

                                selectedResourceEventList.push(response.calendarTaskList[k].ProjectTaskRecordsList[j]);

                            }
                        }

                    }
                    component.set("v.eventList", selectedResourceEventList); // tasks list from selected resource
                    component.set("v.dateEventList", selectedResourceEventList);
                    component.set("v.resourcesList", response.calendarTaskList);
                    component.set("v.areExternalResource", response.areExternalResource);
                    component.set("v.areInternalResource", response.areInternalResource);

                    document.getElementById('mycalendar2').style.display = 'none';
                    document.getElementById('mycalendar').style.display = 'block';
                    helper.buildCalendar(component, helper);
            })
            .catch(error => {
                component.set("v.showSpinner", false);
                console.log('error', error);
            });
        }

    },

    standardViewCalendar: function (component, event, helper) {

        var currEle = event.currentTarget;
        var activeEle = document.getElementsByClassName('calendarView active')[0]
        if (activeEle) {
            activeEle.classList.remove('active');
        }
        if (!currEle.classList.contains('active')) {
            currEle.classList.add('active')
        }

        event.stopPropagation();
    },

    conflictsViewCalendar: function (component, event, helper) {

        var currEle = event.currentTarget;
        var activeEle = document.getElementsByClassName('calendarView active')[0]
        if (activeEle) {
            activeEle.classList.remove('active');
        }
        if (!currEle.classList.contains('active')) {
            currEle.classList.add('active')
        }

        event.stopPropagation();
    },

    onRender: function (component, event, helper) {
        var profileSymbols = document.getElementsByClassName('profile_name');
        var leftNav = document.getElementsByClassName('list-group-item').length;

        console.log('22222');
        if (profileSymbols.length > 1 && leftNav) {
            console.log(profileSymbols.length)
            for (var i = 0; i < profileSymbols.length - 1; i++) {
                var ele = profileSymbols[i];
                var indexVal = (i) % 10;
                var className = 'prof_bg' + Number(indexVal + 1);
                if (!ele.classList.contains(className)) {
                    ele.classList.add(className);
                    if (document.getElementsByClassName('list-group-item')[i]) {
                        document.getElementsByClassName('list-group-item')[i].setAttribute("data-profilesbl", className);
                    }

                }
            }
        }

        var projectProfileSymbols = document.getElementsByClassName('Proj_profile_name');
        if (projectProfileSymbols.length > 0) {
            console.log(projectProfileSymbols.length)
            for (var i = 0; i < projectProfileSymbols.length; i++) {
                var ele = projectProfileSymbols[i];
                var indexVal = (i) % 10;
                var className = 'proj_prof_bg' + Number(indexVal + 1);
                if (!ele.classList.contains(className)) {
                    ele.classList.add(className);
                    if (document.getElementsByClassName('nav-link')[i]) {
                        document.getElementsByClassName('nav-link')[i].setAttribute("data-projprofilesbl", className);
                    }

                }
            }
        }
    },

    checkContent: function (component, event, helper) {
        var profileSymbols = document.getElementsByClassName('profile_name');
        console.log(profileSymbols.length)
        console.log(document.getElementsByClassName('list-group-item').length)
    },

    calendarDayView: function (component, event, helper) {

        var currEle = event.currentTarget;
        component.set("v.currentCalendarView", "dayView");

        const activeEles = document.querySelectorAll(`.viewChange`);
        if (activeEles.length) {
            for (var i = 0; i < activeEles.length; i++) {
                if (activeEles[i].dataset.name == component.get('v.currentCalendarView')) {
                    if (!activeEles[i].classList.contains('active')) {
                        activeEles[i].classList.add('active');
                    }
                }
                else {
                    activeEles[i].classList.remove('active');
                }
            }

        }

        /*hide week header*/
        var weekHeader = document.getElementsByClassName('weekly-header');
        if (weekHeader.length) {
            weekHeader[0].style.display = 'none';
        }

        /*hide calendar view*/
        document.getElementById('mycalendar').style.display = 'none';

        /*Show day view div*/
        document.getElementById('mycalendar2').style.display = 'block';
        /*show day view header*/
        document.getElementsByClassName('daily-header')[0].style.display = 'block';

        var currentDateValue1 = new Date(component.get("v.dateval"));
        var currentDateValue = new Date(currentDateValue1.getFullYear(), currentDateValue1.getMonth(), 1);
        var actualDateValue = new Date();
        var todayDateHeader = component.get('v.todayDateHeader');

        if (actualDateValue.getFullYear() == currentDateValue.getFullYear() && actualDateValue.getMonth() == currentDateValue.getMonth() && actualDateValue.getDate() == currentDateValue.getDate()) {
            todayDateHeader = actualDateValue.toDateString();
        }

        var today = new Date(Date.parse(todayDateHeader));
        var newtodate = new Date(Date.parse(todayDateHeader)).setHours(0, 0, 0, 0);
        var newfromdate;
        var evenList = component.get("v.eventList");
        var currentDateEventList = [];
        for (var i = 0; i < evenList.length; i++) {
            var eventItem = evenList[i];
            var eventStartDate = new Date(Date.parse(eventItem['startdate'])).setHours(0, 0, 0, 0);
            var eventEndDate = new Date(Date.parse(eventItem['enddate'])).setHours(0, 0, 0, 0);
            if (eventStartDate <= newtodate && eventEndDate >= newtodate) {
                currentDateEventList.push(eventItem);
            }
        }

        component.set("v.dateEventList", currentDateEventList);
        component.set('v.todayDateHeader', new Date(newtodate).toDateString());
        component.set("v.todayDate", new Date(newtodate).toLocaleDateString());
        event.stopPropagation();
    },

    calendarWeekView: function (component, event, helper) {

        var currEle = event.currentTarget;
        component.set("v.currentCalendarView", "weekView");

        const activeEles = document.querySelectorAll(`.viewChange`);
        if (activeEles.length) {
            for (var i = 0; i < activeEles.length; i++) {
                if (activeEles[i].dataset.name == component.get('v.currentCalendarView')) {
                    if (!activeEles[i].classList.contains('active')) {
                        activeEles[i].classList.add('active');
                    }
                }
                else {
                    activeEles[i].classList.remove('active');
                }
            }
        }

        /* Show Calendar view Div */
        document.getElementById('mycalendar').style.display = 'block';

        /*show week header*/
        var weekHeader = document.getElementsByClassName('weekly-header');
        if (weekHeader.length) {
            weekHeader[0].style.display = 'block';
        }

        /* Hide Month Header*/
        var monthlyHeader = document.getElementsByClassName('monthly-header');
        if (monthlyHeader.length) {
            monthlyHeader[0].style.display = 'none';
        }

        /*hide day view div*/
        document.getElementById('mycalendar2').style.display = 'none';
        document.getElementsByClassName('daily-header')[0].style.display = 'none';

        var dayListParent = document.getElementsByClassName('monthly-event-list');
        var dayListItems = document.getElementsByClassName('monthly-list-item');
        if (dayListParent.length) {
            console.log(dayListParent[0]);
            dayListParent[0].style.display = 'block';
            dayListParent[0].style.transform = 'scale(1)';

            //jquery method -method1
            if (dayListItems.length) {
                if ($("#mycalendar .monthly-event-list").is(":visible")) {
                    $("#mycalendar .monthly-cal").remove();
                    $("#mycalendar .monthly-header-title").prepend('<a href="#" class="monthly-cal"></a>');
                }
                jQuery('.monthly-list-item').css("display", "block");
            }

            component.reloadCurrentWeekCalendar();
            console.log('component.get(todayDateHeader) ::--->', component.get('v.todayDateHeader'));
        }
        event.stopPropagation();
    },

    calendarMonthView: function (component, event, helper) {

        var currEle = event.currentTarget;
        component.set("v.currentCalendarView", "monthView");

        const activeEles = document.querySelectorAll(`.viewChange`);
        if (activeEles.length) {
            for (var i = 0; i < activeEles.length; i++) {
                if (activeEles[i].dataset.name == component.get('v.currentCalendarView')) {
                    if (!activeEles[i].classList.contains('active')) {
                        activeEles[i].classList.add('active');
                    }
                }
                else {
                    activeEles[i].classList.remove('active');
                }
            }
        }

        /*hide week header*/
        var weekHeader = document.getElementsByClassName('weekly-header');
        if (weekHeader.length) {
            weekHeader[0].style.display = 'none';
        }

        /* Show Month Header*/
        var monthlyHeader = document.getElementsByClassName('monthly-header');
        if (monthlyHeader.length) {
            monthlyHeader[0].style.display = 'block';
        }
        /* Show Calendar view Div */
        document.getElementById('mycalendar').style.display = 'block';

        /*hide day view div*/
        document.getElementById('mycalendar2').style.display = 'none';
        document.getElementsByClassName('daily-header')[0].style.display = 'none';

        var dayListParent = document.getElementsByClassName('monthly-event-list');
        var dayListItems = document.getElementsByClassName('monthly-list-item');
        var monthViewBtn = document.getElementsByClassName('monthly-cal');
        if (monthViewBtn.length) {
            monthViewBtn[0].remove();
        }
        if (dayListParent.length) {
            console.log(dayListParent[0]);
            dayListParent[0].style.display = 'none';
            dayListParent[0].style.transform = 'scale(0)';
        }
        event.stopPropagation();
    },

    previousMonth: function (component, event, helper) {
        document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
        document.getElementById('resourceInitials').innerText = 'R';
        document.getElementById('selectedContractResource').innerText = 'Resource';
        document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';

        component.set("v.showSpinner", true);
        component.set("v.newContractResource", "");
        if (component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null) {
            component.set("v.newSelectedProjectId", component.get("v.newSelectedProjectIdClone"));
        } else {
            component.set("v.newSelectedProjectId", "");
        }
        component.set("v.selectedContractResourceIndex", -1);

        var todayDate = new Date(component.get("v.dateval"));
        var prevMonth
        if (todayDate.getMonth() == 0) {
            prevMonth = new Date(todayDate.getFullYear() - 1, 11, 1);
        } else {
            prevMonth = new Date(todayDate.getFullYear(), todayDate.getMonth() - 1, 1);
        }
        component.set("v.dateval", prevMonth);
        component.set("v.datevalString", prevMonth.toLocaleDateString());
        component.set('v.todayDateHeader', prevMonth.toDateString());
        component.set("v.todayDate", prevMonth.toLocaleDateString());
        helper.getTasksByProjects(component, helper, component.get("v.dateval"));
        var monthBtn = document.getElementsByClassName('viewChange')[2];
        var activeEle = document.getElementsByClassName('viewChange active')[0]
        if (activeEle) {
            activeEle.classList.remove('active');
        }
        if (!monthBtn.classList.contains('active')) {
            monthBtn.classList.add('active')
        }

    },

    nextMonth: function (component, event, helper) {
        document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
        document.getElementById('resourceInitials').innerText = 'R';
        document.getElementById('selectedContractResource').innerText = 'Resource';
        document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';

        component.set("v.showSpinner", true);
        component.set("v.newContractResource", "");
        if (component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null) {
            component.set("v.newSelectedProjectId", component.get("v.newSelectedProjectIdClone"));
        } else {
            component.set("v.newSelectedProjectId", "");
        }
        component.set("v.selectedContractResourceIndex", -1);
        var todayDate = new Date(component.get("v.dateval"));
        var nextMonth;
        if (todayDate.getMonth() == 11) {
            nextMonth = new Date(todayDate.getFullYear() + 1, 0, 1);
        } else {
            nextMonth = new Date(todayDate.getFullYear(), todayDate.getMonth() + 1, 1);
        }
        component.set("v.dateval", nextMonth);
        component.set("v.datevalString", nextMonth.toLocaleDateString());
        component.set('v.todayDateHeader', nextMonth.toDateString());
        component.set("v.todayDate", nextMonth.toLocaleDateString());
        helper.getTasksByProjects(component, helper, component.get("v.dateval"));
    },

    currentDateMonth: function (component, event, helper) {
        document.getElementById('profileBgSymbol').className = "profile_name me-3 prof_bg2";
        document.getElementById('resourceInitials').innerText = 'R';
        document.getElementById('selectedContractResource').innerText = 'Resource';
        document.getElementById('selectedContractResourceTradeType').innerText = 'Trade Type';

        component.set("v.showSpinner", true);
        component.set("v.newContractResource", "");
        if (component.get("v.recordId") != '' && component.get("v.recordId") != undefined && component.get("v.recordId") != null) {
            component.set("v.newSelectedProjectId", component.get("v.newSelectedProjectIdClone"));
        } else {
            component.set("v.newSelectedProjectId", "");
        }
        component.set("v.selectedContractResourceIndex", -1);
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), 1);
        component.set("v.datevalString", Datevalue.toLocaleDateString());
        console.log('Datevalue.toDateString() :---->', Datevalue.toDateString());

        // Chnages for BUIL-3936
        var newtodate = new Date(Date.parse(today)).setHours(0, 0, 0, 0);
        component.set("v.todayDate", new Date(newtodate).toLocaleDateString());
        component.set("v.dateval", today);
        $(`#datepickerPlaceholder`).datepicker('setDate', today);
        console.log('defaultDate ->> ', $(`#datepickerPlaceholder`).datepicker('getDate'));
        helper.getTasksByProjects(component, helper, component.get("v.dateval"));
    },

    previousWeek: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        console.log('currentDateValue :---->', currentDateValue);
        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }

        var currentWeekIndex = component.get("v.weekIndex") - 1;
        var index = (currentWeekIndex) * 7;
        var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
        if (!evetListEle.length) {
            evetListEle = $('.monthly-list-item');
        }
        $('.monthly-list-item').css("display", "none");

        var selectedWeekDIvs;
        var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');
        if (currentWeekIndex + 1 == 0) {
            component.reloadPrevCalendar();
            component.set("v.weekIndex", 0);
        } else if (index <= currentMonthLastDate.getDate() && evetListEle.length >= index + 7) {
            selectedWeekDIvs = evetListEle.slice(index, index + 7);
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + Number(index + 1) + '-' + Number(index + 7); //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        }

        var act = component.get("c.previousWeekClone");
        $A.enqueueAction(act);
    },

    nextWeek: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }


        var currentWeekIndex = component.get("v.weekIndex") + 1;
        var index = (currentWeekIndex) * 7;
        var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
        if (!evetListEle.length) {
            evetListEle = $('.monthly-list-item');
        }
        $('.monthly-list-item').css("display", "none");

        var selectedWeekDIvs;
        var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');
        if (index + 7 > currentMonthLastDate.getDate() && index < currentMonthLastDate.getDate()) { //&& evetListEle.length != index
            selectedWeekDIvs = evetListEle.slice(index, currentMonthLastDate.getDate());
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + Number(index + 1) + '-' + Number(currentMonthLastDate.getDate()); //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        } else if (index <= currentMonthLastDate.getDate() && evetListEle.length >= index + 7) {
            selectedWeekDIvs = evetListEle.slice(index, index + 7);
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + Number(index + 1) + '-' + Number(index + 7); //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        } else {
            //if it is last week and next button is clicked, taking to next month
            component.reloadNextCalendar();
            component.set("v.weekIndex", 0);
        }

        var act = component.get("c.nextWeekClone");
        $A.enqueueAction(act);

    },

    currentWeek: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        var actualDateValue = new Date();

        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }

        var currentWeekIndex = 0;

        var index = currentWeekIndex * 7;

        var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
        if (!evetListEle.length) {
            evetListEle = $('.monthly-list-item');
        }
        $('.monthly-list-item').css("display", "none");
        console.log(evetListEle.slice(index, index + 7));

        var selectedWeekDIvs;
        var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');
        if (index + 7 > currentMonthLastDate.getDate() && index <= currentMonthLastDate.getDate()) {
            selectedWeekDIvs = evetListEle.slice(index, currentMonthLastDate.getDate());
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + Number(index + 1) + '-' + Number(currentMonthLastDate.getDate()); //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        } else if (index <= currentMonthLastDate.getDate()) {
            selectedWeekDIvs = evetListEle.slice(index, index + 7);
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + Number(index + 1) + '-' + Number(index + 7); //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        }

        var act = component.get("c.currentWeekClone");
        $A.enqueueAction(act);
    },

    currentWeekClone: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        var actualDateValue = new Date();

        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }

        var currentWeekIndex = 0;

        //if actual today date is not same as date value in code (ex: present month is jun and user clicks prev btn and changed to week view then resetting to start week)
        if (actualDateValue.getFullYear() == currentDateValue.getFullYear() && actualDateValue.getMonth() == currentDateValue.getMonth() && actualDateValue.getDate() == currentDateValue.getDate()) {

            if (actualDateValue.getDate() % 7 == 0) {
                currentWeekIndex = (actualDateValue.getDate() / 7); //-1;
                if (new Date(actualDateValue.getFullYear(), actualDateValue.getMonth(), 1).getDay() == 0) {
                    currentWeekIndex = (actualDateValue.getDate() / 7) - 1;
                }

            } else {
                let tempWeekIndex = 0;
                tempWeekIndex = Math.floor(currentDateValue.getDate() / 7);
                if (tempWeekIndex != 0) {
                    currentWeekIndex = Math.ceil(currentDateValue.getDate() / 7);
                } else {
                    currentWeekIndex = tempWeekIndex;
                }
            }

        } else {
            if (actualDateValue.getDate() % 7 == 0) {
                currentWeekIndex = (actualDateValue.getDate() / 7); //-1;
                if (new Date(actualDateValue.getFullYear(), actualDateValue.getMonth(), 1).getDay() == 0) {
                    currentWeekIndex = (actualDateValue.getDate() / 7) - 1;
                }

            } else {
                let firstDayOfMonth = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), 1);
                let dayOfMonth = currentDateValue.getDate();

                // Calculate the week index based on the selected date
                currentWeekIndex = Math.ceil((dayOfMonth + firstDayOfMonth.getDay()) / 7) - 1;
            }

        }


        var weekDivs = document.getElementsByClassName('monthly-week');
        var weekDaysLength;
        var weekStartDate;
        var weekEndDate;
        var week;
        var weekStartText;
        var weekEndText;

        if (currentWeekIndex == 0) {
            weekStartDate = 1;
            if (weekDivs.length) {
                console.log("test 5");
                weekDaysLength = weekDivs[currentWeekIndex].children.length;
            }

            for (var i = 0; i < weekDaysLength; i++) {
                if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined && !weekDivs[currentWeekIndex].children[i].classList.contains('monthly-day-blank')) {
                    console.log("test 6", weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0]);
                    weekEndDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                }
            }

            weekEndText = weekEndDate

            if (Number(weekStartDate) == 1) {

                if (currentDateValue.getMonth() == 0) {
                    weekStartText = new Date(currentDateValue.getFullYear(), 0, currentDateValue.getDate() - currentDateValue.getDay()).getDate();
                } else {
                    weekStartText = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), currentDateValue.getDate() - currentDateValue.getDay()).getDate();
                }

                var eventList = component.get("v.eventList");
                var weekFullDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), currentDateValue.getDate() - currentDateValue.getDay())

                var pastEle = document.getElementsByClassName('calendarPast');
                if (pastEle.length) {
                    console.log("test 9");
                    document.querySelectorAll('.calendarPast').forEach(function (a) {
                        a.remove()
                    });
                }
                var pastMonthDates = [];
                var pastMonthDatesTemp = [];

                // Calculate the last day of the previous month (January)
                var lastDayOfPreviousMonth = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), 0).getDate();
                var firstDayOfCurrentMonth = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), 1).getDay();
                var noOfDaysToRemove = currentDateValue.getDay() - firstDayOfCurrentMonth;
                console.log('firstDayOfCurrentMonth :---->', firstDayOfCurrentMonth);
                // Loop to display the past month dates
                for (var i = lastDayOfPreviousMonth; i > lastDayOfPreviousMonth - firstDayOfCurrentMonth; i--) {
                    var markupListEvent = '';
                    var dayName = component.get("v.dayNames");

                    // Create the date object for the past month date
                    var pastMonthDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, i);

                    // Create and append the cell for the past month date
                    var div = document.createElement("DIV");
                    div.setAttribute('data-number', 'past' + i);
                    div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                    div.setAttribute('id', 'mycalendarPast' + i);
                    var div2 = document.createElement("DIV");
                    div2.setAttribute('class', 'monthly-event-list-date');
                    div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[pastMonthDate.getDay()].substring(0, 3) + '<br>' + i + '</br></div>';
                    div2.innerHTML += '<div class="noeventCls" style="padding:0.4em 1em;display:block;margin-bottom:0.5em;">No Events</div>';
                    div.innerHTML = div2.innerHTML;

                    $('#mycalendar .monthly-event-list').prepend(div);
                    pastMonthDatesTemp.push(i);
                }
                pastMonthDates = pastMonthDatesTemp;
                console.log('pastMonthDates :--->', pastMonthDates);
                var lastDayOfPastMonth = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), 0).getDate();

                // Loop through pastMonthDates array and remove extra values
                for (var i = pastMonthDates.length - 1; i >= 0; i--) {
                    var pastDate = pastMonthDates[i];
                    if (pastDate > lastDayOfPastMonth) {
                        // Remove the extra date from the array
                        pastMonthDates.splice(i, 1);
                    }
                }

                console.log('pastMonthDates after removing extras:', pastMonthDates, pastMonthDates.length);
                for (var i = 0; i < eventList.length; i++) {
                    var eve = eventList[i];
                    if (new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0) < new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), Number(weekStartDate)).setHours(0, 0, 0, 0).valueOf()) {
                        console.log("test 12", eventList[i]);
                        var markupListEvent = '<a title="' + eve.title + '" style="background:' + eve.colorName + '" data-eventid="' + eve.Id + '" class="listed-event" href="/lightning/r/buildertek__Project_Task__c/' + eve.Id + '/view">' + eve.title + '</a>'
                        var dayName = component.get("v.dayNames");
                        for (var j = pastMonthDates.length - 1; j >= 0; j--) {
                            var endDate = new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0);
                            var startDate = new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0);
                            console.log('endDate :--->', endDate);
                            console.log('startDate :---> ', startDate);
                            console.log('startDate condition 1:---> ', endDate >= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf());
                            console.log('startDate condition 2:---> ', startDate <= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf());

                            if (endDate >= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf() && startDate <= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf()) {
                                var startdt = pastMonthDates[j];
                                var startDateFormat = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j]))
                                var ele = document.getElementById('mycalendarPast' + startdt);
                                if (!ele) {
                                    console.log("test 14");
                                    var div = document.createElement("DIV");
                                    div.setAttribute('data-number', 'past' + startdt);
                                    div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                                    div.setAttribute('id', 'mycalendarPast' + startdt);
                                    var div2 = document.createElement("DIV");
                                    div2.setAttribute('class', 'monthly-event-list-date');
                                    div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[startDateFormat.getDay()].substring(0, 3) + '<br>' + pastMonthDates[j] + '</br></div>';

                                    div.innerHTML = div2.innerHTML
                                    div.innerHTML += markupListEvent;
                                    $('#mycalendar .monthly-event-list').prepend(div);
                                } else {
                                    var innerhtmlContent = document.getElementById('mycalendarPast' + pastMonthDates[j])
                                    if (innerhtmlContent.lastChild.innerText == 'No Events' && innerhtmlContent.getElementsByClassName('noeventCls').length) {
                                        innerhtmlContent.lastChild.remove()
                                    }
                                    innerhtmlContent.innerHTML += markupListEvent;
                                }
                            }
                        }

                    }
                }
            } else {
                weekStartText = weekStartDate;
            }

        } else {
            if (currentWeekIndex >= 0) {
                if (weekDivs.length) {
                    weekDaysLength = weekDivs[currentWeekIndex].children.length;
                }
                weekStartDate = weekDivs[currentWeekIndex].children[0].getElementsByClassName('monthly-day-number')[0].innerText;

                weekStartText = weekStartDate
                for (var i = 0; i < weekDaysLength; i++) {
                    if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined && !weekDivs[currentWeekIndex].children[i].classList.contains('monthly-day-blank')) {
                        console.log("test 17");
                        weekEndDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                    }
                }
                weekEndText = weekEndDate;
            }

        }

        if (currentMonthLastDate.getDate() == Number(weekEndDate)) {

            weekEndText = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), Number(weekStartDate) + 6).getDate();


            var eventList = component.get("v.eventList");
            var weekFullDate;//= new Date(currentDateValue.getFullYear(),currentDateValue.getMonth(),currentDateValue.getDate()-currentDateValue.getDay())
            var pastEle = document.getElementsByClassName('calendarPast');
            if (pastEle.length) {
                console.log("test 19");
                document.querySelectorAll('.calendarPast').forEach(function (a) {
                    a.remove()
                });
            }
            var futureMonthDates = [];
            var weekLastDate = 6 - currentMonthLastDate.getDay();
            for (var i = 1; i <= weekLastDate; i++) {
                var markupListEvent = ''
                var dayName = component.get("v.dayNames");
                if (currentMonthLastDate.getMonth() == 11) {
                    console.log("test 20");
                    weekFullDate = new Date(currentMonthLastDate.getFullYear() + 1, 0, i)//6-currentMonthLastDate.getDay()
                } else {
                    weekFullDate = new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth() + 1, i)//6-currentMonthLastDate.getDay()
                }
                var ele = document.getElementById('mycalendarPast' + i);
                if (!ele) {
                    console.log("test 21");
                    var div = document.createElement("DIV");
                    div.setAttribute('data-number', 'past' + i);
                    div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                    div.setAttribute('id', 'mycalendarPast' + i);
                    var div2 = document.createElement("DIV");
                    div2.setAttribute('class', 'monthly-event-list-date');
                    div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[weekFullDate.getDay()].substring(0, 3) + '<br>' + i + '</br></div>';
                    div2.innerHTML += '<div class="noeventCls" style="padding:0.4em 1em;display:block;margin-bottom:0.5em;">No Events</div>'
                    div.innerHTML = div2.innerHTML
                    console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                    $('#mycalendar .monthly-event-list').append(div);
                    futureMonthDates.push(i);
                }
            }
            for (var i = 0; i < eventList.length; i++) {
                var eve = eventList[i];
                if (new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0) <= new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth(), Number(weekEndDate)).setHours(0, 0, 0, 0).valueOf() && new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0) > new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth(), Number(weekEndDate)).setHours(0, 0, 0, 0).valueOf()) {
                    console.log("test 22");
                    var markupListEvent = '<a title="' + eve.title + '" style="background:' + eve.colorName + '" data-eventid="' + eve.Id + '" class="listed-event" href="/lightning/r/buildertek__Project_Task__c/' + eve.Id + '/view">' + eve.title + '</a>'
                    var dayName = component.get("v.dayNames");
                    for (var j = 0; j < futureMonthDates.length; j++) {
                        var endDate = new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0);
                        var startDate = new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0);
                        if (endDate >= new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth() + 1, Number(futureMonthDates[j])).setHours(0, 0, 0, 0).valueOf() && startDate <= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, Number(futureMonthDates[j])).setHours(0, 0, 0, 0).valueOf()) {
                            console.log("test 23");
                            var startdt = futureMonthDates[j];
                            var startDateFormat = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, Number(futureMonthDates[j]))
                            var ele = document.getElementById('mycalendarPast' + startdt);
                            if (!ele) {
                                console.log("test 24");
                                var div = document.createElement("DIV");
                                div.setAttribute('data-number', 'past' + startdt);
                                div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                                div.setAttribute('id', 'mycalendarPast' + startdt);
                                var div2 = document.createElement("DIV");
                                div2.setAttribute('class', 'monthly-event-list-date');
                                div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[startDateFormat.getDay()].substring(0, 3) + '<br>' + futureMonthDates[j] + '</br></div>';

                                div.innerHTML = div2.innerHTML
                                div.innerHTML += markupListEvent;
                                console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                                $('#mycalendar .monthly-event-list').append(div);
                            } else {
                                var innerhtmlContent = document.getElementById('mycalendarPast' + futureMonthDates[j])
                                if (innerhtmlContent.lastChild.innerText == 'No Events' && innerhtmlContent.getElementsByClassName('noeventCls').length) {
                                    console.log("test 25");
                                    innerhtmlContent.lastChild.remove()
                                }
                                innerhtmlContent.innerHTML += markupListEvent;
                            }
                        }
                    }
                }
            }
        }


        var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
        if (!evetListEle.length) {
            evetListEle = $('.monthly-list-item');
        }
        $('.monthly-list-item').css("display", "none");
        var selectedWeekDIvs;
        console.log('selectedWeekDIvs 1:---->', weekStartDate);
        var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');
        //selectedWeekDIvs = evetListEle.slice(Number(weekStartDate)-1,Number(weekEndDate));
        if (Number(weekStartDate) == 1) {
            var firstDayOfCurrentMonth = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), 1).getDay();
            selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate) + firstDayOfCurrentMonth);
        } else {
            selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate));
        }
        if (Number(weekEndDate) == currentMonthLastDate.getDate()) {
            selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate) + 6 - currentMonthLastDate.getDay());
        }
        console.log(selectedWeekDIvs);
        for (var i = 0; i < selectedWeekDIvs.length; i++) {
            selectedWeekDIvs[i].style.display = "block";
        }
        if (WeekeaderTitle.length) {
            WeekeaderTitle[0].innerText = 'Week ' + weekStartText + '-' + weekEndText; //currentDateValue.getMonth()
        }

        component.set("v.weekIndex", currentWeekIndex);
        event.stopPropagation();
        event.preventDefault();
        return false;
    },

    nextWeekClone: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }
        var currentWeekIndex = component.get("v.weekIndex") + 1;
        var index = (currentWeekIndex) * 7;
        var weekDivs = document.getElementsByClassName('monthly-week');
        var weekDaysLength;
        console.log(weekDivs);
        var weekStartDate;
        var weekEndDate;
        var week;
        var weekStartText;
        var weekEndText

        var pastEle = document.getElementsByClassName('calendarPast');
        if (pastEle.length) {
            document.querySelectorAll('.calendarPast').forEach(function (a) {
                a.remove()
            });
        }

        if (currentWeekIndex < weekDivs.length) {
            if (weekDivs.length) {
                weekDaysLength = weekDivs[currentWeekIndex].children.length;
            }
            for (var i = 0; i < weekDaysLength; i++) {
                if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined) {
                    weekStartDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                    break;
                }
            }
            weekStartText = weekStartDate;
            for (var i = 0; i < weekDaysLength; i++) {
                if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined && !weekDivs[currentWeekIndex].children[i].classList.contains('monthly-day-blank')) {
                    weekEndDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                }
            }
            weekEndText = weekEndDate;
        }
        if (currentMonthLastDate.getDate() == Number(weekEndDate)) {
            weekEndText = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), Number(weekStartDate) + 6).getDate();


            var eventList = component.get("v.eventList");
            var weekFullDate;//= new Date(currentDateValue.getFullYear(),currentDateValue.getMonth(),currentDateValue.getDate()-currentDateValue.getDay())
            var pastEle = document.getElementsByClassName('calendarPast');
            if (pastEle.length) {
                document.querySelectorAll('.calendarPast').forEach(function (a) {
                    a.remove()
                });
            }
            var futureMonthDates = [];
            var weekLastDate = 6 - currentMonthLastDate.getDay();
            for (var i = 1; i <= weekLastDate; i++) {
                var markupListEvent = ''
                var dayName = component.get("v.dayNames");
                if (currentMonthLastDate.getMonth() == 11) {
                    weekFullDate = new Date(currentMonthLastDate.getFullYear() + 1, 0, i)//6-currentMonthLastDate.getDay()
                } else {
                    weekFullDate = new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth() + 1, i)//6-currentMonthLastDate.getDay()
                }
                var ele = document.getElementById('mycalendarPast' + i);
                if (!ele) {
                    var div = document.createElement("DIV");
                    div.setAttribute('data-number', 'past' + i);
                    div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                    div.setAttribute('id', 'mycalendarPast' + i);
                    var div2 = document.createElement("DIV");
                    div2.setAttribute('class', 'monthly-event-list-date');
                    div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[weekFullDate.getDay()].substring(0, 3) + '<br>' + i + '</br></div>';
                    div2.innerHTML += '<div class="noeventCls" style="padding:0.4em 1em;display:block;margin-bottom:0.5em;">No Events</div>'
                    div.innerHTML = div2.innerHTML
                    console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                    $('#mycalendar .monthly-event-list').append(div);
                    futureMonthDates.push(i);
                }
            }
            for (var i = 0; i < eventList.length; i++) {
                var eve = eventList[i];
                if (new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0) <= new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth(), Number(weekEndDate)).setHours(0, 0, 0, 0).valueOf() && new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0) > new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth(), Number(weekEndDate)).setHours(0, 0, 0, 0).valueOf()) {
                    var markupListEvent = '<a title="' + eve.title + '" style="background:' + eve.colorName + '" data-eventid="' + eve.Id + '" class="listed-event" href="/lightning/r/buildertek__Project_Task__c/' + eve.Id + '/view">' + eve.title + '</a>'
                    var dayName = component.get("v.dayNames");
                    for (var j = 0; j < futureMonthDates.length; j++) {
                        var endDate = new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0);
                        var startDate = new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0);
                        if (endDate >= new Date(currentMonthLastDate.getFullYear(), currentMonthLastDate.getMonth() + 1, Number(futureMonthDates[j])).setHours(0, 0, 0, 0).valueOf() && startDate <= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, Number(futureMonthDates[j])).setHours(0, 0, 0, 0).valueOf()) {
                            var startdt = futureMonthDates[j];
                            var startDateFormat = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, Number(futureMonthDates[j]))
                            var ele = document.getElementById('mycalendarPast' + startdt);
                            if (!ele) {
                                var div = document.createElement("DIV");
                                div.setAttribute('data-number', 'past' + startdt);
                                div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                                div.setAttribute('id', 'mycalendarPast' + startdt);
                                var div2 = document.createElement("DIV");
                                div2.setAttribute('class', 'monthly-event-list-date');
                                div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[startDateFormat.getDay()].substring(0, 3) + '<br>' + futureMonthDates[j] + '</br></div>';

                                div.innerHTML = div2.innerHTML
                                div.innerHTML += markupListEvent;
                                console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                                $('#mycalendar .monthly-event-list').append(div);
                            } else {
                                var innerhtmlContent = document.getElementById('mycalendarPast' + futureMonthDates[j])
                                if (innerhtmlContent.lastChild.innerText == 'No Events' && innerhtmlContent.getElementsByClassName('noeventCls').length) {
                                    innerhtmlContent.lastChild.remove()
                                }
                                innerhtmlContent.innerHTML += markupListEvent;
                            }
                        }
                    }
                }
            }
        }

        if (currentWeekIndex == weekDivs.length) {
            component.reloadNextCalendar();
            component.set("v.weekIndex", 0);
        } else {
            var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
            if (!evetListEle.length) {
                evetListEle = $('.monthly-list-item');
            }

            $('.monthly-list-item').css("display", "none");
            var selectedWeekDIvs;
            var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');

            if (Number(weekEndDate) == currentMonthLastDate.getDate()) {
                selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate) + 6 - currentMonthLastDate.getDay());
            } else {
                selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate));
            }
            console.log(selectedWeekDIvs);
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + weekStartText + '-' + weekEndText; //currentDateValue.getMonth()
            }

            component.set("v.weekIndex", currentWeekIndex);
        }



    },

    previousWeekClone: function (component, event, helper) {
        var currentDateValue = new Date(component.get("v.dateval"));
        var currentMonthLastDate;//  new Date(currentDateValue.getFullYear(),currentDateValue.getMonth()+1,0);
        if (currentDateValue.getMonth() == 11) {
            currentMonthLastDate = new Date(currentDateValue.getFullYear() + 1, 0, 0);
        } else {
            currentMonthLastDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() + 1, 0);
        }

        var currentWeekIndex = component.get("v.weekIndex") - 1;
        var index = (currentWeekIndex) * 7;
        var weekDivs = document.getElementsByClassName('monthly-week');
        var weekDaysLength;
        console.log(weekDivs);
        var weekStartDate;
        var weekEndDate;
        var week;
        var weekStartText;
        var weekEndText;
        var blankdaysInWeekStart;
        var weekStartDayIndex;
        if (currentWeekIndex >= 0) {
            if (weekDivs.length) {
                weekDaysLength = weekDivs[currentWeekIndex].children.length;
            }
            for (var i = 0; i < weekDaysLength; i++) {
                if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined) {
                    //blankdaysInWeekStart
                    weekStartDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                    break;
                }
            }
            if (Number(weekStartDate) == 1) {
                if (currentDateValue.getMonth() == 0) {
                    weekStartText = new Date(currentDateValue.getFullYear(), 0, currentDateValue.getDate() - currentDateValue.getDay()).getDate();
                } else {
                    weekStartText = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), currentDateValue.getDate() - currentDateValue.getDay()).getDate();
                }


                var eventList = component.get("v.eventList");
                var weekFullDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), currentDateValue.getDate() - currentDateValue.getDay())
                var pastEle = document.getElementsByClassName('calendarPast');
                if (pastEle.length) {
                    document.querySelectorAll('.calendarPast').forEach(function (a) {
                        a.remove()
                    });
                }
                var pastMonthDates = [];
                for (var i = currentDateValue.getDay() - 1; i >= 0; i--) {
                    var markupListEvent = ''
                    var dayName = component.get("v.dayNames");
                    if (currentDateValue.getMonth() == 0) {
                        weekFullDate = new Date(currentDateValue.getFullYear(), 0, currentDateValue.getDate() + i - currentDateValue.getDay())
                    } else {
                        weekFullDate = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), currentDateValue.getDate() + i - currentDateValue.getDay())
                    }
                    var ele = document.getElementById('mycalendarPast' + Number(weekStartText + i));
                    if (!ele) {
                        var div = document.createElement("DIV");
                        div.setAttribute('data-number', 'past' + Number(weekStartText + i));
                        div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                        div.setAttribute('id', 'mycalendarPast' + Number(weekStartText + i));
                        var div2 = document.createElement("DIV");
                        div2.setAttribute('class', 'monthly-event-list-date');
                        div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[weekFullDate.getDay()].substring(0, 3) + '<br>' + Number(weekStartText + i) + '</br></div>';
                        div2.innerHTML += '<div class="noeventCls" style="padding:0.4em 1em;display:block;margin-bottom:0.5em;">No Events</div>'
                        div.innerHTML = div2.innerHTML
                        console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                        $('#mycalendar .monthly-event-list').prepend(div);
                        pastMonthDates.push(Number(weekStartText + i));
                    }
                }
                for (var i = 0; i < eventList.length; i++) {
                    var eve = eventList[i];
                    if (new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0) < new Date(currentDateValue.getFullYear(), currentDateValue.getMonth(), Number(weekStartDate)).setHours(0, 0, 0, 0).valueOf()) {
                        var markupListEvent = '<a title="' + eve.title + '" style="background:' + eve.colorName + '" data-eventid="' + eve.Id + '" class="listed-event" href="/lightning/r/buildertek__Project_Task__c/' + eve.Id + '/view">' + eve.title + '</a>'
                        var dayName = component.get("v.dayNames");
                        for (var j = pastMonthDates.length - 1; j >= 0; j--) {
                            var endDate = new Date(Date.parse(eve['enddate'])).setHours(0, 0, 0, 0);
                            var startDate = new Date(Date.parse(eve['startdate'])).setHours(0, 0, 0, 0);
                            if (endDate >= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf() && startDate <= new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j])).setHours(0, 0, 0, 0).valueOf()) {
                                var startdt = pastMonthDates[j];
                                var startDateFormat = new Date(currentDateValue.getFullYear(), currentDateValue.getMonth() - 1, Number(pastMonthDates[j]))
                                var ele = document.getElementById('mycalendarPast' + startdt);
                                if (!ele) {
                                    var div = document.createElement("DIV");
                                    div.setAttribute('data-number', 'past' + startdt);
                                    div.setAttribute('class', 'monthly-list-item item-has-event calendarPast');
                                    div.setAttribute('id', 'mycalendarPast' + startdt);
                                    var div2 = document.createElement("DIV");
                                    div2.setAttribute('class', 'monthly-event-list-date');
                                    div2.innerHTML = '<div class="monthly-event-list-date">' + dayName[startDateFormat.getDay()].substring(0, 3) + '<br>' + pastMonthDates[j] + '</br></div>';

                                    div.innerHTML = div2.innerHTML
                                    div.innerHTML += markupListEvent;
                                    console.log(document.getElementById('mycalendar').getElementsByClassName('monthly-event-list')[0]);
                                    $('#mycalendar .monthly-event-list').prepend(div);
                                } else {
                                    var innerhtmlContent = document.getElementById('mycalendarPast' + pastMonthDates[j])
                                    if (innerhtmlContent.lastChild.innerText == 'No Events' && innerhtmlContent.getElementsByClassName('noeventCls').length) {
                                        innerhtmlContent.lastChild.remove()
                                    }
                                    innerhtmlContent.innerHTML += markupListEvent;
                                }
                            }
                        }

                    }
                }
            } else {
                weekStartText = weekStartDate;
            }
            for (var i = 0; i < weekDaysLength; i++) {
                if (weekDivs[currentWeekIndex].children[i].className.split('dateV')[1] != undefined && !weekDivs[currentWeekIndex].children[i].classList.contains('monthly-day-blank')) {
                    weekEndDate = weekDivs[currentWeekIndex].children[i].getElementsByClassName('monthly-day-number')[0].innerText;
                }
            }
        }

        if (currentWeekIndex + 1 == 0) {
            component.reloadPrevCalendar();
            component.set("v.weekIndex", 0);
        } else {
            var evetListEle = Object.values(document.getElementsByClassName("monthly-list-item"));
            if (!evetListEle.length) {
                evetListEle = $('.monthly-list-item');
            }
            $('.monthly-list-item').css("display", "none");

            weekEndText = weekEndDate
            var selectedWeekDIvs;
            var WeekeaderTitle = document.getElementsByClassName('weekly-header-title-date');
            if (Number(weekStartDate) == 1) {
                selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate) + currentDateValue.getDay());
            } else {
                selectedWeekDIvs = evetListEle.slice(Number(weekStartDate) - 1, Number(weekEndDate));
            }

            console.log(selectedWeekDIvs);
            for (var i = 0; i < selectedWeekDIvs.length; i++) {
                selectedWeekDIvs[i].style.display = "block";
            }
            if (WeekeaderTitle.length) {
                WeekeaderTitle[0].innerText = 'Week ' + weekStartText + '-' + weekEndText; //currentDateValue.getMonth()
            }
            component.set("v.weekIndex", currentWeekIndex);
        }
    },

    prevDayDate: function (component, event, helper) {
        console.log("previousDate");
        console.log("date--> " + todayDateHeader);
        var todayDateHeader = component.get('v.todayDateHeader');
        var today = new Date(Date.parse(todayDateHeader));
        var newtodate = Date.parse(todayDateHeader);
        var newfromdate;
        if (today.getDate() == 1) {
            component.reloadPrevCalendar();
            /* Show Calendar view Div */
            document.getElementById('mycalendar').style.display = 'block';

            /*hide day view div*/
            document.getElementById('mycalendar2').style.display = 'none';
            document.getElementsByClassName('daily-header')[0].style.display = 'none';


        } else {
            component.set("v.showSpinner", true);
            newfromdate = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1);
            var evenList = component.get("v.eventList");
            var currentDateEventList = [];
            for (var i = 0; i < evenList.length; i++) {
                var eventItem = evenList[i];
                var eventStartDate = new Date(Date.parse(eventItem['startdate'])).setHours(0, 0, 0, 0);
                var eventEndDate = new Date(Date.parse(eventItem['enddate'])).setHours(0, 0, 0, 0);
                if (eventStartDate <= Date.parse(newfromdate) && eventEndDate >= Date.parse(newfromdate)) {
                    currentDateEventList.push(eventItem);
                }
            }
            console.log("allevents ", evenList);
            component.set("v.dateEventList", currentDateEventList);
            console.log('currentDateEventList--> ', currentDateEventList);
            component.set('v.todayDateHeader', new Date(newfromdate).toDateString());
            component.set("v.todayDate", new Date(newfromdate).toLocaleDateString());
            window.setTimeout(function () { component.set("v.showSpinner", false); }, 400);
        }
    },

    nextDayDate: function (component, event, helper) {

        console.log("NextDate");
        var todayDateHeader = component.get('v.todayDateHeader');
        var today = new Date(Date.parse(todayDateHeader));
        var newfromdate = Date.parse(todayDateHeader);
        var newtodate;
        var lastDateInMonth;
        if (today.getMonth() == 11) {
            lastDateInMonth = new Date(today.getFullYear() + 1, 0, 0);
        } else {
            lastDateInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        }

        if (lastDateInMonth.getDate() == today.getDate()) {
            component.reloadNextCalendar();
            /* Show Calendar view Div */
            document.getElementById('mycalendar').style.display = 'block';

            /*hide day view div*/
            document.getElementById('mycalendar2').style.display = 'none';
            document.getElementsByClassName('daily-header')[0].style.display = 'none';
        } else {
            component.set("v.showSpinner", true);
            newtodate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
            var evenList = component.get("v.eventList");
            var currentDateEventList = [];
            for (var i = 0; i < evenList.length; i++) {
                var eventItem = evenList[i];
                var eventStartDate = new Date(Date.parse(eventItem['startdate'])).setHours(0, 0, 0, 0);
                var eventEndDate = new Date(Date.parse(eventItem['enddate'])).setHours(0, 0, 0, 0);
                if (eventStartDate <= Date.parse(newtodate) && eventEndDate >= Date.parse(newtodate)) {
                    currentDateEventList.push(eventItem);
                }
            }
            console.log("allevents ", evenList);
            component.set("v.dateEventList", currentDateEventList);
            console.log('currentDateEventList--> ', currentDateEventList);
            component.set('v.todayDateHeader', new Date(newtodate).toDateString());
            component.set("v.todayDate", new Date(newtodate).toLocaleDateString());
            window.setTimeout(function () { component.set("v.showSpinner", false); }, 400);
        }


    },

    dayReset: function (component, event, helper) {
        console.log("cuurentDate");
        var currentDateStr = new Date();//component.get('v.currentDateValString');
        console.log("date--> " + currentDateStr);
        var today = currentDateStr
        var newtodate = new Date(Date.parse(currentDateStr)).setHours(0, 0, 0, 0);
        var newfromdate;
        var evenList = component.get("v.eventList");
        var currentDateEventList = [];


        var currentDate = new Date(component.get("v.dateval"));

        if (currentDate.getFullYear() != new Date(newtodate).getFullYear() || currentDate.getMonth() != new Date(newtodate).getMonth()) {
            component.reloadCurrentDateCalendar();
        } else {
            for (var i = 0; i < evenList.length; i++) {
                var eventItem = evenList[i];
                var eventStartDate = new Date(Date.parse(eventItem['startdate'])).setHours(0, 0, 0, 0);
                var eventEndDate = new Date(Date.parse(eventItem['enddate'])).setHours(0, 0, 0, 0);
                if (eventStartDate <= newtodate && eventEndDate >= newtodate) {
                    currentDateEventList.push(eventItem);
                }
            }
            console.log("allevents ", evenList);
            component.set("v.dateEventList", currentDateEventList);

            // Changes for BUIL-3936
            // To set yellow circle on selected date;
            var seletedDateClass = 'dateV' + today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate() - 1).padStart(2, '0');
            console.log('selected date : ', seletedDateClass);

            var monthDate = document.getElementsByClassName('m-d monthly-day monthly-day-event');
            console.log('monthDate.length : ', monthDate.length);
            if (monthDate.length) {
                for (var i = 0; i < monthDate.length; i++) {
                    if (monthDate[i].classList.contains(seletedDateClass)) {
                        var numberDiv = monthDate[i].querySelector('.monthly-day-number');
                        if (!numberDiv.classList.contains('selected-Date') && !monthDate[i].classList.contains('monthly-today')) {
                            numberDiv.classList.add('selected-Date');
                            console.log(`monthDate ${[i]} : `, monthDate[i].classList);
                        }
                    }
                    else {
                        if (monthDate[i].querySelector('.monthly-day-number').classList.contains('selected-Date')) {
                            monthDate[i].querySelector('.monthly-day-number').classList.remove('selected-Date');
                        }
                    }
                }
            }
        }

        console.log('currentDateEventList--> ', currentDateEventList);
        component.set('v.todayDateHeader', new Date(newtodate).toDateString());
        component.set("v.todayDate", new Date(newtodate).toLocaleDateString());
        component.set("v.dateval", new Date());

        console.log('currentDateValString :: ', component.get("v.currentDateValString"));
        console.log('todayDate :: ', component.get("v.todayDate"));

        // Chnages for BUIL-3936
        $(`#datepickerPlaceholder`).datepicker('setDate', today);
        console.log('defaultDate ->> ', $(`#datepickerPlaceholder`).datepicker('getDate'));
        event.stopPropagation();
    },

    resetPreNextTodayListeners: function (component, event, helper) {

        var prevBtn = document.getElementsByClassName('monthly-prev');
        var nextBtn = document.getElementsByClassName('monthly-next');
        var todayEle = document.getElementsByClassName('monthly-reset');

        var weekPrevBtn = document.getElementsByClassName('weekly-prev');
        var weekNextBtn = document.getElementsByClassName('weekly-next');

        var callBack1 = function (eve) {
            console.log(eve);
            if (todayEle.length) {
                for (var viewIndex = 0; viewIndex < todayEle.length; viewIndex++) {
                    todayEle[viewIndex].removeEventListener("click", callBack3);
                }
            }
            prevBtn[0].removeEventListener("click", callBack1);
            nextBtn[0].removeEventListener("click", callBack2);

            weekPrevBtn[0].removeEventListener("click", callBack4);
            weekNextBtn[0].removeEventListener("click", callBack5);

            component.reloadPrevCalendar("");
            prevBtn[0].blur();
            document.body.click();
        }
        var callBack2 = function (eve) {
            console.log(eve);
            if (todayEle.length) {
                for (var viewIndex = 0; viewIndex < todayEle.length; viewIndex++) {
                    todayEle[viewIndex].removeEventListener("click", callBack3);
                }
            }
            nextBtn[0].removeEventListener("click", callBack2);
            prevBtn[0].removeEventListener("click", callBack1);

            weekPrevBtn[0].removeEventListener("click", callBack4);
            weekNextBtn[0].removeEventListener("click", callBack5);

            component.reloadNextCalendar("");
            nextBtn[0].blur();
            document.body.click();
        }

        var callBack3 = function (eve) {
            console.log(eve);
            if (todayEle.length) {
                for (var viewIndex = 0; viewIndex < todayEle.length; viewIndex++) {
                    todayEle[viewIndex].removeEventListener("click", callBack3);
                }
            }
            nextBtn[0].removeEventListener("click", callBack2);
            prevBtn[0].removeEventListener("click", callBack1);

            weekPrevBtn[0].removeEventListener("click", callBack4);
            weekNextBtn[0].removeEventListener("click", callBack5);

            todayEle[0].blur();
            component.reloadCurrentDateCalendar("");
            document.body.click();
        }

        var callBack4 = function (eve) {
            component.reloadPrevWeekCalendar();
            weekPrevBtn[0].blur();
            document.body.click();
        }

        var callBack5 = function (eve) {
            component.reloadNextWeekCalendar();
            weekNextBtn[0].blur();
            document.body.click();
        }

        if (prevBtn.length) {
            prevBtn[0].addEventListener("click", callBack1);
        }

        if (nextBtn.length) {
            nextBtn[0].addEventListener("click", callBack2);
        }
        if (todayEle.length) {
            for (var viewIndex = 0; viewIndex < todayEle.length; viewIndex++) {
                todayEle[viewIndex].addEventListener("click", callBack3);
            }
        }
        if (weekPrevBtn.length) {
            weekPrevBtn[0].addEventListener("click", callBack4);
        }

        if (weekNextBtn.length) {
            weekNextBtn[0].addEventListener("click", callBack5);
        }

    },

    FilterResourceTasks: function (component, event, helper) {
        console.log(event.target.value);
        component.set("v.searchResourceFilter", event.target.value);
    },

    FilterTradeTypeTasks: function (component, event, helper) {
        component.set("v.allFilter", event.target.value);
    },

    doTaskResourceSearch: function (component, event, helper) {
        console.log(component.get("v.searchResourceFilter"));
        console.log(component.get("v.allFilter"));

        if (component.get("v.searchResourceFilter").trim() == '' || component.get("v.searchResourceFilter").trim() == undefined) {
            component.set("v.newSelectedProjectId", "");
        }

        component.set("v.showSpinner", true);
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
        console.log('ans 4--->', component.get("v.newSelectedProjectId"));
        console.log('component.get("v.project").Id ',component.get("v.project").Id);


        helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), component.get("v.project").Name, component.get("v.searchResourceFilter"), component.get("v.allFilter"))
        .then(response => {
            console.log('doTaskResourceSearch response.getReturnValue()::', response);
                component.set("v.showSpinner", true);

                //commenting projectList set attribute in order to show all projects with selected project
                component.set("v.projectList", response.projectList);

                var evetList = [];
                var projColors = component.get("v.projectColors");
                var resourceColors = component.get("v.resourceColors");

                if (component.get("v.newSelectedProjectId")) {
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
                                response.calendarTaskList[k].ProjectTaskRecordsList[j]['colorName'] = resourceColors[k % 10];
                                evetList.push(response.calendarTaskList[k].ProjectTaskRecordsList[j]);
                            }
                        }
                    }
                } else {
                    for (var itemIdx = 0; itemIdx < response.projectList.length; itemIdx++) {
                        for (var j = 0; j < response.projectList[itemIdx].CalendarWrapList.length; j++) {
                            var weekName = response.projectList[itemIdx].CalendarWrapList[j]['weekName'];
                            var startDate = response.projectList[itemIdx].CalendarWrapList[j]['startdate'];
                            var endDate = response.projectList[itemIdx].CalendarWrapList[j]['enddate'];
                            if (weekName != null && weekName != undefined) {
                                var dayNames = component.get("v.dayNames")
                                response.projectList[itemIdx].CalendarWrapList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3); //weekName.substring(0,3);
                            }

                            response.projectList[itemIdx].CalendarWrapList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                            response.projectList[itemIdx].CalendarWrapList[j]['startdateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(startDate)), 'MM-dd-yyyy');//new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                            response.projectList[itemIdx].CalendarWrapList[j]['enddateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(endDate)), 'MM-dd-yyyy'); //new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                            response.projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColors[itemIdx % 10];
                            evetList.push(response.projectList[itemIdx].CalendarWrapList[j]);
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

                helper.colorFullTasks(component, helper, response);
                helper.buildCalendar(component, helper);
                component.set("v.showSpinner", false);
        })
        .catch(error => {
            component.set("v.showSpinner", false);
            console.log('error', error);
        });
    },

    doTaskAllFilterSearch: function (component, event, helper) {
        component.set("v.showSpinner", true);
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

        if (component.get("v.searchResourceFilter").trim() == '' || component.get("v.searchResourceFilter").trim() == undefined) {
            component.set("v.newSelectedProjectId", "");
        }
        if (component.get("v.allFilter").trim() == '' || component.get("v.allFilter").trim() == undefined) {
            component.set("v.newSelectedProjectId", "");
        }

        var newFromstr, newTostr;

        newFromstr = $A.localizationService.formatDate(newfromdate, "yyyy-MM-dd");
        newTostr = $A.localizationService.formatDate(newtodate, "yyyy-MM-dd")
        console.log('ans 1--->', component.get("v.newSelectedProjectId"));
        console.log('component.get("v.project").Id ',component.get("v.project").Id);

        helper.getScheduleItems(component, newFromstr, newTostr, component.get("v.selectedTradetype").Id, component.get("v.newSelectedProjectId"), component.get("v.newContractResource"), component.get("v.project").Name, component.get("v.searchResourceFilter"), component.get("v.allFilter"))
        .then(response => {
            console.log('doTaskAllFilterSearch response.getReturnValue()::', response);
            component.set("v.showSpinner", true);

            //commenting projectList set attribute in order to show all projects with selected project
            component.set("v.projectList", response.projectList);

            var evetList = [];
            var eventIds = [];
            var projColors = component.get("v.projectColors");
            var resourceColors = component.get("v.resourceColors");
            if (response.projectList.length) {
                for (var itemIdx = 0; itemIdx < response.projectList.length; itemIdx++) {
                    if (response.projectList[itemIdx].CalendarWrapList) {
                        for (var j = 0; j < response.projectList[itemIdx].CalendarWrapList.length; j++) {
                            var weekName = response.projectList[itemIdx].CalendarWrapList[j]['weekName'];
                            var startDate = response.projectList[itemIdx].CalendarWrapList[j]['startdate'];
                            var endDate = response.projectList[itemIdx].CalendarWrapList[j]['enddate'];
                            if (weekName != null && weekName != undefined) {
                                var dayNames = component.get("v.dayNames");
                                response.projectList[itemIdx].CalendarWrapList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3);//weekName.substring(0,3);
                            }

                            response.projectList[itemIdx].CalendarWrapList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                            response.projectList[itemIdx].CalendarWrapList[j]['startdateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(startDate)), 'MM-dd-yyyy'); // new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                            response.projectList[itemIdx].CalendarWrapList[j]['enddateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(endDate)), 'MM-dd-yyyy');// new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                            response.projectList[itemIdx].CalendarWrapList[j]['colorName'] = projColors[itemIdx % 10];
                            if (eventIds.indexOf(response.projectList[itemIdx].CalendarWrapList[j].Id) < 0) {
                                evetList.push(response.projectList[itemIdx].CalendarWrapList[j]);
                                eventIds.push(response.projectList[itemIdx].CalendarWrapList[j].Id);
                            }

                        }
                    }
                }
            }
            if (response.calendarTaskList.length) {
                for (var itemIdx = 0; itemIdx < response.calendarTaskList.length; itemIdx++) {
                    if (response.calendarTaskList[itemIdx].ProjectTaskRecordsList) {
                        for (var j = 0; j < response.calendarTaskList[itemIdx].ProjectTaskRecordsList.length; j++) {
                            var weekName = response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['weekName'];
                            if (weekName != null && weekName != undefined) {
                                var startDate = response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['startdate'];
                                var endDate = response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['enddate'];
                                var dayNames = component.get("v.dayNames");
                                response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['weekSubStr'] = dayNames[new Date(Date.parse(startDate)).getDay()].substring(0, 3)//weekName.substring(0,3);
                            }

                            response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['startdateNum'] = new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0");
                            response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['startdateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(startDate)), 'MM-dd-yyyy');//new Date(Date.parse(startDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(startDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(startDate)).getFullYear();
                            response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['enddateFormatted'] = $A.localizationService.formatDate(new Date(Date.parse(endDate)), 'MM-dd-yyyy'); // new Date(Date.parse(endDate)).getDate().toString().padStart(2, "0")+'-'+(new Date(Date.parse(endDate)).getMonth()+1).toString().padStart(2, "0")+'-'+new Date(Date.parse(endDate)).getFullYear();
                            response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]['colorName'] = resourceColors[itemIdx % 10];
                            if (eventIds.indexOf(response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j].Id) < 0) {
                                evetList.push(response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j]);
                                eventIds.push(response.calendarTaskList[itemIdx].ProjectTaskRecordsList[j].Id);
                            }
                        }
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

            helper.colorFullTasks(component, helper, response);
            helper.buildCalendar(component, helper);
            component.set("v.showSpinner", false);
        })
        .catch(error => {
            component.set("v.showSpinner", false);
            console.log('error', error);
        });
    },

    setConflictData: function (component, event, helper) {
        var eventList = component.get("v.resourcesList");
        var weekDates = document.getElementsByClassName('monthly-list-item');
        var conflictTasks = [];
        var conflictMap = [];
        var conflictResource = [];
        var conflictResourceIndex = [];
        var conflictTaskResourceIndex = [];
        var taskIds = [];
        for (var i = 0; i < eventList.length; i++) {
            for (var k = 0; k < weekDates.length; k++) {
                if (eventList[i].ProjectTaskRecordsList != undefined) {
                    var EquipmentRecordsList = eventList[i].ProjectTaskRecordsList;
                    var tasks = 0;
                    var dateVal = new Date(component.get('v.dateval'));
                    var recordMap = new Map();
                    for (var p = 0; p < EquipmentRecordsList.length; p++) {

                        if (new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() >= new Date(EquipmentRecordsList[p].day).valueOf() && new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() <= new Date(EquipmentRecordsList[p].endday).valueOf()) {
                            tasks++;
                            if (!recordMap.has(eventList[i].ContractresourceId)) {
                                recordMap.set(eventList[i].ContractresourceId, []);
                                recordMap.get(eventList[i].ContractresourceId).push(i + '_' + p);
                            } else if (recordMap.has(eventList[i].ContractresourceId)) {
                                recordMap.get(eventList[i].ContractresourceId).push(i + '_' + p);
                                if (recordMap.get(eventList[i].ContractresourceId).length >= 2) {
                                    conflictResource.push(EquipmentRecordsList[p]);
                                    for (var s = 0; s < recordMap.get(eventList[i].ContractresourceId).length; s++) {
                                        var index = recordMap.get(eventList[i].ContractresourceId)[s];
                                        if (conflictResourceIndex.indexOf(index) < 0) {
                                            conflictResourceIndex.push(index);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    console.log(tasks);

                    if (tasks >= 2 && eventList[i].simultaneousTasksContractorResources != undefined && tasks < eventList[i].simultaneousTasksContractorResources) {
                        console.log(tasks);
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            console.log('aboveif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                            console.log(typeof weekDates[k].Date);
                            console.log(typeof EquipmentRecordsList[t].day);
                            console.log(typeof EquipmentRecordsList[t].endday);
                            if (new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                console.log('belowif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                                console.log('555')
                                if (conflictTaskResourceIndex.indexOf(EquipmentRecordsList[t].Id) < 0) {
                                    conflictTasks.push(EquipmentRecordsList[t]);
                                    conflictTaskResourceIndex.push(EquipmentRecordsList[t].Id);
                                }

                            }
                        }
                    } else if (tasks > 1 && eventList[i].simultaneousTasksContractorResources != undefined && tasks > eventList[i].simultaneousTasksContractorResources) {
                        console.log(tasks);
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            console.log('aboveif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                            console.log(typeof weekDates[k].Date);
                            console.log(typeof EquipmentRecordsList[t].day);
                            console.log(typeof EquipmentRecordsList[t].endday);
                            if (new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                console.log('belowif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                                console.log('545')
                                if (conflictTaskResourceIndex.indexOf(EquipmentRecordsList[t].Id) < 0) {
                                    conflictTasks.push(EquipmentRecordsList[t]);
                                    conflictTaskResourceIndex.push(EquipmentRecordsList[t].Id);
                                }
                            }
                        }
                    } else if (tasks >= 2 && (eventList[i].simultaneousTasksContractorResources == undefined || eventList[i].simultaneousTasksContractorResources == 0)) {
                        console.log(tasks);
                        for (var t = 0; t < EquipmentRecordsList.length; t++) {
                            console.log('aboveif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                            console.log(typeof weekDates[k].Date);
                            console.log(typeof EquipmentRecordsList[t].day);
                            console.log(typeof EquipmentRecordsList[t].endday);
                            if (new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() >= new Date(EquipmentRecordsList[t].day).valueOf() && new Date(dateVal.getFullYear(), dateVal.getMonth(), k + 1).valueOf() <= new Date(EquipmentRecordsList[t].endday).valueOf()) {
                                console.log('543')
                                console.log('belowif----calandaedate--->' + weekDates[k].Date + 'record stardate>=' + EquipmentRecordsList[t].day + 'record enddate-----&& <= ' + EquipmentRecordsList[t].endday);
                                if (conflictTaskResourceIndex.indexOf(EquipmentRecordsList[t].Id) < 0) {
                                    conflictTasks.push(EquipmentRecordsList[t]);
                                    conflictTaskResourceIndex.push(EquipmentRecordsList[t].Id);
                                }
                            }
                        }
                    }
                }
            }
        }
        console.log('conflictTasks::: ', conflictTasks)
        component.set("v.conflictEventList", conflictTasks);
        component.set("v.eventList", conflictTasks);
        helper.buildCalendarWithTasks(component, helper, component.get("v.resourcesList"), -1);
    },

    // Changes for BUIL-3936
    openDatePicker: function (component, event, helper) {
        try {
            console.log("HIiiiiiiiiiii");
            helper.openDatePickerHelper(component, event, helper);
        }
        catch (error) {
            console.log('error in openDatePicker : ', error.stack)
        }

    },

    // Changes for BUIL-3936... [Need to remove.. unused]
    handleDateChanged: function (component, event, helper) {
        try {
            console.log('datePicker handleDateChanged ');
            var dateText = event.getSource().get('v.value');
            console.log('Selected date:', dateText);
            component.set("v.startDt", dateText);
            helper.handleSaveDates(component, event, helper);
        } catch (error) {
            console.log('error in handleDateChanged : ', error.stack);

        }

    },

    handleAfterLoadscript: function (component, event, helper) {
        console.log("Script Loaded");
        $A.enqueueAction(component.get("c.doInit"));
    },

    handleSelectedProject: function (component, event, helper) {
        helper.handleSelectedProject(component, event, helper);
    },

})