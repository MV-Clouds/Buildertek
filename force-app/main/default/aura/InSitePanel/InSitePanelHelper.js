({
	renderChart: function (chartElem, legendElem, data) {
		console.log("rendering ChartJS chart...")
		$.plot(chartElem, data, {
			series: {
				pie: {
					show: true,
					combine: {
						color: '#999',
						threshold: 0.005
					},
					innerRadius: 0.5,
					radius: 1,
					highlight: {
						opacity: 0.2
					},
					label: {
						show: true,
						radius: 0.75,
						formatter: this.chartLabelFormatter,
						background: {
							opacity: 0
						},
						threshold: 0.07
					}
				}
			},
			legend: {
				show: true,
				backgroundOpacity: 0,
				backgroundColor: null,
				/*labelFormatter: this.legendLabelFormatter,*/
				container: legendElem,
				noColumns: 2
			},
			grid: {
				hoverable: true,
				clickable: false
			},
			colors: ["#00adef", "#a5df1d", "#ee6837", "#333a41"]
		});
	},
	chartLabelFormatter: function (label, series) {
		return "<div class='chart-label'>" + Math.round(series.percent) + "%</div>";
	},
	legendLabelFormatter: function (label, series) {
		return "<div class='pie-label-x' data-label='" + label + "' style='font-size:8pt; text-align:left; color:black;'>" + unescape(label) + " <span class='pie-label-series'>(" + Math.round(series.percent) + "%)</span></div>";
	},
	initEngagementTab: function (component, helper) {
		setTimeout(function () {
			// Example Data
			var data = [
				{label: "Series1", data: 10},
				{label: "Series2", data: 30},
				{label: "Series3", data: 90},
				{label: "Series4", data: 70},
				{label: "Series5", data: 80},
				{label: "Series6", data: 110}
			];

			var lotEngagementChartElem = component.find('insite-lot-engagement-chart').getElement();
			var pkgEngagementChartElem = component.find('insite-pkg-engagement-chart').getElement();
			var lotEngagementLegendElem = component.find('insite-lot-engagement-legend').getElement();
			var pkgEngagementLegendElem = component.find('insite-pkg-engagement-legend').getElement();

			helper.renderChart($(lotEngagementChartElem), $('#insite-lot-engagement-legend'), data);
			helper.renderChart($(pkgEngagementChartElem), $('#insite-pkg-engagement-legend'), data);
		}, 300);
	},
	initJourneyTab: function (component, helper) {

	},
	convertToStarRating: function (rating) {
		var buffer = [];
		// Calculate the number of each type of star needed
		var full_stars = Math.floor(rating);
		var half_stars = Math.ceil(rating - full_stars);
		var empty_stars = 5 - full_stars - half_stars;

		for (var i = 0; i < full_stars; i++) {
			buffer.push("FULL");
		}

		for (var i = 0; i < half_stars; i++) {
			buffer.push("HALF");
		}

		for (var i = 0; i < empty_stars; i++) {
			buffer.push("EMPTY");
		}

		return buffer;
	},
	createStarRatingElements: function (rating) {
		var parsedElements = this.convertToStarRating(rating);
		var buffer = [];
		for (var i = 0; i < parsedElements.length; i++) {
			var img = "";
			switch (parsedElements[i]) {
				case "EMPTY":
					img = $A.get('$Resource.insite') + '/insite/svg/star-empty-orange.svg';
					break;
				case "HALF":
					img = $A.get('$Resource.insite') + '/insite/svg/star-half-orange.svg';
					break;
				case "FULL":
					img = $A.get('$Resource.insite') + '/insite/svg/star-orange.svg';
					break;
				default:
					img = $A.get('$Resource.insite') + '/insite/svg/star-empty-orange.svg';
					break;
			}
			buffer.push('<img src="' + img + '" alt="" />')
		}

		return buffer.join("");
	},
	showTickIfTrue: function (value) {
		if (value) {
			return '<div style="width: 100%;"><img src="' + $A.get('$Resource.insite') + '/insite/svg/tick.svg' + '" alt="" style="display: block; margin: 0 auto;" /></div>';
		} else {
			return '<div style="width: 100%;"></div>';
		}
	}
});