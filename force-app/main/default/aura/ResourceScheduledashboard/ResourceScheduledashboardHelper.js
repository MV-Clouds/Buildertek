({
    gettabname: function(component, event, helper) {
        var workspaceAPI = component.find("workspaceresource");
        workspaceAPI.openTab({
            url: '/lightning/n/buildertek__Resource',
            focus: true
        }).then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Resource Dashboard"
            })
        })
    },
    getResources: function(component) {
        var action = component.get("c.getAllResourcess");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.contactList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    currentWeekDates: function(component, Datevalue) {
        // console.log('currentWeekDates ========> ');
        var today = new Date(Datevalue);
        //alert('current date===='+today);
        var week = [];

        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 1);
        week.push({
            Day: 'Mon',
            Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(mondayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(mondayOfWeek, 'MMMM')
        });
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 2);
        week.push({
            Day: 'Tue',
            Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(tuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(tuedayOfWeek, 'MMMM')
        });
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 3);
        week.push({
            Day: 'Wed',
            Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(weddayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(weddayOfWeek, 'MMMM')
        });
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 4);
        week.push({
            Day: 'Thu',
            Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(thuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(thuedayOfWeek, 'MMMM')
        });
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 5);
        week.push({
            Day: 'Fri',
            Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(fridayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(fridayOfWeek, 'MMMM')
        });
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 6);
        // week.push({Day:'Sat',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 7);
        week.push({
            Day: 'Sun',
            Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy'),
            DayMonth: $A.localizationService.formatDate(sundayOfWeek, 'MMMM')
        });
        // console.log('currentWeekDates 1 ========> ');
        var nextmondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 8);
        week.push({
            Day: 'Mon',
            Date: $A.localizationService.formatDate(nextmondayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(nextmondayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(nextmondayOfWeek, 'MMMM')
        });
        var nexttuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 9);
        week.push({
            Day: 'Tue',
            Date: $A.localizationService.formatDate(nexttuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(nexttuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(nexttuedayOfWeek, 'MMMM')
        });
        var nextweddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 10);
        week.push({
            Day: 'Wed',
            Date: $A.localizationService.formatDate(nextweddayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(nextweddayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(nextweddayOfWeek, 'MMMM')
        });
        var nextthuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 11);
        week.push({
            Day: 'Thu',
            Date: $A.localizationService.formatDate(nextthuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(nextthuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(nextthuedayOfWeek, 'MMMM')
        });
        var nextfridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 12);
        week.push({
            Day: 'Fri',
            Date: $A.localizationService.formatDate(nextfridayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(nextfridayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(nextfridayOfWeek, 'MMMM')
        });
        var nextsatdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 13);
        // week.push({Day:'Sat',Date: $A.localizationService.formatDate(nextsatdayOfWeek, 'MM/dd/yyyy')});
        var nextsundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 14);
        week.push({
            Day: 'Sun',
            Date: $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy'),
            DayMonth: $A.localizationService.formatDate(nextsundayOfWeek, 'MMMM')
        });


        var next2mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 15);
        week.push({
            Day: 'Mon',
            Date: $A.localizationService.formatDate(next2mondayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(next2mondayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(next2mondayOfWeek, 'MMMM')
        });
        var next2tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 16);
        week.push({
            Day: 'Tue',
            Date: $A.localizationService.formatDate(next2tuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(next2tuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(next2tuedayOfWeek, 'MMMM')
        });
        var next2weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 17);
        week.push({
            Day: 'Wed',
            Date: $A.localizationService.formatDate(next2weddayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(next2weddayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(next2weddayOfWeek, 'MMMM')
        });
        var next2thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 18);
        week.push({
            Day: 'Thur',
            Date: $A.localizationService.formatDate(next2thuedayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(next2thuedayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(next2thuedayOfWeek, 'MMMM')
        });
        var next2fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 19);
        week.push({
            Day: 'Fri',
            Date: $A.localizationService.formatDate(next2fridayOfWeek, 'MM/dd/yyyy'),
            Dayview: $A.localizationService.formatDate(next2fridayOfWeek, 'dd'),
            DayMonth: $A.localizationService.formatDate(next2fridayOfWeek, 'MMMM')
        });
        var next2satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 20);
        //week.push({Day:'Sat',Date: $A.localizationService.formatDate(next2satdayOfWeek, 'MM/dd/yyyy'),Dayview : $A.localizationService.formatDate(next2fridayOfWeek, 'dd'),  DayMonth : $A.localizationService.formatDate(next2satdayOfWeek, 'MMMM')});
        var next2sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 21);
        week.push({
            Day: 'Sun',
            Date: $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy'),
            DayMonth: $A.localizationService.formatDate(next2sundayOfWeek, 'MMMM')
        });

        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 20);
        // var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-6);

        // console.log('currentWeekDates 2 ========> ');
        component.set("v.weekDates", week);
        component.set("v.beforeweekDate", beforeOfWeek);
        component.set("v.weekfirstDate", mondayOfWeek);
        component.set("v.weeklastDate", next2sundayOfWeek);

        var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
        // console.log('currentWeekDates 4 ========> ');
        //alert(JSON.stringify(component.get("v.selectedTradetype")));
        //alert(fromdateStr+'<-------from-----todate---->'+todateStr);
        action.setParams({
            fromDate: fromdateStr,
            toDate: todateStr,
            slectedTradetypeId: component.get("v.selectedTradetype").Id,
            slectedprojectId: component.get("v.selectedproject").Id,
            slectedcontactId: component.get("v.selectedContact").Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // console.log('state ----------' + state + ' ' + JSON.stringify(response.getReturnValue()));
            if (component.isValid() && state === "SUCCESS") {
                console.log('response.getReturnValue()::', response.getReturnValue());
                component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
                component.drawTable('');
            } else {
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    groupbyWeekViewHelper: function(component, Datevalue) {
        var today = new Date(Datevalue);
        var week = [];

        var firstDate = new Date(today.getFullYear(), today.getMonth(), 1);
        var lastDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        var numDays = lastDate.getDate();
        var weekdays = new Array(7);
        weekdays[0] = "Sunday";
        weekdays[1] = "Monday";
        weekdays[2] = "Tuesday";
        weekdays[3] = "Wednesday";
        weekdays[4] = "Thursday";
        weekdays[5] = "Friday";
        weekdays[6] = "Saturday";
        var weekLoop = [];
        var weekNumberLoop = [];
        var start = 1;
        var dayst = 0;
        var end = 7 - firstDate.getDay();
        while (start <= numDays) {
            var weekstr = '';
            // for (var step = start; step < end; step++) {
            for (var step = start; step < end; step++) {
                var nd = new Date(today.getFullYear(), today.getMonth(), step);
                // alert(nd);
                var startdate;
                var weekenddate;
                var dayname = weekdays[nd.getDay()];
                if (weekstr == '' && dayname == 'Monday') {
                    weekstr += '' + step;
                    startdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (weekstr == '' && dayname == 'Tuesday') {
                    weekstr += '' + step;
                    startdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (weekstr == '' && dayname == 'Wednesday') {
                    weekstr += '' + step;
                    startdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (weekstr == '' && dayname == 'Thursday') {
                    weekstr += '' + step;
                    startdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (weekstr == '' && dayname == 'Friday') {
                    weekstr += '' + step;
                    startdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                var lastday = end - 1;
                if (step == lastday && dayname == 'Friday') {
                    weekstr += '-' + step;
                    weekenddate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (step == lastday && dayname != 'Friday') {
                    if (weekstr == '') {
                        weekstr += end + '-' + end;
                    } else {
                        weekstr += '-' + end;
                    }
                    if (weekstr) {
                        var diff = Number(weekstr.split('-')[1]) - Number(weekstr.split('-')[0])

                        if (diff < 4) {
                            var nd = new Date(today.getFullYear(), today.getMonth(), end);
                        }
                    }

                    weekenddate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }

            }
            //weekNumberLoop.push({start:startdate,end:weekenddate,weekstr:weekstr});
            if (weekstr != null && weekstr != '') {
                week.push({
                    Day: weekstr,
                    Date: startdate,
                    Dayview: $A.localizationService.formatDate(startdate, 'dd'),
                    DayMonth: $A.localizationService.formatDate(startdate, 'MMMM'),
                    weekEndDate: weekenddate
                });
            }
            start = end + 1;
            end = end + 7;
            if (end > numDays)
                end = numDays;
        }

        var nxtfirstDate = new Date(today.getFullYear(), today.getMonth() + 1, 1);
        var nxtlastDate = new Date(today.getFullYear(), today.getMonth() + 2, 0);
        var nxtnumDays = nxtlastDate.getDate();
        var weekdays = new Array(7);
        weekdays[0] = "Sunday";
        weekdays[1] = "Monday";
        weekdays[2] = "Tuesday";
        weekdays[3] = "Wednesday";
        weekdays[4] = "Thursday";
        weekdays[5] = "Friday";
        weekdays[6] = "Saturday";
        var weekLoop = [];
        //  var weekNumberLoop = [];
        var start = 1;
        var dayst = 0;
        var end = 7 - nxtfirstDate.getDay();
        while (start <= nxtnumDays) {
            var nxtweekstr = '';
            for (var step = start; step < end; step++) {
                var nd = new Date(today.getFullYear(), today.getMonth() + 1, step);
                // alert(nd);
                var nxtstartdate;
                var nxtweekenddate;
                var dayname = weekdays[nd.getDay()];
                if (nxtweekstr == '' && dayname == 'Monday') {
                    nxtweekstr += '' + step;
                    nxtstartdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (nxtweekstr == '' && dayname == 'Tuesday') {
                    nxtweekstr += '' + step;
                    nxtstartdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (nxtweekstr == '' && dayname == 'Wednesday') {
                    nxtweekstr += '' + step;
                    nxtstartdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (nxtweekstr == '' && dayname == 'Thursday') {
                    nxtweekstr += '' + step;
                    nxtstartdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (nxtweekstr == '' && dayname == 'Friday') {
                    nxtweekstr += '' + step;
                    nxtstartdate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                var lastday = end - 1;
                if (step == lastday && dayname == 'Friday') {
                    nxtweekstr += '-' + step;
                    nxtweekenddate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }
                if (step == lastday && dayname != 'Friday') {
                    if (nxtweekstr == '') {
                        nxtweekstr += end + '-' + end;
                    } else {
                        nxtweekstr += '-' + end;
                    }
                    nxtweekenddate = $A.localizationService.formatDate(nd, 'MM/dd/yyyy');
                }

            }
            //  weekNumberLoop.push({start:nxtstartdate,end:nxtweekenddate,weekstr:nxtweekstr});
            if (nxtweekstr != null && nxtweekstr != '') {
                week.push({
                    Day: nxtweekstr,
                    Date: nxtstartdate,
                    Dayview: $A.localizationService.formatDate(nxtstartdate, 'dd'),
                    DayMonth: $A.localizationService.formatDate(nxtstartdate, 'MMMM'),
                    weekEndDate: nxtweekenddate
                });
            }
            start = end + 1;
            end = end + 7;
            if (end > nxtnumDays)
                end = nxtnumDays;
        }
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth() - 2, 1);
        var nextweekenddate = new Date(today.getFullYear(), today.getMonth() + 3, 0);
        component.set("v.beforeweekDate", $A.localizationService.formatDate(beforeOfWeek, 'MM/dd/yyyy'));
        component.set("v.weekfirstDate", $A.localizationService.formatDate(firstDate, 'MM/dd/yyyy'));
        component.set("v.weeklastDate", nextweekenddate);
        //alert(JSON.stringify(week));
        // component.set("v.weekDates",weekNumberLoop);
        component.set("v.weekDates", week);

        var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(firstDate, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = nxtweekenddate;
        var todateStr = toDate.toString();
        //alert(fromDate+'-------'+toDate);

        action.setParams({
            fromDate: fromdateStr,
            toDate: todateStr,
            slectedTradetypeId: component.get("v.selectedTradetype").Id,
            slectedprojectId: component.get("v.selectedproject").Id,
            slectedcontactId: component.get("v.selectedContact").Id

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ----------' + state + ' ' + response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {

                // alert(JSON.stringify(response.getReturnValue()));

                component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
                component.drawTablebyweek('');
            } else {
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);

    },

    currentMonthsDates: function(component, Datevalue) {
        var today = new Date(Datevalue);
    },

    getprojectTaskscontacts: function(component) {
        var action = component.get("c.getAllResourcess");
        var SelectedOptions = component.get("v.SelectedOptions");
        action.setParams({
            selected: SelectedOptions
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.projecttaskcontactlist", response.getReturnValue());
                console.log('---->', JSON.stringify(component.get("v.projecttaskcontactlist")));
            }
        });
        $A.enqueueAction(action);
    },

})