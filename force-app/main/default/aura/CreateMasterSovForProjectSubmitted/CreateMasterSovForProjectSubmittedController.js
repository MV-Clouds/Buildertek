({
    doInit : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Manage SOV"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Manage SOV'
        });
    });
    
    helper.getcurr(component, event, helper);
    
    var pageNumber = component.get("v.PageNumber");  
    var pageSize = component.get("v.pageSize"); 
    
      var pageNumber1 = component.get("v.PageNumber1");  
    var pageSize1 = component.get("v.pageSize1");  
    
        debugger;
        var myPageRef = component.get("v.pageReference");
        var projectId = myPageRef.state.buildertek__parentId;
        var recordId = myPageRef.state.buildertek__ManageSovId;
         component.set("v.projectId",projectId);
        component.set("v.recordId",recordId);   
        helper.getApprovedLinesList(component, event, helper, pageNumber, pageSize);
        helper.getPendingLinesList(component, event, helper, pageNumber1, pageSize1);

        var action2 = component.get("c.getProjectName");
        action2.setParams({
            "projectId": projectId           
        });
        action2.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var  result = response.getReturnValue();
                component.set("v.projectName",result)
            }
        });
        $A.enqueueAction(action2);   
        
        var action1 = component.get("c.getManageSovName");
        action1.setParams({
            "sovId": recordId            
        });
        action1.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var  result = response.getReturnValue();
                component.set("v.ManageSovName",result)
            }
        });
        $A.enqueueAction(action1);

        var action3 = component.get("c.getManageSovsTotal");
        action3.setParams({
            "sovId": recordId              
        });
        action3.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var  result = response.getReturnValue();
               // component.set("v.ManageSovTotal",result)
            }
        });
        $A.enqueueAction(action3);

        
    },

    AddtoMasterSOV : function(component, event, helper) {
        
        
        var selectlength = false;
        var Approvedlist = component.get("v.ApprovedrecordsList");
        for(var i=0;i< Approvedlist.length; i++){
            if(Approvedlist[i].checksov){
                selectlength = true;
            }   
        }
        
        if(selectlength){
            var oldApprovedlist = component.get("v.ApprovedrecordsList");
            var NewApprovelist = [];
            var Pendinglist = component.get("v.PendingrecordsList");
            
            for(var j=0;j< oldApprovedlist.length; j++){
                if(oldApprovedlist[j].checksov == false){
                    NewApprovelist.push(oldApprovedlist[j])
                }   
            }
            
            for(var i=0;i< Approvedlist.length; i++){
                if(Approvedlist[i].checksov){
                    Approvedlist[i].checksov = false;
                    Pendinglist.push(Approvedlist[i]);    
                }   
            }
            
            
            component.set("v.PendingrecordsList",Pendinglist);
            component.set("v.ApprovedrecordsList",NewApprovelist);
            component.set("v.pendingcheckAll",false)
            component.set("v.ApprovecheckAll",false)            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOV Lines',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
        
        
        
    },

    selectRfq : function(component, event, helper) {

    },

    CloseScreen : function(component, event, helper) {
        component.set("v.isConsolidate",false)
        component.set("v.isCreateMasterSOV",false)
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
    },

    addCombinedLine: function (component, event, helper) {
        debugger;
     var   DescWork = component.get("v.description");
         var item =  component.get("v.itemNumber");
        if(DescWork){
           component.set("v.showMessage", true);
        component.set("v.IsConslidatedBtn",true);
        component.set("v.isConsolidate",false);
        var Approvedlist = component.get("v.ApprovedrecordsList");
        var oldApprovedlist = component.get("v.ApprovedrecordsList");
        var NewApprovelist = [];
        var Pendinglist = component.get("v.PendingrecordsList");
        for(var j=0;j< oldApprovedlist.length; j++){
            if(oldApprovedlist[j].checksov == false){
                NewApprovelist.push(oldApprovedlist[j])
            }   
        }
        var consolidatedlist = [];
        for(var i=0;i< Approvedlist.length; i++){
            if(Approvedlist[i].checksov){
                consolidatedlist.push(Approvedlist[i]);
            }   
        }
            
            var itemNumber = component.find("itemNumber").get("v.value");
            
        var approvedrecord = {
            'checksov' : false,
            'Item': itemNumber,
            'DescofWork': component.get("v.description"),
            'ScheduleValue': component.get("v.listOfFields"),
            'VendorName ': '', 
            'Type':'',
            'ConsolidatedLinesInnerlist' : consolidatedlist,
            'IsConsolidate' : true,
            'IsExpand' : false  
        }
        Pendinglist.push(approvedrecord);
        component.set("v.PendingrecordsList",Pendinglist);
        component.set("v.ApprovedrecordsList",NewApprovelist);
        component.set("v.pendingcheckAll",false)
        component.set("v.ApprovecheckAll",false) 
        component.set("v.description","")
        component.set("v.itemNumber", "")
        component.set("v.listOfFields", "")
        component.set("v.autoItemNum", Number(component.get("v.autoItemNum")) +1);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Description of Work Required',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
    },

    toggle: function(component, event, helper) {
        var parentItems = component.get("v.PendingrecordsList"),
            parentIndex = event.getSource().get("v.title");
        
            parentItems[parentIndex].IsExpand = !parentItems[parentIndex].IsExpand;
        component.set("v.PendingrecordsList", parentItems);
    },

    ConsolidateLines : function(component, event, helper) {
        debugger;
       
        var action2 = component.get("c.getItemNumber");
        action2.setParams({
            "recordId": component.get("v.recordId")           
        });
        action2.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var  result = response.getReturnValue();
               
                component.set("v.autoItemNum",result)
                 component.set("v.OldAutoItemNum",result)
            }
        });
        
        
        if(!component.get("v.OldAutoItemNum")){
              $A.enqueueAction(action2);
            component.set("v.description","")
        }
      
        
        
        
        var selectlength = false;
        var Approvedlist = component.get("v.ApprovedrecordsList");
        for(var i=0;i< Approvedlist.length; i++){
            if(Approvedlist[i].checksov){
                selectlength = true;
            }   
        }

        if(selectlength){
            component.set("v.showMessage", true);
            component.set("v.isConsolidate",true);
            var Approvedlist = component.get("v.ApprovedrecordsList");
            var schedulevalue = 0;
            var description = '';
            for(var i=0;i< Approvedlist.length; i++){
                if(Approvedlist[i].checksov){
                    schedulevalue +=  Approvedlist[i].ScheduleValue 
                  //  description = Approvedlist[i].DescofWork
                }   
            }
            component.set("v.listOfFields", schedulevalue);
           // component.set("v.description",description);

        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOV Lines',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire(); 
        }  
    },

    deletePopUp : function(component, event, helper){
        var index = event.currentTarget.dataset.index;
        var recordId = event.currentTarget.dataset.recid;
        component.set("v.indexForDelete", index)
        component.set("v.recIdForDelete", recordId)
        component.set("v.isDeletePopUp", true);
    },

    condeletePopUp : function(component, event, helper){
        var index = event.currentTarget.dataset.index;
        var conindex = event.currentTarget.dataset.title;
        var recordId = event.currentTarget.dataset.recid;
        component.set("v.indexForDelete", index)
        component.set("v.conindexForDelete", conindex)
        component.set("v.recIdForDelete", recordId)
        component.set("v.isconDeletePopUp", true);
    },

    cancelDelete : function(component, event, helper){
        component.set("v.isDeletePopUp", false);
    },
    
    deleteRow : function(component, event, helper){
        debugger;
        var index = Number(component.get("v.indexForDelete"));
        var Approvedlist = component.get("v.ApprovedrecordsList");
        var oldApprovedlist = component.get("v.ApprovedrecordsList");
        var NewApprovelist = [];
        var Pendinglist = component.get("v.PendingrecordsList");
        var isdelete = false;
        if(Pendinglist[index].IsConsolidate){
            for(var i=0;i< Pendinglist[index].ConsolidatedLinesInnerlist.length;i++){
                Pendinglist[index].ConsolidatedLinesInnerlist[i].checksov = false;
                Approvedlist.push(Pendinglist[index].ConsolidatedLinesInnerlist[i]);
                isdelete = true;
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'SUCCESS',
                message: 'The Selected SOV Line is Removed Successfully',
                duration: "5000",
                key: "info_alt",
                type: "success",
            });
            toastEvent.fire(); 
        }
        else{
            Pendinglist[index].checksov = false;
            Approvedlist.push(Pendinglist[index]);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'SUCCESS',
                message: 'The Selected SOV Line is Removed Successfully',
                duration: "5000",
                key: "info_alt",
                type: "success",
            });
            toastEvent.fire(); 
        }  
        if(Pendinglist[index].Id != undefined && Pendinglist[index].Id != null && Pendinglist[index].Id != '' && isdelete == true){
            var deleterecords = [];
            deleterecords.push(Pendinglist[index].Id);
            var action2 = component.get("c.deleteSovlineData");
            action2.setParams({
                "recordId": deleterecords         
            });
            action2.setCallback(this, function (response) {
                debugger;
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var  result = response.getReturnValue(); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'SUCCESS',
                        message: 'The Selected SOV Line is Removed Successfully',
                        duration: "5000",
                        key: "info_alt",
                        type: "success",
                    });
                    toastEvent.fire(); 
                }
            });
            $A.enqueueAction(action2);  
        }
        component.set("v.ApprovedrecordsList",Approvedlist);
        Pendinglist.splice(Number(index), 1);
        component.set("v.PendingrecordsList",Pendinglist);
        component.set("v.isDeletePopUp", false);

    },

    concancelDelete : function(component, event, helper){
        component.set("v.isconDeletePopUp", false);
    },

    condeleteRow : function(component, event, helper){
        debugger;
        var index = Number(component.get("v.indexForDelete"));
        var conindex = Number(component.get("v.conindexForDelete"));
        var Approvedlist = component.get("v.ApprovedrecordsList");
        var oldApprovedlist = component.get("v.ApprovedrecordsList");
        var NewApprovelist = [];
        var Pendinglist = component.get("v.PendingrecordsList");

        Pendinglist[index].ScheduleValue = Pendinglist[index].ScheduleValue - Pendinglist[index].ConsolidatedLinesInnerlist[conindex].ScheduleValue
        Pendinglist[index].ConsolidatedLinesInnerlist[conindex].checksov = false;
        Approvedlist.push(Pendinglist[index].ConsolidatedLinesInnerlist[conindex])
       
        component.set("v.ApprovedrecordsList",Approvedlist);
        Pendinglist[index].ConsolidatedLinesInnerlist.splice(Number(conindex), 1);
        if(Pendinglist[index].ScheduleValue <=0){
            
            if(Pendinglist[index].Id != undefined && Pendinglist[index].Id != null && Pendinglist[index].Id != ''){
                var deleterecords = [];
                deleterecords.push(Pendinglist[index].Id);
                var action2 = component.get("c.deleteSovlineData");
                action2.setParams({
                    "recordId": deleterecords         
                });
                action2.setCallback(this, function (response) {
                    debugger;
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var  result = response.getReturnValue(); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'SUCCESS',
                            message: 'The Selected SOV Line is Removed Successfully',
                            duration: "5000",
                            key: "info_alt",
                            type: "success",
                        });
                        toastEvent.fire(); 
                    }
                });
                $A.enqueueAction(action2);
                 
            }
           if(!Pendinglist[index].ConsolidatedLinesInnerlist.length){
               Pendinglist.splice(Number(index), 1); 
           }
           
        }
        component.set("v.PendingrecordsList",Pendinglist);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'SUCCESS',
            message: 'The Selected SOV Line is Removed Successfully',
            duration: "5000",
            key: "info_alt",
            type: "success",
        });
        toastEvent.fire(); 
        component.set("v.isconDeletePopUp", false);

    },

    selectAllRfq : function(component, event, helper){
        var ApprovecheckAll = component.get("v.ApprovecheckAll");
        var Approvedlist = component.get("v.ApprovedrecordsList");
        if(ApprovecheckAll == true){
            for(var i=0;i< Approvedlist.length;i++){
                Approvedlist[i].checksov = true;
            }
        }
        else{
            for(var i=0;i< Approvedlist.length;i++){
                Approvedlist[i].checksov = false;
            }
        }
        component.set("v.ApprovedrecordsList",Approvedlist);
    },

    selectAllRfq1 : function(component, event, helper){
        var pendingcheckAll = component.get("v.pendingcheckAll");
        var PendingrecordsList = component.get("v.PendingrecordsList");
        if(pendingcheckAll == true){
            for(var i=0;i< PendingrecordsList.length;i++){
                PendingrecordsList[i].checksov = true;
            }
        }
        else{
            for(var i=0;i< PendingrecordsList.length;i++){
                PendingrecordsList[i].checksov = false;
            }
        }
        component.set("v.PendingrecordsList",PendingrecordsList);
    },

    removepopopen : function(component, event, helper){
       
        
        var selectlength = false;
        var Approvedlist = component.get("v.PendingrecordsList");
        for(var i=0;i< Approvedlist.length; i++){
            if(Approvedlist[i].checksov){
                selectlength = true;
            }   
        }
        
        if(selectlength){
            component.set("v.isRemovePopUp", true);            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOV Lines',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire(); 
            
        }
        
    },

    removepopclose : function(component, event, helper){
        component.set("v.isRemovePopUp", false);
    },

    deleteSelectedRightLines : function(component, event, helper){
        debugger;
        var Approvedlist = component.get("v.PendingrecordsList");
        var oldApprovedlist = component.get("v.PendingrecordsList");
        var NewApprovelist = [];
        var Pendinglist = component.get("v.ApprovedrecordsList");

        for(var j=0;j< oldApprovedlist.length; j++){
            if(oldApprovedlist[j].checksov == false){
                NewApprovelist.push(oldApprovedlist[j])
            }   
        }
        var deleterecords = [];
        for(var i=0;i< Approvedlist.length; i++){
            if(Approvedlist[i].checksov){
                Approvedlist[i].checksov = false;
                if(Approvedlist[i].IsConsolidate){
                    for(var j=0;j< Approvedlist[i].ConsolidatedLinesInnerlist.length;j++){
                        Approvedlist[i].ConsolidatedLinesInnerlist[j].checksov = false;
                        Pendinglist.push(Approvedlist[i].ConsolidatedLinesInnerlist[j]);
                        deleterecords.push(Approvedlist[i].Id);
                    }
                }
                else{
                    Approvedlist[i].checksov = false;
                    Pendinglist.push(Approvedlist[i]);
                }  
            }   
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'SUCCESS',
            message: 'The Selected SOV Lines are Removed Successfully',
            duration: "5000",
            key: "info_alt",
            type: "success",
        });
        toastEvent.fire(); 

        if(deleterecords.length > 0){
            
            var action2 = component.get("c.deleteSovlineData");
            action2.setParams({
                "recordId": deleterecords         
            });
            action2.setCallback(this, function (response) {
                debugger;
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var  result = response.getReturnValue(); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'SUCCESS',
                        message: 'The Selected SOV Lines are Removed Successfully',
                        duration: "5000",
                        key: "info_alt",
                        type: "success",
                    });
                    toastEvent.fire(); 
                }
            });
            $A.enqueueAction(action2);
             
        }
        
        component.set("v.PendingrecordsList",NewApprovelist);
        component.set("v.ApprovedrecordsList",Pendinglist);
        component.set("v.pendingcheckAll",false)
        component.set("v.ApprovecheckAll",false)
        component.set("v.isRemovePopUp", false);
    },

    gotoSOV : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            setTimeout($A.getCallback(function() {
                workspaceAPI.closeTab({tabId: focusedTabId});
            }), 1000);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
        
        confirmDelete : function(component, event, helper){
            debugger;
            
           
            var Approvedlist = component.get("v.ApprovedrecordsList");
            
            var SelectedIds = [];
            
            for(var i=0;i< Approvedlist.length; i++){
                if(Approvedlist[i].checksov == true){
                    SelectedIds.push(Approvedlist[i].Id);
                }   
            }
            
            component.set("v.selectedLeftRecordList",SelectedIds)
            
            if(SelectedIds.length){
                component.set("v.rejectSOVPopUp",true)
     
                
            }else{
                                component.set("v.rejectSOVPopUp",false)
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'Please select SOV Lines',
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        },
            
            
            
            RejectSelectedSOVLines : function(component, event, helper) {
                debugger;
                component.set("v.Spinner", true);
                component.set("v.rejectSOVPopUp",false);
                
                var Approvedlist = component.get("v.selectedLeftRecordList");
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.get("v.pageSize");
                
                var action = component.get("c.deleteSovLines");
                
                action.setParams({
                    "recIds": Approvedlist           
                }); 
                action.setCallback(this, function (response) {
                    debugger;
                   component.set("v.rejectSOVPopUp",false);
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        component.set("v.Spinner", false);
                        var  result = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'SUCCESS',
                            message: 'Selected SOV Lines are deleted successfully',
                            duration: "5000",
                            key: "info_alt",
                            type: "success",
                        });
                        toastEvent.fire(); 
                        
                        helper.getApprovedLinesList(component, event, helper, pageNumber, pageSize);
                        helper.getPendingLinesList(component, event, helper, pageNumber, pageSize); 
                        
                        
                    }else{
                        component.set("v.Spinner", false);
                    }
                });
                $A.enqueueAction(action);
                
            },
                
                
                
                
                checkToogle : function(component, event, helper){
                    
                },  

    

    redirectToManageSov : function(component, event, helper){  
        var PendingrecordsList = JSON.stringify(component.get("v.PendingrecordsList"))
        var ApprovedrecordsList =   JSON.stringify(component.get("v.ApprovedrecordsList"));
        component.set("v.Spinner", true);
        var action = component.get("c.updateManageSOV");
            action.setParams({
                "Pendingrecord": PendingrecordsList,
                "Approvedrecord" : ApprovedrecordsList,
                "recordId" : component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue() == 'Success') {
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    helper.getApprovedLinesList(component, event, helper);
                    helper.getPendingLinesList(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'SUCCESS',
                            message: 'Your changes are saved successfully',
                            duration: "5000",
                            key: "info_alt",
                            type: "success",
                        });
                        toastEvent.fire();  
                    
                } else {
                    console.log('Error');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: response.getReturnValue(),
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                    });
                    toastEvent.fire();  
                }
            });
            $A.enqueueAction(action);
    },

    NavToProjectRec: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.projectId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }  ,

    NavToSovRec: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }  ,
    
    
    RejectSOVs : function(component, event, helper){
        debugger;
        var index = event.currentTarget.dataset.index;
        var conindex = event.currentTarget.dataset.title;
        var recordId = event.currentTarget.dataset.recid;
        component.set("v.indexForReject", index)
        component.set("v.conindexForReject", conindex)
        component.set("v.recIdForReject", recordId)
        component.set("v.isRejectClick", true);
        var  rejectreason = component.get("v.rejectionreason");
        component.set("v.rejectionreason",rejectreason);
        
    },
    
    
    confirmRejectReason : function(component, event, helper){
         component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        debugger;
        var index = Number(component.get("v.indexForReject"));
        var conindex = Number(component.get("v.conindexForReject"));
        var recId =   component.get("v.recIdForReject");
        var rejectReason =  component.get("v.rejectionreason")
        
        var rejReason = component.get("v.rejectionreason");
        
        if(rejReason){
            var action2 = component.get("c.rejectSovlineData");
        action2.setParams({
            "recordId": recId,
            "rejectReason" : component.get("v.rejectionreason")
        });
        action2.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) { 
                var  result = response.getReturnValue(); 
                
                component.set("v.rejectionreason", '');
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                
                $A.get('e.force:refreshView').fire(); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'SUCCESS',
                    message: 'The Selected SOV Line is Rejected Successfully',
                    duration: "5000",
                    key: "info_alt",
                    type: "success",
                });
                toastEvent.fire(); 
                
                
                
                helper.getPendingLinesList(component, event, helper);
            }else{
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
            }
        });
        $A.enqueueAction(action2);
        component.set("v.isRejectClick", false);
        }else{
            
            component.set("v.Spinner", false);
        component.set("v.showMessage", false);
            
           var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please fill the required field',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
            
        }
        
      
        
        
    },

    cancelReject : function(component, event, helper){
        component.set("v.isRejectClick", false);
        component.set("v.rejectSOVPopUp", false);
    },
    
    CloseAddLinePopUp : function(component, event, helper){
        component.set("v.isAddNewLine", false);
    },
    
    AddNewLine: function (component, event, helper) {
        
        var action2 = component.get("c.getItemNumber");
        action2.setParams({
            "recordId": component.get("v.recordId")           
        });
        action2.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var  result = response.getReturnValue();
                
                component.set("v.autoItemNum",result)
                component.set("v.OldAutoItemNum",result)
            }
        });
        if(!component.get("v.OldAutoItemNum")){
            $A.enqueueAction(action2);
        }
        
        
        component.set("v.isAddNewLine", true);
    }  ,
    
    ConfirmAddNewLine: function (component, event, helper) {
        
        debugger;
        var   DescWork = component.get("v.newDescription");
        if(DescWork){
            component.set("v.showMessage", true);
           
            var Pendinglist = component.get("v.PendingrecordsList");
           
           var itemNumber = component.find("newItemNumber").get("v.value");
            
          
            if(!component.get("v.newScheduledValue")){
                component.set("v.newScheduledValue",0);
            }
            
            var approvedrecord = {
                'checksov' : false,
                'Item': itemNumber,
                'DescofWork': component.get("v.newDescription"),
                'ScheduleValue': component.get("v.newScheduledValue"),
                'VendorName ': '', 
                'Type':'',
                'IsConsolidate' : false,
                'IsExpand' : false  
            }
            Pendinglist.push(approvedrecord);
            component.set("v.PendingrecordsList",Pendinglist);
            component.set("v.pendingcheckAll",false)
            component.set("v.ApprovecheckAll",false) 
            component.set("v.newDescription","")
            component.set("v.newItemNumber","")
            component.set("v.newScheduledValue","")
            component.set("v.isAddNewLine", false);
            component.set("v.autoItemNum", Number(component.get("v.autoItemNum")) +1);
            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Description of Work Required',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
    }  ,
    
    
    editPopUp : function(component, event, helper){
        debugger;
        var index = event.currentTarget.dataset.index;
        var recordId = event.currentTarget.dataset.recid;
        var itemNumber = event.currentTarget.dataset.item;
        var description = event.currentTarget.dataset.desc;
        var scheduledvalue = event.currentTarget.dataset.schv;
        
        
        component.set("v.itemNumber", itemNumber);
        component.set("v.description", description);
        component.set("v.listOfFields", scheduledvalue);
        
        component.set("v.indexForEdit", index)
        component.set("v.recIdForEdit", recordId)
        component.set("v.isEditPopUp", true);
    },
    
    closeEditScreen : function(component, event, helper){
        component.set("v.isEditPopUp", false);
    },
    
    saveConsolidatedLine : function(component, event, helper) {
        debugger;
        var index = component.get("v.indexForEdit");
        var itemNumber = component.find("itemNumber").get("v.value");
        var descWork =  component.find("DescWork").get("v.value");
        var scheduleValue =  component.find("schvalue").get("v.value");
        
        var  DescWork = descWork
        if(DescWork){
            component.set("v.showMessage", true);
            var Pendinglist = component.get("v.PendingrecordsList");
            
            Pendinglist[index].Item = itemNumber;
            Pendinglist[index].DescofWork = descWork;
            Pendinglist[index].ScheduleValue = scheduleValue;
            
          /*  var approvedrecord = {
                'checksov' : false,
                'Item': itemNumber,
                'DescofWork': descWork,
                'ScheduleValue': scheduleValue,
                'VendorName ': '', 
                'Type':'',
                'IsConsolidate' : true,
                'IsExpand' : false  
            }
            Pendinglist.push(approvedrecord);*/
            component.set("v.PendingrecordsList",Pendinglist);
            component.set("v.pendingcheckAll",false)
            component.set("v.ApprovecheckAll",false) 
            component.set("v.newDescription","")
            component.set("v.newItemNumber","")
            component.set("v.newScheduledValue","")
            component.set("v.isEditPopUp",false)
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Description of Work Required',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        } 
    },
        
        
        handleNext: function(component, event, helper) {
            var pageNumber = component.get("v.PageNumber");  
            var pageSize = component.get("v.pageSize");
            pageNumber++;
          
            helper.getApprovedLinesList(component,event,helper, pageNumber, pageSize);
        },
            
            handlePrev: function(component, event, helper) {
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = component.get("v.pageSize");
                pageNumber--;
                helper.getApprovedLinesList(component,event,helper, pageNumber, pageSize);
            },
                
                
                
                
                handleNext1: function(component, event, helper) {
                    var pageNumber = component.get("v.PageNumber1");  
                    var pageSize = component.get("v.pageSize1");
                    pageNumber++;
                    helper.getPendingLinesList(component,event,helper, pageNumber, pageSize);
                },
                    
                    handlePrev1: function(component, event, helper) {
                        var pageNumber = component.get("v.PageNumber1");  
                        var pageSize = component.get("v.pageSize1");
                        pageNumber--;
                        helper.getPendingLinesList(component,event,helper, pageNumber, pageSize);
                    },
                        
                        
                        doSearch: function (component, event, helper) {
                           
                            debugger;
                            var pageNumber = component.get("v.PageNumber");
                            var pageSize = component.get("v.pageSize");
                            helper.getApprovedLinesList(component, event, helper,pageNumber,pageSize);
                        },
})