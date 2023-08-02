({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var recId =  component.get("v.recordId");
        console.log('getMasterBudgets called from INIT==');
        var action = component.get("c.getMasterBudgets");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            // //debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                // //debugger;
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                
                
                
                for(var k=0; k< result.length; k++){
                    if(result[k].poRecordList.length > 0){
                        for(var i=0; i< result[k].poRecordList.length; i++){ 
                            if(result[k].poRecordList[i].buildertek__Date_Ordered__c){
                                result[k].poRecordList[i].buildertek__Date_Ordered__c =new Date(result[k].poRecordList[i].buildertek__Date_Ordered__c).toLocaleDateString() 
                            }
                            
                        }
                    } }
                
                
                
                component.set("v.masterBudgetsList", result);
                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    // searchKeyChange: function(component, event) {
    //     component.set("v.Spinner", true);
    //     var list = component.get("v.PaginationList");
    //     var searchKey = component.find("searchKey").get("v.value");
    //     var action = component.get("c.findByName");
    //     action.setParams({
    //         "searchKey3": searchKey3,
    //         "searchKey2": searchKey2,
    //         "searchKey": searchKey,
    //         recId : component.get("v.recordId"),
    //     });
    //     action.setCallback(this, function(a) {
    //         var result = a.getReturnValue();
    //         component.set("v.Spinner", false);
    //         if(searchKey != ''){
    //             component.set("v.PaginationList",result);
    //         }
    //         else{
    //             var action1 = component.get("c.getMasterBudgets");
    //             action1.setParams({
    //                 recId : component.get("v.recordId")
    //             });
    //             action1.setCallback(this, function(response){
    //                 var state = response.getState();
    //                 if(state === "SUCCESS"){
    //                     component.set("v.Spinner", false);
    //                     var pageSize = component.get("v.pageSize");
    //                     var result = response.getReturnValue();
    //                     component.set("v.masterBudgetsList", result);
    //                     component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
    //                     component.set("v.startPage",0);
    //                     component.set("v.endPage",pageSize-1);
    //                     var PaginationList = [];
    //                     for(var i=0; i< pageSize; i++){
    //                         if(component.get("v.masterBudgetsList").length> i)
    //                             PaginationList.push(result[i]);    
    //                     }
    //                     component.set('v.PaginationList', PaginationList);
    //                 }else{
    //                     component.set("v.Spinner", false);
    //                 }
    //             });
    //             $A.enqueueAction(action1);
    //         }
    //     });
    //     $A.enqueueAction(action);
        
    // },
    
    // searchKeyChange1: function(component, event) {
    //     //debugger;
    //     component.set("v.Spinner", true);
    //     var list = component.get("v.PaginationList");
    //     var searchKey = component.find("searchKey3").get("v.value");
    //     var action = component.get("c.findByName1");
    //     action.setParams({
    //         "searchKey": searchKey,
    //         recId : component.get("v.recordId"),
    //     });
    //     action.setCallback(this, function(a) {
    //         var result = a.getReturnValue();
    //         component.set("v.Spinner", false);
    //         if(searchKey != ''){
    //             component.set("v.PaginationList",result);
    //         }
    //         else{
    //             var action1 = component.get("c.getMasterBudgets");
    //             action1.setParams({
    //                 recId : component.get("v.recordId")
    //             });
    //             action1.setCallback(this, function(response){
    //                 var state = response.getState();
    //                 if(state === "SUCCESS"){
    //                     var pageSize = component.get("v.pageSize");
    //                     var result = response.getReturnValue();
    //                     component.set("v.masterBudgetsList", result);
    //                     component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
    //                     component.set("v.startPage",0);
    //                     component.set("v.endPage",pageSize-1);
    //                     var PaginationList = [];
    //                     for(var i=0; i< pageSize; i++){
    //                         if(component.get("v.masterBudgetsList").length> i)
    //                             PaginationList.push(result[i]);    
    //                     }
    //                     component.set('v.PaginationList', PaginationList);
    //                     component.set("v.Spinner", false);
    //                 }else{
    //                     component.set("v.Spinner", false);
    //                 }
    //             });
    //             $A.enqueueAction(action1);
    //         }
    //     });
    //     $A.enqueueAction(action);
        
    // },
    
    next: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList"); 
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    handleCheck : function(component, event, helper) {
        //debugger;
        var checkbox = event.getSource();
        var Submittals = component.get("v.masterBudgetsList");
        for(var i=0 ; i < Submittals.length;i++){
            for(var j=0;j<Submittals[i].poRecInner.length;j++){
                if(Submittals[i].poRecInner != null){
                    if(Submittals[i].poRecInner[j].poRecord.Id == checkbox.get("v.name") && Submittals[i].poRecInner[j].poCheck == false){
                        Submittals[i].poRecInner[j].poCheck = true;
                        
                    }
                    else if(Submittals[i].poRecInner[j].poRecord.Id == checkbox.get("v.name") && Submittals[i].poRecInner[j].poCheck == true){
                        Submittals[i].poRecInner[j].poCheck = false;
                    }    
                }
            }
            
        }
        
        component.set("v.masterBudgetsList",Submittals);
        
    },
    
    selectAll : function(component, event, helper) { 
        ////debugger;
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var Submittals = component.get("v.masterBudgetsList");
        var getAllId = component.find("checkContractor");
        if (getAllId != undefined) {
            if (Submittals.length > 0) {
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                        component.set("v.selectedCount", 1);
                    }else{
                        component.find("checkContractor").set("v.value", false);
                        component.set("v.selectedCount", 0);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true); 
                            component.find("checkContractor")[i].set("v.checked", true); 
                            
                        }
                        for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Purchase_Order__c == null){
                                    Submittals[i].poRecInner[j].poCheck = true; 
                                }
                                
                            }
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            component.find("checkContractor")[i].set("v.checked", false); 
                            
                        }
                        for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Purchase_Order__c == null){
                                    Submittals[i].poRecInner[j].poCheck = false; 
                                }
                                
                            }
                        }
                    } 
                } 
            }else{
                var i = 0;
                if (selectedHeaderCheck == true) { 
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
                    Submittals[i].poCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].poCheck = false;
                }
            }   
        }
        component.set("v.masterBudgetsList",Submittals)
    },
    
    closeModel : function(component, event, helper){
        $A.get('e.force:refreshView').fire();   
    },
    
    clear :function(component,event,heplper){
        //debugger;
        event.stopPropagation();
        event.preventDefault();
        var selectedPillId = event.getSource().get("v.name");
        var selectedPillIndex = selectedPillId.split("_")[0];
        var selectedPillPo = selectedPillId.split("_")[1];
        var allFileList = component.get("v.fileData2");
        var AllPillsList = component.get("v.selectedfilesFill"); 
        
        /*for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Name == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.selectedfilesFill", AllPillsList);
            }  
        }*/
        
        for(var i = 0; i < allFileList.length; i++){
            if(allFileList[i].POId == selectedPillPo && i == Number(selectedPillIndex)){
                allFileList.splice(i, 1);
                //component.set("v.selectedfilesFill", AllPillsList);
            }  
        }
        component.set("v.fileData2",allFileList);
        
        var names = []
        
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            var name = {};
            name['FileName'] = [];
            name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
            name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
            names.push(name);
        }
        component.set("v.FileNameList",names);
    },
    
    confirmOrderPO : function(component, event, helper){
        //debugger;
        
        var VendorId = component.get("v.POVendorId");
        
       
        
        if(component.get("v.selectedLookUpRecord").Id != null || component.get("v.selectedLookUpRecord").Id != undefined){
            VendorId = component.get("v.selectedLookUpRecord").Id;
            
        }else{
            component.set("v.isNoLookup", true);
        }
        
        
        component.set("v.Spinner2", true);
        component.set("v.Spinner", true);
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.masterBudgetsList");
        var budgetIds = [];
        if(budgetsList != null){
            
            for(var i=0 ; i < budgetsList.length;i++){
                for(var j=0;j<budgetsList[i].poRecInner.length;j++){
                    if(budgetsList[i].poRecInner != null){
                        if(budgetsList[i].poRecInner[j].poCheck == true){
                            budgetIds.push(budgetsList[i].poRecInner[j].poRecord.Id);
                        }
                    }
                }
            }
        }
        
        if(budgetIds.length > 0 ){
            
            if(VendorId != undefined && VendorId != ""){
                 window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.selectedPOList", false);
                    
                }), 1000);
            
            component.set("v.selectedobjInfo",budgetIds);
            var action = component.get("c.createPO"); 
            action.setParams({
                budgetIds : budgetIds,
                recordId : component.get("v.recordId"),
                poVendorId : VendorId
            });
            
            action.setCallback(this, function(response){
                //debugger;
                var state = response.getState();
                if(state === "SUCCESS"){
                    var result = response.getReturnValue();  
                    if(result != null){
                        component.set("v.selectedLookUpRecord", '');
                        component.set("v.Spinner", false);
                        component.set("v.Spinner2", false);
                        component.set("v.selectedPOList", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'Purchase Order Created Successfully',
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                        
                        
                        
                        window.setTimeout(
                            $A.getCallback(function() {
                                //document.location.reload(true);   
                                console.log('getMasterBudgets called from confirmOrderPO==');

                                var action1 = component.get("c.getMasterBudgets");
                                action1.setParams({
                                    recId : component.get("v.recordId")
                                });
                                action1.setCallback(this, function(response){
                                    var state = response.getState();
                                    if(state === "SUCCESS"){
                                        var pageSize = component.get("v.pageSize");
                                        var result = response.getReturnValue();
                                        component.set("v.masterBudgetsList", result);
                                        component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                                        component.set("v.startPage",0);
                                        component.set("v.endPage",pageSize-1);
                                        var PaginationList = [];
                                        for(var i=0; i< pageSize; i++){
                                            if(component.get("v.masterBudgetsList").length> i)
                                                PaginationList.push(result[i]);    
                                        }
                                        component.set('v.PaginationList', PaginationList);
                                        component.set("v.Spinner", false);
                                    }else{
                                        component.set("v.Spinner", false);
                                    }
                                });
                                $A.enqueueAction(action1);
                            }), 100
                        );
                        
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result.Id,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        
                        $A.get("e.force:closeQuickAction").fire();  
                        
                    }else{
                        component.set("v.Spinner", false);
                        component.set("v.Spinner2", false);
                        component.set("v.selectedPOList", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error",
                            "type": 'Error'
                        });
                        toastEvent.fire();    
                    }
                }
            });
            $A.enqueueAction(action);
                
            }
          
            else{
                
                component.set("v.Spinner2", false);
                component.set("v.Spinner", false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Vendor is required to Create Purchase Order.',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                });
                toastEvent.fire(); 
                
            }
            
           
            
        }
    },
    
    orderPO : function(component, event, helper){
        //debugger;
        
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.masterBudgetsList");
        var budgetIds = [];
        if(budgetsList != null){
            
            for(var i=0 ; i < budgetsList.length;i++){
                for(var j=0;j<budgetsList[i].poRecInner.length;j++){
                    if(budgetsList[i].poRecInner != null){
                        if(budgetsList[i].poRecInner[j].poCheck == true){
                            budgetIds.push(budgetsList[i].poRecInner[j].poRecord);
                        }
                    }
                }
            }
        }
        //debugger;
        component.set("v.SelectedPurchaseOrders", budgetIds);
        
        var defaultName
        if(budgetIds.length > 0){
            if(budgetIds[0].buildertek__Vendor__c != undefined){
                defaultName = budgetIds[0].buildertek__Vendor__r.Name;
            }
        }
        var isVendor = false;
        
        var allSame = false;
        
        var allUndeined = false;
        
        var atleastVendor = false;
        
        for(var i=0 ; i < budgetIds.length;i++){
            if(budgetIds[i].buildertek__Vendor__c != undefined){
                isVendor = true
                allUndeined = true
                atleastVendor = true
                component.set("v.POVendorId",budgetIds[i].buildertek__Vendor__c);
                if(defaultName == budgetIds[i].buildertek__Vendor__r.Name){
                    allSame = true;
                }else {
                    allSame = false;
                }
            }else{
                isVendor = false
               // component.set("v.POVendorId", '');
                
            }
            
        }
        
        if(atleastVendor == true){
             component.set("v.isNoVendors", false);
        }else if( isVendor == false){
            component.set("v.isNoVendors", true);
        }
        
        
        
        
        if(allSame == true){
            if(budgetIds.length > 0){
                component.set("v.selectedPOList", true);  
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Please select at least 1 Change Order Line.',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                });
                toastEvent.fire(); 
            }
        }else if(budgetIds.length == 0){
            component.set("v.POVendorId", '');
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least 1 Change Order Line.',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();   
            
            component.find("checkContractors").set("v.value", false);
            
            window.setTimeout(
                $A.getCallback(function() {
                    //document.location.reload(true);   
                    console.log('getMasterBudgets called from orderPO ele if==');
                    
                    var action1 = component.get("c.getMasterBudgets");
                    action1.setParams({
                        recId : component.get("v.recordId")
                    });
                    action1.setCallback(this, function(response){
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            var pageSize = component.get("v.pageSize");
                            var result = response.getReturnValue();
                            component.set("v.masterBudgetsList", result);
                            component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                            component.set("v.startPage",0);
                            component.set("v.endPage",pageSize-1);
                            var PaginationList = [];
                            for(var i=0; i< pageSize; i++){
                                if(component.get("v.masterBudgetsList").length> i)
                                    PaginationList.push(result[i]);    
                            }
                            component.set('v.PaginationList', PaginationList);
                            component.set("v.Spinner", false);
                        }else{
                            component.set("v.Spinner", false);
                        }
                    });
                    $A.enqueueAction(action1);
                }), 100
            );
            
        }
        
            else if(component.get("v.POVendorId") == undefined || component.get("v.POVendorId") == ""){
                 component.set("v.POVendorId", '');
                 component.set("v.selectedPOList", true);
                
               /* component.set("v.POVendorId", '');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'There is no Vendor for the selected COs',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                });
                toastEvent.fire();  
                
                component.find("checkContractors").set("v.value", false);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        //document.location.reload(true);   
                        var action1 = component.get("c.getMasterBudgets");
                        action1.setParams({
                            recId : component.get("v.recordId")
                        });
                        action1.setCallback(this, function(response){
                            var state = response.getState();
                            if(state === "SUCCESS"){
                                var pageSize = component.get("v.pageSize");
                                var result = response.getReturnValue();
                                component.set("v.masterBudgetsList", result);
                                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                                component.set("v.startPage",0);
                                component.set("v.endPage",pageSize-1);
                                var PaginationList = [];
                                for(var i=0; i< pageSize; i++){
                                    if(component.get("v.masterBudgetsList").length> i)
                                        PaginationList.push(result[i]);    
                                }
                                component.set('v.PaginationList', PaginationList);
                                component.set("v.Spinner", false);
                            }else{
                                component.set("v.Spinner", false);
                            }
                        });
                        $A.enqueueAction(action1);
                    }), 100
                );  */
                
            }  
                
                else if(allSame == false){
                component.set("v.POVendorId", '');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'You can only create POs with the Same Vendors',
                    duration: "5000",
                    key: "info_alt",
                    type: "error",
                });
                toastEvent.fire();   
                
                component.find("checkContractors").set("v.value", false);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        //document.location.reload(true);  
                    console.log('getMasterBudgets called from orderPO==');

                        var action1 = component.get("c.getMasterBudgets");
                        action1.setParams({
                            recId : component.get("v.recordId")
                        });
                        action1.setCallback(this, function(response){
                            var state = response.getState();
                            if(state === "SUCCESS"){
                                var pageSize = component.get("v.pageSize");
                                var result = response.getReturnValue();
                                component.set("v.masterBudgetsList", result);
                                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                                component.set("v.startPage",0);
                                component.set("v.endPage",pageSize-1);
                                var PaginationList = [];
                                for(var i=0; i< pageSize; i++){
                                    if(component.get("v.masterBudgetsList").length> i)
                                        PaginationList.push(result[i]);    
                                }
                                component.set('v.PaginationList', PaginationList);
                                component.set("v.Spinner", false);
                            }else{
                                component.set("v.Spinner", false);
                            }
                        });
                        $A.enqueueAction(action1);
                    }), 100
                );
            } 
    },
    
    closePOListPopUp : function(component, event, helper){
        //debugger;
        component.set("v.selectedPOList", false);
        component.set("v.fileData2", []);
        
        var selectedHeaderCheck = component.find("checkContractors").get("v.value");
        
        var Submittals = component.get("v.masterBudgetsList");
        var getAllId = component.find("checkContractor");
        if (getAllId != undefined) {
            if (Submittals.length > 0) {
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                        component.set("v.selectedCount", 1);
                    }else{
                        component.find("checkContractor").set("v.value", false);
                        component.set("v.selectedCount", 0);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            component.find("checkContractor")[i].set("v.checked", false); 
                            
                        }
                        for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered'){
                                    Submittals[i].poRecInner[j].poCheck = false; 
                                }
                                
                            }
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            component.find("checkContractor")[i].set("v.checked", false); 
                            
                        }
                        for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered'){
                                    Submittals[i].poRecInner[j].poCheck = false; 
                                }
                                
                            }
                        }
                    } 
                } 
            }else{
                var i = 0;
                if (selectedHeaderCheck == true) { 
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
                    Submittals[i].poCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].poCheck = false;
                }
            }   
        }
        component.set("v.masterBudgetsList",Submittals)
        
        component.find("checkContractors").set("v.value", false);
        component.set("v.selectedLookUpRecord", '');
        component.set("v.isNoVendors", false);
        
        
        
    },
    

    
    
    // searchKeyChange2: function(component, event) {
    //     //debugger;
    //     component.set("v.Spinner", true);
    //     var list = component.get("v.PaginationList");
    //     var searchKey = component.find("searchKey2").get("v.value");
    //     var action = component.get("c.findByName2");
    //     action.setParams({
    //         "searchKey": searchKey,
    //         recId : component.get("v.recordId"),
    //     });
    //     action.setCallback(this, function(a) {
    //         var result = a.getReturnValue();
    //         console.log("Result");
    //         console.log(result)
    //         component.set("v.Spinner", false);
    //         if(searchKey != ''){
    //             component.set("v.PaginationList",result);
    //         }
    //         else{
    //             var action1 = component.get("c.getMasterBudgets");
    //             action1.setParams({
    //                 recId : component.get("v.recordId")
    //             });
    //             action1.setCallback(this, function(response){
    //                 var state = response.getState();
    //                 if(state === "SUCCESS"){
    //                     var pageSize = component.get("v.pageSize");
    //                     var result = response.getReturnValue();
    //                     component.set("v.masterBudgetsList", result);
    //                     component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
    //                     component.set("v.startPage",0);
    //                     component.set("v.endPage",pageSize-1);
    //                     var PaginationList = [];
    //                     for(var i=0; i< pageSize; i++){
    //                         if(component.get("v.masterBudgetsList").length> i)
    //                             PaginationList.push(result[i]);    
    //                     }
    //                     component.set('v.PaginationList', PaginationList);
    //                     component.set("v.Spinner", false);
    //                 }else{
    //                     component.set("v.Spinner", false);
    //                 }
    //             });
    //             $A.enqueueAction(action1);
    //         }
    //     });
    //     $A.enqueueAction(action);
        
    // },



    SearchSomething: function(component, event) {
        //debugger;
        component.set("v.Spinner", true);
        var list = component.get("v.PaginationList");

        var searchKey3 = component.find("searchKey3").get("v.value"); //vendor search
        var searchKey2 = component.find("searchKey2").get("v.value"); // Line Item
        var searchKey = component.find("searchKey").get("v.value"); // Change Order
        
      
        if(searchKey3 == '' && searchKey2 == '' && searchKey == ''){
          
            var action1 = component.get("c.getMasterBudgets");
            action1.setParams({
                recId : component.get("v.recordId")
            });
            action1.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var pageSize = component.get("v.pageSize");
                    var result = response.getReturnValue();
                    component.set("v.masterBudgetsList", result);
                    component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.masterBudgetsList").length> i)
                            PaginationList.push(result[i]);    
                    }
                    component.set('v.PaginationList', PaginationList);
                    component.set("v.Spinner", false);
                }else{
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action1);

        }else{
            var action = component.get("c.findByName");
            action.setParams({
                "searchKey3": searchKey3,
                "searchKey2": searchKey2,
                "searchKey": searchKey,
                recId : component.get("v.recordId"),
            });
            action.setCallback(this, function(a) {
                var result = a.getReturnValue();
                 component.set("v.Spinner", false);
                // var newlist = [];
                // for(var s in result){
                //     newlist.push(result[s]);
                // }
                    component.set("v.PaginationList",result);
            });
            $A.enqueueAction(action);
        }
        
    }
    

    
})