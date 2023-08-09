({
    getTemplateBody : function(component, event, helper) {
		console.log('getTemplateBody');
        var recordId = component.get("v.recordId");
		var action = component.get("c.createInvoice");
		action.setParams({
		    recordId : recordId
		});
		action.setCallback(this, function(response){
		    var state = response.getState();
		    if(state === "SUCCESS"){
				console.log({result});
		        var result =  response.getReturnValue();
		        component.set("v.invoiceLines", result);
		    }
		});
		$A.enqueueAction(action);

	},

	sendEmail: function (component, event, helper){
		component.set("v.Spinner", true);
		var toIds = [];
		var ccIds = [];
        var noToIds = [];
        var war = '';
		var to = component.get("v.selectedToContact");
		var cc = component.get("v.selectedCcContact");
		to.forEach(function (v) {
            if(v.Email != null && v.Email != undefined){
				toIds.push(v.Id);
            } else{
                noToIds.push(v.Name);
                war += v.Name;
            }
            
		});
		cc.forEach(function (v) {
			ccIds.push(v.Id)
		});

		if (toIds.length != 0) {
			var updateAction = component.get("c.updateMemo");
			updateAction.setParams({
				recordId: component.get("v.recordId"),
				memoValue: component.get("v.invoiceMemo"),
			});
			updateAction.setCallback(this, function (response) {
				var state = response.getState();
				console.log({toIds});
				console.log({ccIds});
				if (state === "SUCCESS") {
					var action = component.get("c.sendProposal");
					action.setParams({
						htmlBody: component.get("v.invoiceLines"),
						recordPId: component.get("v.recordId"),
						to: toIds,
						cc: ccIds
					});
					action.setCallback(this, function (response1) {
						var state = response1.getState();
						if (state === "SUCCESS") {
							var result1 = response1.getReturnValue();
							console.log({result1});
							if (result1 === 'Success') {
								$A.get("e.force:closeQuickAction").fire();
								var toastEvent = $A.get("e.force:showToast");
								toastEvent.setParams({
									"title": "Success!",
									"type": 'success',
									"message": "Email Sent Successfully"
								});
								toastEvent.fire();
							} else {
								$A.get("e.force:closeQuickAction").fire();
								var toastEvent = $A.get("e.force:showToast");
								toastEvent.setParams({
									"type": 'error',
									"message": result1
								});
								toastEvent.fire();
							}
							$A.get('e.force:refreshView').fire();
						}
						component.set("v.Spinner", false);
					});
					$A.enqueueAction(action);
				}
				component.set("v.Spinner", false);
			});
			$A.enqueueAction(updateAction);
		} else {
			component.set("v.Spinner", false);
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
				"type": 'error',
				"message": "Please select To Address to send Email"
			});
			toastEvent.fire();
		}
	}
})