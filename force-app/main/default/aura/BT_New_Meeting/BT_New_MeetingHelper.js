({
	addRecord: function(component, event) {
        //get the account List from component  
        var actionItemsList = component.get("v.actionItemsList");
        //Add New Account Record
        actionItemsList.push({
            'sobjectType': 'buildertek__Action_Item__c',
            'buildertek__Description__c': '',
            'buildertek__Owner__c': '',
            'buildertek__Due_Date__c': ''
        });
        component.set("v.actionItemsList", actionItemsList);
    },
     
    validateList: function(component, event) {
        //Validate all account records
        var isValid = true;
        var actionItemsList = component.get("v.actionItemsList");
        for (var i = 0; i < actionItemsList.length; i++) {
            if (actionItemsList[i].buildertek__Description__c == '') {
                isValid = false;
                //alert('Description cannot be blank on row number ' + (i + 1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'Description cannot be blank on row number ' + (i + 1),
                    type: 'error',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
        return isValid;
    },
    
    validateList1: function(component, event) {
        //Validate all account records
        var isValid = true;
        var actionItemsList = component.get("v.actionItemsList");
        for (var i = 0; i < actionItemsList.length; i++) {
            if (actionItemsList[i].buildertek__Owner__c == '') {
                isValid = false;
                //alert('Description cannot be blank on row number ' + (i + 1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'Owner cannot be blank on row number ' + (i + 1),
                    type: 'error',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
        return isValid;
    },
     
    saveActionItemsList: function(component, event, helper,meetingRecId) {
        //alert('saveActionItemsList');
        //Call Apex class and pass account list parameters
        var action = component.get("c.saveActionItems");
        action.setParams({
            "actItemsList": component.get("v.actionItemsList"),
            "MeetingId" : meetingRecId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state--------'+state);
            if (state === "SUCCESS") {
                component.set("v.actionItemsList", []);
                component.set("v.IsSpinner",false);
                //alert('New meeting saved successfully');
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'New meeting created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": meetingRecId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
        }); 
        $A.enqueueAction(action);
    },

    
    
})