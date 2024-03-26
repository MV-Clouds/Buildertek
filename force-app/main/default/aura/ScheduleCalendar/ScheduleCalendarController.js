({

    doInit : function(component, event, helper) {
        debugger
        let recordId = component.get("v.recordId");
        component.set("v.isSingleProject", (recordId != null && recordId != undefined && recordId != '') ? true : false);
    },

	afterScriptsLoaded : function(component, event, helper) {
        helper.getAllActiveProjects(component, event, helper);
        helper.getAllVendors(component, event, helper);
        helper.getAllTradeTypes(component, event, helper);
        var eventArr = [];
        var defaultDate = new Date()
        let flag = component.get("v.isSingleProject");
        $('#calendar').fullCalendar('addEventSource', eventArr, true);
        helper.loadCalendar(component,event,helper,eventArr,defaultDate);
        if (flag) {
            $('#calendar').fullCalendar('removeEvents', function () { return true; });
            helper.getActiveProjects(component, event, helper);
        }
	},

    onProjectChange : function(component, event, helper) {

    },

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
        let flag = component.get("v.isSingleProject");
        if (!flag) {
            component.set("v.ProjectRecordList", recordListByEvent);
        }

        console.log('--- Event Receive ---');
        console.log('recordListByEvent => ',{recordListByEvent});

    }


})