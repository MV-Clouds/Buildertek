({
	 
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date();
        component.set("v.calendarView","week");
        component.set("v.ColorName1","Project");
        component.set("v.ColorName2","Resources");
        component.set("v.displayView","project Task");
        component.set("v.leftpanelshoworhide", true);
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		var now = new Date(); 
        component.set("v.headerDate", $A.localizationService.formatDate(now, 'dd/MMMM/yyyy'));
       
	//	helper.getRoles(component);
     //   helper.getLocations(component); 
     console.log('calendarView ====>',component.get("v.calendarView"));
        if(component.get("v.calendarView") == 'week'){
            helper.currentWeekDates(component,Datevalue);   
        }
        else{
            var today = new Date();
            var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
            component.set("v.currentDate",Datevalue);	
            helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
        } 
	}, 
    
    
	nextWeek : function(component, event, helper) {
        component.set("v.showSpinner", true);
		helper.currentWeekDates(component,component.get("v.weeklastDate"));
	},   
	previousWeek : function(component, event, helper) {
        component.set("v.showSpinner", true);
		helper.currentWeekDates(component,component.get("v.beforeweekDate"));
	},
    dayView:function(component, event, helper){
      component.set("v.showSpinner", true);
      component.set("v.calendarView","day");
      component.set("v.weekName","Monday");
      var today = new Date();   
      var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
      component.set("v.currentDate",Datevalue);	
      helper.dayViewHelper(component,Datevalue,component.get("v.weekName"));  
    },    
	nextDay : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        today.setDate(today.getDate() + 1);
		var weekName;
        if(component.get("v.weekName") == 'Monday'){
            console.log('----weekNmae--->',component.get("v.weekName"));
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
	previousDay : function(component, event, helper) {
        component.set("v.showSpinner", true);
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

	oneWeek:function(component, event, helper){
        component.set("v.showSpinner", true);
        component.set("v.calendarView","week");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.currentWeekDates(component,Datevalue); 
        
    },    

    twoWeeks:function(component, event, helper){
        component.set("v.showSpinner", true);
        component.set("v.calendarView","twoweeks");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.twoWeekDates(component,Datevalue); 	
        
    },
    threeWeeks:function(component, event, helper){
        component.set("v.showSpinner", true);
        component.set("v.calendarView","threeweeks");
        var today = new Date();
        var Datevalue = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
        helper.threeWeekDates(component,Datevalue); 	
        
    },
	nextTwoWeeks : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
		helper.twoWeekDates(component,component.get("v.weeklastDate"));
	},
    nextThreeWeeks : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
		helper.threeWeekDates(component,component.get("v.weeklastDate"));
	},
	previousTwoWeeks : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        helper.twoWeekDates(component,component.get("v.beforeweekDate"));

	},
	previousThreeWeeks : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var today = new Date(component.get("v.currentDate"));
        helper.threeWeekDates(component,component.get("v.beforeweekDate"));

	},    
    
     
	ResourceCollapse : function(component, event) { 
        var existingText = component.get("v.ResourceCollapseText");
        var container = component.find("resourceCollapsable") ;
        var container1 = component.find("projectCollapsable") ;

        
        if(existingText === "[ - ]"){
            component.set("v.ResourceCollapseText","[ + ]");
            $A.util.addClass(container, 'slds-hide');
        }else{
            component.set("v.ResourceCollapseText","[ - ]"); 
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            component.set("v.projectCollapseText","[ + ]");             
        }  
    }, 
    
	projectCollapse : function(component, event) { 
        var existingText = component.get("v.projectCollapseText");
        var container = component.find("projectCollapsable") ;
        var container1 = component.find("resourceCollapsable") ;
        if(existingText === "[ - ]"){
            component.set("v.projectCollapseText","[ + ]");
            $A.util.addClass(container, 'slds-hide');
        }else{
            component.set("v.projectCollapseText","[ - ]"); 
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(container1, 'slds-hide');
            component.set("v.ResourceCollapseText","[ + ]");               
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
    Filterprojects : function(component, event, helper) {
        var input, filter, ul, li, a, i;
        input = document.getElementById("SearchKeyValue2");
        filter = input.value.toUpperCase();
        ul = document.getElementById("availableprojects");
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
     
    allowDrop: function(component, event, helper) {
		event.preventDefault();
    },    
    drag: function(component, event, helper) {
		event.dataTransfer.setData("text", event.target.id);

        event.dataTransfer.setData("DataType", event.currentTarget.dataset.record);
    },    
	drop: function(component, event, helper) {
        
        event.stopPropagation();
		event.preventDefault();
		event.dataTransfer.dropEffect = 'copy';
		event.preventDefault();
        var ResourceId = event.dataTransfer.getData("text");
        var DataType = event.dataTransfer.getData("DataType");
        var ResourceSetDate = event.currentTarget.dataset.record;
        var ProjectId = event.currentTarget.dataset.recordid;
        //var ScheduleId = event.currentTarget.dataset.scheduleid;  

                component.set("v.ResourceId",ResourceId);
                component.set("v.DataType",DataType);
                component.set("v.ResourceSetDate",ResourceSetDate);
                component.set("v.ProjectId",ProjectId);
                //component.set("v.ScheduleId",ScheduleId);
                helper.getSchedulers(component,ProjectId);
                var modal = component.find('modaldialog');
                var backdrop = component.find('backdrop');
                $A.util.addClass(modal,'slds-fade-in-open');
                $A.util.addClass(backdrop,'slds-backdrop--open'); 

    },
    
    closeModal: function(component, event, helper) {
        var modal = component.find('modaldialog');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(modal,'slds-fade-in-open');
        $A.util.removeClass(backdrop,'slds-backdrop--open');         
	},
     
    SaveCrewmember: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var inputsel = component.find("InputSelectDynamic").get('v.value');
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
                        ScheduleId:inputSchedularId,
                        Role:inputsel
                    });
            
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        if(response.getReturnValue() == 'SUCCESS'){ 
                            var myEvent = $A.get("e.c:SuccessMessageEvnt");
                            myEvent.setParams({ "errMsg": "Crew Member added successfully."});
                            myEvent.setParams({ "isMsg": true});
                            myEvent.fire(); 
                            
                            if(component.get("v.calendarView") == 'week'){
                            	helper.dropWeekDates(component,component.get("v.weekfirstDate"));    
                            }
                            else{
                                var today = new Date(component.get("v.currentDate"));
                                helper.dayViewHelper(component,today,component.get("v.weekName"));
                            }
                                
                                
                            
                        }
                       if(response.getReturnValue() == 'ASSIGNED'){ 
                            var myEvent = $A.get("e.c:ErrorMessageEvnt");
                            myEvent.setParams({ "errMsg": "Member adding failed."});
                            myEvent.setParams({ "isMsg": true});
                            myEvent.fire();  
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
      
	onMultiSelectChange: function(component) { 
         var selectCmp = component.find("InputSelectMultiple"); 
         component.set("v.selectedLocations", selectCmp.get("v.value")); 
      },
    
    drawTable: function(component, event, helper) { 
       
        //Start
        var weekDates=component.get("v.weekDates");
        var eventList=component.get("v.EList");
        var tbody=''; 
        tbody+='<table>'; 
        if(eventList != undefined){
            for(var i=0;i<eventList.length;i++){
                tbody+='<tr>'; 
                tbody+='<div  style="background-color:#90EE90;max-width: 177px !important;min-width: 177px !important;word-break: break-all;height:100%;">';
                tbody+='<td style="background-color:#ABDBFF;height:100px;cursor: pointer;"  align="left"  class="tdl grid-col--fixed-left">'+eventList[i].Name+'</td>';
                tbody+='</div>'; 
                var ServiceRecordList= eventList[i].ServiceRecordList;
                for(var k=0;k<weekDates.length;k++){
                    
                console.log('----303>', weekDates.length);
                    //var SchedulerRecordList=eventList[i].SchedulerRecordList; 
                    //tbody+='<tr>';
                    tbody+='<td class="tdctabledrop"  align="center" style="max-width: 140px !important;min-width: 140px !important;border:1px solid black;text-aling:center !important;vertical-align: top" data-record="'+weekDates[k].Date+'" data-recordid="'+eventList[i].projectId+'">';
                    //for(var m=0;m<SchedulerRecordList.length;m++){
                        //tbody+='<div id="fs" style="height:100%" >';
                        //tbody+='<div style="height:100%" class="slds-show" >'; 
                        	for(var Ser=0;Ser < ServiceRecordList.length;Ser++){
                    	    var ds = '';
                    	    if(ServiceRecordList[Ser].DatetimeValue != undefined){
                    	     //   alert(ServiceRecordList[Ser].DatetimeValue);
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
                    	    
                    //	   alert(eventList[i].Id + ' ' + ServiceRecordList[Ser].ProjectId  + ' '+ weekDates[k].Date + ' '+ Values) ;
                    	   if(eventList[i].Projects == ServiceRecordList[Ser].ProjectId && weekDates[k].Date == Values){
                        	   tbody+='<div>';  
                        	   tbody+='<a href="/'+escape(ServiceRecordList[Ser].Id)+'" target="_blank" style="color:#e4d5d5">';
                        	   tbody+='<div style="background:#449fbd"><p>'+ServiceRecordList[Ser].Name +'</p>';
                        	   tbody+='<p>'+ServiceRecordList[Ser].Resource +'</p>';
                        	   tbody+='<p>'+ds +'</p>';
                        	   tbody+='</div>'; 
                        	   tbody+='</a></div>'; 
                    	   }
                    	}
                        tbody+='<div id="equip" style="background-color:slategray;height:100%">';
                        
                        
                        if(eventList[i].ProjectRecordsList!=undefined){
                            var projectRecordsList=eventList[i].ProjectRecordsList;
                            for(var p=0;p<projectRecordsList.length;p++){
                                console.log('----316>', projectRecordsList[p].day);
                                console.log('----317>', weekDates[k].Date);
                                if(weekDates[k].Date >= projectRecordsList[p].day && weekDates[k].Date <= projectRecordsList[p].endday){ 
                                    tbody+='<div class="slds-show" >';
                                	tbody+='<div>';
                                    if(projectRecordsList[p].weekName == 'Saturday' || projectRecordsList[p].weekName == 'Sunday' ){
                                    	tbody+='<a href="/'+escape(projectRecordsList[p].EId)+'" target="_blank">'; 
                                        tbody+='<div  data-record="'+weekDates[k].Date+'" data-recordid="'+projectRecordsList[p].Id+'"  style="background:rgb(0, 112, 210)">'+projectRecordsList[p].Name+'</div>';
                                        tbody+='<div  style="background:#449fbd" data-record="'+weekDates[k].Date+'" data-recordid="'+projectRecordsList[p].Id+'"  style="background-color: #ffffff;opacity: .4;">'+projectRecordsList[p].UnitId+'</div>';    
                                        tbody+='</a>';
                                        
                                    }
                                    else{
                                        tbody+='<a href="/'+escape(projectRecordsList[p].EId)+'" target="_blank">';
                                        tbody+='<div  style="background:rgb(0, 112, 210)" data-record="'+weekDates[k].Date+'" data-recordid="'+projectRecordsList[p].Id+'" >'+projectRecordsList[p].Name+'</div>';  
                                        tbody+='<div style="background:#449fbd" data-record="'+weekDates[k].Date+'" data-recordid="'+projectRecordsList[p].Id+'"  style="background-color: #ffffff;opacity: .4;">'+projectRecordsList[p].UnitId+'</div>';
                                    
                                        tbody+='</a>';
                                    }
                                    
                                } 
                            }//Loop End
                        }
                        tbody+='</div>';
                        //2 Loop 
                        /*tbody+='<div id="resource" style="background-color:darkgrey;height:100%">';
                        if(eventList[i].ProjectTaskRecordsList!=undefined){
                            var ProjectTaskRecordsList=eventList[i].ProjectTaskRecordsList;
                                for(var tsk=0;tsk<ProjectTaskRecordsList.length;tsk++){
                            	console.log('----316>', ProjectTaskRecordsList[tsk].day);
                            	console.log('----317>', weekDates[k].Date);
                            	if(weekDates[k].Date >= ProjectTaskRecordsList[tsk].day && weekDates[k].Date <= ProjectTaskRecordsList[tsk].endday && eventList[i].Name == ProjectTaskRecordsList[tsk].title){ 
                            		tbody+='<div class="slds-show" >';
                            		tbody+='<div>';
                            		if(ProjectTaskRecordsList[tsk].weekName == 'Saturday' || ProjectTaskRecordsList[tsk].weekName == 'Sunday' ){
                            			tbody+='<a href="/'+ProjectTaskRecordsList[tsk].EId+'" target="_blank">'; 
                            			tbody+='<div  data-record="'+weekDates[k].Date+'" data-recordid="'+ProjectTaskRecordsList[tsk].Id+'"  style="background-color: #ffffff;opacity: .4;">'+ProjectTaskRecordsList[tsk].title+'</div>';
                            			tbody+='<div  data-record="'+weekDates[k].Date+'" data-recordid="'+ProjectTaskRecordsList[tsk].Id+'"  style="background-color: #ffffff;opacity: .4;">'+ProjectTaskRecordsList[tsk].UnitId+'</div>';
                            			tbody+='</a>';
                            			
                            		}
                            		else{
                            			tbody+='<a href="/'+ProjectTaskRecordsList[tsk].EId+'" target="_blank">';
                            			tbody+='<div  style="background:rgb(0, 112, 210)" data-record="'+weekDates[k].Date+'" data-recordid="'+ProjectTaskRecordsList[tsk].Id+'" >'+ProjectTaskRecordsList[tsk].Name+'</div>';  
                            			tbody+='<div style="background:#449fbd" data-record="'+weekDates[k].Date+'" data-recordid="'+ProjectTaskRecordsList[tsk].Id+'"  style="background-color: #ffffff;opacity: .4;">'+ProjectTaskRecordsList[tsk].projectId+'</div>';
                            		
                            			tbody+='</a>';
                            		}
                            		
                            	} 
                             }
                        }
                        tbody+='</div>';*/
                        //tbody+='</div>';
                        //tbody+='</div>';
                    //}
                    tbody+='</td>';
                     
                } 
                tbody+='</tr>';
            }
        }    
        tbody+='</table>';
        //End 
       
        document.getElementsByClassName("tbody")[0].innerHTML=tbody;     
        
        setTimeout(function(){
            for(var i=0;i<document.getElementsByClassName('editproject').length;i++){
                var TextBtn = document.getElementsByClassName("editproject")[i];    
                TextBtn.onclick = function() {
                    document.getElementById("editproject").click();
                }
            }    
            
            for(var i=0;i<document.getElementsByClassName('editResource').length;i++){
                var TextBtn = document.getElementsByClassName("editResource")[i];    
                TextBtn.onclick = function() {
                    document.getElementById("editResource").click();
                }
            }      
        }, 100);
    } ,  
    
     handleComponentEvent: function (component, event, helper) {
		// get the selected  record from the COMPONETN event 
		
		//var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		//component.set("v.selectedContact", selectedAccountGetFromEvent.Id);
		var slectedcontactId = JSON.stringify(component.get("v.selectedContact").Id);
        var slectedprojecttaskId = JSON.stringify(component.get("v.selectedprojecttask").Id);
        
			

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
    
})