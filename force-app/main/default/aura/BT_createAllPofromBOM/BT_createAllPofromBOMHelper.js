({
    createPOwithVendor : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId : ', recordId);
            
        var action = component.get("c.createAllPO");
        action.setParams({
            BOMId : recordId
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('return value : ', result);
            if(result.state == 'success'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
            else if(result.state == 'error'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    createPOwithCostCode : function(component, event, helper) {
        var recordId = component.get("v.recordId");
            
        var action = component.get("c.createAllPOWithCostCode");
        action.setParams({
            BOMId : recordId,
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('return value : ', result);
            if(result.state == 'success'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
            else if(result.state == 'error'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    createPOwithTradeType : function(component, event, helper) {
        var recordId = component.get("v.recordId");
            
        var action = component.get("c.createAllPOWithTradeType");
        action.setParams({
            BOMId : recordId,
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('return value : ', result);
            if(result.state == 'success'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
            else if(result.state == 'error'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    createPOwithBuildPhase : function(component, event, helper) {
        var recordId = component.get("v.recordId");
            
        var action = component.get("c.createAllPOWithBuildPhase");
        action.setParams({
            BOMId : recordId,
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('return value : ', result);
            if(result.state == 'success'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
            else if(result.state == 'error'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    createPOwithCategory : function(component, event, helper) {
        var recordId = component.get("v.recordId");
            
        var action = component.get("c.createAllPOWithCategory");
        action.setParams({
            BOMId : recordId,
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('return value : ', result);
            if(result.state == 'success'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
            else if(result.state == 'error'){
                $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": result.returnMessage,
                    "duration" : 3000,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
    

})