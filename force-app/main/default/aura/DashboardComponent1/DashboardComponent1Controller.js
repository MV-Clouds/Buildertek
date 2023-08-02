({
    init : function(component, event, helper) {
        debugger;
        helper.fetchContract(component,event,helper);
        
        var jq = $.noConflict();
        jq("document").ready(function(){
            Highcharts.chart('container', {
                data: {
                    table: 'datatable'
                },
                chart: {
                    type: 'column'
                },
                title: {
                    text: 'Schedule Information'
                },
                yAxis: {
                    allowDecimals: false,
                    title: {
                        text: 'Units'
                    }
                },
                tooltip: {
                    formatter: function () {
                        return '<b>' + this.series.name + '</b><br/>' +
                            this.point.y + ' ' + this.point.name.toLowerCase();
                    }
                }
            });
            
            Highcharts.chart('container1', {
                chart: {
                    type: 'pie'
                },
                title: {
                    text: 'Contract Report'
                },
                
                plotOptions: {
                    series: {
                        dataLabels: {
                            enabled: true,
                            format: '{point.name}: {point.y:.1f}%'
                        }
                    }
                },
                
                tooltip: {
                    headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                    pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
                },
                
                series: [
                    {
                        name: "Report",
                        colorByPoint: true,
                        data: [
                            {
                                name: "Original Contract Amount",
                                y: 52.74,
                                drilldown: "Original Contract Amount"
                            },
                            {
                                name: "Customer Approved Change Order Amount",
                                y: 10.57,
                                drilldown: "Customer Approved Change Order Amount"
                            },
                            {
                                name: "Revised Contract Amount",
                                y: 7.23,
                                drilldown: "Revised Contract Amount"
                            }               
                        ]
                    }
                ],
                drilldown: {
                    series: [
                        {
                            name: "Original Contract Amount",
                            id: "Original Contract Amount",
                            data: [
                                [
                                    "dfjsnekd",
                                    20
                                ],
                                [
                                    "mundo",
                                    30
                                ],
                                [
                                    "test23",
                                    33.02
                                ],
                                [
                                    "TestContract1",
                                    40
                                ]
                            ]
                        },
                        {
                            name: "Customer Approved Change Order Amount",
                            id: "Customer Approved Change Order Amount",
                            data: [
                                [
                                    "dfjsnekd",
                                    20
                                ],
                                [
                                    "mundo",
                                    30
                                ],
                                [
                                    "test23",
                                    10
                                ],
                                [
                                    "TestContract1",
                                    10
                                ]
                            ]
                        },
                        {
                            name: "Revised Contract Amount",
                            id: "Revised Contract Amount",
                            data: [
                                [
                                    "dfjsnekd",
                                    15
                                ],
                                [
                                    "mundo",
                                    45
                                ],
                                [
                                    "test23",
                                    10
                                ],
                                [
                                    "TestContract1",
                                    30
                                ]
                            ]
                        }
                    ]
                }
            });
            /* Highcharts.chart('container2', {
                chart: {
                    type: 'pie',
                    options3d: {
                        enabled: true,
                        alpha: 45,
                        beta: 0
                    }
                },
                title: {
                    text: 'Pending Change Orders'
                },
                accessibility: {
                    point: {
                        valueSuffix: '%'
                    }
                },
                tooltip: {
                    pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                },
                plotOptions: {
                    pie: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        depth: 35,
                        dataLabels: {
                            enabled: true,
                            format: '{point.name}'
                        }
                    }
                },
                series: [{
                    type: 'pie',
                    name: 'Pending Change Orders',
                    data: [{
                        table:'datatable2'
                    }]
                }]
            });*/
            Highcharts.chart('container2', {
                chart: {
                    type: 'pie',
                    options3d: {
                        enabled: true,
                        alpha: 45,
                        beta: 0
                    }
                },
                title: {
                    text: 'Pending Change Orders'
                },
                accessibility: {
                    point: {
                        valueSuffix: '%'
                    }
                },
                tooltip: {
                    pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                },
                plotOptions: {
                    pie: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        depth: 35,
                        dataLabels: {
                            enabled: true,
                            format: '{point.name}'
                        }
                    }
                },
                series: [{
                    type: 'pie',
                    name: 'Pending Change Orders',
                    data: [
                        ['Test', 45.0],
                        ['Test1', 26.8],
                        {
                            name: 'Test2',
                            y: 12.8,
                            sliced: true,
                            selected: true
                        },
                        ['Test3', 8.5],
                        ['Test4', 6.2],
                        ['Test5', 0.7]
                    ]
                }]
            });
        });
        // Create the chart
        
    }
})