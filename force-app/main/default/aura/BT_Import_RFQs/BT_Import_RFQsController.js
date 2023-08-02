({
    doInit : function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var vendorValue = component.get("v.searchRfqVendorFilter");
        var tradeValue = component.get("v.searchRfqTradeFilter");
        var descriptionValue = component.get("v.searchRfqDesFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        var vendorValue = component.get("v.searchRfqVendorFilter");
        var tradeValue = component.get("v.searchRfqTradeFilter");
        var descriptionValue = component.get("v.searchRfqDesFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
    },
    
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        var vendorValue = component.get("v.searchRfqVendorFilter");
        var tradeValue = component.get("v.searchRfqTradeFilter");
        var descriptionValue = component.get("v.searchRfqDesFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
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
    
    addToBudget: function (component, event, helper) {
        var records = component.get("v.rfqRecordList");
        var rfqIds = component.get("v.listOfSelectedRFQIds");
        var budgetId = component.get("v.recordId");
        if(rfqIds.length>0){
            helper.addRFQToBudget(component, event, helper, rfqIds, budgetId);
        }else{
            helper.showErrorToast(component,event,helper,'Error!','Please Select RFQ.');
        }
    },
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doRfqSearch: function (component, event, helper) {
        //var value = component.get("v.searchRfqFilter");//event.getSource().get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var vendorValue = component.get("v.searchRfqVendorFilter");
        var tradeValue = component.get("v.searchRfqTradeFilter");
        var descriptionValue = component.get("v.searchRfqDesFilter");
        helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
    },
})