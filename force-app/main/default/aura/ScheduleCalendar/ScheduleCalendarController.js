({
	afterScriptsLoaded : function(component, event, helper) {
        helper.getAllActiveProjects(component, event, helper);
        helper.getAllVendors(component, event, helper);
        helper.getAllTradeTypes(component, event, helper);
        var eventArr = [];
        var defaultDate = new Date()
        $('#calendar').fullCalendar('addEventSource', eventArr, true);
        helper.loadCalendar(component,event,helper,eventArr,defaultDate);
        // helper.getActiveProjects(component, event, helper);
        //helper.gettabname(component);
	},
    // onScheduleItemChange : function(component, event, helper) {
        //$('#calendar').fullCalendar('removeEvents', function () { return true; });
        //helper.getActiveProjects(component, event, helper);
    // },
    onProjectChange : function(component, event, helper) {
    	 
    },
    /*handleComponentEvent : function(component, event, helper) {
        var valueFromChild = event.getParam("seletcedOption");
        var value = valueFromChild.split("_")[0];
        var selectBox = valueFromChild.split("_")[2];
        var selecetedName = valueFromChild.split("_")[1];
        
        
        
        /*component.set("v.selectedProjectId",'');
        component.set("v.selectedProjectIdName",'');
        component.set("v.selectedTradeTypeId",'');
        component.set("v.selectedTradeTypeIdName",'');
        component.set("v.selectedVendorId",'');
        component.set("v.selectedVendorIdName",'');*/
        
        /*if(selectBox == "projectULId" || selectBox == "projectId"){
            if(value == '' && selecetedName== ''){
                document.getElementById("projectId").value = '';
                component.set("v.selectedProjectId",'All');
                component.set("v.selectedProjectIdName",'All');
            }else{
                document.getElementById("projectId").value = selecetedName;
                component.set("v.selectedProjectId",value);
                component.set("v.selectedProjectIdName",selecetedName);
            }
            
        }else if(selectBox == "tradeTypeULId" || selectBox == "tradeTypeId"){
            if(value == '' && selecetedName== ''){
                document.getElementById("tradeTypeId").value = '';
                component.set("v.selectedTradeTypeId",'All');
                component.set("v.selectedTradeTypeIdName",'All');
            }else{
                document.getElementById("tradeTypeId").value = selecetedName;
                component.set("v.selectedTradeTypeId",value);
                component.set("v.selectedTradeTypeIdName",selecetedName);
            }
            
        }else if(selectBox == "vendorULId" || selectBox == "vendorId"){
            if(value == '' && selecetedName== ''){
                document.getElementById("vendorId").value = '';
                component.set("v.selectedVendorId",'All');
                component.set("v.selectedVendorIdName",'All');
            }else{
                document.getElementById("vendorId").value = selecetedName;
                component.set("v.selectedVendorId",value);
                component.set("v.selectedVendorIdName",selecetedName);
            }
            
        }
        
        //$('#calendar').fullCalendar('removeEvents', function () { return true; });
        //helper.getActiveProjects(component, event, helper);   
    },*/
    
    
    
     handleComponentEvent: function (component, event, helper) {
        // get the selected Account record from the COMPONETN event 
        
        //var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //component.set("v.selectedContact", selectedAccountGetFromEvent.Id);
        var slectedaccountId = JSON.stringify(component.get("v.selectedVendor").Id);
        var slectedprojectId = JSON.stringify(component.get("v.selectedproject").Id);
        var slectedTradetypeId = JSON.stringify(component.get("v.selectedTradetype").Id);
        
    },
    
    ClearhandleComponentEvent: function (component, event, helper) {
        
        
    },
    
    filterRecords : function(component, event, helper) {
    	$('#calendar').fullCalendar('removeEvents', function () { return true; });
        helper.getActiveProjects(component, event, helper);	    
    },
    startDateChange : function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        var eventDate = component.get("v.finishDate");
        var action = component.get("c.updateDate"); 
        action.setParams({
            'recordId' : recordId,
            'endDate' : eventDate
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	component.set("v.defaultDate", response.getReturnValue());  
                $('#calendar').fullCalendar('removeEvents', function () { return true; });
        		helper.getActiveProjects(component, event, helper);	 
                //component.set("v.Spinner", false);
            }    
        });
        $A.enqueueAction(action);
    },
    
    endDateChange : function(component, event, helper) {
    	component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        var eventDate = component.get("v.endDate");
        var action = component.get("c.updateEndDate"); 
        action.setParams({
            'recordId' : recordId,
            'endDate' : eventDate
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	component.set("v.defaultDate", response.getReturnValue());  
                $('#calendar').fullCalendar('removeEvents', function () { return true; });
        		helper.getActiveProjects(component, event, helper);	 
                //component.set("v.Spinner", false);
            }    
        });
        $A.enqueueAction(action);    
    }, 

    handleRecordListEvent : function(component, event, helper){

        var recordListByEvent = event.getParam("recordListByEvent");
        component.set("v.ProjectRecordList", recordListByEvent);

        console.log('--- Event Receive ---');
        console.log('recordListByEvent => ',{recordListByEvent});

    }
    
    
})