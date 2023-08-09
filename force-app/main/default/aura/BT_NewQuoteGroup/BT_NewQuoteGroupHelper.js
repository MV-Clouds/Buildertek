({
	getGrouopFieldSet : function(component, event, helper) {
		var fieldsetName, recordTypeDeveloperName;
        fieldsetName = 'buildertek__Quote_Line_Group_Fields';

        var getObjectFieldSet = component.get("c.getFieldSet");
        getObjectFieldSet.setParams({
            fieldSetName: fieldsetName,
            objectName: "buildertek__Quote_Line_Group__c"
        });

        getObjectFieldSet.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.groupFields", response.getReturnValue());
            }
        });
        $A.enqueueAction(getObjectFieldSet);
	},
	
	 validateInputFields: function(component, event, helper) {
        var inputFieldValue, inputFields, isValid, fieldName, fValue, fClass, inputErrorMessage;
        inputFields = component.find("inputFields");
        inputErrorMessage = component.find('inputErrorMessage');
        isValid = true;
        for (var i in inputFields) {
            fieldName = inputFields[i].get("v.fieldName");
            fValue = inputFields[i].get("v.value");
            fClass = inputFields[i].get("v.class");

            if (($A.util.hasClass(inputFields[i], 'customvalidation')) &&
                ($A.util.isUndefinedOrNull(fValue) || $A.util.isEmpty(fValue))) {
                $A.util.removeClass(inputErrorMessage[i], 'slds-hide');
                $A.util.addClass(inputFields[i], 'slds-has-error');
                isValid = false;
            } else if (!$A.util.hasClass(inputErrorMessage[i], 'slds-hide')) {
                $A.util.addClass(inputErrorMessage[i], 'slds-hide');
                $A.util.removeClass(inputFields[i], 'slds-has-error');
            }
        }
        return isValid;
    },
    
    addSelectedProducts : function(component, event, helper, items) {
        var action;
        action = component.get("c.createQuoteItem");
        action.setParams({
            quoteItemsJSON: JSON.stringify(items)
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                
		        toastEvent.setParams({
		            message: component.get("v.groupId") ?"Quote Group Updated Successfully": "New Quote Group Added Successfully.",
		            type: 'Success',
		        });
		        toastEvent.fire();
		        component.set("v.lines",[]);
		        var onSuccess = component.get("v.onSuccess");
		        if (!$A.util.isUndefinedOrNull(onSuccess)) {
		            onSuccess();
		        } 
		        
		        helper.closePopup(component);
		        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                console.log(response.getError()[0].message);
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message":  response.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
	
	updateData: function(component, event, helper, dataToUpdate){
			var groupId = component.get("v.group").Id;
			var quoteId =  component.get("v.quoteId");
            var action = component.get("c.updateLineFromDataTable");
            action.setParams({ items : dataToUpdate, groupId : groupId, quoteId : quoteId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if (state === "SUCCESS") {
                    component.set("v.group",response.getReturnValue());
                    component.set("v.lines",response.getReturnValue().buildertek__BT_Quote_Items__r);
                    
                    if(component.find("lineTable")){
                    	component.find("lineTable").set("v.draftValues", null);
                    }
                    
                     helper.getSummary(component, event, helper);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                }
            });
            $A.enqueueAction(action);
	},
	
	getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Edit',
            'iconName': 'utility:edit',
            'name': 'edit_details'
        }];
        var deleteAction = {
            'label': 'Delete',
            'iconName': 'utility:delete',
            'name': 'delete'
        };
        
        /*
        if (row['isPublished']) {
            actions.push({
                'label': 'Unpublish',
                'iconName': 'utility:ban',
                'name': 'unpublish'
            });
            deleteAction['disabled'] = 'true';
        } else {
            actions.push({
                'label': 'Publish',
                'iconName': 'utility:approval',
                'name': 'publish'
            });
        }
		*/

        actions.push(deleteAction);

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    
    deleteLine:function(component, event, helper, row){
    	var groupId = component.get("v.group").Id;
    	var lines = []; lines.push(row);
        var action = component.get("c.deleteItem");
        action.setParams({ Items : lines, groupId:groupId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            if (state === "SUCCESS") {
                component.set("v.group",response.getReturnValue());
                if(response.getReturnValue().buildertek__BT_Quote_Items__r){
                	component.set("v.lines",response.getReturnValue().buildertek__BT_Quote_Items__r);
                } else {
                	component.set("v.lines",[]);
                }
                 helper.getSummary(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSummary: function(component, event, helper){
    	var lines = component.get("v.lines");
    	//('lines2 ------> '+JSON.stringify(lines));
    	var percent='';
    	var Markup='';
    	var discount='';
    	var margin='';
    	for(var j=0;j<lines.length;j++){
    	    percent = lines[j].buildertek__Discount__c +'%';
    	    lines[j].buildertek__Discount__c = percent;
    	    if(lines[j].buildertek__Discount__c == undefined){
    	        lines[j].buildertek__Discount__c = '0';    
    	    }
    	    
    	    if(lines[j].buildertek__Markup__c == undefined){
    	        ines[j].buildertek__Markup__c =  '0';
    	    }
    	    else{
    	        Markup = lines[j].buildertek__Markup__c +'%';
    	        lines[j].buildertek__Markup__c = Markup;
    	    }
    	    
    	    if(lines[j].buildertek__MFG_Discount__c == undefined){
    	        lines[j].buildertek__MFG_Discount__c = '0';
    	    }
    	    else{
    	        discount = lines[j].buildertek__MFG_Discount__c +'%';
    	        lines[j].buildertek__MFG_Discount__c = discount;
    	    }
    	    if(lines[j].buildertek__MFG_Discount__c == undefined){
    	        lines[j].buildertek__Profit_Margin__c = '0';
    	    }
    	    else{
    	        margin = lines[j].buildertek__Profit_Margin__c +'%';
    	        lines[j].buildertek__Profit_Margin__c = margin;
    	    }
    	    
        }
    	
    	component.set("v.lines", lines);
		var columns = component.get("v.columns");
		console.log(JSON.stringify(columns));
		for(var i in columns){
			if(columns[i].type === 'currency') {
				if(lines != undefined && lines.length > 0){
					//summary.total = lines.btsum(columns[i].fieldName);
					columns[i].total = lines.reduce(function (a, b) {return b[columns[i].fieldName] == null ? a : a + b[columns[i].fieldName];}, 0.00);
				} else {
					columns[i].total = 0.00;
				}
				 
				// if(lines != undefined){
    // 				if(lines.length == 1){
    // 				  //  $(".slds-dropdown-trigger_click.slds-is-open .slds-dropdown").addClass('firstChild');
    // 				}
				// }
			}
		}
		console.log('---summaryColumns---->',columns);
		component.set("v.summaryColumns",columns);
		var liness = component.get("v.lines");

    },
    
    fetchPickListVal: function(component, event,helper) {
    	var actions = component.get("c.getselectOptions");
    	actions.setParams({
    		"QuoteObject": component.get("v.objInfo"),
    		"QuoteField": "buildertek__UOM__c"
    	});
    	var opts = [];
    	actions.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    			var allBudgetValues = JSON.parse(response.getReturnValue());
    			if (allBudgetValues != undefined && allBudgetValues.length > 0) {
    				opts.push({
    					class: "optionClass",
    					label: "--- None ---",
    					value: ""
    				});
    			}
    			for (var i = 0; i < allBudgetValues.length; i++) {
    				opts.push({
    					class: "optionClass",
    					label: allBudgetValues[i].Id,
    					value: allBudgetValues[i].Id
    				});
    				
    			}
    			//component.find(elementId).set("v.options", opts);
    			component.set("v.options", opts);
    		}
    	});
    	$A.enqueueAction(actions);
    },
    
    closePopup : function(component) {
		component.find("overlayLib").notifyClose();
	},
	
	closeModalPop : function(component) {
		component.get('v.modalPromise').then(function (modal) {
            modal.close();
        });
	},
	
	deleteGroup: function(component, event, helper, dataToDelete){
			
            var action = component.get("c.deleteGroups");
            action.setParams({ groups : dataToDelete});
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
			        toastEvent.setParams({
			            message: "Quote Group Deleted Successfully",
			            type: 'Success',
			        });
			        toastEvent.fire();
			        
			        var onDelete = component.get("v.onDelete");
			        if (!$A.util.isUndefinedOrNull(onDelete)) {
			            onDelete();
			        }
			        helper.closePopup(component);
                }
            });
            $A.enqueueAction(action);
	},
})