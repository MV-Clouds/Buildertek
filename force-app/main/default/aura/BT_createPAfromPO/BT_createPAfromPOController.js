({
    doInit : function(component, event, helper) {
        try {
            var action = component.get("c.GetRelatedPaymanetApp");
            action.setParams({
                SOVid : component.get("v.recordId")
            });
            action.setCallback(this, function (response){
                var result = response.getReturnValue();
                console.log(' GetRelatedPaymanetApp apex result : ', result);
                if(result != null){
                    if(result.recordId != null){
                        var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                            "recordId": result.recordId,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();

                        var Message;
                        if(result.returnMessage == 'existing_PA'){
                            Message = 'Redirected to most recent Payment Application.'
                        }
                        else if(result.returnMessage == 'newCreated_PA'){
                            Message = 'New Payment application created successfully.'
                        }
                        helper.showToastMessageHelper(component, event, helper, 'Success', Message, 'success', 3000);
                    }
                    else{
                        helper.showToastMessageHelper(component, event, helper, 'Error', 'Please link purchase order.', 'error', 3000);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
                else{
                    helper.showToastMessageHelper(component, event, helper, 'Error', 'Something Went Wrong.', 'error', 3000);
                    $A.get("e.force:closeQuickAction").fire();
                }

            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log('Error in Doint : ', error.stack);
        }
    }
})
