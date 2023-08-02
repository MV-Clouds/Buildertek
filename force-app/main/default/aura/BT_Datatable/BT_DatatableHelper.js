({
    getGidDataRecords: function (component, event, helper, objectName, filterConditions, fieldSetName, callback) {
		var recordData, columnHeaders, columnModels, actionsessionId, actionGetColumnHeaders, actionGetColumnModels, actionRecordData, state;

        //Prepare actoin to retrive column header Json
        actionGetColumnHeaders = component.get("c.getFieldSet");
        actionGetColumnHeaders.setParams({ objectName: objectName, FieldSetName: fieldSetName});
        actionGetColumnHeaders.setStorable({ignoreExisting: true});
        
        actionGetColumnHeaders.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	var fieldset = response.getReturnValue();
            	var columns = [], column = {};
            	
            	for(var i in fieldset){
            		column = {};
            		column.label = fieldset[i].fLabel;
            		column.fieldName = fieldset[i].fAPIName;
            		column.type = fieldset[i].fType.toLowerCase();
            		
            		if(column.type === 'double' || column.type === 'integer'){
            			column.type = 'number';
            		}
            		
            		columns.push(column);
            	}
            	column = {};
        		column.type = 'action';
        		column.typeAttributes = {};
        		column.typeAttributes.rowActions =  helper.getRowActions.bind(this, component);
        		columns.push(column);
        		
            	console.log('---columns---',columns);
                component.set("v.columns", columns);
            }
        });
        
        //Prepare actoin to retrive data Json
        actionRecordData = component.get("c.recordData");
        actionRecordData.setParams({
            objectName: objectName,
            filterConditions: filterConditions,
            fieldSetAPI: fieldSetName,
            parentId: component.get("v.parentId")
        });
        
        actionRecordData.setStorable({ignoreExisting: true});
        
        actionRecordData.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                if(response.getReturnValue() != [] && response.getReturnValue() != '[]'){
            		component.set("v.data", JSON.parse(response.getReturnValue()));
            		console.log("data--->",JSON.parse(response.getReturnValue()));
                } else {
                	component.set("v.data", {});
                }
                
                /*
                var groupdata = helper.groupBy(JSON.parse(response.getReturnValue()), data => data.buildertek__Group_Name__c);
                console.log(groupdata.keys());
                */
                
                callback();
            }
        });
        
        //enqueue GetColumnHeaders method
        $A.enqueueAction(actionGetColumnHeaders);
    	$A.enqueueAction(actionRecordData);
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
    
    groupBy: function (list, keyGetter) {
	    const map = new Map();
	    list.forEach((item) => {
	        const key = keyGetter(item);
	        const collection = map.get(key);
	        if (!collection) {
	            map.set(key, [item]);
	        } else {
	            collection.push(item);
	        }
	    });
	    return map;
	}
})