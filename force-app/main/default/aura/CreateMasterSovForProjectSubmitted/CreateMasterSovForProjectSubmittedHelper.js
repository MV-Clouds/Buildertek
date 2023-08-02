({
    
    
    getcurr : function (component, event, helper) {
        var action = component.get("c.getcurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    
    
    getApprovedLinesList: function(component,event,helper, pageNumber, pageSize){
        
        debugger;
        var vendorValue = component.get("v.searchVendorFilter");
        var ItemNoValue = component.get("v.searchItemFilter");
        var descriptionValue = component.get("v.searchDescriptionFilter");
        
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        
        var action = component.get("c.getApprovedSovData");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "vendorName" : vendorValue,
            "itemNo" : ItemNoValue,
            "description": descriptionValue
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
        component.set("v.showMessage", false);
                var result = response.getReturnValue();
               // alert(result.pageNumber);
               // alert(result.totalRecords);
               // alert(Math.ceil(result.totalRecords / pageSize));
                component.set("v.ApprovedrecordsList",result.ApprovedSovLinesInnerList);
               
                component.set("v.PageNumber", result.pageNumber);
               
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set("v.TotalPages", Math.ceil(result.totalRecords / pageSize));
            }
            else{
                component.set("v.Spinner", false);
        component.set("v.showMessage", false);
            }
        });
        $A.enqueueAction(action);

                
    },
    
    getPendingLinesList: function(component,event,helper, pageNumber1, pageSize1){
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var action = component.get("c.getPendingSovData");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "pageNumber": pageNumber1,
            "pageSize": pageSize1
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
        component.set("v.showMessage", false);
                debugger;
                var result = response.getReturnValue();
                component.set("v.PendingrecordsList",result.PendingSovLinesInnerList);
                
                component.set("v.PageNumber1", result.pageNumber);
               
                component.set("v.TotalRecords1", result.totalRecords);
                component.set("v.RecordStart1", result.recordStart);
                component.set("v.RecordEnd1", result.recordEnd);
                component.set("v.TotalPages1", Math.ceil(result.totalRecords / pageSize1));
                
                
                var ManageSovTotal = 0;  
                
                for(var i=0;i<result.PendingSovLinesInnerList.length;i++){
                    if(result.PendingSovLinesInnerList[i].ScheduleValue != undefined && result.PendingSovLinesInnerList[i].ScheduleValue != null)
                    ManageSovTotal += result.PendingSovLinesInnerList[i].ScheduleValue;
                }
                component.set("v.ManageSovTotal",ManageSovTotal) 
            }else{
                component.set("v.Spinner", false);
        component.set("v.showMessage", false);
            }
        });
        $A.enqueueAction(action);
    },
    
})