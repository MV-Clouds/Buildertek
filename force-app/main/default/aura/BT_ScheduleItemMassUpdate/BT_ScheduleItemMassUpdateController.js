({
    doInit: function (component, event, helper) {
        /*var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Mass Update"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "custom:custom70"
                });
            })
            .catch(function (error) {
                console.log('sub tab error::', error);
            });*/
        
        const workspaceAPI = component.find('workspace');

   if (workspaceAPI) {
     // ensure that we are in Console
     workspaceAPI.isConsoleNavigation().then(isConsole => {
        //  console.log({isConsole});
       if (isConsole) {
         // get our enclosing tab
         workspaceAPI.getEnclosingTabId().then(enclosingTabId => {
        //  console.log({enclosingTabId});
           // retrieve full tab info
           workspaceAPI.getTabInfo({
               tabId: enclosingTabId
           }).then(tabInfo => {
        //  console.log({tabInfo});
               // Actual action implementation

               // create variable name for retrieving info which tab we should be focusing on
               const varName = `__reply_task_return__${tabInfo.tabId}`;

               if (window[varName]) {
                 const returnToId = window[varName];
                 // delete our helper variable as it is not valid anymore
                 delete window[varName];

                 // retrieve all tabs
                 workspaceAPI.getAllTabInfo().then(tabs => {

                   // search for our destination tab
                   let destinationTab = tabs.find(tab => tab.recordId === returnToId);

                   // It is not our destination tab, but let's search in its sub tabs
                   if (!destinationTab) {
                     tabs.forEach(tab => {
                       tab.subtabs.forEach(subTab => {
                         if (returnToId === subTab.recordId) {
                           destinationTab = subTab;
                         }
                       });
                     });
                   }

                   // if we found our destination tab, then focus on it and close the current one
                   if (destinationTab) {
                     workspaceAPI.focusTab({
                       tabId : destinationTab.tabId
                     }).then(() => {
                       workspaceAPI.closeTab({ tabId: enclosingTabId });
                     });
                   }
                 });
               }
           });
         });
       }
     });
   }
        
        
        
        /*var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log({focusedTabId});
            component.set("v.currentTab",focusedTabId);
            
        }).catch(function(error){
                         console.log(error);
        })*/
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var phase = component.find("SearchPhase").get("v.value");
        var contractor = component.find("searchContractor").get("v.value");
        var contractorResources = component.find("searchContractorResources").get("v.value");
        var TradeType = component.find("searchTradeType").get("v.value");
        helper.getTableFieldSet(component, event, helper);

        window.setTimeout(
            $A.getCallback(function () {
            }), 2000
        );
        window.setTimeout(
            $A.getCallback(function () {
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                                //  console.log({focusedTabId});
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Mass Update"
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom70"
                    });
                })
                .catch(function (error) {
                    console.log('sub tab error::', error);
                });
            }), 200
        );
       
    },

    expandCollapseGroups : function (component, event, helper) { 
        var scheduleId = component.get("v.recordId")
        var tabId = component.get("v.currentTab")
        var grpIndex = event.currentTarget.dataset.grpindex;
        var expandicon
        var collapeIcon
        var className 
        var scheduleItems = component.get("v.grpByPhaseValuesMassUpdate")
        var expandedCount = component.get("v.expandedCount");
        var expandallicon;
        var collapeallIcon;
        
        if(tabId){
            var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' massupdate expandGrpIcon_'+grpIndex);
            var collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' massupdate collapseGrpIcon_'+grpIndex);
            var className = tabId+' '+scheduleId+" mapKey_"+grpIndex;
        }else{
            expandicon = document.getElementsByClassName(scheduleId+' massupdate expandGrpIcon_'+grpIndex);
            collapeIcon = document.getElementsByClassName(scheduleId+' massupdate collapseGrpIcon_'+grpIndex);
            className = scheduleId+" mapKey_"+grpIndex;
        }
        
        var grpRows = document.getElementsByClassName(className) ;
        var allGroups = component.get("v.grpByPhaseValuesMassUpdate")
        
       // var expandList = component.get("v.expandedList");
        if( scheduleItems[grpIndex].expanded){
            scheduleItems[grpIndex].expanded = false;
            expandedCount--;
            
        }else{
            scheduleItems[grpIndex].expanded = true;
            expandedCount++;
        }
        
        component.set("v.expandedCount",expandedCount)
        
        if(expandedCount == scheduleItems.length){
            if(tabId){
                expandallicon = document.getElementsByClassName(tabId+' massupdate expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName(tabId+' massupdate CollapeseAllBtn_'+scheduleId);
            }else{
                expandallicon = document.getElementsByClassName('massupdate expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName('massupdate CollapeseAllBtn_'+scheduleId);
            }
            
            collapeallIcon[0].style.display="inline-block";
            expandallicon[0].style.display="none";
            component.set("v.expandedCount",0)
            
        }else if(expandedCount == scheduleItems.length*(-1) || expandedCount == 0){
            if(tabId){
                expandallicon = document.getElementsByClassName(tabId+' massupdate expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName(tabId+' massupdate CollapeseAllBtn_'+scheduleId);
            }else{
                expandallicon = document.getElementsByClassName('massupdate expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName('massupdate CollapeseAllBtn_'+scheduleId);
            }
            
            expandallicon[0].style.display="inline-block";
            collapeallIcon[0].style.display="none";
            component.set("v.expandedCount",0)
        }
        
        component.set("v.grpByPhaseValuesMassUpdate",scheduleItems)
    },  
    
      expandCollapseAll : function (component, event, helper) {
        var scheduleId =  component.get("v.recordId");
        var tabId = component.get("v.currentTab")
        var spanEle = event.currentTarget.dataset.iconname;
        // console.log(spanEle)
        var expandallicon
        var collapeallIcon
        var scheduleItems = component.get("v.grpByPhaseValuesMassUpdate")
        
        if(tabId){
            expandallicon = document.getElementsByClassName(tabId+' massupdate expandAllBtn_'+scheduleId);
            collapeallIcon = document.getElementsByClassName(tabId+' massupdate CollapeseAllBtn_'+scheduleId);
        }else{
            expandallicon = document.getElementsByClassName('massupdate expandAllBtn_'+scheduleId);
            collapeallIcon = document.getElementsByClassName('massupdate CollapeseAllBtn_'+scheduleId);
        }
        
        var labelName =spanEle
        if(labelName == 'Expand All'){
            expandallicon[0].style.display = 'none';
            collapeallIcon[0].style.display = 'inline-block';  
            component.set("v.isExpandGrp",true)
            
            
        }else if(labelName == 'Collapse All'){
            expandallicon[0].style.display = 'inline-block';
            collapeallIcon[0].style.display = 'none';
            component.set("v.isExpandGrp",false)
            
        }
        component.set("v.isExpand",true);
        component.set("v.expandedList",[]);
        var groups = component.get("v.grpByPhaseValuesMassUpdate");
        var budgetId = component.get("v.recordId")
        var expandList
        for(var j=0;j<groups.length;j++){
            
            
            var grpIndex = j;
            var expandicon
            var collapeIcon
            var className
            
            if(tabId){
                expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' massupdate expandGrpIcon_'+grpIndex);
                collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' massupdate collapseGrpIcon_'+grpIndex);
                className = tabId+' '+scheduleId+" mapKey_"+grpIndex;
            }else{
                expandicon = document.getElementsByClassName(scheduleId+' massupdate expandGrpIcon_'+grpIndex);
                collapeIcon = document.getElementsByClassName(scheduleId+' massupdate collapseGrpIcon_'+grpIndex);
                className = scheduleId+" mapKey_"+grpIndex;
            }
            
            var grpRows = document.getElementsByClassName(className) ;
            if(labelName == 'Expand All') {  
             	scheduleItems[grpIndex].expanded = true;
                component.set("v.expandedCount",scheduleItems.length)
            }else if( labelName == 'Collapse All'){
                 scheduleItems[grpIndex].expanded = false;
                component.set("v.expandedCount",0)
            }
            
        }
        component.set("v.grpByPhaseValuesMassUpdate",scheduleItems)
    },
    
    onAddClick: function (component, event, helper) {
        component.set('v.isLoading', true);
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = '';
            if (fields[i].type == 'BOOLEAN') {
                obj[fields[i].name] = false;
            }
        }
        //obj.buildertek__Schedule__c = obj.buildertek__Schedule__c == undefined ? component.get('v.recordId') : component.get('v.recordId');
        list.unshift(obj);
        component.set('v.listOfRecords', list);
        helper.formatDataByGroups(component,list)
        window.setTimeout(function(){

            component.set('v.isLoading', false);
        },2000);
    },

    onMassUpdate: function (component, event, helper) {
        // debugger;
        component.set('v.isLoading', true);
        var phase = component.find("SearchPhase").get("v.value");
        // console.log({phase});
        var contractor = component.find("searchContractor").get("v.value");
        // console.log({contractor});
        var contractorResources = component.find("searchContractorResources").get("v.value");
        // console.log({contractorResources});
        var TradeType = component.find("searchTradeType").get("v.value");
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            helper.updateMassRecords(component, event, helper, phase, contractor, contractorResources, TradeType);
        }
    },

    onMassUpdateCancel: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            component.set('v.listOfRecords', JSON.parse(JSON.stringify(component.get('v.cloneListOfRecords'))));
            //component.set('v.massUpdateEnable', false);
            
            var workspaceAPI = component.find("workspace");
            if( workspaceAPI.getFocusedTabInfo()){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response){
                        // console.log(response)
                        workspaceAPI.openSubtab({
                            parentTabId: response.parentTabId,
                            url: '/lightning/r/buildertek__Schedule__c/'+component.get("v.recordId")+'/view',
                            focus: true
                        });
                    }).catch(function(error) {
                        component.set('v.massUpdateEnable', false);
                        // console.log(error);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "Schedule Table"
                        });
                        navEvt.fire();
                    });
                    
                     /*var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "Schedule Table"
                        });
                        navEvt.fire();*/
                    
                    
                }).catch(function(error) {
                    component.set('v.massUpdateEnable', false);
                    // console.log(error);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Schedule Table"
                    });
                    //navEvt.fire();
                    history.back();
                    //$A.get('e.force:refreshView').fire();
                    component.set('v.isLoading', false);
                });
            }else{
                component.set('v.massUpdateEnable', false);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "Schedule Table"
                });
                navEvt.fire();
            }
            
           
            
           
        }
    },
    
    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.scheduleItem', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.listOfRecords', records);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    handleDelete: function (component, event, helper) {
        component.set('v.isModalOpen', false);
        component.set('v.isLoading', true);
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        var phase = component.find("SearchPhase").get("v.value");
        var contractor = component.find("searchContractor").get("v.value");
        var contractorResources = component.find("searchContractorResources").get("v.value");
        var TradeType = component.find("searchTradeType").get("v.value");
        component.set('v.listOfRecords', []);
        helper.massDeleteRecord(component, event, helper, recordIdsToDelete, phase, contractor, contractorResources, TradeType);
    },

    handleMassDelete: function (component, event, helper) {
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        if (recordIdsToDelete.length > 0) {
            component.set('v.isModalOpen', true);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "No Schedule Items Selected",
                "message": 'Please select at least one Item.'
            });
            toastEvent.fire();
        }
    },

    onCheckBoxSelect: function (component, event, helper) {
        var index = event.getSource().get('v.name');
        var records = component.get('v.listOfRecords');
        var recordIdsToDelete = component.get('v.recordIdsToDelete');
        // debugger;
        if(event.getSource().get("v.checked")){
            event.getSource().set("v.checked",false)
        }else{
             event.getSource().set("v.checked",true)
        }
       /* if (records[index].isSelected == undefined) {
            records[index].isSelected = false;
        }*/
       /* if (records[index] != undefined && records[index].isSelected != undefined) {
            records[index].isSelected = !records[index].isSelected;
            if (records[index].isSelected) {
                recordIdsToDelete.push(records[index].Id);
            } else {
                var indexToRemove = recordIdsToDelete.indexOf(records[index].Id);
                if (indexToRemove !== -1) {
                    recordIdsToDelete.splice(indexToRemove, 1);
                }
            }
        }*/
            if (event.getSource().get("v.checked")) {
                recordIdsToDelete.push(index);
            } else {
                var indexToRemove = recordIdsToDelete.indexOf(index);
                if (indexToRemove !== -1) {
                    recordIdsToDelete.splice(indexToRemove, 1);
                }
            }
        //component.set('v.listOfRecords', records);
        component.set('v.recordIdsToDelete', recordIdsToDelete);
        event.stopPropagation();
        event.preventDefault();
        //helper.formatDataByGroups(component,records);
    },

    handleNext: function (component, event, helper) {
        var phase = component.find("SearchPhase").get("v.value");
        var contractor = component.find("searchContractor").get("v.value");
        var contractorResources = component.find("searchContractorResources").get("v.value");
        var TradeType = component.find("searchTradeType").get("v.value");
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
         component.set("v.iPrevClicked",false)             
        helper.getTableRows(component, event, helper, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
    },

    handlePrev: function (component, event, helper) {
        var phase = component.find("SearchPhase").get("v.value");
        var contractor = component.find("searchContractor").get("v.value");
        var contractorResources = component.find("searchContractorResources").get("v.value");
        var TradeType = component.find("searchTradeType").get("v.value");
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        component.set("v.iPrevClicked",true)
        
          
		component.set("v.lastPhaseNum", component.get("v.prevlastPhaseNum"))
        helper.getTableRows(component, event, helper, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
    },

    searchKeyChange: function (component, event, helper) {
        component.set('v.isLoading', true);
        var phase = component.find("SearchPhase").get("v.value");
        var contractor = component.find("searchContractor").get("v.value");
        var contractorResources = component.find("searchContractorResources").get("v.value");
        var TradeType = component.find("searchTradeType").get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getTableRows(component, event, helper, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
        // component.set('v.isLoading', false);
    }
})