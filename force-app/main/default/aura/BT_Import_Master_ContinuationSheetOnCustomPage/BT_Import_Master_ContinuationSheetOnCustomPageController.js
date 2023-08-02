({
    doInit : function(component, event, helper) {
        //alert('reached');
        console.log('reached')
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var recordId = component.get("v.recordId");
        console.log(component.get("v.recordId"));
        helper.getRfqList(component, event, helper, pageNumber, pageSize);
        
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                    
                    var loc = location.href.split('id=')[1];
                    var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
                    component.set("v.recordId",recordId)  
                    
                    
                }   else{
                    var recordId = component.get("v.recordId");
                }             
                
            }
        });
        $A.enqueueAction(action);
        
    },
    closeModal: function (component, event, helper) {
        
        
        if(location.href.includes("fromsovsheet")){
            var loc = location.href.split('id=')[1];
            var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
            var commUserId = location.href.split('id=')[1].split('&userIdFromcommunity=')[1].split("&dummy=")[0];
            
            var address = '/continuation-sheet-page?id='+recordId+'&userIdFromcommunity='+commUserId+'&dummy=ignore'+'/';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": address,
                "isredirect" :false
            });
            urlEvent.fire();
            $A.get('e.force:refreshView').fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        }else{
            component.get("v.cancelCallback")();
        }
        
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
    },
    
    importSheetLines: function (component, event, helper) {
        
            var records = component.get("v.rfqRecordList");
            var selectedSheetIds = component.get("v.listOfSelectedRFQIds");
        
        
        var sheetId = component.get("v.recordId");
        
        if(location.href.includes("fromsovsheet")){
            
            
            var loc = location.href.split('id=')[1];
            var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
            var commUserId = location.href.split('id=')[1].split('&userIdFromcommunity=')[1].split("&dummy=")[0];
            
            var sheetId = recordId;
            if(selectedSheetIds.length>0){
                helper.importContinuationSheetItems(component, event, helper, selectedSheetIds, sheetId);
            }else{
                helper.showErrorToast(component,event,helper,'Error!','Please select Continuation Sheet');
            }
        }else{
            var sheetId = component.get("v.recordId");
            if(selectedSheetIds.length>0){
                helper.importContinuationSheetItems(component, event, helper, selectedSheetIds, sheetId);
            }else{
                helper.showErrorToast(component,event,helper,'Error!','Please select Continuation Sheet');
            }
        }
        
    },
    
    
    
    
})