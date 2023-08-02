({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        //helper.getResources(component);
        var today = new Date();
        component.set("v.calendarView","Dayview");
        // component.set("v.isConflictview", "Standard");
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-12);
        var now = new Date();
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        helper.currentWeekDates(component,Datevalue);
        helper.currentMonthsDates(component,Datevalue);
        //helper.gettabname(component);
        //  helper.getprojectTaskscontacts(component);
       // component.set("v.showSpinner",false);

    },
    Standardview : function(component, event, helper){
        component.set("v.isConflictview", "Standard");

        if(component.get("v.calendarView") == 'Dayview'){
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component,today);
        }



        // helper.currentWeekDates(component,Datevalue);
        // helper.currentMonthsDates(component,Datevalue);
    },
    Conflictview : function(component, event, helper) {
        component.set("v.isConflictview", "Conflicts");

        if(component.get("v.calendarView") == 'Dayview'){
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component,today);
        }





    },
    previousWeek : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        helper.currentWeekDates(component,component.get("v.beforeweekDate"));
    },
    nextWeek : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        helper.currentWeekDates(component,component.get("v.weeklastDate"));
    },




    taskdrawTable: function(component, event, helper) {
        //Start
        var conflictview  = component.get("v.isConflictview");
        //alert('conflictview---'+conflictview);
        var weekDates=component.get("v.weekDates");
        var eventList=component.get("v.eventList");
        var PaginationList = component.get("v.PaginationList");
        var tbody='';
        var datatable='';
        tbody+='<table class="table table-hover" id="demo-1" style="border: 1px solid #ececec;">';
        tbody+='<thead><tr>';
        tbody+='<th style="color: #313131;font-weight: normal;border-right: 1px solid #ECECEC;border-bottom: none;background: #f8f8f8;width: 335px;">Name</th>';
        tbody+='<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;width: 115px;">Slippage(Days)</th>';
        tbody+='</tr></thead>';
        tbody+='<tbody>';
        // console.log('EventList =======> ' + eventList.length);
        console.log('PagenationList =======> ' , {PaginationList});
       // alert('EventList =======> ' + eventList.length);
     //   alert('PaginationList =======> ' + PaginationList.length);

        for(var i=0;i<PaginationList.length;i++){
            tbody+='<tr>';
            tbody+='<td style="border-right: 1px solid #ECECEC !important;width: 335px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;display: inline-block;"><image src="/resource/buildertek__TaskIcon" style="width: 35px;height: 35px;border-radius: 50%;text-align: center;position: absolute;margin-top: 4px;" />&nbsp;&nbsp;<b> <a style="margin-left:31px;" target="_blank" href="/'+PaginationList[i].Id+'">'+PaginationList[i].title+' </a></b><br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ('+PaginationList[i].projectId+')</td>';
            tbody+='<td style="text-align: center;width: 115px;">'+PaginationList[i].slippage +'</td>';
            tbody+='</tr>';
            datatable+='<tr>';

            //for dataTable
            for(var k=0;k<weekDates.length;k++){
                //* if( weekDates[k].Day != 'Sun'  && conflictview != 'Conflicts'  ){
                    //* as per new requirement client wants to show weekend as well (Nishit Suthar MV Clouds)
                if( conflictview != 'Conflicts'  ){
                    var now = new Date();
                    var todaydate  = $A.localizationService.formatDate(now, 'MM/dd/yyyy');
                    console.log('-------------todaydate'+todaydate);

                    if( new Date(PaginationList[i].endday).valueOf() <=  new Date(weekDates[k].Date).valueOf() && new Date(todaydate).valueOf() >= new Date(weekDates[k].Date).valueOf()){
                          console.log('-------------todaydate'+todaydate);
                            console.log('-------------enddate'+PaginationList[i].endday);
                          const dt1 = new Date(weekDates[k].Date);
                          const dt2 = new Date(PaginationList[i].endday);

                        //   const diffDays =  Math.floor((Date.UTC(dt2.getFullYear(), dt2.getMonth(), dt2.getDate()) - Date.UTC(dt1.getFullYear(), dt1.getMonth(), dt1.getDate()) ) /(1000 * 60 * 60 * 24));
                        var count = 0;
                        var curDate = dt2;
                        while (curDate < dt1) {
                            var dayOfWeek = curDate.getDay();
                            //* if(!((dayOfWeek == 6) || (dayOfWeek == 0)))
                            //* commented above line because client wants to add count for weekend as well (Nishit Suthar MV Clouds)
                            count++;
                            curDate.setDate(curDate.getDate() + 1);
                        }
                        var businessworkingdys = 0;
                        if(count == '0'){
                            businessworkingdys = count;
                        }else{
                            businessworkingdys = '-'+count;
                        }
                        if(businessworkingdys == 0){
                           datatable+='<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                           datatable+='<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: green;padding: 8px 0px;border-radius: 4px;color: #fff;font-size: 14px;height: 35px;width: 35px;">'+ businessworkingdys +'</span>';
                            datatable+='<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;right:0;">';
                            datatable+='<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px">'+PaginationList[i].taskdescription+' </h2>';
                            datatable+='<table class="tabel table-bordered" style="border: 1px solid #ddd;width: 700px;padding: 10px;">';
                            datatable+='<tbody><tr>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Internal Resource</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Contractor</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Contractor Resource</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Notes</th>';
                            datatable+='</tr>';
                            datatable+='<tr>';
                            	    if(PaginationList[i].internelresource != undefined){
                                    datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate">'+ PaginationList[i].internelresource +'</td>';
                                    }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"></td>';
                                    }
                            		 if(PaginationList[i].ContractorName != undefined){
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">'+PaginationList[i].ContractorName +'</td>';
                                     }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"></td>';
                                    }
                            		 if(PaginationList[i].contractresourceId != undefined){
                                         datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">'+PaginationList[i].contractresourceId +'</td>';
                                     }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"></td>';
                                    }
                             		if(PaginationList[i].taskNotes != undefined){
                                         datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"">'+PaginationList[i].taskNotes +'</td>';
                             			}else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px; class="slds-truncate"></td>';
                                    }
                                    datatable+='</tr>';
                            datatable+='</tbody></table>';
                            datatable+='</div>';
                           datatable+='</td></li>';
                        }else{
                         datatable+='<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                         datatable+='<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: red;padding: 8px 0px;border-radius: 4px;color: #fff;font-size: 14px;height: 35px;width: 35px;">'+ businessworkingdys +'</span>';
                            datatable+='<div class="hover-box" style="display: none;clear: both;position: absolute;background: #fff;border-radius: 4px;margin-top: 14px;right:0">';
                            datatable+='<h2 style="background: #d8dada;margin: 0;font-size: 14px;color: #000;text-align: left;padding:8px 10px">'+PaginationList[i].taskdescription+' </h2>';
                            datatable+='<table class="tabel table-bordered" style="border: 1px solid #ddd;width: 700px;padding: 10px;">';
                            datatable+='<tbody><tr>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Internal Resource</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Contractor</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Contractor Resource</th>';
                            datatable+='<th style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">Notes</th>';
                            datatable+='</tr>';
                            datatable+='<tr>';
                                     if(PaginationList[i].internelresource != undefined){
                                    datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">'+ PaginationList[i].internelresource +'</td>';
                                    }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;"></td>';
                                    }
                            		 if(PaginationList[i].ContractorName != undefined){
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">'+PaginationList[i].ContractorName +'</td>';
                                     }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;"></td>';
                                    }
                            		 if(PaginationList[i].contractresourceId != undefined){
                                         datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;">'+PaginationList[i].contractresourceId +'</td>';
                                     }else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;"></td>';
                                    }
                             		if(PaginationList[i].taskNotes != undefined){
                                         datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;" >'+PaginationList[i].taskNotes +'</td>';
                             			}else{
                                        datatable+='<td style="border: 1px solid #ddd;font-size: 12px;padding: 3px;" ></td>';
                                    }
                                    datatable+='</tr>';
                            datatable+='</tbody></table>';
                            datatable+='</div>';
                         datatable+='</td></li>';
                        }
                    }else{
                        datatable+='<td class="top-td-box" onclick="{!c.displayPopup}" style="vertical-align: middle;text-align: center;padding: 0px !important;">';
                        datatable+='<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: lightgrey;padding: 5px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 35px;width: 35px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';
                        datatable+='</td></li>';
                    }
                }
                else{

                    if( weekDates[k].Day != 'Sun'  && conflictview == 'Conflicts'){
                        datatable+='<td style="text-align: center;vertical-align: middle;padding: 3px 0px 0px 0px !important;">';
                        datatable+='<li style="display: inline-block;"><span style="display: block;margin: 0 auto;background: #DBE4EE;padding: 5px 5px;border-radius: 4px;color: #fff;font-size: 15px;height: 35px;width: 35px;"><image src="/resource/buildertek__buildingfa" height="20px" width="20px"/></span>';

                        datatable+='</li></td>';
                    }else{
                        datatable+='<td style="text-align: center;padding: 0px !important;">';

                        datatable+='</td>';
                    }

                }


            }
            datatable+='</tr>';
        }
        tbody+='</tbody></table>';
        if(tbody != null){
            document.getElementById("taskwork-div").innerHTML=tbody;
        }
        var dataDiv = '';
        var mnt1 = '';
        var mnt2 = '';
        var colspanmnt1=0;
        var colspanmnt2=0;
        var headerTr ='';
        var bodyTr ='';
        dataDiv+='<table class="table table-hover" id="demo-1" >';
        dataDiv+='<thead>';
        //dataDiv+='<tr><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th><th></th></tr>';
        //dataDiv+='<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center> september</center></th></tr>';
        bodyTr+='<tr>';
        for(var k=0;k<weekDates.length;k++){
            if(mnt1 == '' && weekDates[k].DayMonth != undefined){
                mnt1 = weekDates[k].DayMonth;
                colspanmnt1 = colspanmnt1+1;
            }
            else if(mnt1 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined){
                mnt1 = weekDates[k].DayMonth;
                colspanmnt1 = colspanmnt1+1;
            }

            if(mnt1 != '' && mnt2 == '' && weekDates[k].DayMonth != mnt1 && weekDates[k].DayMonth != undefined){
                mnt2 = weekDates[k].DayMonth;
                colspanmnt2 = colspanmnt2+1;
            }
            else if(mnt2 == weekDates[k].DayMonth && weekDates[k].DayMonth != undefined){
                mnt2 = weekDates[k].DayMonth;
                colspanmnt2 = colspanmnt2+1;
            }




            //* if(weekDates[k].Day != 'Sun'){
            //* commented this line because client wants to add weekend in chart (Nishit Suthar MV Clouds)
            if(weekDates[k].Day){
                if(weekDates[k].Dayview == '01'){
                    bodyTr+='<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;border-left: 2px solid #dbe4ee;">'+weekDates[k].Day+'&nbsp;'+weekDates[k].Dayview+'</th>';
                }
                else{
                    bodyTr+='<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;">'+weekDates[k].Day+'&nbsp;'+weekDates[k].Dayview+'</th>';
                }

            }else{
                bodyTr+='<th style="color: #313131;font-weight: normal;text-align: center;border-bottom: none;background: #f8f8f8;"></th>';
            }
            console.log(weekDates[k].DayMonth+'-----'+weekDates[k].Day+'--------'+weekDates[k].Dayview);
        }
        if(mnt2 == 0){
            headerTr+='<tr style="background: #f8f8f8;"><th colspan="18" style="height: 40px;background: #f8f8f8;"><center>'+mnt1+'</center></th></tr>';
        }
        else{
            headerTr+='<tr style="background: #f8f8f8;"><th colspan="'+colspanmnt1+'" style="height: 40px;background: #f8f8f8;"><center>'+mnt1+'</center></th><th colspan="'+colspanmnt2+'" style="height: 40px;background: #f8f8f8;border-left: 2px solid #dbe4ee;"><center>'+mnt2+'</center></th></tr>';
        }


        console.log('-----'+weekDates.length);
        console.log(mnt1+'-----'+mnt2);
        console.log(colspanmnt1+'-----'+colspanmnt2);

        bodyTr+='</tr>';

        dataDiv+=headerTr+bodyTr+datatable;

        dataDiv+='</thead>';
        dataDiv+='</table>';


        document.getElementById("taskdata-div").innerHTML=dataDiv;
        component.set("v.showSpinner", false);


    } ,
    displayPopup : function(component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues+"cnt").style.display="";
    },

    hidePopup : function(component, event, helper) {
        var listValues = event.currentTarget.id;
        document.getElementById(listValues+"cnt").style.display="none";
    },



    handleComponentEvent: function (component, event, helper) {
        // get the selected Account record from the COMPONETN event

        //var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //component.set("v.selectedContact", selectedAccountGetFromEvent.Id);
        var slectedcontactId = JSON.stringify(component.get("v.selectedContact").Id);
        var slectedaccountId = JSON.stringify(component.get("v.selectedAccount").Id);
        var slectedprojectId = JSON.stringify(component.get("v.selectedproject").Id);
        var slectedTradetypeId = JSON.stringify(component.get("v.selectedTradetype").Id);


        if(component.get("v.calendarView") == 'Dayview'){
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component,today);
        }


    },
    ClearhandleComponentEvent: function (component, event, helper) {
        if(component.get("v.calendarView") == 'Dayview'){
            var currentDate = component.get("v.beforeweekDate");
            var today = new Date(currentDate);
            today.setDate(today.getDate() + 20);
            helper.currentWeekDates(component,today);
        }

    },
    optionSelected : function (component, event, helper) {
        var slippagePicklistvalue = component.find("slippagePicklist").get("v.value");
       // component.set("v.showSpinner",true);
        var today = new Date();
        component.set("v.calendarView","Dayview");
        // component.set("v.isConflictview", "Standard");
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-12);
        var now = new Date();
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        component.set("v.showSpinner",true);
        helper.currentWeekDates(component,Datevalue);
    },
    next: function (component, event, helper) {
       component.set("v.showSpinner", true);
        var sObjectList = component.get("v.eventList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        setTimeout(function () {
            component.taskdrawTable();
        }, 200);
    },
    previous: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var sObjectList = component.get("v.eventList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        setTimeout(function () {
            component.taskdrawTable();
        }, 200);
    },


})