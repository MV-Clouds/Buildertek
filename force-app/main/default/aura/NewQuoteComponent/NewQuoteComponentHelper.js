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
			
		component.set('v.columns', [
            {label: 'Name', fieldName: 'QuoteName', type: 'url' , typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            // {label: 'Status', fieldName: 'buildertek__Status__c', type: 'picklist'},
            {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'},
			{label: 'Sales Price', fieldName: 'buildertek__Grand_Total__c', type: 'currency' , cellAttributes: { alignment: 'left' }},
        ]);		

		var action = component.get("c.getAllMasterQuote");
		action.setParams({
            "recordLimit": component.get("v.initialRows"),
            "recordOffset": component.get("v.rowNumberOffset")
        });
		action.setCallback(this, function (response) {
			var state=response.getState();
			console.log(response.getError());
			if(state === 'SUCCESS'){
				var records = response.getReturnValue();
				console.log(records.quoteList);
				records.quoteList.forEach(function(record){
					record.QuoteName = '/'+record.Id;
				});
				component.set('v.masterQuoteData' , records.quoteList);
                component.set("v.currentCount", component.get("v.initialRows"));
                component.set("v.totalNumberOfRows", records.totalQuotes);

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
	},
	getMoreQuotes: function(component , rows){
		console.log('getMoreQuotes');
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getAllMasterQuote');
            var recordOffset = component.get("v.currentCount");
            var recordLimit = component.get("v.initialRows");
            action.setParams({
                "recordLimit": recordLimit,
                "recordOffset": recordOffset 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
				console.log(recordOffset);
				console.log(recordLimit);

                if(state === "SUCCESS"){
                    var resultData = response.getReturnValue();
					console.log(resultData);
					var setMasterQuoteRecords=resultData.quoteList;
					setMasterQuoteRecords.forEach(function(record){
						record.QuoteName = '/'+record.Id;
					});
                    resolve(setMasterQuoteRecords);
					recordOffset = recordOffset+recordLimit;
					component.set("v.currentCount", recordOffset);  
                }             
            });
            $A.enqueueAction(action);
        }));
    },
})