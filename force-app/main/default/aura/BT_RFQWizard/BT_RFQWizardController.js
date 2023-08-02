({
	initialize : function(component, event, helper) {
	  $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
	   var navigateToStep, rfq, config, actionRfqConfig;

        actionRfqConfig = component.get("c.getRfqConfig");
        actionRfqConfig.setParams({
            rfqId: component.get("v.recordId")
        });
        actionRfqConfig.setCallback(this, function (response) {
        	if (component.isValid() && response.getState() === "SUCCESS") {
        		console.log(response.getReturnValue());
        		
        		var rfqConfig = response.getReturnValue();
        		rfq = rfqConfig.rfq;
        		config = rfqConfig.config;
        		
        		component.set("v.rfqConfig", config);
        		
        		navigateToStep = rfq.buildertek__RFQ_Workflow_Stage__c;
        		
        		if(!navigateToStep){
			    	navigateToStep = "1";
			    	rfq.buildertek__RFQ_Workflow_Stage__c = "1";
			    }
			    
			    helper.wizardNavigation(component, event, helper, navigateToStep, rfq);
        	}
        });
        
        $A.enqueueAction(actionRfqConfig);
	},
	
	navigateTo: function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var rfq, navigateToStep = event.getSource().get("v.value");
		rfq = component.get("v.rfq");
		// Destroy existing component
		if(rfq.buildertek__RFQ_Workflow_Stage__c !== navigateToStep){
		
			if(component.get("v.currentComponent") && component.get("v.currentComponent")[0]){
				
				// commented out this line due to the error
				// if we distroy the component here then system throw an error: childnode null
				// TODO: find the rout issue and desctroy the componet here.  
				//component.get("v.currentComponent")[0].destroy();
            }
            
            helper.wizardNavigation(component, event, helper, navigateToStep, rfq);
        }
	},
	
	recordUpdated : function(component, event, helper) {

	    var changeType = event.getParams().changeType;
	
	    if (changeType === "ERROR") { /* handle error; do this first! */ }
	    else if (changeType === "LOADED") { /* handle record load */ }
	    else if (changeType === "REMOVED") { /* handle record removal */ }
	    else if (changeType === "CHANGED") { 
	      /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
	      console.log('---reloadRecord---');
	      component.find("recordEditor").reloadRecord();
	      console.log('---reloadRecord--after---');
	     
        }
    }
})