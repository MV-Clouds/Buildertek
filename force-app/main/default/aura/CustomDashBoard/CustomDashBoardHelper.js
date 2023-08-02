({
    fetchContract:function(component,event,helper){
        // debugger;
        var action = component.get("c.getContractDetails");
        action.setParams({ projectId : component.get("v.recordId")});
        action.setCallback(component, function(response){
            var state = response.getState();
            console.log(state);
            if (state == "SUCCESS"){
                var obj = JSON.parse(response.getReturnValue());
                
                //phoneNumber formatted
                var s2 = (""+obj.Phone).replace(/\D/g, '');
                var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
                obj.Phone= (!m) ? null :  m[1] + "-" + m[2] + "-" + m[3];
                
                component.set("v.Contract", obj);
            }
            //console.log('response',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    formatPhoneNumber: function( phone) {
        var s2 = (""+phone).replace(/\D/g, '');
        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        return (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3];
    },
    
    chartHelper : function(component,helper){
        console.log('helper')
        var action = component.get("c.getHCChartData"); //apex call
        action.setParams({
            "recordId": component.get('v.recordId') //pass the recordId from lightning 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('dash helper::',state);
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                console.log('Response Value ::',response.getReturnValue());
                var data1=result.OpenChangeOrder;
                var data2=result.ApprovedChangeOrder;
                var data3=result.OpenInvoice;
                console.log('data 1 :::: ',JSON.stringify(data1));
                console.log('data 2 :::: ',JSON.stringify(data2));
                console.log('data 3 :::: ',JSON.stringify(data3));
                
                var chartDataArray1=[];
                var chartDataArray2=[];
                var chartDataArray3=[];
                
                for(var j=0;j<data1.length;j++){
                    var chartData={};
                    chartData.columnName=data1[j].Name;
                    var dataValue=data1[j].buildertek__Total_Amount_Tax__c;
                    if(dataValue==undefined){
                        dataValue=0;
                    }else{
                        dataValue=dataValue.toFixed(0);
                    }
                    chartData.data=dataValue;
                    chartData.id=data1[j].Id;
                    chartDataArray1.push(chartData);
                }
                for(var j=0;j<data2.length;j++){
                    var chartData={};
                    chartData.columnName=data2[j].Name;
                    var dataValue=data2[j].buildertek__Total_Amount_Tax__c;
                    if(dataValue==undefined){
                        dataValue=0;
                    }else{
                        dataValue=dataValue.toFixed(0);
                    }
                    chartData.data=dataValue;
                    chartData.id=data2[j].Id;
                    chartDataArray2.push(chartData);
                }
                for(var j=0;j<data3.length;j++){
                    var chartData={};
                    chartData.columnName=data3[j].Name;
                    var dataValue=data3[j].buildertek__Total_Amount_Tax__c;
                    if(dataValue==undefined){
                        dataValue=0;
                    }else{
                        dataValue=dataValue.toFixed(0);
                    }
                    chartData.data=dataValue;
                    chartData.id=data3[j].Id;
                    chartDataArray3.push(chartData);
                }
                component.set("v.chartDataArray1",chartDataArray1);
                component.set("v.chartDataArray2",chartDataArray2);
                component.set("v.chartDataArray3",chartDataArray3);
                component.set("v.isChart",true);
                
            }
        });
        $A.enqueueAction(action);
    },
    fetchSchedule :function(component,event,helper){
    	var action = component.get("c.getScheduleData");
        action.setParams({
            "recordId": component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=JSON.parse(response.getReturnValue());
                var row=[];
                for(var i=0,k=0;i<result.length;i++){
                    var rowData={};
                    rowData.Name=result[i].scheduleRec.Name;
                    rowData.id=result[i].scheduleRec.Id;
                    rowData.expanded=true;
                    var childData=[]; 
                    for(var j=0;j<result[i].TaskRecs.length;j++){
                        var data={};
                        data.id=result[i].TaskRecs[j].Id;
                        data.Name=result[i].TaskRecs[j].Name; 
                       // data.FinishDate=result[i].TaskRecs[j].buildertek__Finish__c;
                        data.StartDate=result[i].TaskRecs[j].buildertek__Start__c;
                        data.Duration=result[i].TaskRecs[j].buildertek__Duration__c;
                         childData[j]=data;         
                    }
                    if(result[i].TaskRecs.length>0){
                    rowData.children=childData;
                    row[k]=rowData;
                    k++;
                    }
                }
                component.set("v.rows",row);
            }
        });
        $A.enqueueAction(action);
	},
})