({
	doInit : function(component, event, helper) {
        var scheduleRecords = JSON.stringify(component.get("v.selectedScheduleRecords"));
		var scheduleItems = JSON.stringify(component.get("v.newScheduledItems"));
        
        //component.set("v.projectID",component.get("v.projectID"));
        component.set("v.scheduleItemsToInsert",JSON.parse(scheduleItems));
        component.set("v.scheduleRecordsItems",JSON.parse(scheduleRecords));
        var schedules = JSON.parse(scheduleRecords)
        if(schedules.length){
            component.set("v.singleselectedScheduleRecord",schedules[0])
        }
        console.log(component.get("v.recordId"));
	},
    doSave: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.newSchedule.buildertek__Project__c",component.get("v.projectID"));
        component.get("v.newSchedule.buildertek__Description__c");
        var scheduleItems = JSON.parse(JSON.stringify(component.get("v.scheduleItemsToInsert")));
        var action;
        action = component.get("c.createScheduleItems");
        action.setParams({
            "isCreateNewScheduleAttr" : component.get("v.isCreateNewScheduleAttr"),
            "newScheduleRecord" : component.get("v.newSchedule"),
            "scheduleItems": scheduleItems,
            "scheduleRecordsIds": JSON.parse(JSON.stringify(component.get("v.scheduleRecordsItems")))
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
               
                var result = response.getReturnValue();
                if (result.isSuccess === true) {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        mode: 'dismissible',
                        duration: 2,
                        message: 'Schedule Items created successfully',
                        type: 'success'
                    });
                    toastEvent.fire();
                    $A.enqueueAction(component.get("v.saveCallback"));
                    var selectedSceduleItems = JSON.parse(JSON.stringify(component.get("v.scheduleRecordsItems")));
                    component.get("v.cancelCallback")();
                    if(component.get("v.isCreateNewScheduleAttr")){
                         var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent.setParams({
                            "recordId": result.strRecordId,
                        })
                        sObjectEvent.fire();
                    }else if(selectedSceduleItems.length == 1){
                        var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent.setParams({
                            "recordId": result.strRecordId,
                        })
                        sObjectEvent.fire();
                    }else if(selectedSceduleItems.length > 1){
                        location.href = '/lightning/r/buildertek__Schedule__c/'+result.strRecordId+'/related/buildertek__Schedules__r/view';
                    }
                    
                   /* var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": result.strRecordId,
                    })
                    sObjectEvent.fire();*/
                     component.set("v.isCreateNewScheduleAttr",false)
                    component.set("v.scheduleRecordsItems",[]);
                    component.set("v.Spinner", false);
                }else {
                    component.set("v.Spinner", false);
                  /*  component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result,
                        closeCallback: function () {}
                    });*/
                }
            } 
        });
        $A.enqueueAction(action);
    },
    doCancel: function (component, event, helper) {
        component.set("v.singleselectedScheduleRecord","")
        component.get("v.cancelCallback")();
    },
    
    onChangScheduleType : function (component, event, helper) {
       var val =  component.find('selectScheduleType').get('v.value')
       if(val != 'None'){
           component.set("v.newSchedule.buildertek__Type__c",val);
       }else{
           component.set("v.newSchedule.buildertek__Type__c",'');
       }
    }
    
})