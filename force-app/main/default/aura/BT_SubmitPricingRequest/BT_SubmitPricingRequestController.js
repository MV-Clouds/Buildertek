({
	doInit : function(component, event, helper) {
        /*var action = component.get("c.getRFQStatus");
        action.setParams({
            recordId : component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
               if(result.buildertek__Status__c == 'Submitted'){
                   $A.get("e.force:closeQuickAction").fire();
                   var showToast = $A.get( "e.force:showToast" );   
                   showToast.setParams({   
                       title : "Error!",
                       message : "This Pricing Request has already been Submitted.",
                       type: 'error',
                       duration: '1000',
                       key: 'info_alt',
                       mode: 'pester'
                   });   
                   showToast.fire();
               }else{*/
                    component.set("v.SubmitPR", true);
              /* }
            }
         });
        $A.enqueueAction(action);*/
		
    },
    cancelrequest : function(component, event, helper){
           component.set("v.SubmitPR", false);
           $A.get("e.force:closeQuickAction").fire();
      },
    updatePR : function(component, event, helper){
           var action = component.get("c.getpricingRequest");
         component.set('v.isdisabled', true);
        action.setParams({
            recordId : component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var PricrecordId =component.get("v.recordId");
                var result = response.getReturnValue();
                if(result == 'success'){
                    component.set('v.isLoading', false);
                    component.set("v.SubmitPR", false);
                     $A.get("e.force:closeQuickAction").fire();
                     $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Pricing Request is Submitted Successfully',
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