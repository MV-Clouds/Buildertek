({
	showFailedToLoadSessionDetails: function () {
		var toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
			title: 'Could not find session details',
			type: 'warning',
			message: 'InSite could not find any sessions attached to the current user with the associated session ID.'
		});

		toastEvent.fire();
	}
})