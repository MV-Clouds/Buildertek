({
    
    
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currencycode",response.getReturnValue());
                
                
            } 
        });
        $A.enqueueAction(action);		
    },
    
    
    getIsCOEnable : function (component, event, helper) {
        debugger;
        var btadminaction = component.get("c.getChangeOrderBtValue");
        btadminaction.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == true){
                    component.set("v.IsCOEnable",true);
                }else{
                    component.set("v.IsCOEnable",false);
                }
            }     
        });
        $A.enqueueAction(btadminaction);
    },
 
    
    
    getrelatedrfqvendorlist : function(component, event, helper){
        
          
        debugger;
        component.set('v.mycolumns', [
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
            {label: 'Vendor', fieldName: 'buildertek__Owner_Account__c', type: 'text'},
            {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'},
            {label: 'PaymentApp Name', fieldName: 'Name', type: 'text'},
           // { label: 'Amount', fieldName: 'buildertek__Original_Contract_Sum__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }}}
            {label: 'Amount', fieldName: 'buildertek__Original_Contract_Sum__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            }
            
        ]);
        component.set('v.mycolumns2', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
            {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'},
           // {label: 'Total Amount', fieldName: 'buildertek__Total_Amount_Tax__c',  type: 'currency',typeAttributes:{minimumFractionDigits :'2', currencyCode: { fieldName: 'CurrencyIsoCode'}} }
            {label: 'Total Amount', fieldName: 'buildertek__Total_Amount_Tax__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            }
            
        ]);
        
    },
    
    
    
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Continuation Details"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "", //set icon you want to set
                iconAlt: "" //set label tooltip you want to set
            });
        });
        
    },
    groupRecords : function(component, event, helper) {
        debugger;
        var result = {};
        var records = component.get("v.continuationSheetLines")
        component.set("v.sheetLineInGrp",records)
        result.groupHierarchy = groupRecords(records);
        
        function groupRecords(data,res) {
            var listOfRecords = [];
            let recordsMap = new Map();
            if(data){
                if(data.length){
                    for (var i in data) {
                        if (!recordsMap.has(data[i].buildertek__Budget_Grouping__c  != undefined ? data[i].buildertek__Budget_Grouping__c :'No Grouping' )) {
                            recordsMap.set(data[i].buildertek__Budget_Grouping__c  != undefined ? data[i].buildertek__Budget_Grouping__c :'No Grouping', []);
                        }
                        recordsMap.get(data[i].buildertek__Budget_Grouping__c  != undefined ? data[i].buildertek__Budget_Grouping__c :'No Grouping').push(JSON.parse(JSON.stringify(data[i])));
                    }
                   
                    
                    if(component.get("v.isCommUser") == true){
                        debugger;
                        var result = Array.from(recordsMap.entries());
                        for (var i in result) {
                            var obj = {};
                            obj.grouping1Name = result[i][0];
                            obj.subGroupRecords = subGroupRecords(result[i][1]);
                            obj['scheduleValue'] = 0;
                            obj['fromPrevApp'] = 0;
                            obj['workCompleted'] = 0;
                            obj['materialStored'] = 0;
                            obj['totalWork'] = 0;
                            obj['gcTotal'] = 0;
                            obj['balanceTotal'] = 0;
                            for(var j=0; j< obj.subGroupRecords.length;j++){
                                for(var k =0;k<obj.subGroupRecords[j].records.length; k++){
                                    obj['balanceTotal']+= obj.subGroupRecords[j].records[k].buildertek__Vendor_Balance_To_Finish__c;
                                    obj['materialStored'] += obj.subGroupRecords[j].records[k].buildertek__Vendor_Material_Presently_Stored__c ? obj.subGroupRecords[j].records[k].buildertek__Vendor_Material_Presently_Stored__c : 0;
                                    if(obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c){
                                      //  alert('hai'+obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c);
                                        obj['scheduleValue'] += Number(obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c.toFixed(2));
                                    }else{
                                        obj['scheduleValue'] +=  0
                                    }
                                    obj['totalWork'] += obj.subGroupRecords[j].records[k].buildertek__Vendor_Total__c;
                                    obj['workCompleted'] += obj.subGroupRecords[j].records[k].buildertek__Vendor_Work_Completed_This_Period__c;
                                    obj['fromPrevApp'] += obj.subGroupRecords[j].records[k].buildertek__Vendor_Work_Completed_from_Previous_Appl__c;
                                   
                                    obj['gcTotal'] +=  obj.subGroupRecords[j].records[k].buildertek__Vendor_G_C__c?(obj.subGroupRecords[j].records[k].buildertek__Vendor_Total__c / obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c)*100 : 0;
                                }
                            }
                           
                            obj['gcTotal']  = (obj['totalWork'] / obj['scheduleValue'])*100;
                            var totalRetainage =  (obj['fromPrevApp']+ obj['workCompleted'] + obj['materialStored'])*component.get("v.Retainage")/100;
                            obj['retainage'] = totalRetainage;
                            console.log(obj)
                            obj["scheduleValue"] = Number(obj["scheduleValue"].toFixed(2))
                            obj['balanceTotal'] =  Number(obj["balanceTotal"].toFixed(2))
                            listOfRecords.push(obj);
                        }
                        return listOfRecords;
                    }
                    else{
                        debugger;
                        var result = Array.from(recordsMap.entries());
                        for (var i in result) {
                            var obj = {};
                            obj.grouping1Name = result[i][0];
                            obj.subGroupRecords = subGroupRecords(result[i][1]);
                            obj['scheduleValue'] = 0;
                            obj['fromPrevApp'] = 0;
                            obj['workCompleted'] = 0;
                            obj['materialStored'] = 0;
                            obj['totalWork'] = 0;
                            obj['gcTotal'] = 0;
                            obj['balanceTotal'] = 0;
                            for(var j=0; j< obj.subGroupRecords.length;j++){
                                for(var k =0;k<obj.subGroupRecords[j].records.length; k++){
                                    obj['balanceTotal']+= obj.subGroupRecords[j].records[k].buildertek__Balance_To_Finish__c;
                                    obj['materialStored'] += obj.subGroupRecords[j].records[k].buildertek__Material_Presently_Stored__c ? obj.subGroupRecords[j].records[k].buildertek__Material_Presently_Stored__c : 0;
                                    if(obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c){
                                        obj['scheduleValue'] += Number(obj.subGroupRecords[j].records[k].buildertek__Scheduled_Value__c.toFixed(2));
                                    }else{
                                        obj['scheduleValue'] +=  0
                                    }
                                    obj['totalWork'] += obj.subGroupRecords[j].records[k].buildertek__Total__c;
                                    obj['workCompleted'] += obj.subGroupRecords[j].records[k].buildertek__Work_Completed__c;
                                    obj['fromPrevApp'] += obj.subGroupRecords[j].records[k].buildertek__Work_Completed_from_Previous_Application__c;
                                    
                                    obj['gcTotal'] +=  obj.subGroupRecords[j].records[k].buildertek__G_C__c?obj.subGroupRecords[j].records[k].buildertek__G_C__c /100 : 0;
                                }
                            }
                             obj['gcTotal']  = (obj['totalWork'] / obj['scheduleValue'])*100;
                            var totalRetainage =  (obj['fromPrevApp']+ obj['workCompleted']+ obj['materialStored'])*component.get("v.Retainage")/100;
                            
                            obj['retainage'] = totalRetainage;
                            console.log(obj)
                            obj["scheduleValue"] = Number(obj["scheduleValue"].toFixed(2))
                            obj['balanceTotal'] =  Number(obj["balanceTotal"].toFixed(2))
                            listOfRecords.push(obj);
                            
                        }
                        return listOfRecords; 
                        
                    }
                    
                }
            }
            
            
        }
        
        function subGroupRecords(data) {
            var listOfRecords = [];
            var recordValue = [];
            let recordsMap = new Map();
            if(data){
                if(data.length){
                    for (var i in data) {
                        if (!recordsMap.has( data[i].buildertek__Grouping2__c ? data[i].buildertek__Grouping2__c : 'No Grouping2')) {
                            recordsMap.set(  data[i].buildertek__Grouping2__c ? data[i].buildertek__Grouping2__c : 'No Grouping2', []);
                        }
                        recordsMap.get( data[i].buildertek__Grouping2__c ? data[i].buildertek__Grouping2__c : 'No Grouping2').push(JSON.parse(JSON.stringify(data[i])));
                    }
                    var result = Array.from(recordsMap.entries());
                    for (var i in result) {
                        var obj = {};
                        var recordValue = [];
                        //obj.recordValue = [];
                        var sumCol = 0;
                        obj.grouping2Name = result[i][0] == undefined ? 'No Grouping' : result[i][0];
                        obj.records = result[i][1];
                        listOfRecords.push(obj);
                    }
                    return listOfRecords;
                }
            }
            
            
        }
        component.set("v.groupedRecords",result.groupHierarchy)
        console.log(result.groupHierarchy)   
        //$A.enqueueAction(totalByGroupAction);
    },
    Submitpayment : function(component, event, helper) {
        var action = component.get("c.submitPAForView");
        action.setParams({
            recordId : component.get("v.commrecordId"),
            todayDate : new Date()
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == "success"){
                    component.set("v.IsSubmitted",true);
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.commrecordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                    $A.get('e.force:refreshView').fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        // message: 'Payment Application Submitted For View Successfully',
                        message: 'Payment Application Submitted Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }     
        });
        $A.enqueueAction(action);
    },
    getuploadSignature : function (component, event) {
        var recId = component.get("v.commrecordId");
        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var quoteLine = component.get("v.quoteLines");
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];
        
        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName,
            LienTest : quoteLine
        });
        signatureaction.setCallback(this, function (e) {
            if (e.getState() == 'SUCCESS') {
                debugger;
                var result = e.getReturnValue();
                component.set("v.Spinner", false);
                component.set("v.Spinner2", false);
                component.set("v.fileimageId", result);
                component.set('v.Issignlienrelease', false);
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();*/
                $A.get("e.force:closeQuickAction").fire();
                // location.reload();
                
            } else {
                //   alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);
        
    },
    
    
    getTemplateBody: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getLienRelease");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.quoteLines", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPaymentRec: function (component, event, helper) {
        debugger;
        var recordId = component.get("v.ClonerecordId");
        // alert(recordId);
        var action = component.get("c.getPaymentRecord");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    component.set("v.isimportedpaymentApp", result.buildertek__Is_Imported__c);
                }
            }
        });
        $A.enqueueAction(action);
    }
    
    
})