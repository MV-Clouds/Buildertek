({
	init: function (component, event, helper) {
		console.log(component);
		console.log(event);
		console.log(helper);

		var loadProjectIdAction = component.get('c.getProjectId');
		loadProjectIdAction.setParams({recordId: component.get('v.recordId')});
		loadProjectIdAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();
				console.log(payload);
				if (Object.keys(payload).length > 0) {
					component.set('v.projectId', payload.project_id);
				} else {
					console.error('Could not load project ID');
				}
			}
		});

		var loadProfileDataAction = component.get('c.makeProfileCallout');
		loadProfileDataAction.setParams({recordId: component.get('v.recordId')});
		loadProfileDataAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();
				console.log(payload);
				if (Object.keys(payload).length > 0) {
					component.set('v.userId', payload.userId);
					component.set('v.fullName', payload.fullName);
					component.set('v.userRating', payload.overview.rating);

					component.set('v.overviewData', payload.overview);
					component.set('v.lotEngagement', payload.engagement.lot);
					component.set('v.packageEngagement', payload.engagement.package);
					component.set('v.downloadEngagement', payload.engagement.download);
					component.set('v.journey', payload.journey);
					component.set('v.notesData', payload.notes);
				} else {
					component.set('v.emptyData', true);
				}
			} else {
				component.set('v.emptyData', true);
			}

			component.set('v.dataHasNotLoaded', false);
		});

		$A.enqueueAction(loadProjectIdAction);
		$A.enqueueAction(loadProfileDataAction);
	},
	handleSelect: function (component, event, helper) {
		console.log('tab swapped');
	},
	openInSite: function (component, event, helper) {
		//window.open('https://land.insitelogic.com.au', '_blank');
		var recordId = component.get('v.recordId');
		var url = "/apex/insitehost?lead=" + recordId;
		var pid = component.get('v.projectId');
		if(pid) {
			url += "&project=" + pid;
		}

		$A.get("e.force:navigateToURL").setParams({
			"url": url
		}).fire();
	},
	handleZoomClick: function (component, evt, helper) {
		var modalBody = null;
		var recordId = component.get('v.recordId');
		$A.createComponent('c:InSitePanel', {"disableExpandable": true, "recordId": recordId}, function (content, status) {
			if (status === "SUCCESS") {
				modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: "InSite Logic Data",
					body: modalBody,
					showCloseButton: true,
					cssClass: 'slds-modal_medium',
					closeCallback: function () {
						console.log("Closed modal");
					}
				})
			}
		});
	},
	handleSessionClicked: function (component, evt, helper) {
		var sessionId = evt.getParam('sessionId');
		var sku = evt.getParam('sku');

		var sessionDetailsAction = component.get('c.getSessionDetails');
		sessionDetailsAction.setParams({sessionId: sessionId, sku: sku});
		sessionDetailsAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				var payload = response.getReturnValue();
				var modalBody = null;
				$A.createComponent('c:InSiteSessionDetails', {"actions": payload}, function (content, status) {
					if (status === "SUCCESS") {
						modalBody = content;
						component.find('overlayLib').showCustomModal({
							header: "InSite Session Breakdown",
							body: modalBody,
							showCloseButton: true,
							cssClass: 'slds-modal_medium',
							closeCallback: function () {
								console.log("Closed modal");
							}
						})
					}
				});
			} else {
				console.error('Failed to get a valid');
				helper.showFailedToLoadSessionDetails();
			}

		});

		$A.enqueueAction(sessionDetailsAction);
	}
});