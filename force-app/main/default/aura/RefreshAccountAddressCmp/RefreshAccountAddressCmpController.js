({
    doInit : function(component, event, helper) {   
        var action = component.get("c.verifyOERStatus");
        action.setParams({
            recordid: component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
             if ( state === "SUCCESS" ) {
                var result = response.getReturnValue();
                if (result == "error"){
                    var toastEvent = $A.get( "e.force:showToast" );
                    if( toastEvent ) {
                        toastEvent.setParams({
                            "title": "ERROR",
                            "message": "Account Address Refresh not supported at current Order Status",
                            duration:'6000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                    	toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    component.set('v.RefreshAllowed',true);
                }
            }else {
                    var toastEvent = $A.get( "e.force:showToast" );
                    if( toastEvent ) {
                        toastEvent.setParams({
                            "title": "ERROR",
                            "message": "Unable to perfrom requested action",
                            duration:'6000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                    	toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
			}
           
        });
        $A.enqueueAction(action);
    },
    showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message,
					'mode' : 'dismissible',
					'duration' : 7000 
                });
                toastEvent.fire();
            }
        }
    },
    handleClick : function(component, event, helper)
    {    
        var SoldTo = component.get("v.SoldTo");
        var Billing = component.get("v.Billing");
        
        var action = component.get("c.updateAccount");
        
        action.setParams({
            recordid: component.get('v.recordId'),soldto: component.get("v.SoldTo")  , billing:component.get("v.Billing")
        });
        action.setCallback(this, function(response){
            var result =  response.getReturnValue();
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    "title": "Success",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                $A.get('e.force:refreshView').fire();
                dismissActionPanel.fire();
                
            }else if(state === "ERROR"){
                var errors = response.getError();
                var errorMessage = '';
                if(errors[0]){
                    errorMessage = errors[0].message;
                }
                
                toastEvent.setParams({
                    "title": "ERROR",
                    "message": errorMessage,
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
    cancelClick :function (component, event, helper)
    {
     var dismissActionPanel = $A.get("e.force:closeQuickAction");
               
                dismissActionPanel.fire();
               
    }
})