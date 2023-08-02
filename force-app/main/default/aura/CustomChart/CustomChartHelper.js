({  
    createBarChart : function(component,chartData,chartHeader) {
        function getRandomColor() {
            var letters = '0123456789ABCDEF';
            var color = '#';
            for (var i = 0; i < 6; i++) {
                color += letters[Math.floor(Math.random() * 16)];
            }
            return color;
        }
        
        var chartColumnData=[];
        var chartLabel=[];
        var chartColors = [];
        for(var j=0;j<chartData.length;j++){
            chartColumnData.push(chartData[j].data);
            chartLabel.push(chartData[j].columnName);
            chartColors.push(getRandomColor());
        }
        var el = component.find('stackedGroupChart').getElement();
        var ctx = el.getContext('2d');
        
        var myChart =new Chart(ctx, {
            type: 'bar',
            data: {
                labels: chartLabel,
                datasets: [{
                    data: chartColumnData,
                    backgroundColor: chartColors,
                    borderColor:chartColors,
                    borderWidth: 1
                }]
            },
            options: {
                title: {
                    display: true,
                    text: chartHeader,
                    position: 'bottom'
                },
                tooltips: {
                    mode: 'index',
                    intersect: false
                },
                legend: {
                    display: false
                },
                responsive: true,
                scales: {
                    xAxes: [{
                        stacked: true,
                        categoryPercentage: 0.7,
                        barPercentage: 1,
                        lineWidth: 3,
                        ticks: {
                            autoSkip: false
                        }
                    }],
                    yAxes: [{
                        stacked: true,
                        ticks: {
                            callback: function(value, index, values) {
                                if(parseInt(value) > 999){
                                    return '$' + value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                } else if (parseInt(value) < -999) {
                                    return '-$' + Math.abs(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                } else {
                                    return '$' + value;
                                }
                            }
                        }
                    }]
                },
                tooltips: {
                    callbacks: {
                        label: function(t, d) {
                            var xLabel = d.datasets[t.datasetIndex].label;
                            var yLabel = t.yLabel >= 1000 ?
                                '$' + t.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") :
                            '$' + t.yLabel;
                            return   yLabel;
                        }
                    }
                }
            },
        });
        
        var canvas = component.find('stackedGroupChart').getElement();
        var cmp=component;
        var datasetIndex;
        canvas.onclick = function(evt) {
            var activePoint = myChart.getElementAtEvent(evt)[0];
            if(activePoint!=undefined){
                if(activePoint._index !=undefined){
                    cmp.set("v.datasetIndex",activePoint._index);
                }    
            }
        };
    },
    
})