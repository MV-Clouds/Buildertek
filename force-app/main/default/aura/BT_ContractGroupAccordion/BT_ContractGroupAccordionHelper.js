({
	
	updateData: function(component, event, helper, dataToUpdate){
			var groupId = component.get("v.group").Id;
            var action = component.get("c.updateLineFromDataTable");
            action.setParams({ items : dataToUpdate, groupId:groupId, contractId : component.get("v.contractId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                if (state === "SUCCESS") {
                    component.set("v.group",response.getReturnValue());
                    component.set("v.lines",response.getReturnValue().buildertek__Contract_Lines__r);
                    
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
    	var lines = []; lines.push(row);
        var action = component.get("c.deleteItem");
        action.setParams({Items : lines, groupId:groupId, contractId:component.get("v.contractId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            if (state === "SUCCESS") {
                component.set("v.group",response.getReturnValue());
                if(response.getReturnValue().buildertek__Contract_Lines__r){
                	component.set("v.lines",response.getReturnValue().buildertek__Contract_Lines__r);
                } else {
                	component.set("v.lines","[]");
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
				//alert(lines.length);
				/*if(lines != undefined){
    				if(lines.length == 1){
    				    $(".slds-dropdown-trigger_click.slds-is-open .slds-dropdown").addClass('firstChild');
    				}
				}*/
			}
		}
		component.set("v.summaryColumns",columns);
    },
    
})