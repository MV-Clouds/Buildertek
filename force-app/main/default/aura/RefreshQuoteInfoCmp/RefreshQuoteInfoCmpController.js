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
                            "message": "Quote Info Refresh not supported at current Order Status",
                            duration:'6000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                    	toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    var action = component.get("c.syncQuoteInfo");
                    action.setParams({
                        recordid: component.get('v.recordId')
                    });
                    action.setCallback(this, function(response){
                        var result =  response.getReturnValue();
                        var state = response.getState();
                        var toastEvent = $A.get("e.force:showToast");
                        if (state === "SUCCESS") {
                            if (result == "success"){
                                toastEvent.setParams({
                                    "title": "Success",
                                    "message": "The Quote Info has been successfully refreshed."
                                });
                                toastEvent.fire();
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                $A.get('e.force:refreshView').fire();
                                dismissActionPanel.fire();
                            }else{
                                var toastEvent = $A.get( "e.force:showToast" );
                                if( toastEvent ) {
                                    toastEvent.setParams({
                                        "title": "ERROR",
                                        "message": "Quote Info Refresh Failed",
                                        duration:'6000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                            	}
                            }
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
    }
})