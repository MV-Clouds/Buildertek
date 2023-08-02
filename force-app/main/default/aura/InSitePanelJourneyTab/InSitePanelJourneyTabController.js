({
	handleRowClick: function (component, event, helper) {
		var target = event.target;
		var row = null;

		if (event.target.nodeName === "TD") {
			row = target.parentElement;
		} else if (event.target.nodeName === "TR") {
			row = target;
		}

		var sessionId = row.dataset.sessionId;
		var sku = row.dataset.sku;

		var evt = component.getEvent('onSessionRowClicked');
		evt.setParams({
			sessionId: sessionId,
			sku: sku
		}).fire();
	}
})