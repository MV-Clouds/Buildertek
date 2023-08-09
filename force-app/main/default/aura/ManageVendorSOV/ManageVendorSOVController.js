({
    doInit : function(component, event, helper) {
        
        helper.getcurr(component, event, helper);
        
        debugger;
          var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                }
            }
                
            });
            $A.enqueueAction(action);
        

        
        
        component.set("v.SOVtotaltext","Schedule value total");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Manage SOVs"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Manage SOVs'
        });
    });
    debugger;
    var myPageRef = component.get("v.pageReference");
    var recordId = myPageRef.state.buildertek__parentId;
    var sovId = myPageRef.state.buildertek__ManageSovId;
    
    component.get("v.ProjectId", recordId);
    component.set("v.ManageSovId", sovId);
    
    // Fetch the account list from the Apex controller
    console.log('Inside Controller doInit method');
    helper.fetchSOVLinesList(component,event,helper,sovId);
    helper.getSOVStatus(component,event,helper,sovId);
    
    console.log('After helper call');
    
    
  

},
    
    NavToSovRec: function (component, event, helper) {
        debugger;
        var sovId = component.get("v.ManageSovId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.ManageSovId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }  , 
        
        selectAllRfq : function (component, event, helper) {
            debugger;
            var checkStatus = event.getSource().get("v.checked");
            var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovLineList")));
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
                debugger;
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
                
            },
                
                ApproveSOVs : function(component, event, helper){
                    debugger;
                    var target = event.target;
                    var selectId = target.getAttribute("data-index");
                    
                    var selectedSOVLines = component.get("v.listOfSelectedSOVIds");
                    if(component.get("v.SOVstatus") == 'Vendor Submitted'){  
                        if(selectId){
                            
                            component.set("v.ApprovedSOVid",selectId);
                            component.set("v.isApproveClick", true);
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : "Error!",
                                message : 'Please Select atleast 1 SOV Line.',
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });
                            toastEvent.fire(); 
                        }
                    }else if(component.get("v.SOVType") == 'Master'){  
                        if(selectId){
                            
                            component.set("v.ApprovedSOVid",selectId);
                            component.set("v.isApproveClick", true);
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : "Error!",
                                message : 'Please Select atleast 1 SOV Line.',
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });
                            toastEvent.fire(); 
                        }
                    }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : '',
                                message: 'SOV status should be 	Vendor Submitted.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        } 
                    
                },
                    
                    
                    RejectSOVs : function(component, event, helper){
                        debugger;
                        var target = event.target;
                        var selectId = target.getAttribute("data-index");
                        
                        var selectedSOVLines = component.get("v.listOfSelectedSOVIds");
                        if(component.get("v.SOVstatus") == 'Vendor Submitted'){  
                            if(selectId){
                                component.set("v.RejectSOVid",selectId);
                                component.set("v.isRejectClick", true);
                            }else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : "Error!",
                                    message : 'Please Select atleast 1 SOV Line.',
                                    type: 'error',
                                    duration: '1000',
                                    key: 'info_alt',
                                    mode: 'pester'
                                });
                                toastEvent.fire(); 
                            }
                        }else if(component.get("v.SOVType") == 'Master'){  
                            if(selectId){
                                component.set("v.RejectSOVid",selectId);
                                component.set("v.isRejectClick", true);
                            }else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : "Error!",
                                    message : 'Please Select atleast 1 SOV Line.',
                                    type: 'error',
                                    duration: '1000',
                                    key: 'info_alt',
                                    mode: 'pester'
                                });
                                toastEvent.fire(); 
                            }
                        }
                            else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : '',
                                    message: 'SOV status should be 	Vendor Submitted.',
                                    duration:' 500',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }
                        
                        
                    },
                        
                        cancelApprove: function (component, event, helper) {
                            component.set('v.isApproveClick', false);
                            component.set('v.isApproveAllClick', false);
                        },
                            
                            
                            cancelReject: function (component, event, helper) {
                                component.set("v.rejectionreason",'');
                                component.set('v.isRejectClick', false);
                            },
                                
                                
                                confirmApprove: function (component, event, helper) {
                                    //var selectedSovLineIds = component.get("v.listOfSelectedSOVIds");
                                    var action = component.get("c.ApproveSovLines");
                                    action.setParams({
                                        "sovLineIds": component.get("v.ApprovedSOVid")         
                                    });
                                    action.setCallback(this, function (response) {
                                        if (response.getState() == 'SUCCESS') {
                                            component.set('v.isApproveClick', false);
                                            
                                            var  result = response.getReturnValue();
                                            
                                            if(result == 'success'){
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    mode: 'sticky',
                                                    message: 'SOV Lines are Approved Successfully.',
                                                    type: 'success',
                                                    duration: '5000',
                                                    mode: 'dismissible'
                                                });
                                                toastEvent.fire();
                                            }
                                            
                                            $A.get('e.force:refreshView').fire();
                                        } 
                                        else {
                                            console.log('Error');
                                        }
                                    });
                                    $A.enqueueAction(action);
                                    
                                },
                                    
                                    
                                    confirmReject: function (component, event, helper) {
                                        
                                        // var selectedSovLineIds = component.get("v.listOfSelectedSOVIds");
                                         var value =  component.get("v.RejectSOVid");
                                       // alert(value);
                                        var action = component.get("c.rejectSovLines");
                                        action.setParams({
                                            "sovLineIds": component.get("v.RejectSOVid"),
                                            "rejectReason" : component.get("v.rejectionreason")
                                        });
                                        action.setCallback(this, function (response) {
                                            if (response.getState() == 'SUCCESS') {
                                                component.set('v.isRejectClick', false);
                                                
                                                var  result = response.getReturnValue();
                                               // alert(JSON.stringify(result));
                                                if(result == 'success'){
                                                    var toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        mode: 'sticky',
                                                        message: 'SOV Lines are Rejected Successfully.',
                                                        type: 'success',
                                                        duration: '5000',
                                                        mode: 'dismissible'
                                                    });
                                                    toastEvent.fire();
                                                }
                                                
                                                $A.get('e.force:refreshView').fire();
                                                
                                               //  component.set("v.editreject",result);
                                                
                                            } 
                                            else {
                                                console.log('Error');
                                            }
                                        });
                                        if(component.get('v.rejectionreason') != null && component.get('v.rejectionreason') != undefined && component.get('v.rejectionreason') != ''){
                                            $A.enqueueAction(action);
                                        }else{
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "type": "error",
                                                "title": "Error",
                                                "message": "Please Complete this field."
                                            }); 
                                            toastEvent.fire();
                                        }
                                        
                                    },
                                        
                                        
                                        closeModal : function(component, event, helper) {
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            navEvt.setParams({
                                                "recordId": component.get("v.ManageSovId"),
                                                "slideDevName": "detail"
                                            });
                                            navEvt.fire(); 
                                            
                                            
                                            
                                            var workspaceAPI = component.find("workspace");
                                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                                var focusedTabId = response.tabId;
                                                workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                                                    setTimeout($A.getCallback(function() {
                                                        //  location.reload()
                                                        $A.get('e.force:refreshView').fire();
                                                    }), 800);  
                                                })
                                                
                                            })
                                            .catch(function(error) {
                                                console.log(error);
                                            });
                                            
                                            
                                        },
                                            ApproveAllSOVs :  function(component, event, helper) {
                                                if(component.get("v.SOVstatus") == 'Vendor Submitted'){
                                                    component.set('v.isApproveAllClick', true);
                                                }
                                                else if(component.get("v.SOVType") == 'Master'){
                                                    component.set('v.isApproveAllClick', true);
                                                }
                                                    else{
                                                        var toastEvent = $A.get("e.force:showToast");
                                                        toastEvent.setParams({
                                                            title : '',
                                                            message: 'SOV status should be 	Vendor Submitted.',
                                                            duration:' 5000',
                                                            key: 'info_alt',
                                                            type: 'error',
                                                            mode: 'dismissible'
                                                        });
                                                        toastEvent.fire();
                                                    }
                                                
                                            },
                                                confirmApproveAll :  function(component, event, helper) {
                                                    //var SovIds = component.get("v.sovLineListIds");
                                                    var action = component.get("c.getAllApproved");
                                                    action.setParams({
                                                        "sovLineIds": component.get("v.sovLineListIds")         
                                                    });
                                                    action.setCallback(this, function (response) {
                                                        var  result = response.getReturnValue();
                                                        
                                                        if (response.getState() == 'SUCCESS') {
                                                            component.set('v.isApproveAllClick', false);
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                mode: 'sticky',
                                                                message: 'SOV Lines are Approved Successfully.',
                                                                type: 'success',
                                                                duration: '5000',
                                                                mode: 'dismissible'
                                                            });
                                                            toastEvent.fire();
                                                            
                                                            
                                                            $A.get('e.force:refreshView').fire();
                                                        } 
                                                        else {
                                                            console.log('Error');
                                                        }
                                                    });
                                                    $A.enqueueAction(action);
                                                    
                                                },
                                                    
                                                    changeApprovedToggle : function(component, event, helper) {
                                                        //alert(component.get("v.ApprovedToggle"));
                                                        if(component.get("v.ApprovedToggle") == false){
                                                            component.set("v.ApprovedToggle",true)
                                                            component.set("v.RejectedToggle",false);
                                                            component.set("v.AllToggle",false);
                                                            component.set("v.VendorSubmittedToggle",false)
                                                            component.set("v.CompanySubmittedToggle",false);
                                                            component.set("v.PendingToggle",false);
                                                        }else{
                                                            // component.set("v.ApprovedToggle",false)
                                                        }
                                                        var filtercondition = 'Approved';
                                                        component.set("v.SOVtotaltext","Approved Schedule value");
                                                        var sovId = component.get("v.ManageSovId");
                                                        helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
                                                        
                                                    },
                                                        ChangeRejectedToggle : function(component, event, helper) {
                                                            if(component.get("v.RejectedToggle") == false){
                                                                component.set("v.ApprovedToggle",false)
                                                                component.set("v.RejectedToggle",true);
                                                                component.set("v.AllToggle",false);
                                                                component.set("v.VendorSubmittedToggle",false)
                                                                component.set("v.PendingToggle",false);
                                                                component.set("v.CompanySubmittedToggle",false);
                                                            }else{
                                                                //component.set("v.RejectedToggle",false)
                                                            }
                                                            
                                                            var filtercondition = 'Rejected';
                                                            component.set("v.SOVtotaltext","Rejected Schedule value");
                                                            var sovId = component.get("v.ManageSovId");
                                                            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
                                                        },
                                                            changePendingToggle : function(component, event, helper) {
                                                                if(component.get("v.PendingToggle") == false){
                                                                    component.set("v.ApprovedToggle",false)
                                                                    component.set("v.RejectedToggle",false);
                                                                    component.set("v.VendorSubmittedToggle",false)
                                                                    component.set("v.AllToggle",false);
                                                                    component.set("v.PendingToggle",true);
                                                                    component.set("v.CompanySubmittedToggle",false);
                                                                }else{
                                                                    //component.set("v.PendingToggle",false)
                                                                }
                                                                var filtercondition = 'Pending';
                                                                //component.set("v.SOVtotaltext",'Pending schedule value');
                                                                var sovId = component.get("v.ManageSovId");
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
                                                                    }else{
                                                                        //component.set("v.AllToggle",false);
                                                                    }
                                                                    
                                                                    var filtercondition = 'All';
                                                                    var sovId = component.get("v.ManageSovId");
                                                                    component.set("v.SOVtotaltext","Schedule value total");
                                                                    helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
                                                                    //$A.get('e.force:refreshView').fire();
                                                                },
                                                                    
                                                                    
                                                                    changeVendorSubmittedToggle : function(component, event, helper) {
                                                                        if(component.get("v.VendorSubmittedToggle") == false){
                                                                            component.set("v.ApprovedToggle",false)
                                                                            component.set("v.RejectedToggle",false);
                                                                            component.set("v.AllToggle",false);
                                                                            component.set("v.PendingToggle",false);
                                                                            component.set("v.VendorSubmittedToggle",true);
                                                                            component.set("v.CompanySubmittedToggle",false);
                                                                            
                                                                        }else{
                                                                            //component.set("v.VendorSubmittedToggle",false)
                                                                        }
                                                                        var filtercondition = 'Vendor Submitted';
                                                                        //component.set("v.SOVtotaltext",'Pending schedule value');
                                                                        var sovId = component.get("v.ManageSovId");
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
                                                                            var sovId = component.get("v.ManageSovId");
                                                                            component.set("v.SOVtotaltext","Company Submitted Schedule value");
                                                                            helper.fetchvendorSOVonType(component,event,helper,sovId,filtercondition);
                                                                        },
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            EditRejectSOVs : function(component, event, helper){
                                                                                var value =  component.get("v.RejectSOVid");
                                                                              //  alert(value);
                                                                                debugger;
                                                                                var target = event.target;
                                                                                var selectId= target.getAttribute("data-index").split('_')[1];
                                                                                var selectedname= target.getAttribute("data-index").split('_')[0];
                                                                              
                                                                                var selectedSOVLines = component.get("v.listOfSelectedSOVIds");
                                                                                // component.set("v.isRejectClick", true);
                                                                                 component.set("v.RejectSOVid",selectId);
                                                                                        component.set("v.isRejectClick", true);
                                                                           /*   if(component.get("v.SOVstatus") == 'Vendor Submitted'){  
                                                                                    if(selectId){
                                                                                        component.set("v.RejectSOVid",selectId);
                                                                                        component.set("v.isRejectClick", true);
                                                                                    }else{
                                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                                        toastEvent.setParams({
                                                                                            title : "Error!",
                                                                                            message : 'Please Select atleast 1 SOV Line.',
                                                                                            type: 'error',
                                                                                            duration: '1000',
                                                                                            key: 'info_alt',
                                                                                            mode: 'pester'
                                                                                        });
                                                                                        toastEvent.fire(); 
                                                                                    }
                                                                                }else if(component.get("v.SOVType") == 'Master'){  
                                                                                    if(selectId){
                                                                                        component.set("v.RejectSOVid",selectId);
                                                                                        component.set("v.isRejectClick", true);
                                                                                    }else{
                                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                                        toastEvent.setParams({
                                                                                            title : "Error!",
                                                                                            message : 'Please Select atleast 1 SOV Line.',
                                                                                            type: 'error',
                                                                                            duration: '1000',
                                                                                            key: 'info_alt',
                                                                                            mode: 'pester'
                                                                                        });
                                                                                        toastEvent.fire(); 
                                                                                    }
                                                                                }*/
                                                                                   /* else{
                                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                                        toastEvent.setParams({
                                                                                            title : '',
                                                                                            message: 'SOV status should be 	Vendor Submitted.',
                                                                                            duration:' 500',
                                                                                            key: 'info_alt',
                                                                                            type: 'error',
                                                                                            mode: 'dismissible'
                                                                                        });
                                                                                        toastEvent.fire();
                                                                                    }*/
                                                                               // component.set("v.RejectSOVid",[]);
                                                                                  component.set('v.rejectionreason',selectedname);
                                                                            },
                                                                                
                                                                                
                                                                                
                                                                                
                        ApproveAllSOVsexceptReject :  function(component, event, helper) {
                                                if(component.get("v.SOVstatus") == 'Vendor Submitted'){
                                                    component.set('v.isApproveAllexceptRejectClick', true);
                                                }
                                                else if(component.get("v.SOVType") == 'Master'){
                                                    component.set('v.isApproveAllexceptRejectClick', true);
                                                }
                                                    else{
                                                        var toastEvent = $A.get("e.force:showToast");
                                                        toastEvent.setParams({
                                                            title : '',
                                                            message: 'SOV status should be 	Vendor Submitted.',
                                                            duration:' 5000',
                                                            key: 'info_alt',
                                                            type: 'error',
                                                            mode: 'dismissible'
                                                        });
                                                        toastEvent.fire();
                                                    }
                                                
                                            },                                                          
                                                                            
                  cancelApproveexceptReject: function (component, event, helper) {
                            component.set('v.isApproveClick', false);
                            component.set('v.isApproveAllexceptRejectClick', false);
                        },                                                          
                            
                            
                            confirmApproveAllExceptReject :  function(component, event, helper) {
                                                    //var SovIds = component.get("v.sovLineListIds");
                                                    var action = component.get("c.getAllApprovedexceptReject");
                                                    action.setParams({
                                                        "sovLineIds": component.get("v.sovLineListIds")         
                                                    });
                                                    action.setCallback(this, function (response) {
                                                        var  result = response.getReturnValue();
                                                        
                                                        if (response.getState() == 'SUCCESS') {
                                                            component.set('v.isApproveAllClick', false);
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                mode: 'sticky',
                                                                message: 'SOV Lines are Approved Successfully.',
                                                                type: 'success',
                                                                duration: '5000',
                                                                mode: 'dismissible'
                                                            });
                                                            toastEvent.fire();
                                                            
                                                            
                                                            $A.get('e.force:refreshView').fire();
                                                        } 
                                                        else {
                                                            console.log('Error');
                                                        }
                                                    });
                                                    $A.enqueueAction(action);
                                                    
                                                },
                                                    
                                                                            
                                                                            
})