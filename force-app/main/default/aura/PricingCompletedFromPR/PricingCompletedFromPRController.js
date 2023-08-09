({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));

    },
    cancelrequest : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
   },
   updatePR:function(component, event, helper){
        component.set('v.isLoading', true);

        var action=component.get('c.updatePRStatus');
        action.setParams({
            pricingRequestId : component.get("v.recordId")    
        }); 
        action.setCallback(this, function(response){
            console.log(response.getError());
            console.log(response.getState());
            var state= response.getState();
            if(state == 'SUCCESS'){
                console.log(response.getReturnValue());

                component.set('v.isLoading', false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();


                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Pricing Request is Returned Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }else{
                component.set('v.isLoading', false);
                $A.get("e.force:closeQuickAction").fire();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Something Went Wrong',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    }
})