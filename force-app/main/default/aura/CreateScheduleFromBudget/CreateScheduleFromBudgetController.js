({
    doInit : function(component, event, helper) {
        console.log(component.get('v.recordId'));

    },
    handleSubmit: function (component, event, helper) {
        component.set('v.isLoading' , true);
        console.log('handleSubmit:::');
        component.set("v.isDisabled", true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
        component.find('recordViewForm').submit(fields); // Submit form
    
    },
    onRecordSuccess: function (component, event, helper) {
        console.log('onRecordSuccess:::');
        console.log(event.getParams().response);
        component.set('v.isLoading' , false);
        var record = event.getParams().response; 
        console.log(record.id);
        component.set('v.scheduleId' ,record.id);
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Schedule created successfully',
                messageTemplate: "Schedule created successfully.",
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
        toastEvent.fire();

        var action=component.get("c.createScheduleLine");
        action.setParams({
            scheduleId:component.get('v.scheduleId'),
            budgetId:component.get('v.recordId')
        });
        action.setCallback(this, function (response){
            console.log(response.getState());
            console.log(response.getError());


        });
        $A.enqueueAction(action); 

        $A.get("e.force:closeQuickAction").fire();

        var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": record.id,
                "actionName": "view",               
                "objectApiName":"buildertek__Schedule__c"              
            }        
        };
                
        component.set("v.pageReference", pageReference);
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference); 
    },

    handleError: function (component, event, helper) {
        var error = event.getParam("error");
        console.error(JSON.stringify(error));

    },
    closeModel:function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    // handleProjectChange:function (component, event, helper) {
    //     console.log(event.getSource().get('v.value'));
    // }
})