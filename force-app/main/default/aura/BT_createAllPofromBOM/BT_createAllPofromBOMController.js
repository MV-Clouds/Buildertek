({
    doInit : function(component, event, helper) {
       try {
            var recordId = component.get("v.recordId");

            var action = component.get("c.createAllPO");
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
            
       } catch (error) {
            console.log('Error in doInit : ', error.stack);
       }
    }
})
