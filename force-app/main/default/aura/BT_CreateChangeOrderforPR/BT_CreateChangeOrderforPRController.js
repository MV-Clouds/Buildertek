({
	doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        var action = component.get("c.getprrec");
        action.setParams({
            recordId : component.get("v.recordId")    
        });
        
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
               
                 component.set('v.isLoading', false);
               if(result == 'success'){
                    $A.get("e.force:closeQuickAction").fire();
                     $A.get('e.force:refreshView').fire();
                   var showToast = $A.get( "e.force:showToast" );   
                   showToast.setParams({   
                       title : "Success",
                       message : "Change Order Created Successfully.",
                       type: 'success',
                       duration: '5000',
                       key: 'info_alt',
                       mode: 'dismissible'
                   });   
                   showToast.fire();
               }else if(result == 'error'){
                   $A.get("e.force:closeQuickAction").fire();
                  // $A.get('e.force:refreshView').fire();
                   var showToast = $A.get( "e.force:showToast" );   
                   showToast.setParams({   
                       title : "Error!",
                       message : "There are No Accepted Lines to create the Change Orders.",
                       type: 'error',
                       duration: '1000',
                       key: 'info_alt',
                       mode: 'pester'
                   });   
                  showToast.fire(); 
               }
            }
            else{
                debugger;
                  $A.get("e.force:closeQuickAction").fire();
                var error = response.getError()[0].fieldErrors;
                console.log(error.Name[0].message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: error.Name[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
         });
        $A.enqueueAction(action);
    },
})