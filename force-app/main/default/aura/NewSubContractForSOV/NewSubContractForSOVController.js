({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true)
        
        var action1 = component.get("c.recTypeId");
        action1.setParams({
            recordId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.showMessage", false)
                var result = response.getReturnValue();
                component.set("v.SubConRecType",result);
                
                
                
                
            }
        });
        $A.enqueueAction(action1);
        
        
        
        var action = component.get("c.getSOVDetails");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.showMessage", false)
                var subcon = component.get("v.SubConRecType");
                var result = response.getReturnValue();
                component.find("recType").set("v.value",subcon);
                
                component.set("v.projectName", result.buildertek__Project__c);
                component.set("v.SOVVendor", result.buildertek__Vendor__c);
                
                
            }
            
        });
        $A.enqueueAction(action);
        
        
    },
    
    
    handleOnSubmit : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        
        component.find('leadCreateForm').submit(eventFields);
        component.set("v.applicationValues",eventFields)
    },
    
    handleOnSuccess : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
        var payload = event.getParams().response;
        console.log(payload.id);
        
        
        var action = component.get("c.createContract");
        action.setParams({
            recordId : payload.id,
            SovId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
                
                component.set("v.projectName", result.buildertek__Project__c);
                component.set("v.SOVVendor", result.buildertek__Vendor__c);
                
                
                
                
                debugger;
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
                setTimeout(function () {
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        /*  "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"*/
                        "recordId": payload.id,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }, 200);
                
                
            }
            
        });
        $A.enqueueAction(action);
        
        
    },
    
    
    CloseScreen : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();      
        
    },
    
    
    
})