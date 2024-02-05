({
    createBOMfromTakeoff : function(component, event) {
        try {
            var action = component.get("c.createBOMformTakeoff");
            action.setParams({ TakeoffId : component.get("v.recordId") });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var resultValue = response.getReturnValue();
                console.log('resultValue : ', resultValue);

                if(state === "SUCCESS"){
                    if(resultValue.returnState == 'success'){
                        $A.get("e.force:closeQuickAction").fire();
                        component.find('notifLib').showNotice({
                            "variant": "success",
                            "header": "Success",
                            "message": "BOM Successfully Created.",
                            closeCallback: function() {
                                var event = $A.get('e.force:navigateToSObject' );
                                event.setParams({
                                    'recordId' : resultValue.CreatedrecordId
                                }).fire();
                            }
                        });    
                    }
                    else{
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error",
                            "message": resultValue.returnState,
                        });    
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            });

            $A.enqueueAction(action);	     

            
        } catch (error) {
            console.log('Error in createBOMfromTakeoff : ', error.message);
            
        }
    }
})