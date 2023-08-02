({
	renderChart: function (chartElem, legendElem, data) {
		console.log("rendering Flot chart...")
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
	}
})