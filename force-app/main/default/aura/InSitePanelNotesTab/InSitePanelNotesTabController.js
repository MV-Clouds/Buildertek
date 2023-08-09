({
	init: function (component, event, helper) {
		var userId = component.get('v.userId');
		console.log("passed userId of: " + userId);
	},
	onUpdateProfileClicked: function (component, event, helper) {
		var modalBody = null;
		var userId = component.get('v.userId');
		var projectId = component.get('v.projectId');
		console.log("passed userId of: " + userId);
		console.log("passed projectId of: " + projectId);
		$A.createComponent('c:InSiteUpdateProfileModal', {"userId": userId, "projectId": projectId}, function (content, status) {
			if (status === "SUCCESS") {
				modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: "Update InSite Profile",
					body: modalBody,
					showCloseButton: true,
					cssClass: 'slds-modal_small',
					closeCallback: function () {
						console.log("Closed modal");
					}
				});
			}
		});
	}
})