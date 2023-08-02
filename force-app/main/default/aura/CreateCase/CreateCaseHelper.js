({
    /*
     * This methid takes recordTypeId and entityTypeName parameters
     * and invoke standard force:createRecord event to create record
     * if recordTypeIs is blank, this will create record under master recordType
     * */
    fetchListOfRecordTypes: function(component, event, helper) {
        var checkOppRecord = window.location.pathname;
        var opportunityId;
        var currentOppId = component.get("v.recordId");
        var defaultRecordType = $A.get("$Label.c.DefaultCaseRecordType");

        if(!currentOppId.startsWith("006")){
            component.set("v.recordId",null);
            if(checkOppRecord.includes("/lightning/r/Opportunity/")){
                var res = checkOppRecord.split("/");
                if(res[4].startsWith("006")){
                    component.set("v.recordId",res[4]);
                }
            }
        }
        var action = component.get("c.fetchRecordTypeValues");
        action.setParams({
            "objectName" : "Case",
            "defaultRecordType" : defaultRecordType
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
                var sortedLits = recordTypeList.reverse();
                component.find("recordTypePickList").set("v.value",sortedLits[0]);
                component.set("v.lstOfRecordType", sortedLits);            
            }
        });
        $A.enqueueAction(action);
    },
    getOpprtunityDetails : function(component,event,helper) {
        var action = component.get("c.getOpportunityDetail");
        var opp = component.get("v.recordId");

        action.setParams({
            "opportunityId" : opp
        });
        
        action.setCallback(this, function(response) {
            var opportunityDetail = response.getReturnValue();
            component.set("v.opportunityDetail", opportunityDetail);
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
        var opportunityDetail = component.get("v.opportunityDetail");
        console.log(opportunityDetail);
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                    "defaultFieldValues": {
                        "Opportunity__c": component.get("v.recordId"),
                        "AccountId" : opportunityDetail.AccountId
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