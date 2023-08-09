({
    /*
     * This methid takes recordTypeId and entityTypeName parameters
     * and invoke standard force:createRecord event to create record
     * if recordTypeIs is blank, this will create record under master recordType
     * */
    fetchListOfRecordTypes: function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeValuesforcustomersite");
        var defaultRecordType = $A.get("$Label.c.DefaultCaseRecordType");
        
        action.setParams({
            "objectName" : "Case",
            "defaultRecordType" :defaultRecordType
        });
        action.setCallback(this, function(response) {
            var mapOfRecordTypes = response.getReturnValue();
            component.set("v.mapOfRecordType", mapOfRecordTypes);
            var recordTypeList = [];
            //Creating recordTypeList from retrieved Map
            
            for(var key in mapOfRecordTypes){
                recordTypeList.push(mapOfRecordTypes[key]);
            }
            if(recordTypeList.length == 0){
                helper.closeModal();                
                helper.showCreateRecordModal(component, "", "Case");
            } else{
                var finalList =[],defaultValue=[];
                defaultValue.push(recordTypeList.reverse()[0]);
                recordTypeList.shift();
                finalList = defaultValue.concat(recordTypeList.sort());
                component.find("recordTypePickList").set("v.value",defaultValue);
                component.set("v.lstOfRecordType", finalList);
            }
        });
        $A.enqueueAction(action);
    },
    getCustomerSiteDetail : function(component,event,helper) {
        var action = component.get("c.getCustomerSiteDetail");
        var customerSiteId = component.get("v.recordId");
        action.setParams({
            "customerSiteId" : customerSiteId
        });
        action.setCallback(this, function(response) {
            var customeSiteDetail = response.getReturnValue();
            component.set("v.customeSiteDetail", customeSiteDetail);
        });
        
        $A.enqueueAction(action);
    },
    getSelectRecordType: function(component,event, helper, sObjectRecord){
        var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
        if(selectedRecordTypeName != ""){
            var selectedRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeId;
            //finding selected recordTypeId from recordTypeName
            for(var key in selectedRecordTypeMap){
                if(selectedRecordTypeName == selectedRecordTypeMap[key]){
                    selectedRecordTypeId = key;//match found, set value in selectedRecordTypeId variable
                    break;
                }
            }
            helper.closeModal();
            helper.showCreateRecordModal(component, selectedRecordTypeId, "Case");
        } else{
            alert('You did not select any record type');
        }
    },
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {        
        var createRecordEvent = $A.get("e.force:createRecord");
        var customeSiteDetail = component.get("v.customeSiteDetail");
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                    "defaultFieldValues": {
                        "Customer_Site__c" :  component.get("v.recordId"),
                        "Opportunity__c":customeSiteDetail.Opportunity__c,
                        "AccountId" : customeSiteDetail.Account__c
                    }
                });
            }
            createRecordEvent.fire();
        }
    },
    /*
     * closing quickAction modal window
     * */
    closeModal : function(){
        var closeEvent = $A.get("e.force:closeQuickAction");
        if(closeEvent){
            closeEvent.fire();
        } else{
            alert('force:closeQuickAction event is not supported in this Ligthning Context');
        }
    },
})