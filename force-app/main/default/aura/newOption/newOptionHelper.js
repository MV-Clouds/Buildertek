({
	changeSelectionType:function(component, event, helper) {
		console.log('change selection type');
		let getValue= event.getSource().get('v.value');
		var temp = getValue;
		console.log('check name --> ',temp[0]);
		component.set('v.selectionTypeId', temp[0]);

        var action = component.get("c.getBudget");
        action.setParams({
            seleTypeId:temp[0]
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log(response.getError());
            console.log({state});
            var result= response.getReturnValue();
            if (state === "SUCCESS") {

                console.log({result});
                component.set('v.selectedLookUpRecord' ,result);
                component.set('v.selectedtRecord' ,result);

				
            }
        });
        $A.enqueueAction(action);
		
     },
	 getAlBudget:function(component, event, helper) {
		var action = component.get("c.getAllBudget1");
		action.setCallback(this, function(response) {
			var state = response.getState();
			console.log({state});
			var result= response.getReturnValue();
			console.log('Budgert ==>',result);
			if (state === "SUCCESS") {


				component.set('v.budgetList' , result);
				result.forEach(function(value, index){
					console.log({value});
					component.set('v.projectValue' , value.buildertek__Project__c);
				})
				
			}
		});
		$A.enqueueAction(action);
	 },
	getOnlyBudget:function(component, event, helper , selectionTypeId) {
	var action = component.get("c.getBudget");
	action.setParams({
		seleTypeId:selectionTypeId
	});
	action.setCallback(this, function(response) {
		var state = response.getState();
		console.log(response.getError());
		console.log({state});
		var result= response.getReturnValue();
		if (state === "SUCCESS") {

			console.log({result});
			component.set('v.budgetList' ,result);
			result.forEach(function(value, index){
				console.log({value});
				component.set('v.projectValue' , value.buildertek__Project__c);
			})
			
		}
	});
	$A.enqueueAction(action);
	},
	getAllBudgetLine:function(component, event, helper , selectedBudgetId , BudgetValue) {
	console.log('getAllBudgetLine');
	var action = component.get("c.getBudgetLine");
	action.setParams({
		BudgetId:selectedBudgetId
	});
	action.setCallback(this, function(response) {
		var state = response.getState();
		console.log({state});
		var result= response.getReturnValue();
		if (state === "SUCCESS") {
			console.log({result});

			if(BudgetValue != ''){
				console.log('no null');
				component.set('v.budgetLineList' ,result);

			}else{
				component.set('v.budgetLineList' , []);

			}
		}
	});
	$A.enqueueAction(action);
	}

})