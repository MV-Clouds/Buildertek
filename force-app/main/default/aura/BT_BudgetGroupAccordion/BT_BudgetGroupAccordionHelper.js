({
	
	updateData: function(component, event, helper, dataToUpdate){
			var groupId = component.get("v.group").Id;
            var action = component.get("c.updateBudgetLinFromDataTable");
            action.setParams({ budgetItems : dataToUpdate, groupId:groupId, budgetId : component.get("v.budgetId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if (state === "SUCCESS") {
                    component.set("v.group",response.getReturnValue());
                    component.set("v.lines",response.getReturnValue().buildertek__Budget_Items__r);
                    
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
            'label': 'Delete Label',
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
        var action = component.get("c.deleteBudgetItem");
        action.setParams({budgetItems : lines, groupId:groupId, budgetId: component.get("v.budgetId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            if (state === "SUCCESS") {
                component.set("v.group",response.getReturnValue());
                if(response.getReturnValue().buildertek__Budget_Items__r){
                	component.set("v.lines",response.getReturnValue().buildertek__Budget_Items__r);
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
    	//alert(''+JSON.stringify(lines));
		var columns = component.get("v.columns");
		//alert(''+JSON.stringify(columns));
		console.log(JSON.stringify(columns));
		if(lines != undefined){
		    for(var i in columns){
			
			if(columns[i].type === 'currency') {
				if(lines != undefined && lines.length > 0){
					//summary.total = lines.btsum(columns[i].fieldName);
					columns[i].total = lines.reduce(function (a, b) {return b[columns[i].fieldName] == null ? a : a + b[columns[i].fieldName];}, 0.00);
				} else {
					columns[i].total = 0.00;
				}
				//alert(lines.length);
				/*if(lines != undefined){
    				if(lines.length == 1){
    				    $(".slds-dropdown-trigger_click.slds-is-open .slds-dropdown").addClass('firstChild');
    				}
				}*/
			}
		}
		}
		console.log('---summaryColumns---->',columns);
		component.set("v.summaryColumns",columns);
		//alert('Columns length ----------> '+columns.length); 
		component.set("v.buttonWidth", buttonWidth);
		var columnsLength = (100/columns.length) + 0.6; 
		var firstColumnWidth = columnsLength + (columnsLength/10);
		var widthOfColumn = (columnsLength*1.1) + (columnsLength/2);
		var buttonWidth;
		var btTableColumnsLength;
		if(columns.length == 13){
		    widthOfColumn = widthOfColumn + 1.5;    
		}else if(columns.length == 12){
		    widthOfColumn = widthOfColumn + 1;    
		}else if(columns.length == 11){
		    widthOfColumn = widthOfColumn + 0.5;    
		}
		else if(columns.length == 10){
		    widthOfColumn = widthOfColumn;    
		}else if(columns.length == 9){
		    widthOfColumn = widthOfColumn - 1;       
		}else if(columns.length == 8){
		    widthOfColumn = widthOfColumn - 2;           
		}else if(columns.length == 7){
		    widthOfColumn = widthOfColumn - 3;          
		}
		var fontSize;
		var a = window.matchMedia("(max-width: 1980px) and (min-width: 1780px)");
		var x = window.matchMedia("(max-width: 1779px) and (min-width: 1580px)");
		var y = window.matchMedia("(max-width: 1579px) and (min-width: 1370px)");
		var z = window.matchMedia("(max-width: 1366px) and (min-width: 1280px)");
		var b = window.matchMedia("(max-width: 1279px) and (min-width: 1180px)");
		var c = window.matchMedia("(max-width: 1179px) and (min-width: 1080px)");
		if(x.matches){
		    //alert('x --------> '+x);
		    widthOfColumn = widthOfColumn - 1.46;  
		    btTableColumnsLength = columnsLength - 0.45;
		    component.set("v.IsDesktop", true);
		    component.set("v.IsMobile", false);
		}
		if(y.matches){
		    //alert('y --------> '+y); 
		    widthOfColumn = widthOfColumn - 1;
		    btTableColumnsLength = columnsLength - 0.5;
		    component.set("v.IsDesktop", true);
		    component.set("v.IsMobile", false);
		    //buttonWidth = 10.4;
		}
		if(z.matches){
		    //alert('z --------> '+z); 
		    widthOfColumn = widthOfColumn - 0.5;
		    btTableColumnsLength = columnsLength - 0.45;
		    component.set("v.IsDesktop", true);
		    component.set("v.IsMobile", false);
		    //buttonWidth = 10.4;
		}
		if(a.matches){
		    //alert('a --------> '+a); 
		    widthOfColumn = widthOfColumn - 2;
		    btTableColumnsLength = columnsLength - 0.45;
		    component.set("v.IsDesktop", true);
		    component.set("v.IsMobile", false);
		    //buttonWidth = 10.4;
		}
		if(b.matches){
		    //alert('b --------> '+b); 
		    widthOfColumn = widthOfColumn + 0.5;
		    btTableColumnsLength = columnsLength - 0.45;
		    fontSize = 13;
		    component.set("v.IsDesktop", false);
		    component.set("v.IsMobile", true);
		    component.set("v.fontSize", fontSize);
		    //buttonWidth = 10.4;
		}
		if(c.matches){
		    //alert('c --------> '+c); 
		    widthOfColumn = widthOfColumn + 1;
		    btTableColumnsLength = columnsLength - 0.45;
		    fontSize = 13;
		    component.set("v.IsDesktop", false);
		    component.set("v.IsMobile", true);
		    component.set("v.fontSize", fontSize);
		    //buttonWidth = 10.4;
		}
		/*alert('Final columnsLength -------> '+columnsLength);
		alert('Final firstColumnLength -------> '+widthOfColumn);
		alert('Final firstColumnWidth -------> '+firstColumnWidth);*/
		component.set("v.columnsLength", columnsLength);
		component.set("v.firstColumnWidth", firstColumnWidth);
		component.set("v.firstColumnLength", widthOfColumn);
		component.set("v.buttonWidth", buttonWidth);
		component.set("v.btTableColumnsLength", btTableColumnsLength);
    },
    
    fetchPickListVal: function(component, event,helper) {
    	var actions = component.get("c.getselectOptions");
    	actions.setParams({
    		"BudgetObject": component.get("v.objInfo"),
    		"BudgetField": "buildertek__UOM__c"
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