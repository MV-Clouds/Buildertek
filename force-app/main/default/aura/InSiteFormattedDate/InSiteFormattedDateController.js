({
	init: function (component, event, helper) {
		var outputContainer = component.find('output');
		var timestamp = component.get('v.timestamp');
		var format = component.get('v.format');
		var convertedFormat = format.replace("*BR*", "<br/>");

		var m = window.moment.unix(timestamp);
		outputContainer.getElement().innerHTML = m.format(convertedFormat);
	}
})