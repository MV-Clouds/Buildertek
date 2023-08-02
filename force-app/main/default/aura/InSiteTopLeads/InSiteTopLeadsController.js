({
	init: function (component, event, helper) {
		// our APEX Controller returns the HTTP callout data
		var loadTopDataAction = component.get('c.makeTopLeadsCallout');
		loadTopDataAction.setParams({ sortBy: null, filter: null });
		loadTopDataAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();

				// store two copies of the response, a pristine original and our working copy
				component.set('v.masterData', payload);
				component.set('v.workingData', payload);
			}

			// turn off spinner
			component.set('v.dataHasNotLoaded', false);
		});

		$A.enqueueAction(loadTopDataAction);

		var availableProjectsAction = component.get('c.getSupportedProjectsList');
		availableProjectsAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();
				component.set('v.projectList', payload);
				component.set('v.selectedReport', payload.total);
			}
		});

		$A.enqueueAction(availableProjectsAction);

		var combinedReportsAction = component.get('c.makeCombinedReportingCallout');
		combinedReportsAction.setParams({
			currentTimestamp: Math.floor(Date.now() / 1000),
			timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
			selectedRange: component.get('v.selectedRange')
		});
		combinedReportsAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();
				component.set('v.combinedReports', payload);
				component.set('v.selectedReport', payload.total);
			}
		});

		$A.enqueueAction(combinedReportsAction);
	},
	handleNoteTypeButtonSelect: function (component, event, helper) {
		// the name attribute of the selected button
		var selectedButtonName = event.getSource().get("v.name");
		var selectedNoteType = null;
		switch (selectedButtonName) {
			case "actioned":
				selectedNoteType = 2;
				break;
			case "unactioned":
				selectedNoteType = 0;
				break;
			case "to_review":
				selectedNoteType = 1;
				break;
			case "clear":
				break;
			default:
				break;
		}

		component.set('v.filter__note_state', selectedNoteType);

		var filterValuesUpdatedEvent = component.getEvent('InSiteTopLeadsFiltersChanged');
		filterValuesUpdatedEvent.setParams({
			noteType: selectedNoteType,
			sort: component.get('v.filter__sort')
		}).fire();
	},
	handleSortSelect: function (component, event, helper) {
		// the select value is tied directly to an attribute, this handler listens to changes on the attribute, not the select element.
		var filterValuesUpdatedEvent = component.getEvent('InSiteTopLeadsFiltersChanged');
		var selectedButtonName = event.getSource().get("v.name");
		component.set('v.filter__sort', selectedButtonName);
		console.log(selectedButtonName);

		filterValuesUpdatedEvent.setParams({
			noteType: component.get('v.filter__note_state'),
			sort: selectedButtonName
		}).fire();
	},
	handleFiltersChanged: function (component, event, helper) {
		// // we've received the custom event, apply our filters
		var loadTopLeadsAction = component.get('c.loadTopLeads');
		$A.enqueueAction(loadTopLeadsAction);
	},
	handleRowClick: function (component, event, helper) {
		var target = event.target;
		var row = null;

		if (event.target.nodeName === "TD") {
			row = target.parentElement;
		} else if (event.target.nodeName === "TR") {
			row = target;
		}

		var emailAddress = row.dataset.userEmail;
		if (emailAddress !== null && emailAddress !== "") {
			var getEnquiryDataAction = component.get('c.retrieveEnquiryDataForUserWithEmailAddress');
			getEnquiryDataAction.setParams({
				emailAddress: emailAddress
			});

			getEnquiryDataAction.setCallback(this, function (response) {
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					var payload = response.getReturnValue();
					if (payload !== null) {
						var id = payload.Id;
						helper.navigateToRecordById(id);
					} else {
						helper.showFailedToRedirectToEnquiryToast();
					}
				} else {
					console.error('Failed to get a valid');
					helper.showFailedToRedirectToEnquiryToast();
				}
			});

			$A.enqueueAction(getEnquiryDataAction);
		} else {
			helper.showFailedToRedirectToEnquiryToast();
		}
	},
	openInSite: function (component, event, helper) {
		//window.open('https://land.insitelogic.com.au', '_blank');
		var url = "/apex/insitehost";
		var pid = component.get('v.selectedProjectId');
		if(pid) {
			url += "?project=" + pid;
		}

		$A.get("e.force:navigateToURL").setParams({
			"url": url
		}).fire();
	},
	handleZoomClick: function (component, evt, helper) {
		var modalBody = null;
		$A.createComponent('c:InSiteTopLeads', {"disableExpandable": true}, function (content, status) {
			if (status === "SUCCESS") {
				modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: "InSite Top Hot Leads",
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
	handleProjectSelect: function (component, evt, helper) {
		// turn on spinner
		component.set('v.dataHasNotLoaded', true);
		component.set('v.workingData', []);

		var val = evt.getParam('value');
		component.set('v.selectedProjectId', val);

		// our APEX Controller returns the HTTP callout data
		var loadTopDataAction = null;
		if (val === null || val === "") {
			loadTopDataAction = component.get('c.makeTopLeadsCallout');
		} else {
			loadTopDataAction = component.get('c.makeSelectedProjectInSiteCallout');
		}

		loadTopDataAction.setParams({selectedProjectId: val});
		loadTopDataAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();

				// store two copies of the response, a pristine original and our working copy
				component.set('v.masterData', payload);
				component.set('v.workingData', payload);

				var noteTypeFilter = component.get('v.filter__note_state');
				var sortDesc = component.get('v.filter__sort');

				var working = JSON.parse(JSON.stringify(payload));
				var workingData = helper.applyFilters(working, noteTypeFilter, sortDesc);
				console.log(workingData);
				component.set('v.workingData', workingData);
				var combinedReport = component.get('v.combinedReports');
				if (val) {
					component.set('v.selectedReport', combinedReport.entries[val]);
				} else {
					component.set('v.selectedReport', combinedReport.total);
				}
			}

			// turn off spinner
			component.set('v.dataHasNotLoaded', false);
		});

		$A.enqueueAction(loadTopDataAction);
	},
	resetProjectSelection: function (component, evt, helper) {
		// turn on spinner
		component.set('v.dataHasNotLoaded', true);
		component.set('v.workingData', []);
		component.set('v.selectedProjectId', "");
		component.set('v.selectedReport', null);
		$A.enqueueAction(component.get('c.init'));
	},
	handleRangeSelect: function (component, evt, helper) {
		var combinedReportsAction = component.get('c.makeCombinedReportingCallout');
		combinedReportsAction.setParams({
			currentTimestamp: Math.floor(Date.now() / 1000),
			timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
			selectedRange: evt.getParam('value')
		});
		combinedReportsAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();
				component.set('v.combinedReports', payload);
				var selectedProjectId = component.get('v.selectedProjectId');
				if (selectedProjectId) {
					component.set('v.selectedReport', payload.entries[selectedProjectId]);
				} else {
					component.set('v.selectedReport', payload.total);
				}
			}
		});

		$A.enqueueAction(combinedReportsAction);
	},
	loadTopLeads: function (component, event, helper) {
		component.set('v.dataHasNotLoaded', true);
		// our APEX Controller returns the HTTP callout data
		var loadTopDataAction = component.get('c.makeTopLeadsCallout');
		var sortFilterValue = component.get('v.filter__sort');
		var sortParam = helper.convertSortToQueryString(sortFilterValue);
		loadTopDataAction.setParams({ sortBy: sortParam, filter: component.get('v.filter__note_state') });
		loadTopDataAction.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				var payload = response.getReturnValue();

				// store two copies of the response, a pristine original and our working copy
				component.set('v.masterData', payload);
				component.set('v.workingData', payload);
			} else {
				console.error("error on callout from loadTopLeads()");
			}

			// turn off spinner
			component.set('v.dataHasNotLoaded', false);
		});

		$A.enqueueAction(loadTopDataAction);
	}
})