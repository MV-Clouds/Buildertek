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

	handleChangeProjectHelper: function(component, event, helper) {
        let getValue= component.get("v.parentRecordId");
        console.log('getValue');
        var action = component.get("c.getPO");
        action.setParams({
            recordId:getValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getError());
            console.log({state});
            var result= response.getReturnValue();
            if (state === "SUCCESS") {
                console.log({result});
                component.set('v.poList' ,result);
                component.set('v.allPORecords' ,result);
            }
        });
        $A.enqueueAction(action);
    },
})