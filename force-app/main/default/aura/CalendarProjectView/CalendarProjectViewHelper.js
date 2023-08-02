({
    currentWeekDates : function(component,Datevalue) {
    console.log('currentWeekDates ========> ');
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
        console.log('currentWeekDates 1 ========> ');
        var beforeOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay()-6);
       
        console.log('currentWeekDates 2 ========> ');
        component.set("v.weekDates",week);
        component.set("v.beforeweekDate",beforeOfWeek);	
        component.set("v.weekfirstDate",mondayOfWeek);	
        component.set("v.weeklastDate",sundayOfWeek);
        console.log('currentWeekDates 3 ========> ');
        var SelectedOptions = component.get("v.SelectedOptions");
        var ChSelectedOptions = component.get("v.selectedprojecttask").Id;
        var ResslectedOptions = component.get("v.selectedContact").Id; 
        console.log('currentWeekDates 5 ========> ');
        var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
        console.log('currentWeekDates 4 ========> ');
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                selected : SelectedOptions,
                ChildSelected : ChSelectedOptions,
                ContChildSelected : ResslectedOptions
            });
	    action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ----------' + state + ' ' + response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false); 
                component.drawTable(''); 
            }
            else{
                component.set("v.showSpinner", false);
            } 
	    }); 
	    $A.enqueueAction(action);   
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
                	component.set("v.showSpinner", false);	
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
                
            }else{
                component.set("v.showSpinner", false);	
            }
	    });
       
	    $A.enqueueAction(action);        
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
        var SelectedOptions = component.get("v.SelectedOptions");
         var ChSelectedOptions = component.get("v.selectedprojecttask").Id;
        var ResslectedOptions = component.get("v.selectedContact").Id; 
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                selected : SelectedOptions,
                ChildSelected : ChSelectedOptions,
                ContChildSelected : ResslectedOptions
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
                component.drawTable('');
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
	    $A.enqueueAction(action); 
        
            

	}, 
    
    getContacts: function(component) {
	    var action = component.get("c.getAllResourcess"); 
	    var SelectedOptions = component.get("v.SelectedOptions");
	    action.setParams({
            selected : SelectedOptions
        });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.contactList", response.getReturnValue());
            }
	    }); 
	    $A.enqueueAction(action);
	},
    getprojectTasks: function(component) {
	    var action = component.get("c.getAllProjectTasks");
	    var SelectedOptions = component.get("v.SelectedOptions");
	    action.setParams({
                selected : SelectedOptions
            });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.projectTaskList", response.getReturnValue());
	            console.log('---->', component.get("v.projectTaskList"));
            }
	    }); 
	    $A.enqueueAction(action);
	},
	
	 getprojects: function(component) {
	    var action = component.get("c.getAllProjects"); 
	    var Sales  = '';
	    if(component.get("v.recordId") != undefined){
	        Sales = component.get("v.recordId");
	    }
	    
	    action.setParams({
                selected : Sales
        });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.projectList", response.getReturnValue());
	            console.log('---->', component.get("v.projectList"));
            }
	    }); 
	    $A.enqueueAction(action);
	},
    
    dayViewHelper : function(component,dayValue,weekName) {

    var week = [];
        console.log('dayViewHelper ========> ');
		week.push({Day:weekName,Date: $A.localizationService.formatDate(dayValue, 'MM/dd/yyyy')});
        component.set("v.currentDate",dayValue);	
        component.set("v.weekDates",week); 
        var SelectedOptions = component.get("v.SelectedOptions");
         var ChSelectedOptions = component.get("v.selectedprojecttask").Id;
        var ResslectedOptions = component.get("v.selectedContact").Id; 
         console.log('state ========> ',ResslectedOptions);
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(dayValue, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(dayValue, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                selected : SelectedOptions,
                ChildSelected : ChSelectedOptions,
                ContChildSelected : ResslectedOptions
            });
        
			action.setCallback(this, function(response) {
			   
	        var state = response.getState();
	         console.log('state ========> ',state);
	        if (component.isValid() && state === "SUCCESS") {
                
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
                component.drawTable('');
            }
            else{
                component.set("v.showSpinner", false);
            }
            
	    });
         
	    $A.enqueueAction(action);            
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
       var SelectedOptions = component.get("v.SelectedOptions");
        var ChSelectedOptions = component.get("v.selectedprojecttask").Id;
        var ResslectedOptions = component.get("v.selectedContact").Id; 
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
                toDate : todateStr,
                selected : SelectedOptions,
                ChildSelected : ChSelectedOptions,
                ContChildSelected : ResslectedOptions
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();

	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());
                component.set("v.showSpinner", false);
                component.drawTable('');
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
        
	    $A.enqueueAction(action);
        
       
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
        var SelectedOptions = component.get("v.SelectedOptions");
         var ChSelectedOptions = component.get("v.selectedprojecttask").Id;
        var ResslectedOptions = component.get("v.selectedContact").Id; 
	    var action = component.get("c.getWeekRecords");
        var fromDate = $A.localizationService.formatDate(mondayOfWeek, 'MM/dd/yyyy');
        var fromdateStr = fromDate.toString()
        var toDate = $A.localizationService.formatDate(next2sundayOfWeek, 'MM/dd/yyyy');
        var todateStr = toDate.toString();
         action.setParams({
                fromDate : fromdateStr,
                toDate : todateStr,
                selected : SelectedOptions,
                ChildSelected : ChSelectedOptions,
                ContChildSelected : ResslectedOptions
            });
        
	    action.setCallback(this, function(response) {
	        var state = response.getState();

	        if (component.isValid() && state === "SUCCESS") {
	            component.set("v.eventList", response.getReturnValue());  
                component.set("v.showSpinner", false);
                component.drawTable('');
            }
            else{
                component.set("v.showSpinner", false);
            }
	    });
        
	    $A.enqueueAction(action);
        
       
	},

    getprojectJunctions : function(component) { 
        var opts=[];
        var action = component.get("c.getprojectJunction");
        var inputsel = component.find("InputSelectProjectTask"); 
        action.setCallback(this, function(a) { 
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") { 
                if(a.getReturnValue().length > 0){ 
                    opts.push({"class": "optionClass", label:"", value:""});
                    for(var i=0;i< a.getReturnValue().length;i++){
                        if(a.getReturnValue()[i].Id == component.get("v.Eid")){
                            opts.push({"class": "optionClass", label: a.getReturnValue()[i].Name, value: a.getReturnValue()[i].Id,selected:"true"});
                        }
                        else{
                           opts.push({"class": "optionClass", label: a.getReturnValue()[i].Name, value: a.getReturnValue()[i].Id}); 
                        }
                            inputsel.set("v.options", opts);
                    } 
                }
            }
        });
       
	    $A.enqueueAction(action);
    },
    
    SetResource : function(component){
       var action = component.get("c.setResourceText"); 
        action.setParams({
                rid : component.get("v.Rid")
            }); 
        action.setCallback(this, function(a) { 
            
            var state = a.getState(); 
            if (component.isValid() && state === "SUCCESS") {  
                component.find("atcmplbox").set("v.value", a.getReturnValue());
            }
	    });
       
	    $A.enqueueAction(action);
    },
    
     CreateServiceRecord : function(component,event,helper){
       //  alert('Hii')
       var action = component.get("c.CreateServiceRequest"); 
      // alert(component.get("v.DateSelected") + ' '+ component.get("v.ProjectIds"))
        // action.setParams({
        //         Datevalue : component.get("v.DateSelected"),
        //         ProjectId : component.get("v.ProjectIds"),
                
        //     }); 
        action.setCallback(this, function(a) { 
            
            var state = a.getState(); 
          //  alert(state);
            if (state === "SUCCESS") {  
                
               // component.find("atcmplbox").set("v.value", a.getReturnValue());
            }
	    });
       
	    $A.enqueueAction(action);
    },
    
     
    
    
    
})