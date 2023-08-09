({
	doInit : function(component, event, helper) {
	    component.set("v.Spinner", true);
        var action = component.get("c.getProduct");
        var poItem = JSON.stringify(component.get("v.newSubContractItems"));
        action.setParams({
            poItems: poItem
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.contractItemsToInsert", result);
                component.set("v.Spinner", false);
                
            }
        });
        $A.enqueueAction(action);
	},
	
	addProduct : function(component, event, helper) {
        var poItemsToInsert = component.get("v.contractItemsToInsert");
        var lstOfFilters = JSON.stringify(poItemsToInsert);
	    var action = component.get("c.addProductsToList");
	    action.setParams({
	        POItems : lstOfFilters,
	        POItem : component.get("v.newContractItem"),
	        count : poItemsToInsert.length
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.contractItemsToInsert", result);
	        }
	    });
        $A.enqueueAction(action);
    },
    
    removeProduct : function(component, event, helper) {
        var rowIndex = event.target.dataset.name;
        var FiltersList = component.get("v.contractItemsToInsert");
        FiltersList.splice(rowIndex,1);
        for(var i=0;i<FiltersList.length;i++){
            FiltersList[i].rowIndex = i;
        }
        component.set("v.contractItemsToInsert", FiltersList);
    },
    
    doSave:function(component, event, helper) {
    
    	/*var cmpContainer = component.find('subContractContainer');
        $A.util.addClass(cmpContainer, 'slds-hide');
        
        
        var btspinner = component.find('btspinner');
        $A.util.removeClass(btspinner, 'slds-hide');
        
		var action;
		action = component.get("c.createSubContract");
        action.setParams({
            subContractJson: JSON.stringify(component.get("v.newSubContract")),
            subContractItemsJson: JSON.stringify(component.get("v.newSubContractItems"))
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	//$A.enqueueAction(component.get("v.saveCallback"));
            	//component.get("v.cancelCallback")();
            	var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": response.getReturnValue().Id,
                })
                sObjectEvent.fire();
			} else {
				component.find('notifLib').showNotice({
		            "variant": "error",
		            "header": "Error!",
		            "message": response.getError()[0].message,
		            closeCallback: function() {
		            }
		        });
			}
        });
        
        $A.enqueueAction(action);*/
        
        component.set("v.Spinner", true);
    	var action;
		action = component.get("c.createSubContractFromBudget");
        action.setParams({
            contractJson:  component.get("v.newSubContract"),
            contractItemsJson: JSON.stringify(component.get("v.contractItemsToInsert"))
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	$A.enqueueAction(component.get("v.saveCallback"));
            	var result = response.getReturnValue();
            	if(result.isSuccess === true){
            	     component.set("v.Spinner", false);
            	     component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": 'Contract created successfully',
                        closeCallback: function() {
                            var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": result.strRecordId,
                            })
                            sObjectEvent.fire(); 
                        }
                    });   
            	}else{
            	    component.set("v.Spinner", false);
            	    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.strMessage,
                        closeCallback: function() {
                        }
                    });   
            	} 
			}
        }); 
        
        $A.enqueueAction(action);
	},
	
	doCancel:function(component, event, helper) {
		component.get("v.cancelCallback")();
	}
})