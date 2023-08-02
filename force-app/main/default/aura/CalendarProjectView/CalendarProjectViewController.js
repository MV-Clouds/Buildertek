({
	doInit : function(component, event, helper) { 
        
        component.set("v.recordIds",true)
        if(component.get("v.recordId") != undefined){
            var SelectedOptions = component.get("v.SelectedOptions");
        	SelectedOptions.push(component.get("v.recordId"));
        	component.set("v.SelectedOptions",SelectedOptions);
        	component.set("v.recordIds",false);
        }
        document.title = "Project Scheduler";
        component.set("v.showSpinner", true);
        var today = new Date();
        component.set("v.calendarView","week");
        component.set("v.ColorName1","Project Task");
        component.set("v.ColorName2","Resources");
        component.set("v.displayView","project");
        component.set("v.leftpanelshoworhide", true);
        
               // var SelectedOptions = component.get("v.SelectedOptions");
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        var now = new Date(); 
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
        
      //  helper.getprojects(component); 
      //  helper.getContacts(component);
	  //  helper.getprojectTasks(component);     
	  
        
		//helper.getRoles(component);
        //helper.getLocations(component);
        //helper.getPermission(component);
        if(component.get("v.projectView") == 'Active'){
        //helper.getprojects(component);  
        }

        
        if(component.get("v.calendarView") == 'week'){
            helper.currentWeekDates(component,Datevalue);   
        }
        else{
            var today = new Date();
            var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
            component.set("v.currentDate",Datevalue);	
            helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        } 
        component.set("v.showSpinner", false);
	},
    
    leftpanel : function(component, event, helper) {
        var lp = component.find('leftPanel');
        if(component.get("v.leftpanelshoworhide") == true){
        	component.set("v.leftpanelshoworhide", false);
        }
        else{
          component.set("v.leftpanelshoworhide", true);  
        }
        for(var cmp in lp) {
            $A.util.toggleClass(lp[cmp], 'slds-show');  
            $A.util.toggleClass(lp[cmp], 'slds-hide');  
        }
            
    },
    
    ResourceCollapse : function(component, event) { 
        var existingText = component.get("v.ResourceCollapseText");
        var container = component.find("resourceCollapsable") ;
        var container1 = component.find("projectTaskCollapsable") ;
        var container2 = component.find("projectCollapsable") ;
        
        if(existingText === "[ - ]"){
            component.set("v.ResourceCollapseText","[ + ]");
            $A.util.addClass(container, 'slds-hide');
        }else{
            component.set("v.ResourceCollapseText","[ - ]"); 
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            $A.util.addClass(container2, 'slds-hide');
            component.set("v.projectTaskCollapseText","[ + ]"); 
            component.set("v.projectCollapseText","[ + ]");
        }  
    }, 
    projectTaskCollapse : function(component, event) { 
        var existingText = component.get("v.projectTaskCollapseText");
        var container = component.find("projectTaskCollapsable") ;
        var container1 = component.find("resourceCollapsable") ;
        var container2 = component.find("projectCollapsable") ;
        if(existingText === "[ - ]"){
            component.set("v.projectTaskCollapseText","[ + ]");
            $A.util.addClass(container, 'slds-hide');
        }else{
            component.set("v.projectTaskCollapseText","[ - ]"); 
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            $A.util.addClass(container2, 'slds-hide');
            component.set("v.ResourceCollapseText","[ + ]");
            component.set("v.projectCollapseText","[ + ]");
        }  
    }, 
    
    projectCollapse : function(component, event) {  
        var existingText = component.get("v.projectCollapseText");
        var container = component.find("projectCollapsable") ;
        var container1 = component.find("resourceCollapsable") ;
        var container2 = component.find("projectTaskCollapsable") ;
        if(existingText === "[ - ]"){
            component.set("v.projectCollapseText","[ + ]");
            $A.util.addClass(container, 'slds-hide');
        }else{
            component.set("v.projectCollapseText","[ - ]"); 
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            $A.util.addClass(container2, 'slds-hide');
            component.set("v.ResourceCollapseText","[ + ]");    
            component.set("v.projectTaskCollapseText","[ + ]"); 
        }  
    }, 
    FilterContacts : function(component, event, helper) {
        var input, filter, ul, li, a, i;
        input = document.getElementById("SearchKeyValue");
        filter = input.value.toUpperCase();
        ul = document.getElementById("availableContacts");
        li = ul.getElementsByTagName('li');
        
        // Loop through all list items, and hide those who dont match the search query
        for (i = 0; i < li.length; i++) {
            a = li[i];
            if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
        
      
    },
    FilterprojectTasks : function(component, event, helper) {
        var input, filter, ul, li, a, i;
        input = document.getElementById("SearchKeyValue2");
        filter = input.value.toUpperCase();
        ul = document.getElementById("availableprojectTasks");
        li = ul.getElementsByTagName('li');
        
        // Loop through all list items, and hide those who dont match the search query
        for (i = 0; i < li.length; i++) {
            a = li[i];
            if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
        
      
    },  
    
     FilterProjects : function(component, event, helper) {
        var input, filter, ul, li, a, i;
        input = document.getElementById("SearchKeyValue3");
        filter = input.value.toUpperCase();
        ul = document.getElementById("availableProjects");
        li = ul.getElementsByTagName('li');
        
        // Loop through all list items, and hide those who dont match the search query
        for (i = 0; i < li.length; i++) {
            a = li[i];
            if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
        
      
    },  
    previousDay : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        today.setDate(today.getDate() -1);
        var weekName;
        if(component.get("v.weekName") == 'Monday'){
        	weekName = 'Sunday' 
            component.set("v.weekName","Sunday");
        }
        else if(component.get("v.weekName") == 'Sunday'){
        	weekName = 'Saturday' 
            component.set("v.weekName","Saturday");
        }
        else if(component.get("v.weekName") == 'Saturday'){
        	weekName = 'Friday' 
            component.set("v.weekName","Friday");
        }
        else if(component.get("v.weekName") == 'Friday'){
        	weekName = 'Thursday' 
            component.set("v.weekName","Thursday");
        }
        else if(component.get("v.weekName") == 'Thursday'){
        	weekName = 'Wednesday' 
            component.set("v.weekName","Wednesday");
        }
        else if(component.get("v.weekName") == 'Wednesday'){
        	weekName = 'Tuesday' 
            component.set("v.weekName","Tuesday");
        }
        else if(component.get("v.weekName") == 'Tuesday'){
        	weekName = 'Monday' 
            component.set("v.weekName","Monday");
        }
		helper.dayViewHelper(component,today,weekName);
	},
    nextDay : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        today.setDate(today.getDate() + 1);
        var weekName;
        if(component.get("v.weekName") == 'Monday'){
        	weekName = 'Tuesday' 
            component.set("v.weekName","Tuesday");
        }
        else if(component.get("v.weekName") == 'Tuesday'){
        	weekName = 'Wednesday' 
            component.set("v.weekName","Wednesday");
        }
        else if(component.get("v.weekName") == 'Wednesday'){
        	weekName = 'Thursday' 
            component.set("v.weekName","Thursday");
        }
        else if(component.get("v.weekName") == 'Thursday'){
        	weekName = 'Friday' 
            component.set("v.weekName","Friday");
        }
        else if(component.get("v.weekName") == 'Friday'){
        	weekName = 'Saturday' 
            component.set("v.weekName","Saturday");
        }
        else if(component.get("v.weekName") == 'Saturday'){
        	weekName = 'Sunday' 
            component.set("v.weekName","Sunday");
        }
        else if(component.get("v.weekName") == 'Sunday'){
        	weekName = 'Monday' 
            component.set("v.weekName","Monday");
        }
		helper.dayViewHelper(component,today,weekName);
	},   
    previousWeek : function(component, event, helper) {
        //component.set("v.showSpinner", true);
		helper.currentWeekDates(component,component.get("v.beforeweekDate"));
	},
    nextWeek : function(component, event, helper) {
        //component.set("v.showSpinner", true);
		helper.currentWeekDates(component,component.get("v.weeklastDate"));
	},
    previousTwoWeeks : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        helper.twoWeekDates(component,component.get("v.beforeweekDate"));

	},
	previousThreeWeeks : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        helper.threeWeekDates(component,component.get("v.beforeweekDate")); 
	}, 
    nextTwoWeeks : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
		helper.twoWeekDates(component,component.get("v.weeklastDate"));
	},
    nextThreeWeeks : function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
		helper.threeWeekDates(component,component.get("v.weeklastDate"));
	},
    dayView:function(component, event, helper){
      //component.set("v.showSpinner", true);
      component.set("v.calendarView","day");
      component.set("v.weekName","Monday");
      var today = new Date();
      var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
      component.set("v.currentDate",Datevalue);	
      helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
    }, 
    oneWeek:function(component, event, helper){
        //component.set("v.showSpinner", true);
        component.set("v.calendarView","week");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.currentWeekDates(component,Datevalue); 
        
    }, 
    twoWeeks:function(component, event, helper){
        //component.set("v.showSpinner", true);
        component.set("v.calendarView","twoweeks");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.twoWeekDates(component,Datevalue); 	
        
    },
    threeWeeks:function(component, event, helper){
        //component.set("v.showSpinner", true);
        component.set("v.calendarView","threeweeks");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.threeWeekDates(component,Datevalue); 	
        
    },
    closeModal: function(component, event, helper) {
        var modal = component.find('modaldialog');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(modal,'slds-fade-in-open');
        $A.util.removeClass(backdrop,'slds-backdrop--open');         
	},
	SaveCrewmember: function(component, event, helper) {
        component.set("v.showSpinner", true);
        //var inputsel = component.find("InputSelectDynamic").get('v.value');
         
        var inputSchedularId='';
        //var inputUnit='';
        //var inputModel='';
        if(!component.get("v.NoSchedules")){
        inputSchedularId = component.find("InputSelectSchedular").get('v.value');
        //inputUnit = component.find("InputUnitId").get('v.value');
        //inputModel = component.find("InputModel").get('v.value');  
        } 
                var action = component.get("c.updateDates");
                 action.setParams({
                        ResourceId : component.get("v.ResourceId"),
                        DataType : component.get("v.DataType"),
                        ResourceSetDate:component.get("v.ResourceSetDate"),
                        ProjectId:component.get("v.ProjectId"),
                        ScheduleId:inputSchedularId
                         
                    }); 
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        if(response.getReturnValue() == 'SUCCESS'){ 
                           /* var myEvent = $A.get("e.c:SuccessMessageEvnt");
                            myEvent.setParams({ "errMsg": "Crew Member added successfully."});
                            myEvent.setParams({ "isMsg": true});
                            myEvent.fire(); */
                            
                            if(component.get("v.calendarView") == 'week'){ 
                            	helper.dropWeekDates(component,component.get("v.weekfirstDate"));    
                            }
                            else if(component.get("v.calendarView") == 'twoweeks'){
                                //helper.twoWeekDates(component,component.get("v.weekfirstDate")); 
                            }
                            else{
                                var today = new Date(component.get("v.currentDate"));
                                helper.dayViewHelper(component,today,component.get("v.weekName"));
                            }
                                
                                
                            
                        }
                       if(response.getReturnValue() == 'ASSIGNED'){ 
                           /* var myEvent = $A.get("e.c:ErrorMessageEvnt");
                            myEvent.setParams({ "errMsg": "Member adding failed."});
                            myEvent.setParams({ "isMsg": true});
                            myEvent.fire();  */
                            if(component.get("v.calendarView") == 'week'){
                            	helper.dropWeekDates(component,component.get("v.weekfirstDate"));    
                            }
                            else{
                                var today = new Date(component.get("v.currentDate"));
                                helper.dayViewHelper(component,today,component.get("v.weekName"));
                            }
                        }
                            var modal = component.find('modaldialog');
                            var backdrop = component.find('backdrop');
                            $A.util.removeClass(modal,'slds-fade-in-open');
                            $A.util.removeClass(backdrop,'slds-backdrop--open'); 
                    }
                    
                });
                $A.enqueueAction(action); 
       },
    drag: function(component, event, helper) {
		/*event.dataTransfer.setData("text", event.target.id);
        event.dataTransfer.setData("DataType", event.currentTarget.dataset.record);*/

    },
    drop: function(component, event, helper) {
         
                var ResourceId = component.get("v.ResourceIdDrop");
                var DataType = component.get("v.DataTypeDrop");
                var ResourceSetDate = component.get("v.ResourceSetDateDrop");
                var ProjectId = component.get("v.ProjectIDrop");
                
       			
        
                component.set("v.ResourceId",ResourceId);
                component.set("v.DataType",DataType);
                component.set("v.ResourceSetDate",ResourceSetDate);
                component.set("v.ProjectId",ProjectId);
                //component.set("v.ScheduleId",ScheduleId);
                
        	 
                    component.set("v.showSpinner", true);
                    helper.getSchedulers(component,ProjectId);
                    var modal = component.find('modaldialog');
                    var backdrop = component.find('backdrop');
                    $A.util.addClass(modal,'slds-fade-in-open');
                    $A.util.addClass(backdrop,'slds-backdrop--open');  
		
    },
    drawTable: function(component, event, helper) {
       
        //Start
        var weekDates=component.get("v.weekDates"); 
        var eventList=component.get("v.eventList");
        var tbody='';
        tbody+='<table>';
        console.log('EventList =======> ' + eventList.length);
        for(var i=0;i<eventList.length;i++){
            tbody+='<tr>'; 
                if(component.get("v.recordIds") == true){
                    tbody+='<div  style="background-color:#90EE90;max-width: 177px !important;min-width: 177px !important;word-break: break-all;height:100%;">';
                    tbody+='<td style="height:250px;background-color:#90EE90;cursor: pointer;"  align="left"  class="tdl grid-col--fixed-left">';
                    tbody+='<div class="editProject '+eventList[i].projectId+' "  style="cursor: pointer;">';
                    tbody+= eventList[i].projectName+'<br/>'; 
                    /*if(eventList[i].projectScope == null){
                    	tbody+='<span class="slds-shrink-none slds-align-middle badge--dev-ready1" style="word-break: break-all;white-space: pre-line;">'+'(Add Scope)'+'</span>';
                    }
                    else{
                    	tbody+='<span class="slds-shrink-none slds-align-middle badge--dev-ready1" style="word-break: break-all;white-space: pre-line;">'+eventList[i].projectScope+'</span>';   
                    }*/
                    tbody+='</div>';
                    tbody+= '</td>';
                    tbody+='</div>'; 
                }
             //console.log('weekDates-->'+weekDates[0]["Day"]);
             
            for(var k=0;k<weekDates.length;k++){
                
                var SchedulerRecordList=eventList[i].SchedulerRecordList;
                var ServiceRecordList= eventList[i].ServiceRecordList;
                //tbody+='<tr>';
                if(weekDates[k]["Day"] == 'Saturday' || weekDates[k]["Day"] == 'Sunday'){
                tbody+='<td class="tdc tabledrop"  align="center" style="max-width: 140px !important;min-width: 140px !important;border:1px solid black;text-aling:center !important;vertical-align: top" data-record="'+weekDates[k].Date+'" data-recordid="'+eventList[i].projectId+'">';
                }
                else{
                    
                    tbody+='<td class="tdc tabledrop"  align="center" style="max-width: 140px !important;min-width: 140px !important;border:1px solid black;text-aling:center !important;vertical-align: top" data-record="'+weekDates[k].Date+'" data-recordid="'+eventList[i].projectId+'">';    
                    
                
                	 console.log('ServiceRecordList =======> ' + ServiceRecordList.length);
                	for(var Ser=0;Ser < ServiceRecordList.length;Ser++){
                	    var ds = '';
                	    if(ServiceRecordList[Ser].DatetimeValue != undefined){
                	      //  var ds = (ServiceRecordList[Ser].DatetimeValue).format("dddd, MMMM Do YYYY, h:mm:ss a");
                	        
                	        
                	       // var createdDate =  new Date(ServiceRecordList[Ser].DatetimeValue);
                        //     var date = createdDate;
                        
                             var Dates = ServiceRecordList[Ser].DatetimeValue.split('T');
                            // alert(Dates);
                            var NewDates;
                            if(Dates.length > 1){
                               NewDates =  Dates[0].split('-');
                            }
                            if(NewDates.length > 2){
                            var day = NewDates[2];
                            var month = NewDates[1]; //months are zero based
                            var year = NewDates[0];
                            var Newtimes =  Dates[1].split(':');
                            //alert(Newtimes);
                            var time;
                            if(Newtimes.length > 2){
                                if(Newtimes[0] > 12){
                                    time = (parseInt(Newtimes[0]) - 12) + ':'+  Newtimes[1] + ' PM';
                                }
                                else if(Newtimes[0] == 12){
                                    time = Newtimes[0] + ':'+  Newtimes[1] + ' PM';
                                }
                                else{
                                    time = Newtimes[0] + ':'+  Newtimes[1] + ' AM';
                                }
                            }
                           // var time = createdDate.toLocaleTimeString().replace(/(.*)\D\d+/, '$1');
                            
                            ds = month + '/' + day + '/' + year + ' ' + time;
                            
                            }
                           // alert(ds);
                           
                           var Strings = ServiceRecordList[Ser].Datevalue.split("-");
                    	    var Values = '';
                    	    if(Strings.length > 2){
                    	        Values = month + '/'+day + '/'+year;
                    	    }

                	    }
                	       
                	   if(eventList[i].projectId == ServiceRecordList[Ser].ProjectId && weekDates[k].Date == Values){
                    	   tbody+='<div>';  
                    	   tbody+='<a href="/'+escape(ServiceRecordList[Ser].Id)+'" target="_blank" style="color:#e4d5d5">';
                    	   tbody+='<div style="background:#449fbd"><p>'+ServiceRecordList[Ser].Name +'</p>';
                    	   tbody+='<p>'+ServiceRecordList[Ser].Resource +'</p>';
                    	   tbody+='<p>'+ds +'</p>';
                    	   tbody+='</div>'; 
                    	   tbody+='</a></div>'; 
                    	   
                    	   
                    	   //  tbody+='<div>'; 
                        //      tbody+='<span class="detailInfo">'; 
                        // 	tbody+='<input class="detailButton slds-button slds-button_outline-brand"  style="padding: 0px 10px;" type="button"   value="Show SR"/>';
                        // 	tbody+='<input type="hidden"  value="'+weekDates[k].Date+'" class="Calldate"/>';
                        // 	tbody+='<input type="hidden"  value="'+eventList[i].projectId +'" class="CallId"/>';
                        // 	tbody+='</span></div>';
                    	   
                    	  
                    	   
                	   }
                	}
                	
                	
                    
                    
                }
                
                 console.log('SchedulerRecordList =======> ' + SchedulerRecordList.length);
                for(var m=0;m<SchedulerRecordList.length;m++){
                    tbody+='<div id="fs" style="height:100%" >';
                    tbody+='<div style="height:100%" class="slds-show" >'; 
                    
                    if(SchedulerRecordList[m].JobStatus == 'Cancel'){
                    tbody+='<div id="equip" style="background-color:red;height:100%">';
                    }
                    else{
                    //tbody+='<div id="equip" style="background-color:slategray;height:100%">'; 
                    }
                    
                    if(SchedulerRecordList[m].ProjectTaskRecordsList != undefined){
                        var EquipmentRecordsList=SchedulerRecordList[m].ProjectTaskRecordsList;
                        for(var p=0;p<EquipmentRecordsList.length;p++){ 
                           // //alert(EquipmentRecordsList[p].endday +'EquipmentRecordsList[p].endday '+ EquipmentRecordsList[p].day + ' EquipmentRecordsList[p].day '+ weekDates[k].Date)
                            if(weekDates[k].Date >= EquipmentRecordsList[p].day && weekDates[k].Date <= EquipmentRecordsList[p].endday){
                                if(EquipmentRecordsList[p].weekName == 'Saturday' || EquipmentRecordsList[p].weekName == 'Sunday'){
                                tbody+='<div id="equip" style="background-color:rgb(0, 112, 210);height:100%">'; 
                                tbody+='<a href="/'+escape(EquipmentRecordsList[p].Id)+'" target="_blank" style="color:#e4d5d5">';
                                tbody+='<div class="editProjectTask '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;background-color: rgb(0, 112, 210)">'+EquipmentRecordsList[p].title+'</div>';
                                tbody+='<div class="editProjectTask '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;">';  
                                tbody+='<span class="slds-badge slds-shrink-none slds-align-middle badge--dev-ready">'+EquipmentRecordsList[p].Model+'</span>';
                                tbody+='<div style="background:#449fbd" class="editResource '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;"><a href="/'+escape(EquipmentRecordsList[p].Id)+'" target="_blank">'+EquipmentRecordsList[p].UnitId+'</a></div>';
                                tbody+='</a>';
                                tbody+='</div>'; 
                                }  
                                else{
                                tbody+='<div id="equip" style="background-color:rgb(0, 112, 210);height:100%" >';
                                tbody+='<a href="/'+escape(EquipmentRecordsList[p].Id)+'" target="_blank" style="color:#e4d5d5">';
                                tbody+='<div class="editProjectTask '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;"><a href="/'+escape(EquipmentRecordsList[p].Id)+'" target="_blank">'+EquipmentRecordsList[p].title+'</a></div>';
                                tbody+='<div class="editProjectTask '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;">';
                                tbody+='<span class="slds-badge slds-shrink-none slds-align-middle badge--dev-ready">'+EquipmentRecordsList[p].Model+'</span>';
                                tbody+='<div style="background:#449fbd" class="editResource '+EquipmentRecordsList[p].Id+' '+weekDates[k].Date+' '+EquipmentRecordsList[p].Eid+' " data-record="'+weekDates[k].Date+'" data-recordid="'+EquipmentRecordsList[p].Id+'" style="cursor: pointer;"><a href="/'+escape(EquipmentRecordsList[p].Id)+'" target="_blank">'+EquipmentRecordsList[p].UnitId+'</a></div>';
                                tbody+='</a>';
                                tbody+='</div>';   
                                }
                            } 
                    }//Loop End
                        
                        tbody+='</div>';
                        //2 Loop 
                        if(SchedulerRecordList[m].JobStatus == 'Cancel'){
                        tbody+='<div id="resource" style="background-color:red;height:100%">';
                        }
                        else{
                        tbody+='<div id="resource" style="background-color:darkgrey;height:100%">';    
                        }
                    }
                    
        //             if(SchedulerRecordList[m].ResourceRecordsList != undefined){
        //                 var ResourceRecordsList=SchedulerRecordList[m].ResourceRecordsList;
        //                 for(var p=0;p<ResourceRecordsList.length;p++){
                            
        //                     if(weekDates[k].Date >= ResourceRecordsList[p].day  && weekDates[k].Date <= ResourceRecordsList[p].endday){
        //                         if(ResourceRecordsList[p].weekName == 'Saturday' || ResourceRecordsList[p].weekName == 'Sunday'){
        //                         tbody+='<div class="slds-show" style="">';
        //                         tbody+='<div>';
        //                         tbody+='<a href="/'+EquipmentRecordsList[p].Id+'" target="_blank">';
        //                         tbody+='<div class="editResource '+ResourceRecordsList[p].Id+' '+weekDates[k].Date+' '+ResourceRecordsList[p].Sid+' '+ResourceRecordsList[p].role+' " data-record="'+weekDates[k].Date+'" data-recordid="'+ResourceRecordsList[p].Id+'" style="cursor: pointer;background-color: #ffffff;opacity: .4;">'+ResourceRecordsList[p].title+'</a></div>'; 
        //                         tbody+='</a>';
    				// 			}
        //                         else{
        //                         tbody+='<div class="slds-show">';
        //                         tbody+='<div>';
        //                         tbody+='<a href="/'+EquipmentRecordsList[p].Id+'" target="_blank">';
        //                         tbody+='<div class="editResource '+ResourceRecordsList[p].Id+' '+weekDates[k].Date+' '+ResourceRecordsList[p].Sid+' '+ResourceRecordsList[p].role+' " data-record="'+weekDates[k].Date+'" data-recordid="'+ResourceRecordsList[p].Id+'" style="cursor: pointer;">'+ResourceRecordsList[p].title+'</div>'; 
        //                       // tbody+='<span class="slds-badge slds-shrink-none slds-align-middle badge--dev-ready">'+ResourceRecordsList[p].role+'</span>';
        //                         tbody+='</a>';
        //                         //tbody+='</div>';
        //                         }
        //                     }
        //                 }
        //             }
                    
                    tbody+='</div>';
                    tbody+='</div>';
                    tbody+='</div>';
                }
                tbody+='</td>';
                 
            } 
            tbody+='</tr>';
        }
        tbody+='</table>';
        //End 
        
        document.getElementsByClassName("tbody")[0].innerHTML=tbody;
        
        $(".detailButton").unbind( "click" );
    	$('.detailButton').click(function(e) { 
    		var Calldate=$(this).closest('.detailInfo').find('.Calldate').val();
    		var CallId=$(this).closest('.detailInfo').find('.CallId').val();
    		alert(Calldate);
    		component.set("v.SRDateSelected",Calldate);
    		component.set("v.SRProjectIds",CallId);
            var action = component.get("c.getServiceRequest"); 
            action.setParams({
                 Datevalue : component.get("v.SRDateSelected"),
                 ProjectId : component.get("v.SRProjectIds")
             }); 
                action.setCallback(this, function(a) { 
                    alert(a.getState());
                var state = a.getState(); 
                if (state === "SUCCESS") {
                    component.set("v.ServiceRequest",a.getReturnValue());
               }
	        });
       
	        $A.enqueueAction(action);
    		component.set("v.isOpen",true);
    	});
        
    } ,
    
    handleComponentEvent: function (component, event, helper) {
		// get the selected  record from the COMPONETN event 
		
		//var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		//component.set("v.selectedContact", selectedAccountGetFromEvent.Id);
		var slectedcontactId = JSON.stringify(component.get("v.selectedContact").Id);
        var slectedprojecttaskId = JSON.stringify(component.get("v.selectedprojecttask").Id);
        
			 //component.set("v.SelectedOptions",SelectedOptions);

         if(component.get("v.calendarView") == 'day'){
        component.set("v.weekName","Monday");
              var today = new Date();
              var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
              component.set("v.currentDate",Datevalue);	
              helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        
        }
        if(component.get("v.calendarView") == 'week'){
           
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.currentWeekDates(component,Datevalue); 
        }
        if(component.get("v.calendarView") == 'twoweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.twoWeekDates(component,Datevalue); 	
        }
        if(component.get("v.calendarView") == 'threeweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.threeWeekDates(component,Datevalue); 	
        }


	},
    ClearhandleComponentEvent: function (component, event, helper) {
        if(component.get("v.calendarView") == 'day'){
        component.set("v.weekName","Monday");
              var today = new Date();
              var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
              component.set("v.currentDate",Datevalue);	
              helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        
        }
        if(component.get("v.calendarView") == 'week'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.currentWeekDates(component,Datevalue); 
        }
        if(component.get("v.calendarView") == 'twoweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.twoWeekDates(component,Datevalue); 	
        }
        if(component.get("v.calendarView") == 'threeweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.threeWeekDates(component,Datevalue); 	
        }
        
    },
    
     handleCheck : function(component, event, helper) {
        var checkbox = event.getSource(); 
        component.set("v.showSpinner",true);
        var SelectedOptions = component.get("v.SelectedOptions");
        if(checkbox.get("v.value") == true){
          
            
        }
        else{
            var SelOptions = SelectedOptions;
            SelectedOptions = [];
        	for( var i = 0;i < SelOptions.length; i++){
                if ( SelOptions[i] != checkbox.get("v.text")) 
                    
                    SelectedOptions.push(SelOptions[i]);
            }
            component.set("v.SelectedOptions",SelectedOptions);
            
        	//SelectedOptions.remove(checkbox.get("v.text"));
        }
        component.set("v.ResslectedOptions",[]);
        component.set("v.childslectedOptions",[]);

     // //alert(component.get("v.calendarView"));
      if(component.get("v.calendarView") == 'day'){
        component.set("v.weekName","Monday");
              var today = new Date();
              var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
              component.set("v.currentDate",Datevalue);	
              helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        
        }
        if(component.get("v.calendarView") == 'week'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.currentWeekDates(component,Datevalue); 
        }
        if(component.get("v.calendarView") == 'twoweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.twoWeekDates(component,Datevalue); 	
        }
        if(component.get("v.calendarView") == 'threeweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.threeWeekDates(component,Datevalue); 	
        }
        
       helper.getprojectTasks(component);
        helper.getContacts(component);
     },
     
      handleChecks : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var checkbox = event.getSource(); 
       
        var SelectedOptions = component.get("v.childslectedOptions");
        if(checkbox.get("v.value") == true){
            
        	SelectedOptions.push(checkbox.get("v.text"));
        }
        else{
            
            var SelOptions = SelectedOptions;
            SelectedOptions = [];
        	for( var i = 0;i < SelOptions.length; i++){
                if ( SelOptions[i] != checkbox.get("v.text")) 
                    
                    SelectedOptions.push(SelOptions[i]);
            }
            component.set("v.childslectedOptions",SelectedOptions);
        }
        
     // //alert(component.get("v.calendarView"));
      if(component.get("v.calendarView") == 'day'){
        component.set("v.weekName","Monday");
              var today = new Date();
              var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
              component.set("v.currentDate",Datevalue);	
              helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        
        }
        if(component.get("v.calendarView") == 'week'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.currentWeekDates(component,Datevalue); 
        }
        if(component.get("v.calendarView") == 'twoweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.twoWeekDates(component,Datevalue); 	
        }
        if(component.get("v.calendarView") == 'threeweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.threeWeekDates(component,Datevalue); 	
        }

     },
     
     ReshandleChecks : function(component, event, helper) {
        var checkbox = event.getSource(); 
        
        var SelectedOptions = component.get("v.ResslectedOptions");
        if(checkbox.get("v.value") == true){
          
            
        	SelectedOptions.push(checkbox.get("v.text"));
        
        }
        else{
            var SelOptions = SelectedOptions;
            SelectedOptions = [];
        	for( var i = 0;i < SelOptions.length; i++){
                if ( SelOptions[i] != checkbox.get("v.text")) 
                    
                    SelectedOptions.push(SelOptions[i]);
            }
            component.set("v.ResslectedOptions",SelectedOptions);
        	//SelectedOptions.remove(checkbox.get("v.text"));
        }
        
     // //alert(component.get("v.calendarView"));
      if(component.get("v.calendarView") == 'day'){
        component.set("v.weekName","Monday");
              var today = new Date();
              var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
              component.set("v.currentDate",Datevalue);	
              helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        
        }
        if(component.get("v.calendarView") == 'week'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.currentWeekDates(component,Datevalue); 
        }
        if(component.get("v.calendarView") == 'twoweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.twoWeekDates(component,Datevalue); 	
        }
        if(component.get("v.calendarView") == 'threeweeks'){
                 var today = new Date();
                var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
                helper.threeWeekDates(component,Datevalue); 	
        }
        
        //helper.getprojectTasks(component);         
     },
     
    MouseoverFunction: function (component) {
    
        var existingText = component.get("v.projectTaskCollapseText");
        var existingText2 = component.get("v.projectCollapseText");
        var existingText3 = component.get("v.ResourceCollapseText");
        var container = component.find("projectTaskCollapsable") ;
        var container1 = component.find("resourceCollapsable") ;
        var container2 = component.find("projectCollapsable") ;
        if(existingText === "[ - ]"){
        	component.set("v.projectTaskCollapseText","[ + ]");
        	$A.util.addClass(container, 'slds-hide');
        }
        if(existingText2 === "[ - ]"){
        	component.set("v.projectCollapseText","[ + ]");
        	$A.util.addClass(container2, 'slds-hide');
        }
        if(existingText3 === "[ - ]"){
        	component.set("v.ResourceCollapseText","[ + ]");
        	$A.util.addClass(container1, 'slds-hide');
        } 
    },
    
    openModel: function(component, event, helper) {
        component.set("v.Subject",'');
        component.set("v.SerDescription",'');
        component.set("v.SerPrimaryAssignee",'');
        component.set("v.ServiceRequestRecord",'');	
        component.set("v.SerProjectId",'');
       
      // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
   },
   
   closeModel:function(component, event, helper) {
       component.set("v.isOpen", false);
   }
 
   
    
})