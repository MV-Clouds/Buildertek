({
	getBudgetGroups : function(component, event, helper) {
		component.set("v.groupLoaded", true);
		var dummyData = [], dummy = {};
		dummyData.push(dummy);
		component.set("v.dummyData", dummyData);
		
        if(component.get("v.budgetId")) {
        
        	// set the attribute to default value.
        	component.set("v.groupLoaded", false);
        	component.set("v.groupListSize", 0);
        	
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveGroups"),groupLoaded =  component.get("v.groupLoaded");
            action.setParams({ budgetId : component.get("v.budgetId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                
                	// Assigned the component attribute values
                	component.set("v.headerFields",response.getReturnValue().headerFields);
                    component.set("v.groups",response.getReturnValue().groups);
                    component.set("v.groupListSize",response.getReturnValue().groups.length);
                    
                    var actions = helper.getRowActions.bind(this, component); 
                    var column = {}, columns = response.getReturnValue().columns;
					column.type = 'action';
					column.typeAttributes = { rowActions: actions };
					//column.typeAttributes.rowActions =  helper.getRowActions.bind(this, component);
					columns.push(column);
			        component.set("v.columns", columns);
			        //alert(''+JSON.stringify(component.get("v.columns")));
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
        
        
        /*if (row['isPublished']) {
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
        }*/
		

        actions.push(deleteAction);

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        console.log("----productId",productId);
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            console.log("----respo---",res.length);
            var getProductDetails = component.get("v.newBudgetLine");
            delete getProductDetails.buildertek__Grouping__r;
            console.log("@Budgetline@",component.get("v.budgetId"));
            getProductDetails.buildertek__Budget__c = component.get("v.budgetId");
            console.log("getprodct----",JSON.stringify(getProductDetails));
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newBudgetLine",getProductDetails);
            
            console.log("getprodct----",JSON.stringify(getProductDetails));
            
            console.log("----log",res);
        });
        $A.enqueueAction(action);
    },
    
    updateBooks: function (cmp) {
        var rows = cmp.get('v.rawData');
        var activeFilter = cmp.get('v.activeFilter');
        //alert('activeFilter --> '+activeFilter);
        var filteredRows = rows;

        if (activeFilter !== 'all') {
            filteredRows = rows.filter(function (row) {
                return (activeFilter === 'show_published' && row['isPublished']) ||
                    (activeFilter === 'show_unpublished' && !row['isPublished']);
            });
        }

        cmp.set('v.dummyData', filteredRows);
    },
})