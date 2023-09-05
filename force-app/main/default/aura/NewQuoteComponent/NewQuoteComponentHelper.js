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
		console.log('masterQuoteRecord');
		
		var action = component.get("c.getAllMasterQuote");
		// action.setParams({
		// 	pageNumber: pageNumber,
        //     pageSize: pageSize
		// })
		action.setCallback(this, function (response) {
			var state=response.getState();
			console.log(response.getError());
			if(state === 'SUCCESS'){
				// var result=response.getReturnValue();			
				// component.set('v.masterQuoteList' ,result);

				var records = response.getReturnValue();
                // var currentRecords = component.get("v.masterQuoteList") || [];
                // currentRecords = currentRecords.concat(records);
                // component.set("v.masterQuoteList", currentRecords);
                component.set("v.masterQuoteList", records);



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