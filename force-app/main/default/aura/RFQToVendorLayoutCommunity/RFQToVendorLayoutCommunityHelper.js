({
	verifyduedate : function(component, event, helper) {
        var action = component.get("c.checkduedate");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == true){
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can not Reject this RFQ , because the Due Date of this RFQ is expired. Please Contact System Administrate.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                }else{
                    if(component.get("v.isaccept") == true){
                       component.set("v.acceptPopUp",true); 
                    }else if(component.get("v.isreject") == true){
                        component.set("v.rejectPopUp",true);
                    }
                  //component.set("v.isduedate",false);
                }
            }     
        });
        $A.enqueueAction(action);
		
	}
})