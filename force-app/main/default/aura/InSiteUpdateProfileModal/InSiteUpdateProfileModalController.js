({
	init: function (component, event, helper) {
		setTimeout(function () {
			component.set('v.isLoading', false);
		}, 750);
	},
	onSubmitClicked: function (component, event, helper) {
		console.log('firing onSubmitClicked');
		var purchaseDateComponent = component.find('purchaseDate');
		var purchaseRefComponent = component.find('purchaseRef');
		var statusComponent = component.find('status');
		var noteComponent = component.find('note');

		if (!statusComponent.checkValidity()) {
			statusComponent.reportValidity();
			return;
		}

		if (!noteComponent.checkValidity()) {
			noteComponent.reportValidity();
			return;
		}

		if (purchaseDateComponent && !purchaseDateComponent.checkValidity()) {
			console.log("still checking validity");
			purchaseDateComponent.reportValidity();
			return;
		}

		if (purchaseRefComponent && !purchaseRefComponent.checkValidity()) {
			console.log("still checking validity");
			purchaseRefComponent.reportValidity();
			return;
		}

		component.set('v.isLoading', true);
		var purchaseDate = null;
		var purchaseRef = null;

		var userId = component.get('v.userId');
		var projectId = component.get('v.projectId');
		var status = statusComponent.get('v.value');
		var parsedStatus = parseInt(status);
		var note = noteComponent.get('v.value');

		if (purchaseDateComponent) {
			purchaseDate = purchaseDateComponent.get('v.value');
		}

		if (purchaseRefComponent) {
			purchaseRef = purchaseRefComponent.get('v.value');
		}


		var payload = {
			userId: userId,
			projectId: projectId,
			status: parsedStatus,
			note: note
		};

		if (parsedStatus === 5 || parsedStatus === 6) {
			payload.salesRecord = {
				date: purchaseDate,
				ref: purchaseRef
			}
		} else {
			payload.salesRecord = null;
		}

		console.log(payload);

		var updateProfileCallout = component.get('c.makeUpdateProfileCallout');
		updateProfileCallout.setParams({jsonBody: JSON.stringify(payload)});
		updateProfileCallout.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				var payload = response.getReturnValue();
				console.log(payload);
				window.location.reload();
			}
		});

		$A.enqueueAction(updateProfileCallout);
	}
})