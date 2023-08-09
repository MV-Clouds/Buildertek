({
	
	updateData: function(component, event, helper, dataToUpdate){
			var groupId = component.get("v.group").Id;
            var action = component.get("c.updateLineFromDataTable");
            action.setParams({ items : dataToUpdate, groupId:groupId, quoteId : component.get("v.quoteId")});
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
                    $A.get('e.force:refreshView').fire();
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
    	var quoteId = component.get("v.quoteId");
    	var lines = []; lines.push(row);
        var action = component.get("c.deleteItem");
        action.setParams({ Items : lines, groupId : groupId, quoteId : quoteId});
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
                 window.setTimeout(
                    $A.getCallback(function() {
                        $A.get('e.force:refreshView').fire();
                    }), 2000
                );
            }
        });
        $A.enqueueAction(action);
    },
    
    getSummary: function(component, event, helper){
        
    	var lines = component.get("v.lines");
    	//alert('lines2 ------> '+JSON.stringify(lines)); 
    	var percent='';
    	var Markup='';
    	var discount='';
    	var margin='';
    	var Additional = '';
    	if(lines != undefined){
    	    for(var j=0;j<lines.length;j++){
    	    //alert(lines[j].buildertek__Discount__c);
        	    if(lines[j].buildertek__Discount__c == undefined){
        	        
        	        lines[j].buildertek__Discount__c = '0%';    
        	    }
        	    else{
        	        percent = lines[j].buildertek__Discount__c +'%';
        	        lines[j].buildertek__Discount__c = percent;
        	    }
        	    
        	    if(lines[j].buildertek__Markup__c == undefined){
        	        lines[j].buildertek__Markup__c =  '0%';
        	    }
        	    else{
        	        Markup = lines[j].buildertek__Markup__c +'%';
        	        lines[j].buildertek__Markup__c = Markup;
        	    }
        	    
        	    if(lines[j].buildertek__MFG_Discount__c == undefined){
        	        lines[j].buildertek__MFG_Discount__c = '0%';
        	    }
        	    else{
        	        discount = lines[j].buildertek__MFG_Discount__c +'%';
        	        lines[j].buildertek__MFG_Discount__c = discount;
        	    }
        	    if(lines[j].buildertek__Profit_Margin__c == undefined){
        	        lines[j].buildertek__Profit_Margin__c = '0%';
        	    }
        	    else{
        	        margin = lines[j].buildertek__Profit_Margin__c +'%';
        	        lines[j].buildertek__Profit_Margin__c = margin;
        	    }
        	    //alert(lines[j].buildertek__Additional_Discount__c);
        	    if(lines[j].buildertek__Additional_Discount__c  != undefined){
        	        Additional = lines[j].buildertek__Additional_Discount__c + '%';
        	        lines[j].buildertek__Additional_Discount__c = Additional;
        	    }
        	    else{
        	        lines[j].buildertek__Additional_Discount__c = '0%';
        	    }
        	    
        	    
        	    
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
				 
				/*if(lines != undefined){
     				if(lines.length == 1){
     				    $(".slds-dropdown-trigger_click.slds-is-open .slds-dropdown").addClass('firstChild');
   				}
				}*/
			}
		}
		//alert('summaryColumns ----> '+columns);
		console.log('---summaryColumns---->'+JSON.stringify(columns));
		component.set("v.summaryColumns",columns);
		var liness = component.get("v.lines");
		 //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire(); 
		/*window.setTimeout($A.getCallback(function() {
	        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire(); 
	    }), 500);*/
		 

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
})