({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
        if(!recordId){
            recordId = component.get("v.recordId");
        }
        //alert(recordId)
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter");
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
        var priceBook = component.get("v.searchPriceBookFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook);
       
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter");
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
         var priceBook = component.get("v.searchPriceBookFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, productTypeValue, tradeValue, productFamilyValue, productValue, productCategoryValue, priceBook);
    },
    
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter");
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
         var priceBook = component.get("v.searchPriceBookFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, productTypeValue, tradeValue, productFamilyValue, productValue, productCategoryValue, priceBook);
    },
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedRFQIds");
        var getAllId = component.find("checkRFQ");
       
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedRFQIds",selectedRfqIds);
    },
    
    selectAllRfq : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.rfqRecordList")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                        //rfqRecordList[i].checkValue = "true";
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                        //rfqRecordList[i].checkValue = "true";
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    addToPOLines: function (component, event, helper) {
         var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
        if(!recordId){
            recordId = component.get("v.recordId");
        }
        
        //alert('record in add product controller'+recordId)
        var records = component.get("v.rfqRecordList");
        var productIds = component.get("v.listOfSelectedRFQIds");
        var RfqId = recordId;
        var Spinner = component.get("v.spinner");
        if(productIds.length>0){
            helper.addProductsToPO(component, event, helper, productIds, RfqId);
        }else{
            helper.showErrorToast(component,event,helper,'Error!','Please Select RFQ.');
        }
    },
    
    closeModal: function (component, event, helper) {
         var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        
        .catch(function(error) {
            console.log(error);
        });
        //component.get("v.onCancel")(); 
    },
    
    doRfqSearch: function (component, event, helper) {
        //var value = component.get("v.searchRfqFilter");//event.getSource().get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var productFamilyValue = component.get("v.searchProductFamilyFilter");
        var productValue = component.get("v.searchProductFilter");
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var tradeValue = component.get("v.searchTradeTypeFilter");
        var priceBook = component.get("v.searchPriceBookFilter");
      
        helper.getRfqList(component, event, helper, pageNumber, pageSize, productFamilyValue, tradeValue, productTypeValue, productValue, productCategoryValue, priceBook);
    },
})