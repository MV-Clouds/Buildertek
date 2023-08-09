({
	currentWeekDates : function(component,Datevalue) { 	  
           this.getResourcesList(component,Datevalue);  
	},
	twoWeekDates : function(component,datevalue) {

	var today = new Date(datevalue);
    var week = [];
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        var nextmondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+8);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(nextmondayOfWeek, 'MM/dd/yyyy')});
        var nexttuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+9);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(nexttuedayOfWeek, 'MM/dd/yyyy')});
        var nextweddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+10);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(nextweddayOfWeek, 'MM/dd/yyyy')});
        var nextthuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+11);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(nextthuedayOfWeek, 'MM/dd/yyyy')});
        var nextfridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+12);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(nextfridayOfWeek, 'MM/dd/yyyy')});
        var nextsatdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+13);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(nextsatdayOfWeek, 'MM/dd/yyyy')});
        var nextsundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+14);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy')});        
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-13);
       
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",nextsundayOfWeek); 
        
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();

	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
        
	    $A.enqueueAction(action);
        
        if(component.get("v.displayView") == 'equipment' ){
           this.getEquipmentstwoweekList(component,datevalue);  
        }
        if(component.get("v.displayView") == 'crewMembers' ){
           this.getResourcestwoweekList(component,datevalue); 
        }
	},
    
    threeWeekDates : function(component,datevalue) {

	var today = new Date(datevalue);
    var week = [];
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        var nextmondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+8);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(nextmondayOfWeek, 'MM/dd/yyyy')});
        var nexttuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+9);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(nexttuedayOfWeek, 'MM/dd/yyyy')});
        var nextweddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+10);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(nextweddayOfWeek, 'MM/dd/yyyy')});
        var nextthuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+11);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(nextthuedayOfWeek, 'MM/dd/yyyy')});
        var nextfridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+12);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(nextfridayOfWeek, 'MM/dd/yyyy')});
        var nextsatdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+13);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(nextsatdayOfWeek, 'MM/dd/yyyy')});
        var nextsundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+14);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy')});        
        
        var next2mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+15);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(next2mondayOfWeek, 'MM/dd/yyyy')});
        var next2tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+16);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(next2tuedayOfWeek, 'MM/dd/yyyy')});
        var next2weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+17);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(next2weddayOfWeek, 'MM/dd/yyyy')});
        var next2thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+18);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(next2thuedayOfWeek, 'MM/dd/yyyy')});
        var next2fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+19);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(next2fridayOfWeek, 'MM/dd/yyyy')});
        var next2satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+20);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(next2satdayOfWeek, 'MM/dd/yyyy')});
        var next2sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+21);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy')});        
        
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-20);
       
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",next2sundayOfWeek); 
        
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();

	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
        
	    $A.enqueueAction(action);
        
        if(component.get("v.displayView") == 'equipment' ){
           this.getEquipmentstwoweekList(component,datevalue);  
        }
        if(component.get("v.displayView") == 'crewMembers' ){
           this.getResourcesthreeweekList(component,datevalue); 
        }
	},
 
	dropWeekDates : function(component,datevalue) {

	var today = new Date(datevalue);
    var week = [];
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-6);        
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",sundayOfWeek);  
        
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
	    $A.enqueueAction(action); 
        
        if(component.get("v.displayView") == 'equipment' ){
           this.getEquipmentsList(component,Datevalue); 
        }
        if(component.get("v.displayView") == 'crewMembers' ){
           this.getResourcesList(component,Datevalue); 
        }       

	}, 

	dayViewHelper : function(component,dayValue,weekName) {
	 
           this.getResourcesdayList(component,dayValue,weekName);  
    },
    

    
    

    getEquipmentJunction : function(component) {
        var opts=[];
        var action = component.get("c.getEquipmentJunction");
        var inputsel = component.find("InputSelectEquipment"); 
        action.setCallback(this, function(a) { 
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") { 
                if(a.getReturnValue().length > 0){ 
                    for(var i=0;i< a.getReturnValue().length;i++){
                        opts.push({"class": "optionClass", label: a.getReturnValue()[i].Name, value: a.getReturnValue()[i].Id});
                    	inputsel.set("v.options", opts);
                    } 
                }
            }
        });
       
	    $A.enqueueAction(action);
    },
    getResourceJunction : function(component) {
        var opts=[]; 
        var action = component.get("c.getResourceJunction");
        var inputsel = component.find("InputSelectResource");  
        action.setCallback(this, function(a) { 
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") { 
                if(a.getReturnValue().length > 0){ 
                    for(var i=0;i< a.getReturnValue().length;i++){
                        opts.push({"class": "optionClass", label: a.getReturnValue()[i].Name, value: a.getReturnValue()[i].Id});
                    	inputsel.set("v.options", opts); 
                    } 
                }
            }
        });
       
	    $A.enqueueAction(action);
        this.UpdateRole(component);
    },
   
    getSchedulers: function(component,projectID) {
		component.set("v.NoSchedules",false); 
        var opts=[];
	    var action = component.get("c.getSchedulers");
        var inputsel = component.find("InputSelectSchedular");
         action.setParams({
                ProjectID : projectID
            });   

	    action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(a.getReturnValue().length > 0){
                    for(var i=0;i< a.getReturnValue().length;i++){
                        opts.push({"class": "optionClass", label: a.getReturnValue()[i].Name, value: a.getReturnValue()[i].Id});
                    	inputsel.set("v.options", opts);
                    }
                   component.set("v.NoSchedules",false);    
                }
                else{
                   component.set("v.NoSchedules",true); 
                }
                
            }
	    });
       
	    $A.enqueueAction(action);        
    },
    
  	getResourcesList: function(component,Datevalue) {
        var today = new Date(Datevalue);
    var week = [];
       
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-6);
        
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);	
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",sundayOfWeek);
        
	     
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
        var RecordId = '';
        if(component.get("v.recordId") != undefined){
            RecordId = component.get("v.recordId");
        }
        var action = component.get("c.getAllJunctionResources");         
        action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                recordId : RecordId
            });
        
		action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
				  component.set("v.RList", a.getReturnValue()); 
                  component.set("v.showSpinner", false);
                component.drawTable('');
            }
	    });
       $A.enqueueAction(action);         
    },
    getResourcestwoweekList: function(component,Datevalue) {
        var today = new Date(Datevalue);
    var week = [];
       
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        var nextmondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+8);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(nextmondayOfWeek, 'MM/dd/yyyy')});
        var nexttuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+9);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(nexttuedayOfWeek, 'MM/dd/yyyy')});
        var nextweddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+10);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(nextweddayOfWeek, 'MM/dd/yyyy')});
        var nextthuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+11);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(nextthuedayOfWeek, 'MM/dd/yyyy')});
        var nextfridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+12);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(nextfridayOfWeek, 'MM/dd/yyyy')});
        var nextsatdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+13);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(nextsatdayOfWeek, 'MM/dd/yyyy')});
        var nextsundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+14);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy')});        
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-13);
       
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);	
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",nextsundayOfWeek);
        
	     
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
        var RecordId = '';
        if(component.get("v.recordId") != undefined){
            RecordId = component.get("v.recordId");
        }
        var action = component.get("c.getAllJunctionResources");         
        action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                recordId : RecordId
            });
        
		action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
				  component.set("v.RList", a.getReturnValue()); 
                  component.set("v.showSpinner", false);
                component.drawTable('');
            }
	    });
       $A.enqueueAction(action);         
    },
    
    getResourcesthreeweekList: function(component,Datevalue) {
        var today = new Date(Datevalue);
    var week = [];
       
        var dayOfWeekStartingSundayZeroIndexBased = today.getDay(); // 0 : Sunday ,1 : Monday,2,3,4,5,6 : Saturday
        var mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+1);
		week.push({Day:'Monday',Date: $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy')});
        var tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+2);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(tuedayOfWeek, 'MM/dd/yyyy')});
        var weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+3);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(weddayOfWeek, 'MM/dd/yyyy')});
        var thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+4);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(thuedayOfWeek, 'MM/dd/yyyy')});
        var fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+5);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(fridayOfWeek, 'MM/dd/yyyy')});
        var satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+6);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(satdayOfWeek, 'MM/dd/yyyy')});
        var sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+7);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy')});
        var nextmondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+8);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(nextmondayOfWeek, 'MM/dd/yyyy')});
        var nexttuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+9);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(nexttuedayOfWeek, 'MM/dd/yyyy')});
        var nextweddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+10);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(nextweddayOfWeek, 'MM/dd/yyyy')});
        var nextthuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+11);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(nextthuedayOfWeek, 'MM/dd/yyyy')});
        var nextfridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+12);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(nextfridayOfWeek, 'MM/dd/yyyy')});
        var nextsatdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+13);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(nextsatdayOfWeek, 'MM/dd/yyyy')});
        var nextsundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+14);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(nextsundayOfWeek, 'MM/dd/yyyy')});        
        
        var next2mondayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+15);
        week.push({Day:'Monday',Date: $A.localizationService.formatDate(next2mondayOfWeek, 'MM/dd/yyyy')});
        var next2tuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+16);
		week.push({Day:'Tuesday',Date: $A.localizationService.formatDate(next2tuedayOfWeek, 'MM/dd/yyyy')});
        var next2weddayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+17);
        week.push({Day:'Wednesday',Date: $A.localizationService.formatDate(next2weddayOfWeek, 'MM/dd/yyyy')});
        var next2thuedayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+18);
        week.push({Day:'Thursday',Date: $A.localizationService.formatDate(next2thuedayOfWeek, 'MM/dd/yyyy')});
        var next2fridayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+19);
        week.push({Day:'Friday',Date: $A.localizationService.formatDate(next2fridayOfWeek, 'MM/dd/yyyy')});
        var next2satdayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+20);
        week.push({Day:'Saturday',Date: $A.localizationService.formatDate(next2satdayOfWeek, 'MM/dd/yyyy')});
        var next2sundayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()+21);
        week.push({Day:'Sunday',Date: $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy')});        
        
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-20);
       
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);	
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",next2sundayOfWeek);
        
	     
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
        var RecordId = '';
        if(component.get("v.recordId") != undefined){
            RecordId = component.get("v.recordId");
        }
        var action = component.get("c.getAllJunctionResources");         
        action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                recordId : RecordId
            });
        
		action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
				  component.set("v.RList", a.getReturnValue()); 
                  component.set("v.showSpinner", false);
                component.drawTable('');
            }
	    });
       $A.enqueueAction(action);         
    },
    getResourcesdayList: function(component,Datevalue,weekName) {
        var today = new Date(Datevalue);
    var week = [];
       
        week.push({Day:weekName,Date: $A.localizationService.formatDate(Datevalue, 'MM/dd/yyyy')});
        component.set("v.currentDate",Datevalue);	
        component.set("v.weekDates",week); 
         
        
	     
        var fromDate = $A.localizationService.formatDate(Datevalue, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(Datevalue, 'MM/dd/yyyy');
        var todateStr = toDate.toString(); 
        var RecordId = '';
        if(component.get("v.recordId") != undefined){
            RecordId = component.get("v.recordId");
        }
	    var action = component.get("c.getAllJunctionResources");         
        action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                recordId : RecordId
            });
        
		action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
				  component.set("v.RList", a.getReturnValue()); 
                  component.set("v.showSpinner", false);
                component.drawTable('');
            }
	    });
       $A.enqueueAction(action);         
    }

})