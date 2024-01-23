({
    
    
    getPurchaseOrders : function(component, event, helper, pageNumber, pageSize) {
        component.set("v.Spinner", true);
        component.set("v.isExpanded", false);
        // debugger;
        var purchaseOrderFilter = component.get("v.searchItemFilter");
        
        var descriptionValue = component.get("v.searchDescriptionFilter");
        
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");
        
        var projectValue = component.get("v.searchProjectFilter");

        var productValue = component.get("v.searchProductFilter");

        var permitValue = component.get("v.searchPermitFilter");

        // var searchStatusFilter = component.get("v.searchStatusFilter");
   
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
            "productFilter" : productValue,
            "permitFilter" : permitValue
            // "statusFilter" : searchStatusFilter
        });
        action.setCallback(this, function(response){
            
            // debugger;
            var state = response.getState();
            console.log('State => ' + state);
            if(state === "SUCCESS"){
                // debugger;
                
                var result = response.getReturnValue();
                console.log({result});
                if(result != null && result.length > 0){
                    
                    
                    component.set("v.masterBudgetsList", result);
                    component.set("v.PageNumber", result[0].pageNumber);
                    component.set("v.TotalRecords", result[0].totalRecords);
                    component.set("v.RecordStart", result[0].recordStart);
                    component.set("v.RecordEnd", result[0].recordEnd);
                    component.set("v.orgCurr", result[0].orgCurr);
                                       
                    component.set('v.PaginationList', result);
                    if (result[0].poRecInner != undefined) {
                        for (let i = 0; i < result[0].poRecInner.length; i++) {
                            if (result[0].poRecInner[i].poRecord.hasOwnProperty('buildertek__Vendor__r')) {
                                let name = result[0].poRecInner[i].poRecord.buildertek__Vendor__r.Name;
                                if (name != undefined && name.length > 40) {
                                    result[0].poRecInner[i].poRecord.buildertek__Vendor__r.Name = name.slice(0, 40) + '...';
                                }
                            }
                        }
                    }
                    console.log(' --- --- --- doInit --- --- --- ');
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

        helper.getPOListDetails(component, event, helper);
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
                console.log({result});
                component.set("v.totalPOs", result.totalPOs);
                component.set("v.totalPOAmount", result.totalPOAmount);
                component.set("v.totalPaidAmount", result.totalPaidAmount);
                // component.set("v.totalRemainingAmount", result.totalRemainingAmount);
                component.set("v.totalRemainingAmount", (result.totalPOAmount - result.totalPaidAmount));   // Changes for BUIL - 3638
                component.set("v.orderedPercent", result.orderedPercent);
                // component.set("v.paidPercent", result.paidPercent);
                component.set("v.paidPercent", (result.totalPaidAmount/result.totalPOAmount)*100);          // Changes for BUIL - 3638

                var poFilter = component.get("v.searchItemFilter");
                var  poLineFilter = component.get("v.searchDescriptionFilter");
                var tradeTypeFilter = component.get("v.searchTradeTypeFilter");
                var projectFilter = component.get("v.searchProjectFilter");
                var productFilter = component.get("v.searchProductFilter");
                var permitFilter = component.get("v.searchPermitFilter");
                
                if(poFilter != '' || poLineFilter != '' || tradeTypeFilter != '' || projectFilter != '' || productFilter != '' || permitFilter != ''){
                    component.set("v.TotalPages", 1);
                } else{
                    component.set("v.TotalPages", Math.ceil(result.totalPOs / component.get("v.pageSize")));
                }
                var TotalPages = component.get("v.TotalPages");
                console.log('TotalPages => ' + TotalPages);
            } 
        });
        $A.enqueueAction(action);
    },
    
    
    
    readFiles2: function(component, event, helper, file, poId) {
        let maxSize = 4194304;
        // let maxSize = 2097152;
        let filesList = component.get("v.fileData2");
        let reader = new FileReader();
    
        reader.onload = () => {
            let base64 = reader.result.split(',')[1];
            let fileData2 = {
                'fileName': file.name,
                'fileContent': base64,
                'POId': poId
            };
    
            let existingFilesSize = 0;
    
            for (let i = 0; i < component.get("v.fileData2").length; i++) {
                console.log('existingFilesSize => ' + existingFilesSize);
                console.log('file.size => ' + component.get("v.fileData2")[i].fileContent.length);
                existingFilesSize += component.get("v.fileData2")[i].fileContent.length;
            }
    
            let totalFileSize = existingFilesSize + file.size;
    
            if (totalFileSize < maxSize) {
                component.get("v.fileData2").push(fileData2);
                component.set("v.fileData2", component.get("v.fileData2"));
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": "File Size Exceeded",
                    "message": "The uploaded file exceeds the limit. Please upload a smaller file."
                });
                toastEvent.fire();
                return;
            }
    
            let names = [];
    
            for (let i = 0; i < component.get("v.fileData2").length; i++) {
                let name = {
                    'FileName': component.get("v.fileData2")[i].fileName,
                    'poId': component.get("v.fileData2")[i].POId
                };
                names.push(name);
            }
    
            component.set("v.FileNameList", names);
            component.set("v.fileBody", filesList.fileName);
        };
    
        reader.readAsDataURL(file);
    },        

    settempId : function(component, poId){
        var action = component.get("c.addEmailTemplateId");
        action.setParams({
            POIDs: poId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('error-->',errors[0].message);
                } else {
                    console.log('Unknown error');
                }
            } else if (state === "INCOMPLETE") {
                console.log('Server request incomplete');
            }
        });
        $A.enqueueAction(action);
    }
})