({
    getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},
	getAllBudgetLine:function (component, event, helper){
		var BudgetLineList = component.get("c.getBudgetList");
		BudgetLineList.setParams({
			budgetId:component.get('v.parentBudgetRecordId'),
		});
		BudgetLineList.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				console.log(response.getReturnValue());
				let result=response.getReturnValue();
				component.set('v.budgetLinesOptions' ,result);
			
			}
		});
		$A.enqueueAction(BudgetLineList);
	}
})