({
    Update : function(component, event, helper) {
        
        if(component.get("v.selectedLookUpRecord").Id==undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please select certification template',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
            component.set("v.certificatename",component.get("v.selectedLookUpRecord").Name);
            component.set('v.showConfirmDialog', true);

        }
        
       
      
    },
    
    
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
     
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showConfirmDialog', false);
        component.set("v.callUpdate",true);
         if(component.get("v.callUpdate")==true){          
            
            var action=component.get("c.updateCourse");
            //alert('action------'+action);        
            
            if(component.get("v.selectedLookUpRecord").Id != undefined){
                //alert(component.get("v.recordId"));
                //alert(component.get("v.selectedLookUpRecord").Name);
                
                action.setParams({
                    id:component.get("v.recordId"),
                    templatename:component.get("v.selectedLookUpRecord").Name
                })
                action.setCallback(this,function(e){
                    //alert('eeeeeee-------'+e.getState())
                    if(e.getState()=='SUCCESS'){    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Certification Template updated successfully',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });  
                        toastEvent.fire();   
                        window.location.reload(true);
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'Record not updated',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
                $A.get('e.force:refreshView').fire();
            }             
            
            
        }
        
      
        
        
    },
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
        component.set("v.callUpdate",false);
    },
    
})