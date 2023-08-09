({
	doInit : function(component, event, helper) {
         component.set("v.ApprovePR", true);
    },
    cancelrequest : function(component, event, helper){
           component.set("v.ApprovePR", false);
           $A.get("e.force:closeQuickAction").fire();
      },
    updatePR : function(component, event, helper){
        console.log('updatePR');
           var action = component.get("c.approvepricingRequest");
         component.set('v.isdisabled', true);
        action.setParams({
            recordId : component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            console.log(response.getState());
            console.log(response.getError());

            if(response.getState() === "SUCCESS"){
                var PricrecordId =component.get("v.recordId");
                var result = response.getReturnValue();
                if(result == 'success'){
                    component.set('v.isLoading', false);
                    component.set("v.ApprovePR", false);
                     $A.get("e.force:closeQuickAction").fire();
                     $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Pricing Request is Customer Approved Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }
        })
        $A.enqueueAction(action);
      },
})