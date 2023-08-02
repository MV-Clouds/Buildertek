({
	doInit : function(component, event, helper) {
	    
	    console.log("newquote");
	        var value = helper.getParameterByName(component , event, 'inContextOfRef');
            //alert('value' + value);
        	var context = '';
        	var parentRecordId = '';
        	component.set("v.parentRecordId",parentRecordId);
        	if(value != null){
        		context = JSON.parse(window.atob(value));  
        		parentRecordId = context.attributes.recordId;
                component.set("v.parentRecordId",parentRecordId);
    		}
            //alert(parentRecordId);
            if(parentRecordId != '' && parentRecordId != undefined){
                var evt = $A.get("e.force:createRecord");
                    evt.setParams({  
                        'entityApiName':'buildertek__RFQ__c',
                        'defaultFieldValues': {
                        'buildertek__Project__c':parentRecordId 
                    	}
                    });
            		evt.fire(); 
                }
                else{
                    var evt = $A.get("e.force:createRecord");
                    evt.setParams({  
                        'entityApiName':'buildertek__RFQ__c',
                        
                    });
            		evt.fire();               
                }                 
                
                //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
            
       
    },
    
    gotoList : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "buildertek__RFQ__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    doneRendering: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        
        if(component.get("v.parentRecordId") == undefined){
             $A.enqueueAction(component.get("c.gotoList"));   
        }
        else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.parentRecordId"),
              "slideDevName": "detail"
            });
            navEvt.fire();
        }
    }
})