({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
	  var action ;
        /*var action = component.get("c.getProductRecords");
            action.setStorable();
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
                'filter' : component.get("v.filter"),
                'parentId' : component.get("v.parentId"),
                'prodctfamly' : component.get("v.prodctfamly")
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                }
                
            });*/
        
          if(component.get("v.objectAPIName") == "buildertek__Dependency__c"){
            action = component.get("c.getTasksInSchedule");
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : 'buildertek__Project_Task__c',
                'filter' : component.get("v.filter"),
                'parentId' : component.get("v.parentId")
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                }
                
            });
        }else if(component.get("v.objectAPIName") == "buildertek__Contractor_Resource__c"){
            action = component.get("c.getContractResource");
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : 'Contact',
                'filter' : component.get("v.filter"),
                'parentId' : component.get("v.parentId")
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                }
                
            });
        }else{
            var action = component.get("c.getProductRecords");
            action.setStorable();
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
                'filter' : component.get("v.filter"),
                'parentId' : component.get("v.parentId"),
                'prodctfamly' : component.get("v.prodctfamly")
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                }
                
            });
        }
        
        // enqueue the Action  
        $A.enqueueAction(action);
        
    }
    
})