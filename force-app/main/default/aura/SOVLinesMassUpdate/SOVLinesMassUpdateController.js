({
    doInit : function(component, event, helper) {
        
          var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Vendorname",result.buildertek__Account_Id__c);
                    
                    component.set("v.Iscommunity",true);
                    component.set("v.isCommUser",true)
                    
                    
                    var loc = location.href.split('id=')[1];
                    
                    var recordId = location.href.split('id=')[1].split("&dummy=")[0];
                    component.set("v.recordId",recordId)  
                }
                
                
                
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
                        }
                    }
                });
                $A.enqueueAction(action2);
                
                
                component.set('v.isLoading', true);
                helper.getTableFieldSet(component, event, helper);
                helper.getTotalRecord(component, event, helper);
        
            }
            
        });
        $A.enqueueAction(action);
        

      
        
        
    },
    
    onMassUpdate: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
        
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            helper.updateMassRecords(component, event, helper);
        }
    },
    
    onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = '';
            if (fields[i].type == 'BOOLEAN') {
                obj[fields[i].name] = false;
            }
        }
        list.unshift(obj);
        component.set('v.listOfRecords', list);
        // helper.formatDataByGroups(component,list)
    },
    
    
    onMassUpdateCancel: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            component.set('v.listOfRecords', JSON.parse(JSON.stringify(component.get('v.cloneListOfRecords'))));
            component.set('v.massUpdateEnable', false);
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
            
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
            
            
        }
    },
    
    onCheckBoxSelect: function (component, event, helper) {
        var index = event.getSource().get('v.name');
        var records = component.get('v.listOfRecords');
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        debugger;
        if (records[index].isSelected == undefined) {
            records[index].isSelected = false;
        }
        if (records[index] != undefined && records[index].isSelected != undefined) {
            records[index].isSelected = !records[index].isSelected;
            if (records[index].isSelected) {
                recordIdsToDelete.push(records[index].Id);
            } else {
                var indexToRemove = recordIdsToDelete.indexOf(records[index].Id);
                if (indexToRemove !== -1) {
                    recordIdsToDelete.splice(indexToRemove, 1);
                }
            }
        }
        component.set('v.listOfRecords', records);
        component.set('v.recordIdsToDelete', recordIdsToDelete);
        event.preventDefault();
    },
    
    handleMassDelete: function (component, event, helper) {
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        if (recordIdsToDelete.length > 0) {
            component.set('v.isModalOpen', true);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "No SOV Lines Selected",
                "message": 'Please select at least one Line Item.'
            });
            toastEvent.fire();
        }
    },
    
    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },
    
    handleDelete: function (component, event, helper) {
        component.set('v.isModalOpen', false);
        component.set('v.isLoading', true);
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        
        component.set('v.listOfRecords', []);
        helper.massDeleteRecord(component, event, helper, recordIdsToDelete);
    },
    
    handlePrev: function (component, event, helper) {
        
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },
    
    handleNext: function (component, event, helper) {
        
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },
    BackToSov : function(component, event, helper) {
        event.preventDefault();
        /* var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/r/buildertek__Schedule_of_Values__c/'+component.get("v.recordId")+'/view'
            });
            urlEvent.fire(); */
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        
    },
    
    
})