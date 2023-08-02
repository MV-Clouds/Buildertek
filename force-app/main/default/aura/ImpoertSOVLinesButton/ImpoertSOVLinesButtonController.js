({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'SOV', fieldName: 'Name', type: 'text'},
            
            { 
                label: 'Date Submitted', 
                fieldName: 'buildertek__Date_Submitted__c', 
                type: 'date', 
                typeAttributes: {
                    day: 'numeric',
                    month: 'numeric',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                },
                sortable: false
            },
            {label: 'Project', fieldName: 'projectName', type: 'text'},
        ]);
        var action1 = component.get("c.getApplicationValue");
        action1.setParams({
            recordId: component.get("v.recordId"),
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var resultData = response.getReturnValue();
             
             if(resultData.isSheetLinesAvailable == true){
              var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'You have already Imported the SOVs for this Payment App.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             $A.get("e.force:closeQuickAction").fire();
             }
             else if(resultData.status == "Company Accepted"){
                    // component.set("v.CustomError",true);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'You Cannot make any changes to Record, Once the Payment Application is Submitted or Company Accepted',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else if(resultData.status == "Vendor Submitted"){
                    // component.set("v.isVendorSubmitted",true);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'You Cannot make any changes to Record, Once the Payment Application is Submitted or Company Accepted',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    component.set("v.CustomError",false);
                    if(resultData.isApplication1 == true){
                        //component.set("v.isshow",true);
                        var action = component.get("c.getSOVData");
                        action.setParams({
                            recordId: component.get("v.recordId"),
                    });
                    action.setCallback(this, function(response){
                        debugger;
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var resultData = response.getReturnValue();
                            if(resultData == ""){
                                component.set("v.isshow",false);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: '',
                                    message: "There are no Company Approved SOV's for this Project",
                                    duration: "5000",
                                    key: "info_alt",
                                    type: "error",
                                    mode: "pester",
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire()
                            }else{
                                component.set("v.isshow",true);
                            }
                         //  alert('ok');
             for(var i =0;i<resultData.length;i++){
             var row = resultData[i];
                       if(row.buildertek__Project__c){
             row.projectName = row.buildertek__Project__r.Name;
         }
       
             }
           
                            component.set("v.rfqRecordList", resultData);
                        }
                    });
                    $A.enqueueAction(action);
                    
                }else{
                    component.set("v.isshow",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'You cannot import SOV lines',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                } 
            } 
                
            }
        });
        $A.enqueueAction(action1);
        
        
       
    },
    doCancel :function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire() 
    },
    
    importSOVSheetLines : function(component, event, helper,sheetId){
        component.set("v.Spinner",true);
        var action = component.get("c.importScheduleOfValueItems");
         var selectedSheetIds = component.get("v.listOfSelectedRFQIds")
         var sheetId = component.get("v.recordId")  
         
        // var appId = component.get("v.paymentAppId");
        action.setParams({
            selectedId : selectedSheetIds,
            recordId : sheetId,
            isCommunity: true
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.Spinner",false);
                    //if(location.href.includes("fromsovsheet")){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": sheetId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'SOV lines imported successfully.',
                        "type": 'Success'
                    });
                    toastEvent.fire();  
                    //}
                
            }else{
                component.set("v.Spinner",false);
                this.showErrorToast(component, event, helper, 'Error', response.getReturnValue());
            }
            
        }); 
        if(selectedSheetIds == ""){
            component.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: '',
                message: 'Please Select the SOV.',
                duration: "3000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }else{
            $A.enqueueAction(action);
        }
    },
   
   
  /*   selectAllRfq : function (component, event, helper) {
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
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }
        console.log(recordIds);
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
    }, */
    
    updateSelectedText :  function (component, event, helper) {
        
        var selected = event.getParam('selectedRows');
      //  alert(selected.Id)
        var y = [];
        component.set('v.listOfSelectedRFQIds',y);
        var b =  component.get('v.listOfSelectedRFQIds');
        for(var i = 0;i < selected.length;i++)
        {
            if(b.indexOf(selected[i].Id) < 0)
            {
                b.push(selected[i].Id);
            }
            component.set('v.listOfSelectedRFQIds',b);
             // alert('you selected : ',selected[i].Id);
           // console.log('you selected : ',selected[i].Id)
        }
    }
   
    
    
    
    
    
})