({
    doInit : function(component, event, helper) {
        
        var chartData=component.get("v.chartDataArray");
        var chartHeader=component.get("v.chartHeader");
        helper.createBarChart(component,chartData,chartHeader);
    },
    onchangeDatasetIndex : function(component,event,helper){
        var index=parseInt(component.get("v.datasetIndex"));
        if(index!=undefined){
            var chartData=component.get("v.chartDataArray");
            var data=chartData[index];
            if(data!=undefined){
                var recId=data.id;
                if(recId!=""&&recId!=undefined){
                    var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        recordId: recId,
                        slideDevName: "detail"
                    });
                    navEvent.fire();
                }
            }
        }
    }
})