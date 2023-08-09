({
    doInit : function(component, event, helper) {
        debugger;
        
        
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.buildertek__parentId;
        
        if(recordId != null || recordId != undefined){
            component.set("v.recordId",recordId);
        }else{
            var recId = component.get("v.recordId");
            component.set("v.recordId",recId);
        }
        
        component.set('v.mycolumns', [
            {label: 'SOV', fieldName: 'Name', type: 'text'},
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
            {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'}
            
        ]);
        console.log('reached')
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var recordId = component.get("v.recordId");
        console.log(component.get("v.recordId"));
        
        
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                    if(location.href.includes("fromsovsheet")){
                        var loc = location.href.split('id=')[1];
                        
                        var recordId = location.href.split('id=')[1].split("&dummy=")[0];
                        component.set("v.recordId",recordId)
                    }
                    helper.getRfqList(component, event, helper, pageNumber, pageSize);
                    
                    
                    //To Check Status Is Submitted Or Not
                    var action2 = component.get("c.isSovSubmitted");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            var result = response.getReturnValue();
                            if(result == "Vendor Submitted"){
                                component.set("v.IsSubmitted", true)
                            }else if(result == "Company Approved"){
                                component.set("v.IsCompanyApproved", true)
                            }else{
                                component.set("v.IsActive", true)
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                    
                    
                    
                }else{
                    component.set("v.IsActive", true)
                    helper.getRfqList(component, event, helper, pageNumber, pageSize);
                }
                
                
            }
        });
        $A.enqueueAction(action);
        
    },
    close : function (component, event, helper) {
        debugger;
      /*  var fromSheet = component.get("v.address");
        if(fromSheet == 'SOVSheetfromsalesforce'){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });  
            
        }
        else if(component.get("v.IsImportMasterSOV") == true){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
        }
            else{
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire(); 
            }*/
        
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        debugger;
        var workspaceAPI = component.find( "workspace" );
        workspaceAPI.getFocusedTabInfo().then( function( response ) {
            var focusedTabId = response.tabId;
            window.setTimeout(
                $A.getCallback(function() {
                    workspaceAPI.closeTab( { tabId: focusedTabId } );
                    
                }), 1000);
        })
        
  // $A.get('e.force:refreshView').fire();        
        
    },
    
    
    closeModal: function (component, event, helper) {
        
        debugger;
        if(location.href.includes("fromsovsheet")){
            var address = '/schedule-of-value-lines?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": address,
                "isredirect" :false
            });
            urlEvent.fire();
            $A.get('e.force:refreshView').fire();
            
        }else{
            
            var fromsovsheet = component.get("v.address");
            
            if(fromsovsheet == 'FromSovSheet'){
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:ScheduleOfValueLines",
                    componentAttributes: {
                        recordId : component.get("v.recordId"),
                    }
                });
                evt.fire();
                
             /*   var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    console.log(focusedTabId)
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                }); */
                
                $A.get('e.force:refreshView').fire();
            }else{
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
            }
            
            
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
        if(selectedSheetIds.length>0){
            helper.importContinuationSheetItems(component, event, helper, selectedSheetIds, sheetId);
        }else{
            helper.showErrorToast(component,event,helper,'Error!','Please select SOV ');
        }
    },
    getSelectedName: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        var y =[];
        component.set("v.listOfSelectedRFQIds",y);
        var selectedRowList =component.get("v.listOfSelectedRFQIds")
        
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            }
            component.set("v.listOfSelectedRFQIds",selectedRowList)
            
        }
        
    },
    
    
    
    
})