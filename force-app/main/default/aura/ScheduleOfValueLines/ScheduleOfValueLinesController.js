({
    doInit : function(component, event, helper) {
        debugger;
        
        
        
        helper.getcurr(component, event, helper);
        
        
        
        component.set("v.SOVtotaltext","Schedule value total");
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
                
                
                var commUserId = result.userRecord.Id;
                component.set("v.IsCurrencyEnabled",result.isCurrencyEnabled);
                
                if(result.userRecord.IsPortalEnabled == true){
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Vendorname",result.userRecord.buildertek__Account_Id__c); 
                    
                    component.set("v.Iscommunity",true);
                    component.set("v.isCommUser",true)
                    
                    
                    var loc = location.href.split('id=')[1];
                    var recordId = location.href.split('id=')[1].split("&dummy=")[0];
                    component.set("v.recordId",recordId)  
                }else{
                    var myPageRef = component.get("v.pageReference");
                    var recordId = myPageRef.state.buildertek__parentId;
                    
                    if(recordId != null || recordId != undefined){
                        component.set("v.recordId",recordId);
                    }else{
                        var recId = component.get("v.recordId");
                        component.set("v.recordId",recId);
                    }
                }
                
                
                
                debugger;
                var action7 = component.get("c.getSovType");
                action7.setParams({
                    "recordId": recordId
                });
                action7.setCallback(this, function (response1) {
                    if (response1.getState() == 'SUCCESS') {
                        
                        var result = response1.getReturnValue();
                        if(result.RecordType.Name == 'Standard'){
                            component.set("v.isStndSOV",true);
                            
                        }
                    }
                    
                });
                $A.enqueueAction(action7);
      
                component.set('v.up',true);
         
                var action1 = component.get("c.getSovLines");
                action1.setParams({
                    recordId: recordId
                });
                action1.setCallback(this, function(response){
                    debugger;
                    
                    
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                        
                        if(result.length > 0){
                            
                            debugger;
                            component.set("v.continuationSheetLines",result)
                            
                            console.log('continuationSheetLines----------->',result);
                            
                            if(component.get("v.IsCurrencyEnabled") == true){
                                component.set("v.ISOCode",result[0].CurrencyIsoCode);
                            }else{
                                component.set("v.ISOCode","USD");
                            }
                            
                            if(component.get("v.Iscommunity")== true){
                                //component.set("v.sovTotal",result[0]['buildertek__Schedule_of_Values__r']['buildertek__Vendor_Total_CostsTotal_Costs__c'])
                            }else{
                                //component.set("v.sovTotal",result[0]['buildertek__Schedule_of_Values__r']['buildertek__Total_Costs__c'])
                            }
                            
                            
                            component.set("v.continuationSheetLinesDup",result) 
                            var sovlist = component.get("v.continuationSheetLines");
                            var aggresult = 0; 
                            var scheduleTotal = 0;
                            
                            for(var i=0;i < sovlist.length;i++){
                                
                                
                                if(component.get("v.Iscommunity")== true){
                                    if(sovlist[i].buildertek__Vendor_Scheduled_Value__c){
                                        scheduleTotal += Number(sovlist[i].buildertek__Vendor_Scheduled_Value__c);
                                        
                                        sovlist[i].buildertek__Vendor_Scheduled_Value__c = sovlist[i].buildertek__Vendor_Scheduled_Value__c.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                    }
                                }else{
                                    if(sovlist[i].buildertek__Scheduled_Value__c){
                                        scheduleTotal += Number(sovlist[i].buildertek__Scheduled_Value__c);
                                        sovlist[i].buildertek__Scheduled_Value__c = sovlist[i].buildertek__Scheduled_Value__c.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                    }
                                } 
                            }
                            component.set("v.sovTotal",scheduleTotal);
                            component.set("v.continuationSheetLines",sovlist);
                        }else{
                            debugger;
                            component.set("v.continuationSheetLines",result) 
                            component.set("v.sovTotal",0);
                            component.set("v.continuationSheetLinesDup",result) 
                            var action4 = component.get("c.getSovforCurrency");
                            action4.setParams({
                                recordId: recordId
                            });
                            action4.setCallback(this, function(response){
                                if(response.getState() === "SUCCESS"){
                                    var result = response.getReturnValue();
                                    var arr = []
                                    var emptyObj;
                                    
                                    if(component.get("v.Iscommunity")== true){
                                        if(component.get("v.IsCurrencyEnabled") == true){
                                            component.set("v.ISOCode",(result.CurrencyIsoCode));
                                            emptyObj = {
                                                'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                                                'buildertek__Description_of_Work__c': "",
                                                'buildertek__Vendor_Scheduled_Value__c' : "",
                                                'buildertek__Item__c': "",
                                                'CurrencyIsoCode': component.get("v.ISOCode"),
                                                'Name': ""
                                            }
                                        }else{
                                            
                                            emptyObj = {
                                                'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                                                'buildertek__Description_of_Work__c': "",
                                                'buildertek__Vendor_Scheduled_Value__c' : "",
                                                'buildertek__Item__c': "",
                                                
                                                'Name': ""
                                            }
                                        } 
                                    }else{
                                        if(component.get("v.IsCurrencyEnabled") == true){
                                            component.set("v.ISOCode",(result.CurrencyIsoCode));
                                            emptyObj = {
                                                'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                                                'buildertek__Description_of_Work__c': "",
                                                'buildertek__Scheduled_Value__c' : "",
                                                'buildertek__Item__c': "",
                                                'CurrencyIsoCode': component.get("v.ISOCode"),
                                                'Name': ""
                                            }
                                        }else{
                                            
                                            emptyObj = {
                                                'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                                                'buildertek__Description_of_Work__c': "",
                                                'buildertek__Scheduled_Value__c' : "",
                                                'buildertek__Item__c': "",
                                                
                                                'Name': ""
                                            }
                                        }  
                                    }
                                    
                                    arr.push(emptyObj)
                                    component.set("v.continuationSheetLines",arr) 
                                }
                            });
                            $A.enqueueAction(action4); 
                            
                        }
                        
                    }
                });
                $A.enqueueAction(action1);
                
                var action2 = component.get("c.isSovSubmitted");
                action2.setParams({
                    recordId: component.get("v.recordId")
                });
                action2.setCallback(this, function(response){
                    debugger;
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                        if(result == 'Company Approved'){
                            component.set("v.IsSubmitted", true);
                            component.set("v.statusDisable", true);
                            
                        }
                        if(result == 'Customer Approved'){
                            component.set("v.statusDisable", true);
                        }
                        
                        if(result == "Vendor Submitted"){
                            component.set("v.IsSubmitted", true)
                        }
                    }
                });
                $A.enqueueAction(action2);
                
                var action3 = component.get("c.getSOVName");
                action3.setParams({
                    recordId: component.get("v.recordId")
                });
                action3.setCallback(this, function (response) {
                    debugger;
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var  result = response.getReturnValue();
                        component.set("v.SOVName",result)
                    }
                });
                $A.enqueueAction(action3);  
                
            }
        });
        $A.enqueueAction(action);
        
        
       

    },
    
    
    sovChange : function(component, event, helper){
      
        
        component.set("v.indexValWithError",event.target.getAttribute('data-id'));
        debugger;
        var sovValue;
        var inputField = event.getSource();
        
        var sov = event.getSource().get("v.value");
        sov = sov.toString();
        if(sov.toString().includes("$")){
           // sovValue = sov.split('$')[1];
           sovValue = sov.toString().replace('$','')
           sovValue = sov;
        }else{
            if(sov.toString() == ""){
                sovValue = ''; 
            }else{
                sovValue = sov; 
            }
           
        }
        var regExp = /[a-zA-Z]/g;
        var reg = /[!@#%^&*()_+\-=\[\]{};:\\|,<>\/?]+/;
        
        var testString = "john";
        sovValue = sovValue.replace(/,/g, "")
       var updateNumvalues =  sovValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        inputField.set("v.value",updateNumvalues);
       
        if(sovValue != null && sovValue != undefined){
            if(regExp.test(sovValue) || reg.test(sovValue) ||  sovValue.indexOf('"') > -1 ||  sovValue.indexOf("'") > -1){
                inputField.setCustomValidity("Enter a valid value");
                inputField.reportValidity();
                
                
                 var total = component.get("v.sovTotal");
                var sovLines =  component.get("v.continuationSheetLinesDup");
                
            }else{
                
                component.set("v.isscheduleValError",false);
                inputField.setCustomValidity("");
                inputField.reportValidity();
                if(sovValue.includes("$")){
                    
                    sovValue = Number(sovValue.split('$')[1].replace(/,/g,''));
                    
                }
                var index = event.getSource().get("v.label");
                var total = component.get("v.sovTotal");
                var sovLines =  component.get("v.continuationSheetLinesDup");
                //sovValue.replace(/,/g, "");
                
                if(sovValue){
                  
                   total = Number(total) - Number(component.get("v.preval")) + Number(sovValue);
                   component.set("v.sovTotal",Number(total));
                    
                }else{
                    total = Number(total) - Number(component.get("v.preval"));
                   component.set("v.sovTotal",Number(total));
                }
                
            }
        }
        
       
    },
    
    inputClick: function(component, event, helper){
        debugger;
        var sov = event.getSource().get("v.value");
        var sovValue;
        if(sov != undefined){
            if(sov.toString().includes("$")){
                sovValue = sov.replace('$','');
                
            }else{
                sovValue = sov;
            } 
        }
        
        
        var regExp = /[a-zA-Z]/g;
        var reg = /[!@#%^&*()$_+\-=\[\]{};:\\|,<>\/?]+/;
         
        if(sovValue != undefined){
            if(regExp.test(sovValue) || reg.test(sovValue) ||  sovValue.toString().includes("'") ||  sovValue.toString().includes('"')){
                component.set("v.preval",Number(sovValue.replace(/\D/g, "")));
            }
            else{
                
                component.set("v.preval",Number(sovValue));
                
            }
        }else{
            var pre = 0;
            component.set("v.preval",Number(pre));
        }
        

        
        event.stopPropagation()
    },
    addNewRow : function(component, event, helper){
     
        var sheetLineItems = component.get("v.continuationSheetLines");        
        var index = Number(event.currentTarget.dataset.index);
        var emptyObj;
        var isocode = component.get("v.ISOCode") 
        
        if(component.get("v.Iscommunity")== true){
            if(component.get("v.IsCurrencyEnabled") == true){
                emptyObj = {
                    //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                    buildertek__Description_of_Work__c: "",
                    buildertek__Vendor_Scheduled_Value__c : "",
                    buildertek__Item__c: "",
                    CurrencyIsoCode: component.get("v.ISOCode")
                    
                }
            }else{
                emptyObj = {
                    //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                    buildertek__Description_of_Work__c: "",
                    buildertek__Vendor_Scheduled_Value__c : "",
                    buildertek__Item__c: "",
                }
            }
        }else{
            if(component.get("v.IsCurrencyEnabled") == true){
                emptyObj = {
                    //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                    buildertek__Description_of_Work__c: "",
                    buildertek__Scheduled_Value__c : "",
                    buildertek__Item__c: "",
                    CurrencyIsoCode: component.get("v.ISOCode")
                    
                }
            }else{
                emptyObj = {
                    //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                    buildertek__Description_of_Work__c: "",
                    buildertek__Scheduled_Value__c : "",
                    buildertek__Item__c: "",
                }
            }
        }

        sheetLineItems.splice(index+1,0,emptyObj);
        component.set("v.continuationSheetLines",sheetLineItems);
        console.log("sheetLineItems------->",sheetLineItems);
        console.log('$$$$'+component.get("v.continuationSheetLines").length);
        
    },
    
    
    deleteRow : function(component, event, helper){
        debugger;
        var target = event.target;
        var index = Number(target.getAttribute("data-index"));
        var records = component.get('v.continuationSheetLines');
        var sovtotalvalue = component.get("v.sovTotal");
        if(records.length == 1 && records[index].Id == undefined){
            
            $A.get("e.force:refreshView").fire();
        }else{
            if (records[index].Id != undefined) {
                component.set('v.deleteContinuationSheetLine', index);
                component.set('v.isdeleteClick', true);
            } else if (records[index].Id == undefined) {
               
                for (const item in component.get("v.continuationSheetLines")[index]) {
                  
                    if(component.get("v.Iscommunity") == true){
                        if(item == 'buildertek__Vendor_Scheduled_Value__c'){
                           if(component.get("v.continuationSheetLines")[index][item]){ 
                            sovtotalvalue = parseFloat(sovtotalvalue) - parseFloat(component.get("v.continuationSheetLines")[index][item].replace(/,/g,''));
                           }
                            component.set("v.sovTotal",sovtotalvalue);
                        }
                    }else{
                        if(item == 'buildertek__Scheduled_Value__c'){
                            if(component.get("v.continuationSheetLines")[index][item]){
                               sovtotalvalue = parseFloat(sovtotalvalue) - parseFloat(component.get("v.continuationSheetLines")[index][item].replace(/,/g,'')); 
                            }
                            
                            component.set("v.sovTotal",sovtotalvalue);
                        }
                    }
                }
                
                
                
                
                records.splice(index, 1);
                component.set('v.continuationSheetLines', records);
            }
        }
        
    },
    
    cancelline: function (component, event, helper) {
        component.set('v.isdeleteClick', false);
        
    },
    
    confirmdelete: function (component, event, helper) {
        var records = component.get('v.continuationSheetLines');
        var index = component.get('v.deleteContinuationSheetLine');
        for (const item in component.get("v.continuationSheetLines")[index]) {
            if(component.get("v.Iscommunity") == true){
            if(item == 'buildertek__Vendor_Scheduled_Value__c'){
                
                var sovtotalvalue = component.get("v.sovTotal");
                
                sovtotalvalue = sovtotalvalue - Number(component.get("v.continuationSheetLines")[index][item]);
                
                component.set("v.sovTotal",sovtotalvalue);
            }
            }else{
                
                if(item == 'buildertek__Scheduled_Value__c'){
                
                var sovtotalvalue = component.get("v.sovTotal");
                
                sovtotalvalue = sovtotalvalue - Number(component.get("v.continuationSheetLines")[index][item]);
                
                component.set("v.sovTotal",sovtotalvalue);
                }
            }
        }
        
        if (records[index].Id != undefined) {
            var deleteSheetLine = records[index].Id;
            component.set('v.isdeleteClick', false);
        }
        var actionDeleteLink;
        actionDeleteLink = component.get("c.deletesheetline");
        actionDeleteLink.setParams({
            sheetlineIds: deleteSheetLine,
            recordId: component.get("v.recordId")
        });
        actionDeleteLink.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            if (component.isValid() && response.getState() === "SUCCESS") {
                
                if (response.getReturnValue() == 'success') {
                    $A.get("e.force:refreshView").fire();
                    toastEvent.setParams({
                        "type": "success",
                        "title": "",
                        "message": "SOV Line Removed Successfully."
                    });
                    
                    var sheetLines = component.get("v.continuationSheetLines");
                    if(sheetLines.length == 0){
                        $A.get("e.force:refreshView").fire();
                    }else{
                        component.set("v.continuationSheetLines",sheetLines);
                    }
                    
                    
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
                    
                }
            } else {
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": response.getError()[0].message
                });
            }
            toastEvent.fire();
        });
        
        $A.enqueueAction(actionDeleteLink);
    },
    
    createContinuationSheetLines : function (component, event, helper) {
        //component.set("v.Spinner", true);
        
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        
        debugger;
        var coIds = [];
        console.log(component.get("v.continuationSheetLines"));
        var sheetLines = component.get("v.continuationSheetLines");
        console.log(sheetLines);
        console.log(JSON.stringify(sheetLines));
        for(var i=0;i<sheetLines.length;i++){
            
            if(component.get("v.Iscommunity") == true){
                if(sheetLines[i]['buildertek__Vendor_Scheduled_Value__c']){
                if(sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'].toString().includes("$")){
                    
                    sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'] = Number(sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'].toString().split('$')[1].replace(/,/g,''));
                }else{
                    
                    sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'] = Number(sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'].toString().replace(/,/g,''));
                }
                }else{
                   //sheetLines[i]['buildertek__Vendor_Scheduled_Value__c'] = Number(0);
                }
            }else{
                if(sheetLines[i]['buildertek__Scheduled_Value__c']){
                if(sheetLines[i]['buildertek__Scheduled_Value__c'].toString().includes("$")){
                    
                    sheetLines[i]['buildertek__Scheduled_Value__c'] = Number(sheetLines[i]['buildertek__Scheduled_Value__c'].toString().split('$')[1].replace(/,/g,''));
                }else{
                    sheetLines[i]['buildertek__Scheduled_Value__c'] = Number(sheetLines[i]['buildertek__Scheduled_Value__c'].toString().replace(/,/g,''));
                } 
                }else{
                   // sheetLines[i]['buildertek__Scheduled_Value__c'] = Number(0);
                    
                }
            }
        }
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.createSheetLines");  
        action.setParams({
            SovLineValues : sheetLines,//component.get("v.continuationSheetLines"),
            recordId : recordId,
            vendorId : component.get("v.Vendorname")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                
                var result = response.getReturnValue();  
                if(result.Status === 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": result.Message,
                        "type": 'Success'
                    });
                    toastEvent.fire(); 
                    component.set("v.Spinner", false);
                    if(component.get("v.Iscommunity") == true){
                        location.reload();
                    }else{
                        $A.get('e.force:refreshView').fire();
                    }
                    /*$A.get("e.force:closeQuickAction").fire();  
                    $A.enqueueAction(component.get("c.doInit"));
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();*/
                    
                    /*var workspaceAPI = component.find( "workspace" );
                    workspaceAPI.getFocusedTabInfo().then( function( response ) {
                        var focusedTabId = response.tabId;
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab( { tabId: focusedTabId } );
                                
                            }), 1000);
                    })
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                           // $A.get('e.force:refreshView').fire();

                        }), 1000
                    );*/
               
                    
                }else{
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": result.Message,
                        "type": 'error'
                    });
                    toastEvent.fire();    
                }
                
                component.set("v.isEditable",true);
                
            }else{
                console.log(response.getError());
            }
        });
        
        var isemptyrecord = false;
        var continuationRecordList = component.get("v.continuationSheetLines");
        
        for(var i=0; i<continuationRecordList.length; i++){
            if(continuationRecordList[i].buildertek__Description_of_Work__c == null || continuationRecordList[i].buildertek__Description_of_Work__c == '' || continuationRecordList[i].buildertek__Description_of_Work__c == undefined){
                isemptyrecord = true;
            }
        }
        
        if(isemptyrecord == false){
            $A.enqueueAction(action);
        }else{
            component.set("v.Spinner", false);
            component.set("v.showMessage", false);
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Description of Work is Required',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();
        }
        
        
    },
    
    closeCOModal : function(component, event, helper) {
        
    /*   var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
        //    $A.get('e.force:refreshView').fire();
            
          //  component.set("v.isOpen",true);
        })
        .catch(function(error) {
            console.log(error);
        });  */
        
                
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        
        var workspaceAPI = component.find( "workspace" );
        workspaceAPI.getFocusedTabInfo().then( function( response ) {
            var focusedTabId = response.tabId;
            window.setTimeout(
                $A.getCallback(function() {
                    workspaceAPI.closeTab( { tabId: focusedTabId } );
                    
                }), 1000);
        })
        
        
        
        
        
    
        
    },
    
    
    closeModal : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        //location.reload()
        $A.get('e.force:refreshView').fire();      
    },
    
    
    
    importMasterSov : function(component, event, helper) {
        debugger;
        if(component.get("v.Iscommunity") == true){
            var address = '/import-master-sov?id='+component.get("v.recordId")+'&dummy=ignore'+'&fromsovsheet=ignore'+'/';
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": address,
                "isredirect" :false
            });
            urlEvent.fire();
            
        }else{
            var address = '/import-master-sov?id='+component.get("v.recordId")+'&dummy=ignore'+'&fromsovsheetBt=ignore'+'/';
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ImportMasterSovToPaymentApp",
                componentAttributes: {
                    recordId : component.get("v.recordId"),
                    address : 'SOVSheetfromsalesforce'
                }
            });
            evt.fire();
        }
    },
    
    importSovFromCsv : function(component, event, helper) {
        if(component.get("v.Iscommunity") == true){
            var address = '/import-sov?id='+component.get("v.recordId")+'&dummy=ignore'+'&fromsovsheet=ignore'+'/';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": address,
                "isredirect" :false
            });
            urlEvent.fire();
        }else{
           /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:importSOV",
                componentAttributes: {
                    recordId : component.get("v.recordId"),
                    sheetPage : 'gotoSheetPage'
                }
            });
            evt.fire(); */
            
            
               var recordId = component.get("v.recordId");
                    
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
                        var parentTabId = tabResponse.tabId;
                        var isSubtab = tabResponse.isSubtab;
                        workspaceAPI.openSubtab({
                            parentTabId: parentTabId,
                            pageReference: {
                                "type": "standard__component",
                                "attributes": {
                                    "recordId" : recordId,
                                    "componentName": "buildertek__importSOV"
                                },
                                "state": {
                                    "buildertek__parentId": recordId
                                }
                            },
                            //focus: true
                        }).then(function(response){
                            console.log(response);
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                var focusedTabId = response.tabId;
                                workspaceAPI.setTabLabel({
                                    tabId: focusedTabId,
                                    label: "Import SOVs from CSV",
                                });
                                workspaceAPI.setTabIcon({
                                    tabId: focusedTabId,
                                    icon: "custom:custom5",
                                    iconAlt: "Import SOVs from CSV"
                                });
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        })
                    });     
                    
                    var workspaceAPI = component.find( "workspace" );
                    workspaceAPI.getFocusedTabInfo().then( function( response ) {
                        var focusedTabId = response.tabId;
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab( { tabId: focusedTabId } );
                                
                            }), 1500);
                    })
            
        }
        
    },
    
    
    
    SubmitForView : function (component, event, helper) {  
        
        component.set("v.isSubmitForView",true);
        
    }, 
    
    
    cancelSubmit: function (component, event, helper) {
        component.set('v.isSubmitForView', false);
        
    },
    
    confirmSubmit: function (component, event, helper) {
        component.set("v.isSubmitForView",false);
        var action = component.get("c.submitSOVForView");
        action.setParams({
            recordId : component.get("v.recordId"),
            todayDate : new Date()
        });
        action.setCallback(this, function(response){
            
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'SOV Lines Submitted To Owner Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
                
            }     
            
        });
        $A.enqueueAction(action);
    },
    
    
    NavToSovRec: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }  ,
    
    changeApprovedToggle : function(component, event, helper) {
            if(component.get("v.ApprovedToggle") == false){
                component.set("v.ApprovedToggle",true)
                component.set("v.RejectedToggle",false);
                component.set("v.AllToggle",false);
                component.set("v.VendorSubmittedToggle",false)
                component.set("v.CompanySubmittedToggle",false);
                component.set("v.PendingToggle",false);
            }else{
                //component.set("v.ApprovedToggle",false)
            }
            var filtercondition = 'Approved';
            component.set("v.SOVtotaltext","Approved Schedule value");
            var sovId = component.get("v.recordId");
            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
            
        },
        ChangeRejectedToggle : function(component, event, helper) {
            if(component.get("v.RejectedToggle") == false){
                component.set("v.ApprovedToggle",false)
                component.set("v.RejectedToggle",true);
                component.set("v.AllToggle",false);
                component.set("v.VendorSubmittedToggle",false)
                component.set("v.CompanySubmittedToggle",false);
                component.set("v.PendingToggle",false);
            }else{
                //component.set("v.RejectedToggle",false)
            }

            var filtercondition = 'Rejected';
            component.set("v.SOVtotaltext","Rejected Schedule value");
            var sovId = component.get("v.recordId");
            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
        },
        changePendingToggle : function(component, event, helper) {
            if(component.get("v.PendingToggle") == false){
                component.set("v.ApprovedToggle",false)
                component.set("v.RejectedToggle",false);
                component.set("v.VendorSubmittedToggle",false)
                component.set("v.AllToggle",false);
                component.set("v.CompanySubmittedToggle",false);
                component.set("v.PendingToggle",true);
            }else{
                //component.set("v.PendingToggle",false)
            }
             var filtercondition = 'Pending';
            //component.set("v.SOVtotaltext",'Pending schedule value');
            var sovId = component.get("v.recordId");
            component.set("v.SOVtotaltext","Pending Schedule value");
            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
        },
            AllToggle : function(component, event, helper) {
                
               if(component.get("v.AllToggle") == false){
                component.set("v.ApprovedToggle",false)
                component.set("v.RejectedToggle",false);
                component.set("v.VendorSubmittedToggle",false)
                component.set("v.AllToggle",true);
                component.set("v.PendingToggle",false);
                   component.set("v.CompanySubmittedToggle",false);
                component.set("v.SOVtotaltext","Schedule value total");
               }else{
                   //component.set("v.AllToggle",false);
               } 
                var filtercondition = 'All';
                var sovId = component.get("v.recordId");
                helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
                //$A.get('e.force:refreshView').fire();
            },
           
                
          changeVendorSubmittedToggle : function(component, event, helper) {
            if(component.get("v.VendorSubmittedToggle") == false){
                component.set("v.ApprovedToggle",false)
                component.set("v.RejectedToggle",false);
                component.set("v.AllToggle",false);
                component.set("v.PendingToggle",false);
                component.set("v.CompanySubmittedToggle",false);
                component.set("v.VendorSubmittedToggle",true);
                
            }else{
                //component.set("v.VendorSubmittedToggle",false);
            }
             var filtercondition = 'Vendor Submitted';
            //component.set("v.SOVtotaltext",'Pending schedule value');
            var sovId = component.get("v.recordId");
            component.set("v.SOVtotaltext","Vendor Submitted Schedule value");
            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
        },
         changeCompanySubmittedToggle : function(component, event, helper) {
            if(component.get("v.CompanySubmittedToggle") == false){
                component.set("v.ApprovedToggle",false)
                component.set("v.RejectedToggle",false);
                component.set("v.AllToggle",false);
                component.set("v.PendingToggle",false);
                component.set("v.VendorSubmittedToggle",false);
                component.set("v.CompanySubmittedToggle",true);
                
            }else{
                //component.set("v.VendorSubmittedToggle",false);
            }
             var filtercondition = 'Company Submitted';
            //component.set("v.SOVtotaltext",'Pending schedule value');
            var sovId = component.get("v.recordId");
            component.set("v.SOVtotaltext","Company Submitted Schedule value");
            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
        },
    
    
    
    
    
    selectAll: function(component,event, helper){
        var slctCheck = event.getSource().get("v.value");
        var getCheckAllId = component.find("cboxRow");
        
        if (slctCheck == true) {
            for (var i = 0; i < getCheckAllId.length; i++) {
                component.find("cboxRow")[i].set("v.value", true);             
            }
        } else {
            for (var i = 0; i < getCheckAllId.length; i++) {
                component.find("cboxRow")[i].set("v.value", false);
            }
        }
    },
     changeSelectAll:function(component,event, helper){
        var slctCheckRow = event.getSource().get("v.value");
        var getCheckAllId = component.find("cbox");
        if(slctCheckRow == false) {
            component.find("cbox").set("v.value", false);
        }
    },
    
    deleteSlctd : function(component,event,helper) {
        var getCheckAllId = component.find("cboxRow");
        var selctedRec = [];
        for (var i = 0; i < getCheckAllId.length; i++) {
            
            if(getCheckAllId[i].get("v.value") == true )
            {
                selctedRec.push(getCheckAllId[i].get("v.text")); 
            }
        }
        if(selctedRec=='' || selctedRec==null){
            
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'error',
                    message: 'Please select the SOV Line you would like to Delete.',
                    duration:' 1000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
        }else{
            component.set("v.selectdeSOVIDS",selctedRec);
            component.set("v.deleteSOVScreen",true);
           //helper.deleteSelected(component,event,selctedRec);
        }
    },
    callDeleteHelper:function(component,event,helper) {
        var sovIds=component.get("v.selectdeSOVIDS");
        helper.deleteSelected(component,event,sovIds);
    },
    closeDeleteConformationScreen: function(component,event,helper) {
        component.set("v.deleteSOVScreen",false);
        component.set("v.selectdeSOVIDS",'');
        
         var slctCheckRow = event.getSource().get("v.value");
        var getCheckAllId = component.find("cbox");
        if(slctCheckRow == false) {
            component.find("cbox").set("v.value", false);
        }
    },
    
    
    importVendorSov : function(component, event, helper) {
        debugger;
        component.set("v.isImpVndSOV",true);
        
        
        debugger;
        var action10 = component.get("c.getSovType");
        action10.setParams({
            "recordId": component.get("v.recordId")
        });
        action10.setCallback(this, function (response1) {
            if (response1.getState() == 'SUCCESS') {
                var result = response1.getReturnValue();
                
                if(result.buildertek__Status__c == 'Customer Approved'){
                   $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'You cannot make changes to Customer Approved SOV',
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire(); 
            }else{
                helper.fetchSOVs(component, event, helper);
            }
        }
            
        });
        $A.enqueueAction(action10);
        
    },
    
    close : function(component,event,helper){
         component.set("v.isImpVndSOV", false);
    },

    
      closeModal1: function(component, event, helper) {
        component.set("v.isImpVndSOV", false);s
       
    },
    
    selectAllRfq : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovsList")));
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
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
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
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        
        //alert('Chechbox--------------  '+component.find("checkRFQ").get("v.name"));
        var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
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
            
            var sovlist =  component.get("v.sovsList");            
            for(var i=0;i<sovlist.length;i++){
                if(sovlist[i].RecordId==checkbox.get("v.name")){
                    sovlist[i].isChecked = checkbox.get("v.checked");
                }
            }
            component.set("v.sovsList",sovlist);
            
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
        component.set("v.listOfSelectedSOVIds",selectedRfqIds);
        
        
        // alert(event.getSource().get("v.name"));
        
        
    },
    
     ImportSOVLines: function (component, event, helper){
            debugger;
            component.set("v.IsSpinner",true);
        var SOVIds=component.get("v.listOfSelectedSOVIds");
       // alert('SOVIds------------'+SOVIds);
        //alert('newRecId--------'+newRecId);
        var action = component.get("c.createSOVLines");
           console.log(SOVIds.length);
            debugger;
        action.setParams({
            selectedSOV : SOVIds,
            newSOV : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(fieldSetObj);
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",false);
                if(fieldSetObj < 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Error!",
                        message : 'No sov lines',
                        type: 'error',
                        duration: '5000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                     component.set("v.IsSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "SOV lines imported successfully."
                });
                toastEvent.fire();
                component.set("v.up",false);
                    component.set("v.IsSpinner",false);
                    $A.get("e.force:closeQuickAction").fire()
                    $A.get('e.force:refreshView').fire();
                }
                
            }
            
            //component.set("v.rfiList",fieldSetObj);
        })
       
        if(SOVIds.length < 1){
             component.set("v.IsSpinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '5000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
           $A.enqueueAction(action); 
        }
        
    },
    
    
    calculateWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        console.log('final tag Name'+parObj.tagName);
        
        var mouseStart=event.clientX; 
        component.set("v.mouseStart",mouseStart);
        component.set("v.oldWidth",parObj.offsetWidth);
        event.stopPropagation()
    },
    setNewWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart = component.get("v.mouseStart");
        var oldWidth = component.get("v.oldWidth");
        //To calculate the new width of the column
        var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
        parObj.style.width = newWidth+'px';//assign new width to column
        event.stopPropagation();
    },
    
     toggle: function(component, event, helper) {
        var parentItems = component.get("v.sovsList"),
            parentIndex = event.getSource().get("v.title");
        
        
        var items = component.get("v.sovlinesList"),
            index = event.getSource().get("v.value");
        
        parentItems[parentIndex].expanded = !parentItems[parentIndex].expanded;
        component.set("v.sovsList", parentItems);
    },
    
    
    importCompanyApprovedSov : function (component, event, helper) {  
        
         helper.fetchSOVs(component, event, helper);
         component.set("v.isImpVndSOV",true);
        
        
    }, 
    
})