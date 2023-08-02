({
    doInit: function (component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.getEmails");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()=='noEmail'){
                    component.set("v.islocked", true);
                    component.set("v.message", "There is no Project Manager for Project");
                }else if(response.getReturnValue()=='noProject'){
                    component.set("v.islocked", true);
                    component.set("v.message", "There is no Project for Purchase Order");
                }else{
                    //component.set('v.email',  JSON.parse(JSON.stringify(action.getReturnValue())));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Email successfully sent to Project Manager',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                    // component.set("v.islocked", true);
                    // component.set("v.message", "Email successfully sent to Project Manager");
                }
                
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    
    
    
    closeModal: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    
    
})