({
    
    
    getPurchaseOrders : function(component, event, helper, pageNumber, pageSize) {
        component.set("v.Spinner", true);
        component.set("v.isExpanded", false);
        // debugger;
        var purchaseOrderFilter = component.get("v.searchItemFilter");
        
        var descriptionValue = component.get("v.searchDescriptionFilter");
        
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");

        var searchProductValue = component.get("v.searchProductFilter");
        
        var projectValue = component.get("v.searchProjectFilter");

        var permitValue = component.get("v.searchPermitFilter");
   
        component.find("checkContractors").set("v.value", false);

        var action = component.get("c.getMasterBudgets");
        action.setParams({
            recId : component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "poFilter" : purchaseOrderFilter,
            "poLineFilter" : descriptionValue,
            "tradeTypeFilter" : tradeTypeValue,
            "projectFilter" : projectValue,
            "productFilter" : searchProductValue,
            "permitFilter" : permitValue
        });
        action.setCallback(this, function(response){
            // debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                // debugger;
                
                var result = response.getReturnValue();
                console.log('--- result ---');
                console.log({result});
                if(result != null && result.length > 0){
                    
                    
                    component.set("v.masterBudgetsList", result);
                    component.set("v.PageNumber", result[0].pageNumber);
                    component.set("v.TotalRecords", result[0].totalRecords);
                    component.set("v.RecordStart", result[0].recordStart);
                    component.set("v.RecordEnd", result[0].recordEnd);
                    component.set("v.orgCurr", result[0].orgCurr);
                   
                    var  poLineFilter = component.get("v.searchDescriptionFilter");
                    var poFilter = component.get("v.searchItemFilter");
                    
                    if(poFilter != '' || poLineFilter != ''){
                        component.set("v.TotalPages", 1);
                    }else{
                        component.set("v.TotalPages", Math.ceil(result[0].totalRecords / pageSize));
                    }
                    
                   
                    component.set('v.PaginationList', result);
                    console.log({result});
                    // console.log(JSON.stringify(result));
                    component.set("v.Spinner", false);
                    
                }else{
                    component.set("v.Spinner", false);
                    component.set("v.PaginationList", []);
                }
                
                
          
            }else{
                 component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getPOListDetails : function(component, event, helper) {
        // debugger;
        var action = component.get("c.getPORecListDetails");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                component.set("v.totalPOs", result.totalPOs);
                component.set("v.totalPOAmount", result.totalPOAmount);
                component.set("v.totalPaidAmount", result.totalPaidAmount);
                component.set("v.totalRemainingAmount", result.totalRemainingAmount);
                component.set("v.orderedPercent", result.orderedPercent);
                component.set("v.paidPercent", result.paidPercent);
            } 
        });
        $A.enqueueAction(action);
    },
    
    
    
    readFiles2 : function(component, event, helper, file,poId){
        // debugger;
        var filesList = component.get("v.fileData2");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData2 = {
            'fileName': file.name,
            'fileContent': base64,
            'POId': poId
        }
        console.log(JSON.stringify(fileData2));
        component.get("v.fileData2").push(fileData2);
        component.set("v.fileData2",component.get("v.fileData2"))
        
        var names = []
        
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            var name = {};
            name['FileName'] = [];
            name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
            name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
            names.push(name);
        }
        component.set("v.FileNameList",names);
        component.set("v.fileBody", filesList.fileName);
    }
    reader.readAsDataURL(file);
}
 

})