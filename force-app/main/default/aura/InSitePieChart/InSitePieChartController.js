({
	afterScriptsLoaded: function (component, event, helper) {
		var pieChartContainer = component.find('chart-container').getElement();
		var legendContainer = component.find('legend-container').getElement();
		var chartData = component.get('v.data');
		helper.renderChart($(pieChartContainer), $(legendContainer), chartData);
	}
})