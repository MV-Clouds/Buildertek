({
    getPricebooksProduct:function(component, event, helper, searchFilter) {
		var action = component.get("c.getProduct");
		action.setParams({
			prodName:searchFilter
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			var result= response.getReturnValue();
			if (state === "SUCCESS") {
				component.set('v.productList' , result);
			}
		});
		$A.enqueueAction(action);
	 },
})