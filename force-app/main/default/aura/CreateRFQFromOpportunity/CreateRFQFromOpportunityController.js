({
	init : function(component, event, helper) {
      var recid = component.get("v.recordId");
       
     
	 component.find("oppid").set("v.value", component.get("v.recordId")); 
        
	},
	
	closeModel : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();   
	},
	
	saveRFQ : function(component, event, helper) {  
	    component.set("v.Spinner", true);
	    var projectId = component.find('projectNameId').get("v.value");
        var opprecid = component.find('oppid').get("v.value");
	    //alert('projectId ----------> '+projectId);
	    var rfqRecord = JSON.stringify(component.get("v.newRFQ"));
	    var action = component.get("c.saveRFQRecord");   
	    action.setParams({
	        projectId : projectId,
	        rfqRecord : rfqRecord,
            opprecid : opprecid
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.Spinner", false);
	            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": result.Id,
                  "slideDevName": "related"
                });
                navEvt.fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'RFQ created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	saveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
	    var projectId = component.find('projectNameId').get("v.value");
        var opprecid = component.find('oppid').get("v.value");
	    //alert('projectId ----------> '+projectId);
	    var rfqRecord = JSON.stringify(component.get("v.newRFQ"));
	    var action = component.get("c.saveRFQRecord");   
	    action.setParams({
	        projectId : projectId,
	        rfqRecord : rfqRecord,
            opprecid : opprecid
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.Spinner", false);
	            component.find('projectNameId').set("v.value", null);
	            //component.set("v.newRFQ.buildertek__Project__c", null);
	            component.set("v.newRFQ.Name", '');
	            component.set("v.newRFQ.buildertek__RFQ_Details__c", '');
	            component.set("v.newRFQ.buildertek__Trade_Type__c", null);
	            component.set("v.newRFQ.buildertek__Due_Date__c", null);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'RFQ created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
	        }
	    });
	    $A.enqueueAction(action);	    
	}
})