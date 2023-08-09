/* Lightning Component Controller.
 * Copyright 2018-2019, Riskonnect Inc.
 * All rights reserved
 *
 * Created by - Sagar Thoriya
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert */
({
	/* init handler method */
	init : function(component, event, helper) {
		
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		if(component.get("v.sectionId")) {
			// Get all the related section's question group details 
			var action = component.get("c.retrieveControls"), refreshTreeNode = $A.get("e.c:BT_RefreshTreeNodeEvent"), questionGroupLoaded = component.set("v.questionGroupLoaded");
	        action.setParams({ "citationId" : component.get("v.sectionId") });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
                    console.log('Response::',JSON.stringify(response.getReturnValue()));
					console.log('response of controls>>>',response.getReturnValue().controls);
	               // Assigned value to component attributes
	               component.set("v.questionGroupByParentId",response.getReturnValue().controlByParentId);
	               component.set("v.questionGroups",response.getReturnValue().controls);
	               component.set("v.headerFields",response.getReturnValue().controlHeaderFields);
	               component.set("v.questionGroupListSize",response.getReturnValue().controls.length);
	               
	               if(response.getReturnValue().controls.length === 0) {
	            	   component.set("v.questionGroupLoaded", true);
		           }
	            }
	        });
            
            if(refreshTreeNode){
		        refreshTreeNode.setParams({"key" : component.get("v.sectionId")});
		        refreshTreeNode.fire();
	        }
	        
	        $A.enqueueAction(action);
        } else {
        	var questionGroupByParentId = new Map();
            questionGroupByParentId = component.get("v.questionGroupByParentId");
            var parentId = component.get("v.parentId");
			
            // Get all the child section from map
            if(questionGroupByParentId && questionGroupByParentId[parentId]){
                component.set("v.questionGroups",questionGroupByParentId[parentId]);
                component.set("v.questionGroupListSize",questionGroupByParentId[parentId].length);
            }
        }
	},
	
	/*This method will call after question Group list loaded through aura itration*/
	questionGroupLoaded : function(component, event, helper) {
		if(component.get("v.questionGroupLoaded") && component.get("v.sectionId")) {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        }
	}
})