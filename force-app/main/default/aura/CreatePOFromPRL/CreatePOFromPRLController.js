({
    doInit : function(component, event, helper) {
        component.set("v.openProductBox",false);
        var action = component.get("c.getPRLD");
        console.log('recordId --- '+component.get("v.recordId"));
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var result =  response.getReturnValue();
                console.log("Data : "+JSON.stringify(response.getReturnValue()))
                if(result.length > 0){
                    component.set("v.openProductBox",true);
                    component.set("v.PaginationList",response.getReturnValue());
                    var y = [];
                    for(let i=0;i<result.length;i++){
                        if(result[i].VendorName != undefined && result[i].VendorName != null){
                            if(result[i].VendorName != null && result[i].VendorName != undefined){
                                y.push((result[i].VendorName));
                            }
                        }
                    }
                    var count = 0;
                    var z = response.getReturnValue()
                    for(var k in z){
                        console.log(z[k]['VendorName'])
                        if(z[k]['VendorName'] == undefined){
                            count++;
                        }
                    }
                  component.set("v.Count",count)
                    
                    var uniqueArray = [];
                    for(let i=0; i < y.length; i++){
                        if(uniqueArray.indexOf(y[i]) === -1) {
                            uniqueArray.push(y[i]);
                        }
                    }
                    component.set("v.vendorList",uniqueArray);
                    console.log(y);
                    component.set("v.VendorId",result[0].VendorId);
                }
                else{
                    console.log('recordId --- '+component.get("v.recordId"));
                    var action2 = component.get("c.getPRLDsCheck");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function (response) {
                        var result2 = response.getReturnValue();
                        if(result2.length > 0){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:"All the PRLDs are associated with respective RFQs.",
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire(); 
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:"There are no PRLD's",
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire(); 
                        }
                        
                    });
                    $A.enqueueAction(action2); 
                }
            }
            else{
                console.log(response.getError());
            }
        });
        var action3 = component.get("c.getPRL");
        action3.setParams({
            recordId: component.get("v.recordId")
        });
        action3.setCallback(this, function (response) {
            var state1 = response.getState();
            if(state1 === 'SUCCESS'){
                if(response.getReturnValue()){
                    console.log("PRL : "+JSON.stringify(response.getReturnValue()));
                    component.set("v.prlRecord",response.getReturnValue());
                }
            }
            else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action3);
        $A.enqueueAction(action);
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        component.set('v.today', today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
    },
    
    closeModel :  function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    selectAll : function(component, event, helper) { 
        debugger;
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var Submittals = component.get("v.PaginationList");
        var getAllId = component.find("checkContractor");
        if (getAllId != undefined) {
            if (Submittals.length > 1) {
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
                            console.log( component.find("checkContractor")[i].get("v.value"))
                            var checkbox = component.find("checkContractor")[i].get("v.text");  
                            Submittals[i].isCheck = true;
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            var checkbox = component.find("checkContractor")[i].get("v.text"); 
                            var Submittals = component.get("v.PaginationList");
                            Submittals[i].isCheck = false;
                        }
                    } 
                } 
            }else{
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
                    Submittals[i].isCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].isCheck = false;
                }
            }   
        }
        
        component.set("v.PaginationList",Submittals);
    },
    
    handleCheck : function(component, event, helper) {
        debugger;
        var checkbox = event.getSource();
        var Submittals = component.get("v.PaginationList");
        for(var i=0 ; i < Submittals.length;i++){
            if(Submittals[i] != null){
                if(Submittals[i].Id == checkbox.get("v.text") && Submittals[i].isCheck == false){
                    Submittals[i].isCheck = true;
                }
                else if(Submittals[i].Id == checkbox.get("v.text") && Submittals[i].isCheck == true){
                    Submittals[i].isCheck = false;
                }    
            }else if(Submittals[i] != null){
                if(Submittals[i].Id == checkbox.get("v.text") && Submittals[i].isCheck == false){
                    Submittals[i].isCheck = true;
                }
                else if(Submittals[i].Id == checkbox.get("v.text") && Submittals[i].isCheck == true){
                    Submittals[i].isCheck = false;
                }    
            }  
        }
    },
    
    importBudget : function(component, event, helper){
        component.set("v.Spinner", true);
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.PaginationList");
        var budgetIds = [];
        if(budgetsList != null){
            for(var i=0 ; i < budgetsList.length;i++){
                if(budgetsList[i].isCheck == true){
                    budgetIds.push(budgetsList[i].Id);
                }
            }
        }
        if(budgetIds.length > 0){
            component.set("v.selectedobjInfo",budgetIds);
            var x = component.get("v.selectedLookUpRecord")
            var y;
            if(Object.keys(x).length > 0){
                y = x['Id'];
            }
            else{
                y = 'Empty';
            }
            var action = component.get("c.insertPO");
            
            action.setParams({
                recordId: component.get("v.recordId"),
                Ids:budgetIds,
                Vendor : y
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.isdisabled",true);
                    $A.get("e.force:closeQuickAction").fire();
                    var result = response.getReturnValue();
                    if(result != null){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Purchase Order is created successfully.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    else if(result === 'ERROR'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'There is no PRL to create PO.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                else{
                    component.set("v.isdisabled",true);
                    component.set("v.Spinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                    var error = response.getError();
                    console.log(error)
                    var errorMessage = error[0].fieldErrors.Name[0].message
                    console.log(errorMessage);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: errorMessage,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please Select at least One PRLD record.',
                "type": 'Error',
                "duration": '10000',
                "mode": 'dismissible'
            });    
            toastEvent.fire();
        }
    },
    
    importBudget2 : function(component, event, helper){
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.PaginationList");
        var budgetIds = [];
        if(budgetsList != null){
            for(var i=0 ; i < budgetsList.length;i++){
                if(budgetsList[i].isCheck == true){
                    budgetIds.push(budgetsList[i].Id);
                }
            }
        }
        if(budgetIds.length > 0){
            component.set("v.openProductBox",false);
            component.set("v.openPO",true);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please Select at least One PRLD record.',
                "type": 'Error',
                "duration": '10000',
                "mode": 'dismissible'
            });    
            toastEvent.fire();
        }
    },
    
    closePOListPopUp :  function(component, event, helper){
        console.log("HI : "+JSON.stringify(component.get("v.selectedLookUpRecord")))
        component.set("v.openPO",false);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    
    confirmOrderPO :  function(component, event, helper){
        component.set("v.Spinner",true)
        component.set("v.isdisabled",true);
        if(Object.keys(component.get("v.selectedLookUpRecord")).length > 0){
            var action = component.get('c.importBudget');
            $A.enqueueAction(action);
            component.set("v.Spinner",false)
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please enter the vendor field.',
                "type": 'Error',
                "duration": '10000',
                "mode": 'dismissible'
            });    
            toastEvent.fire();
            component.set("v.isdisabled",false);
            component.set("v.Spinner",false)
        }
    }
    
    
    
    
    
})