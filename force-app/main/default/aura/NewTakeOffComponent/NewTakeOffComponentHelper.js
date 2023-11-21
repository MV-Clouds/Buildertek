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
	masterTakeOffRecord: function (component, event, helper) {
		console.log('masterTakeOffRecord');
			
		component.set('v.columns', [
            {label: 'TakeOff Name #', fieldName: 'TakeOffName', type: 'url' , typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Name', fieldName: 'buildertek__Name__c', type: 'text'},
            {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'}
        ]);		

		var action = component.get("c.getAllMasterTakeOff");
		action.setParams({
            "recordLimit": component.get("v.initialRows"),
            "recordOffset": component.get("v.rowNumberOffset")
        });
		action.setCallback(this, function (response) {
			var state=response.getState();
			console.log(response.getError());
			if(state === 'SUCCESS'){
				var records = response.getReturnValue();
				console.log(records.TakeOffList);
				records.TakeOffList.forEach(function(record){
					record.TakeOffName = '/'+record.Id;
				});
				component.set('v.masterTakeOffData' , records.TakeOffList);
                component.set("v.currentCount", component.get("v.initialRows"));
                component.set("v.totalNumberOfRows", records.totalTakeOffs);

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
	getMoreTakeOffs: function(component , rows){
		console.log('getMoreTakeOffs');
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getAllMasterTakeOff');
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
					var setMasterTakeOffRecords=resultData.TakeOffList;
					setMasterTakeOffRecords.forEach(function(record){
						record.TakeOffName = '/'+record.Id;
					});
                    resolve(setMasterTakeOffRecords);
					recordOffset = recordOffset+recordLimit;
					component.set("v.currentCount", recordOffset);  
                }             
            });
            $A.enqueueAction(action);
        }));
    },
})