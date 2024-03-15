({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        window.setTimeout(
            $A.getCallback(function () {
                console.log('recordId', component.get('v.recordId'));
                helper.getTimeSheetEntries(component, event, helper);
            }),
            2000
        );
    },

    onMassUpdate: function(component, event, helper){
        component.set("v.Spinner", true);
        helper.validateTimeSheetEntries(component, event, helper);
        // helper.updateTimeSheetEntries(component, event, helper);
    },

    onAddClick: function(component, event, helper){
        console.log('onAddClick');
        var timeSheetEntries = component.get('v.timeSheetEntries');
        //create a timeSheetEntry
        var timeSheetEntry = {
            'Name': '',
            'buildertek__BT_Time_Sheet__c': component.get('v.recordId'),
        };
        //push on the top of the list
        timeSheetEntries.unshift(timeSheetEntry);
        component.set('v.timeSheetEntries', timeSheetEntries);
    },

    deleteRecord: function(component, event, helper){
        console.log('deleteRecord');
        var target = event.target;
        var timeSheetEntries = component.get('v.timeSheetEntries');
        var index = target.getAttribute("data-index");
        console.log('index', index);
        if(index != null){
            if(timeSheetEntries[index].Id != ''){
                var deletedTimeSheetEntries = component.get('v.deletedTimeSheetEntries');
                deletedTimeSheetEntries.push(timeSheetEntries[index]);
                component.set('v.deletedTimeSheetEntries', deletedTimeSheetEntries);
                timeSheetEntries.splice(index, 1);
                component.set('v.timeSheetEntries', timeSheetEntries);

            } else {
                timeSheetEntries.splice(index, 1);
                component.set('v.timeSheetEntries', timeSheetEntries);
            }
        }
        
    },

    onMassUpdateCancel: function(component, event, helper){
        component.set("v.isCancelModalOpen", true);
    },

    closeScreen: function(component, event, helper){
        component.set("v.isCancelModalOpen", false);
        //    <aura:registerEvent name="myevent" type="c:myEvent" />
        var appEvent = $A.get("e.c:myEvent");
        appEvent.setParams({
            "message" : "Event fired"
        });
        appEvent.fire();
        
        sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
    },

    closeCancelModal: function(component, event, helper){
        component.set("v.isCancelModalOpen", false);
    },


})
