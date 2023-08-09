/* Lightning Component Controller.
 * Copyright 2018-2019, @ thoriyas.
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

	/*This method will call after section list loaded through aura itration*/
    sectionLoaded: function(component, event, helper) {
        if(component.get("v.sectionLoaded") && component.get("v.adId")) {
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        } 
    },
    
    
    /*component init method, In this method get all the related section and it's details*/
	init : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		
        if(component.get("v.adId")) {
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveCitations"),refreshTreeNode = $A.get("e.c:BT_RefreshTreeNodeEvent"),sectionLoaded =  component.get("v.sectionLoaded");
            action.setParams({ adId : component.get("v.adId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Response Section List::',response.getReturnValue().citations);
                	// Assigned the component attribute values
                    component.set("v.sectionByParentId",response.getReturnValue().citationByParentId);
                    component.set("v.sections",response.getReturnValue().citations);
                    component.set("v.sectionListSize",response.getReturnValue().citations.length);
                    component.set("v.headerFields",response.getReturnValue().sectionHeaderFields);
                    
                    if(response.getReturnValue().citations.length === 0) {
                    	component.set("v.sectionLoaded", true);
                    }
                }
            });
            if(refreshTreeNode && sectionLoaded === true){
		        refreshTreeNode.setParams({"key" : "ALL_TREE"});
		        refreshTreeNode.fire();
	        }
            $A.enqueueAction(action);
        } else {
            var sectionByParentId = new Map();
            sectionByParentId = component.get("v.sectionByParentId");
            var parentId = component.get("v.parentId");
            
            // Get all the child section from map
            if(sectionByParentId && sectionByParentId[parentId]){
                component.set("v.sections",sectionByParentId[parentId]);
                component.set("v.sectionListSize",sectionByParentId[parentId].length);
            }
        }
        
	},
	
	/* This method will display the new section component to create section record*/
	openNewSectionComponent : function(component, event, helper) {
        var sectionRecordType = component.get("v.recordTypeDeveloperName");
      	var adId = component.get("v.adId");
        var sectionModalHeader;
        
       console.log('Event Called');
       sectionModalHeader = "New Selection Category Details";
        
      
        $A.createComponents(
            [["aura:html", {
                    "tag": "h2",
                    "body": sectionModalHeader,
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewSection", {
                	"adId" : adId,
                    "onSuccess" : function(object) {
                       var initReference = component.get('v.initReference');
                       $A.enqueueAction(initReference);
                    }
                }],
            ], function(components, status) {
				if (status === 'SUCCESS') {
					component.find('overlayLib').showCustomModal({
					    header: components[0],
					    body: components[1],
					    footer:components[1].find("footer") ,
					    showCloseButton: true,
					    cssClass: 'uiModal--medium'
				    });
				}
        });
    },
    openNewSectionModal : function(component, event, helper) {
             console.log(':::Re Init:::');
    },
    // This function is used to add new child section into the list
    initChild: function(component, event, helper) {
    	
    	// get section by parent id map
    	var sectionByParentId = new Map();
        sectionByParentId = component.get("v.sectionByParentId");
        
        // get new child section
        var newsection = JSON.parse(component.get("v.newSection"));
        var parentId = newsection.Parent__c;
        
        // Get all the child section from map
    	var childSections = sectionByParentId[parentId];
    	
    	if(childSections) {
    		childSections.push(newsection);
    	} else {
    		childSections = [];
    		childSections.push(newsection);
    	}
    	
    	sectionByParentId[parentId] = childSections;
    	component.set("v.sectionByParentId",sectionByParentId);
    	
    	// Append new child section to section list.
    	if(component.find("childsectionlist").length) {
	    	component.find("childsectionlist")[newsection.index].set("v.sections",childSections);
	    	component.find("childsectionlist")[newsection.index].set("v.sectionListSize",childSections.length);
    	} else {
	    	component.find("childsectionlist").set("v.sections",childSections);
	    	component.find("childsectionlist").set("v.sectionListSize",childSections.length);
    	}
       
    	// Save the section hierarchy
         window.setTimeout($A.getCallback(function() {
           $A.enqueueAction(component.get("v.save"));
        }),100);
        
    },
    
    
})