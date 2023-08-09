({
    /*
     * This methid takes recordTypeId and entityTypeName parameters
     * and invoke standard force:createRecord event to create record
     * if recordTypeIs is blank, this will create record under master recordType
     * */
    fetchListOfRecordTypes: function(component, event, helper) {
        var checkOppRecord = window.location.pathname;
        var currentOppId = component.get("v.recordId");
        var action = component.get("c.fetchRecordTypeValues");
        action.setParams({
            "objectName" : "Issue__c",
            "defaultRecordType" : ""
        });
        action.setCallback(this, function(response) {
            var mapOfRecordTypes = response.getReturnValue();
            component.set("v.mapOfRecordType", mapOfRecordTypes);
            var recordTypeList = [];            
            for(var key in mapOfRecordTypes){
                recordTypeList.push(mapOfRecordTypes[key]);
            }
            if(recordTypeList != []){
                component.set("v.lstOfRecordType", recordTypeList);
            }
        });
        $A.enqueueAction(action);
    },
    getOpprtunityDetails : function(component,event,helper) {
        var recordId = component.get("v.recordId");  
        if(recordId!= null && recordId != undefined && !recordId.startsWith("500")){
            var action = component.get("c.getIssueDetail");  
            action.setParams({
                "workOrderId" : recordId
            });
            action.setCallback(this, function(response) {
                var mapOfRecordTypes = response.getReturnValue();
                component.set("v.workOrderDetail", mapOfRecordTypes);
            });
            $A.enqueueAction(action);
        }
        else if(recordId!= null && recordId != undefined && recordId.startsWith("500")){
            var action = component.get("c.getCaseDetailForIssue");
            action.setParams({
                "CaseId" : recordId
            });
            action.setCallback(this, function(response) {
                var caseDetail = response.getReturnValue();
                component.set("v.caseDetail", caseDetail);
            });
            $A.enqueueAction(action);
        }
        
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
            component.set("v.selectedRecordTypeId",selectedRecordTypeId);
            helper.showCreateRecordModal(component, selectedRecordTypeId, "Issue__c");
        } else{
            alert('You did not select any record type');
        }
    },
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {        
        var createRecordEvent = $A.get("e.force:createRecord");
        var workOrderDetail = component.get("v.workOrderDetail");
        var caseDetail = component.get("v.caseDetail");
        var dateIdentified;
        var oppid;
        var shippingcity,shippingcountry,shippingState,shippingPostalCode,shippingStreet;
        var caseId,workOrderId,accountId,contactId;
        if(workOrderDetail!= null && workOrderDetail != undefined){
            workOrderId =workOrderDetail.Id;
            if(workOrderDetail.CaseId != null && workOrderDetail.CaseId != undefined){
                dateIdentified = workOrderDetail.Case.Intelligence_Start_Date__c;
                caseId=workOrderDetail.CaseId;
				contactId = workOrderDetail.Case.ContactId;
                if(workOrderDetail.Case.AccountId != null && workOrderDetail.Case.AccountId != undefined){
                    accountId = workOrderDetail.Case.AccountId;
                    shippingcity=workOrderDetail.Case.Account.ShippingCity;
                    if(workOrderDetail.Case.Account.ShippingCountry =="USA"){
                        shippingcountry = "United States";
                    }
                    else{
                        shippingcountry=workOrderDetail.Case.Account.ShippingCountry;
                    }                    
                    shippingState=workOrderDetail.Case.Account.ShippingState;
                    shippingPostalCode = workOrderDetail.Case.Account.ShippingPostalCode;
                    shippingStreet = workOrderDetail.Case.Account.ShippingStreet;
                }
            }
        }
        else if(caseDetail!= null && caseDetail != undefined){
            dateIdentified = caseDetail.Intelligence_Start_Date__c;
            caseId = caseDetail.Id;
			contactId = caseDetail.ContactId;  
            if(caseDetail.AccountId != null && caseDetail.AccountId != undefined){
                accountId = caseDetail.AccountId;
                shippingcity=caseDetail.Account.ShippingCity;
                if(caseDetail.Account.ShippingCountry =="USA"){
                    shippingcountry = "United States";
                }
                else{
                    shippingcountry=caseDetail.Account.ShippingCountry;
                }
                oppid=caseDetail.Opportunity__c;
                shippingState=caseDetail.Account.ShippingState;
                shippingPostalCode = caseDetail.Account.ShippingPostalCode;
                shippingStreet = caseDetail.Account.ShippingStreet;
            }
            
        }
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                    "defaultFieldValues": {
                        "Source_Work_Order__c": workOrderId,
                        "Case__c" : caseId,
                        "Date_Identified__c" : dateIdentified,
                        "Shipping_Street_1__c" : shippingStreet,
                        "Shipping_City__c" : shippingcity,
                        "Shipping_State_Province__c" :shippingState,
                        "Shipping_Country__c" : shippingcountry,
                        "Shipping_Postal_Code__c" : shippingPostalCode,
                        "Customer_Account__c" :accountId,
                        "Opportunity__c":oppid,
                        "Customer_Contact__c" : contactId
                    }
                });
            } 
            createRecordEvent.fire();
        }        
    },
    
})