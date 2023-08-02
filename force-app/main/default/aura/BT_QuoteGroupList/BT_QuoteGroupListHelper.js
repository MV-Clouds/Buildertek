({
	getGroups : function(component, event, helper) {
		component.set("v.groupLoaded", false);
		var dummyData = [], dummy = {};
		dummyData.push(dummy);
		component.set("v.dummyData", dummyData);
		
		
        if(component.get("v.quoteId")) {
        	// set the attribute to default value.
        	component.set("v.groupLoaded", false);
        	component.set("v.groupListSize", 0);
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveGroups");
            action.setParams({ quoteId : component.get("v.quoteId"), groupId : null });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert('Groups ------------> '+JSON.stringify(response.getReturnValue().groups));
                    //alert('Columns ------------> '+JSON.stringify(response.getReturnValue().columns));
                	// Assigned the component attribute values
                    component.set("v.groups",response.getReturnValue().groups);
                    component.set("v.groupListSize",response.getReturnValue().groups.length);
                    component.set("v.headerFields",response.getReturnValue().headerFields);
                    
                    var column = {}, columns = response.getReturnValue().columns;
					column.type = 'action';
					column.typeAttributes = {minimumFractionDigits : '2'};
					column.typeAttributes.rowActions =  helper.getRowActions.bind(this, component);
					columns.push(column);
			        component.set("v.columns", columns);
			        
                    if(response.getReturnValue().groups.length === 0) {
                    	component.set("v.groupLoaded", true);
                    }
                }
            });
            $A.enqueueAction(action);
        }
	},
	getRowActions: function (cmp, row, doneCallback) {
		var actions = [];
        var actions = [{
            'label': 'Edit',
            'iconName': 'utility:edit',
            'name': 'edit'
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
         // get an Price from 
    getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            var getProductDetails = component.get("v.newQuote");
            delete getProductDetails.buildertek__Grouping__r;
            getProductDetails.buildertek__Quote__c = component.get("v.quoteId");
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Cost__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Cost__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newQuote",getProductDetails);
        });
        $A.enqueueAction(action);
    },
    
    fetchPickListVal: function(component, event,helper) {
    	var actions = component.get("c.getselectOptions");
    	actions.setParams({
    		"QuoteObject": component.get("v.newQuote"),
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