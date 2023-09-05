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
	masterQuoteRecord: function (component, event, helper) {
		var action = component.get("c.getAllMasterQuote");
        action.setCallback(this, function (response) {
			var state=response.getState();
			if(state === 'SUCCESS'){
				var result=response.getReturnValue();
				console.log({result});
				component.set('v.masterQuoteList' ,result);

			}else{
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": "Error!",
                    "message": "Something went wrong."
				});
				toastEvent.fire();
			}
		});
		$A.enqueueAction(action);

	}
})