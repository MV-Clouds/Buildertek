/* Lightning Component Helper.
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
	createQuestionGroupDetails : function(component, event, helper, sectionId) {
	    var elem = document.getElementById('accordion'+component.getGlobalId());  
        // Dynamically create component to show section details with question group list 
        // 
        console.log('headerFields :: '+JSON.stringify(component.get("v.headerFields")));
        var headerFields = component.get("v.headerFields");
        var headerFieldsNew = [];
        var instructionsField ="buildertek__Instructions__c";
        for(var i=0;i<headerFields.length;i++){
            if(headerFields[i]!=instructionsField){
                headerFieldsNew.push(headerFields[i]);
            }
            if(headerFieldsNew.length>5&&headerFields.includes(instructionsField)){
                headerFieldsNew.push(instructionsField);
            }
        }
        if(headerFieldsNew.length<5&&headerFields.includes(instructionsField)){
             headerFieldsNew.push(instructionsField);
        }
        
	    $A.createComponents([
	        ["lightning:recordForm",{
	            "objectApiName" : "buildertek__Section__c",
	            "recordId" : sectionId,
                "columns":"3",
                "fields":headerFieldsNew 
	        }],
	        ["c:BT_QuestionGroupList",{
	            "sectionId":sectionId,
                "selectionId":component.get('v.selectionId'),
	            "section": component.get("v.section"),
                "callerName": component.get("v.callerName")
	        }]
	        
	    ],function(components, status, errorMessage){
            if (status === "SUCCESS") { 
                var recordViewForm = components[0];
                component.set("v.recordViewForm",recordViewForm);
                component.set("v.questionGroupDetails",components[1]);
                var index = component.get("v.index");
                $('#'+sectionId+'nestableQuestionGroups').nestable({ listNodeName:'ul', maxDepth:1, handleClass:'av-control-handle', itemClass:'av-questionGroup',
                                                                    listClass:'av-list', threshold:15, group:1+index  }).on('change', function(e) {
                    var list   = e.length ? e : $(e.target);
                    helper.setSortIds(component, event, helper, list.nestable('serialize'));
                    
                });
	            
	        }
	    });
	    
	    elem.classList.add('slds-is-open'); 
	    elem.classList.remove('slds-is-close');
	    component.set("v.icone","dash"); 
	},
	
	setSortIds : function(component, event, helper, questionGroups) {
		//$A.get("e.buildertek:avSpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var updatedQuestionGroups = [];
		updatedQuestionGroups = helper.convert(questionGroups, updatedQuestionGroups, 1, '', '', 0, false);
		
		var action = component.get("c.updateControlOrder");
            action.setParams({ controls : updatedQuestionGroups });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                   var refreshTreeNode = $A.get("e.c:BT_RefreshTreeNodeEvent");
                   refreshTreeNode.setParams({"key" : component.get("v.section").Id});
                   refreshTreeNode.fire();
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
	},
	// Convert JSON object to sObject List
	convert:function(questionGroups, updatedQuestionGroups, level, parentID, parentSortId, hierarchyLevel, isChildren) {
		
		var item, key, accordion, sortid, sortvalue;
		for( key in questionGroups) {
		    if( !questionGroups.hasOwnProperty(key) ) continue;
		    item = questionGroups[key];
		    sortvalue =  this.sortIdFormat(level, 3).trim();
		    level++;
		    
		    sortid =  parentSortId+' '+sortvalue;
		    
		    if(typeof item.children !== 'object' && !isChildren){
		    	hierarchyLevel = 0;
		    }
		    
		    accordion = { Id: item.id, 
		    			  Sort_Id__c:sortid.trim(),
		    			  Sort_Value__c:sortvalue,
		    			  Hierarchy_Level__c:hierarchyLevel,
		    			  Parent__c:parentID
		    			};
		    updatedQuestionGroups.push(accordion);
		    
		    if( typeof item.children === 'object' ) {
		    	isChildren = true;
		    	hierarchyLevel ++;
				this.convert(item.children, updatedQuestionGroups, 1, item.id, sortid, hierarchyLevel, isChildren);
				hierarchyLevel --;
		    }
		}
		
		return updatedQuestionGroups;
	},
	
	sortIdFormat: function(number, width) {
	
		width -= number.toString().length;
        if(width > 0) {
            return ' ' + new Array(width + (/\./.test(number) ? 2 : 1)).join('0') + number;
        }
        return ' ' + number;
	}
})