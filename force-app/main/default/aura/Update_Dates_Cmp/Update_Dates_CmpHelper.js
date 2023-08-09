({
    getInitialData: function(component, event, helper) {         
        var action = component.get("c.onLoadCall");
        
        console.log('Opty Id==>'+component.get("v.recordId"));
        
        action.setParams({
            oppId : component.get("v.recordId")
        });
        console.log('Opty Id records==>');
        
        action.setCallback(this, function(result) {
            console.log(result.getState());
            var records = result.getReturnValue();
            console.log('records==>');
            console.log(records);
            if(records != null){ 
                component.set("v.referenceIds", records.referenceIds);
               /* var references = records.referenceIds;
                //alert(references.length);
                var plValues = [];
                for (var i = 0; i < references.length; i++) {
                    //alert(references[i].Name);
                    plValues.push({                        
                        label: references[i].Name,
                        value: references[i].Name
                    });
                }
                component.set("v.GenreList", plValues);*/
                
                component.set("v.releaseNames", records.releaseNames);
                component.set("v.listWrapper", records.editableOELs);
                component.set("v.listWrapperNonEditable", records.nonEditableOELs);                
                component.set("v.enableShipDate", records.enableShipDate);                
                component.set("v.enableRequestDate", records.enableRequestDate);             
                component.set("v.productSKU", records.productSKU);  
                component.set("v.enablePage", records.enablePage);
                component.set("v.mapWrapperOld", records.mapWrapperOld);
                component.set("v.processHeaders", records.processHeaders);
                console.log("v.listOEL==>");
                
                component.set("v.updateDatesWrapper", records);
                //console.log(component.get("v.listOEL"));
                //            component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    filterChangeEvent: function(component, event, helper,closePop) {         
        var action = component.get("c.filterChange");
        
        console.log('Opty Id==> '+ component.get("v.recordId"));
        var wrapperInfo = component.get("v.updateDatesWrapper");
        
        console.log('Opty selectedReferenceId ==> '+ component.get("v.selectedReferenceId"));
        console.log('Opty selectedSKU==> '+ component.get("v.selectedSKU"));
        
        
        wrapperInfo.selectedReferenceId = component.get("v.selectedReferenceId");
        //wrapperInfo.selectedReferenceId = JSON.stringify(component.get("v.selectedGenreList"));
        wrapperInfo.selectedSKU = component.get("v.selectedSKU");
        action.setParams({
            oppId : component.get("v.recordId"),
            wrapperData : JSON.stringify(wrapperInfo)
        });
        console.log('Opty Id records==>');
        
        action.setCallback(this, function(result) {
            console.log(result.getState());
            var records = result.getReturnValue();
            console.log('records==>');
            console.log(records);
            if(records != null){      
                
                if(records.selectedReferenceId == '' || records.selectedReferenceId == '--None--'){
                    component.set("v.referenceIds", records.referenceIds);                    
                    var references = records.referenceIds;
                    //alert(references.length);
                    var plValues = [];
                    for (var i = 0; i < references.length; i++) {
                        //alert(references[i].Name);
                        plValues.push({                        
                            label: references[i].Name,
                            value: references[i].Name
                        });
                    }
                    component.set("v.GenreList", plValues);
                }
                
                if(records.selectedSKU == '' || records.selectedSKU == '--None--'){
                    component.set("v.productSKU", records.productSKU);
                }
                
                component.set("v.listWrapper", records.editableOELs);
                component.set("v.listWrapperNonEditable", records.nonEditableOELs);                
                component.set("v.enableShipDate", records.enableShipDate);                
                component.set("v.enableRequestDate", records.enableRequestDate); 
                component.set("v.enablePage", records.enablePage);
                component.set("v.mapWrapperOld", records.mapWrapperOld);
                component.set("v.processHeaders", records.processHeaders);
                console.log("v.listOEL==>");
                component.set("v.updateDatesWrapper", records);                
                component.set("v.selectedSKU", records.selectedSKU);
                component.set("v.selectedReferenceId", records.selectedReferenceId);
                
                
                if(closePop){
                    helper.toggleClassInverse(component,'backdrop','slds-backdrop--');
                    helper.toggleClassInverse(component,'Filters','slds-fade-in-'); 
                }
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    saveUpdateDatesCall : function(component,helper){
        //alert('Call Save ');
        var action = component.get("c.saveUpdateDates");
        
        action.setParams({ 
            oppId : component.get("v.recordId"),
            wrapperData : JSON.stringify(component.get("v.updateDatesWrapper")),
            shippedDate : component.get("v.shippedDate"),
            shippedDateReason : component.get("v.shippedDateReason"),
            requestDate : component.get("v.requestDate"),
            requestDateReason : component.get("v.requestDateReason"),
            shippedDateCmnt : component.get("v.shippedDateCmnt"),
            requestDateCmnt : component.get("v.requestDateCmnt")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            //alert('Update Status'+state);
            var wrapperResult = a.getReturnValue();
            if(wrapperResult.hasError){
                wrapperResult.isContinue =  false;
                wrapperResult.isFinishedMethod =  false;
                //alert('hasError : '+wrapperResult.hasError + ' : DisplayPageBlock : '+ wrapperResult.DisplayPageBlock);
                if(wrapperResult.DisplayPageBlock){
                    
                    component.set("v.message","You have indicated the date for one or more lines should stay the same. Please click \"Confirm\" to approve current dates otherwise click \"Cancel\"." );
                    this.toggleClass(component,'backdrop','slds-backdrop--');
                    this.toggleClass(component,'errorModel','slds-fade-in-');
                    var existingWrapper = component.get("v.updateDatesWrapper");
                    existingWrapper.conformOrders = wrapperResult.conformOrders;
                    existingWrapper.getOrdersToUpdate = wrapperResult.getOrdersToUpdate;
                    existingWrapper.editableOELsTemp = wrapperResult.editableOELsTemp;
                    //existingWrapper.isContinue =  false;
                    //existingWrapper.isFinishedMethod =  false;
                    component.set("v.updateDatesWrapper", existingWrapper);
                } else{
                    component.set("v.isError",true);
                    component.set("v.message",wrapperResult.errorMsg);
                }               
                component.set("v.showSpinner",false);
                //isError = true;
            }else{
                component.set("v.showSpinner",false);
                //alert('navigateToOpp : '+ wrapperResult.navigateToOpp + ' : Refresh : '+ wrapperResult.refreshPage);
                if(wrapperResult.navigateToOpp){
                    this.redirectToRecord(component, event, helper);
                }
                else if(wrapperResult.refreshPage){
                    component.set("v.updateDatesWrapper", wrapperResult);
                    component.set("v.shippedDate",null);
                    component.set("v.shippedDateReason","--None--");
                    component.set("v.requestDate",null);
                    component.set("v.requestDateReason","--None--");
                    component.set("v.shippedDateCmnt",'');
                    component.set("v.requestDateCmnt",'');
                    
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    fetchScheduleShipDateChangeReasons : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Order_Entry_Line__c',
            'field_apiname': 'Schedule_Ship_Date_Change_Reason__c',
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.ScheduleShipDateChangeReasons", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    fetchRequestDateChangeReasons : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Order_Entry_Line__c',
            'field_apiname': 'Request_Date_Change_Reason__c',
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(a) { 
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.RequestDateChangeReasons", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    toggleClass: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal,className+'hide');
        $A.util.addClass(modal,className+'open');
    },
    
    toggleClassInverse: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal,className+'hide');
        $A.util.removeClass(modal,className+'open');
    },
    updateandContinueHelper: function (component, event, helper){
        
        var action = component.get("c.SelectSaveRecordsInlineEdit");
        
        console.log('Opty Id==>'+component.get("v.recordId"));
        console.log("v.listForSave==>");
        console.log(component.get("v.listForSave"));
        console.log("v.listOEL==>");
        
        console.log(component.get("v.listOEL"));
        var listInfoToSave = component.get("v.listForSave");
        if(component.get("v.isAll"))
            listInfoToSave = component.get("v.listOEL");
        action.setParams({
            listForSave : listInfoToSave, oppId : component.get("v.recordId"), requestDateUpdateCheck : component.get("v.requestDateUpdateCheck"),scheduledDateUpdateCheck : component.get("v.scheduledDateUpdateCheck"),oel1:component.get("v.oel1"),isContinue:true,allBool:component.get("v.isAll"),selectedName:component.get("v.selectedName"), selectedSKU:component.get("v.selectedSKU"), updatedlistWrapper:component.get("v.updatedlistWrapper"), mapWrapperOld:component.get("v.mapWrapperOld"),enableShipDate:component.get("v.enableShipDate"),enableRequestDate:component.get("v.enableRequestDate"),UpdatedIds : component.get("v.UpdatedIds")
            
        }); 
        
        action.setCallback(this, function(result) {
            console.log(result.getState());
            var records = result.getReturnValue();
            console.log('records==>');
            console.log(records);
            if(result.getState()=='SUCCESS'){
                component.set("v.isError",records.isError);
                
                component.set("v.isSuccess",records.isSuccess);
                component.set("v.isWarning",records.isWarning);
                
                
                
                
                component.set("v.message",records.message);
                component.set("v.DisplayPageBlock",records.DisplayPageBlock);
                component.set("v.isChanged",records.isChanged);
                component.set("v.oelLines",records.oelLines);
                component.set("v.UpdatedIds",records.UpdatedIds);
                if(records.releaseNames!=null&&records.releaseNames!=undefined)
                    component.set("v.releaseNames",records.releaseNames);
                if(records.isError==false){
                    if(records.isRedirect){
                        this.redirectToRecord(component, event, helper);
                    }
                    else{
                        component.get("v.mapUpdatedOEL",records.mapUpdatedOEL);
                        component.get("v.mapWrapperOld",records.mapWrapperOld);
                        var updateWraper = component.get("v.updatedlistWrapper");
                        
                        updateWraper.push.apply(updateWraper,records.updatedlistWrapper);
                        component.set("v.updatedlistWrapper",updateWraper);
                        if(records.listWrapper==null||records.listWrapper==undefined){
                            if(component.get("v.isAll"))
                                component.set("v.listWrapper",[]);
                            else{
                                var lst = component.get("v.listWrapper");
                                var lstExcept =[];
                                var i = 0;
                                for(i=0;i<lst.length;i++){
                                    if(lst[i].isEdit==false){
                                        lstExcept.push(lst[i]);
                                    }
                                }
                                component.set("v.listWrapper",lstExcept);
                                
                            }
                        }
                        else{
                            component.set("v.listWrapper",records.listWrapper);
                            
                        }
                        if(records.isWarning){
                            helper.toggleClass(component,'backdrop','slds-backdrop--');
                            helper.toggleClass(component,'errorModel','slds-fade-in-');
                        }
                        else{
                            component.set("v.selectedCount",0);
                            component.set("v.listForSave",[]);
                        }
                    }
                }
                else{
                    component.set("v.message",records.message);    
                }
            }
            else{
                component.set("v.isError",true);
                component.set("v.message",result.getError().toString());    
                //result.getState()
            }
            component.set("v.showSpinner",false);
            
        });
        $A.enqueueAction(action);
        // component.set("v.listForSave",recordsForSave);            component.get("v.listOfIdsForSave",recordIdsForSave);
        
        
        //SelectSaveRecordsInlineEdit(String oppId,Boolean requestDateUpdateCheck, Boolean scheduledDateUpdateCheck,List<Order_Entry_Line__c> listForSave,Order_Entry_Line__c oel1,Boolean isContinue,Boolean allBool, String selectedName, String selectedReferenceId,String selectedSKU,List<WrapperClass> updatedlistWrapper)
    },
    showToast : function(component, event, helper) {
        //alert('Selected Records'+"v.selectedCount");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": 'sticky',
            "title": "Success!",
            "message": component.get("v.message")
        });
        toastEvent.fire();
    },
    FilteredDataHelper: function(component, event, helper,isApply) {         
        var action = component.get("c.initMethod");
        
        console.log('Opty Id==>'+component.get("v.recordId"));
        action.setParams({
            oppId : component.get("v.recordId"), selectedName : component.get("v.selectedName"), isContinue:false, selectedReferenceId: component.get("v.selectedReferenceId"),selectedSKU : component.get("v.selectedSKU"),scheduledDateUpdateCheck:component.get("v.scheduledDateUpdateCheck"),requestDateUpdateCheck:component.get("v.requestDateUpdateCheck"),selectedSKU:component.get("v.selectedSKU")
            
        });
        console.log('Opty Id records==>');
        if(component.get("v.selectedName")!=''&&component.get("v.message")=='Please first select an Order Entry Release name from the dropdown list'){
            component.set("v.message",'');
            component.set("v.isError",false);
        }
        action.setCallback(this, function(result) {
            console.log(result.getState());
            var records = result.getReturnValue();
            console.log('records==>');
            console.log(records);
            if(result.getState()=='SUCCESS'){
                if(records != null){     
                    //component.set("v.referenceIds", records.referenceIds);
                    //component.set("v.releaseNames", records.releaseNames);
                    // if(isApply)
                    {
                        component.set("v.isAll", false);
                        component.set("v.listWrapper", records.listWrapper);
                        component.set("v.listWrapperNonEditable", records.listWrapperNonEditable); 
                        helper.toggleClassInverse(component,'backdrop','slds-backdrop--');
                        
                        helper.toggleClassInverse(component,'Filters','slds-fade-in-');
                    }
                    component.set("v.productSKU", records.productSKU);  
                    component.set("v.referenceIds", records.referenceIds);
                    component.set("v.showSpinner",false);
                    
                    /*component.set("v.isError", false);                
                component.set("v.isSuccess", false);                
                   helper.toggleClassInverse(component,'backdrop','slds-backdrop--');
        
        helper.toggleClassInverse(component,'Filters','slds-fade-in-');
        helper.toggleClassInverse(component,'EditAction','slds-fade-in-');
        helper.toggleClassInverse(component,'FieldsPicking','slds-fade-in-');     
        component.set("v.isEditWindow",false);
        component.set("v.isFilterWindow",false);*/
            }
            }
            else{
                
                
                component.set("v.message",result.getERROR().toString());
                component.set("v.isError",true);
            }
        });
        $A.enqueueAction(action);
    },
    redirectToRecord: function(component, event, helper) {    
        window.open('/lightning/r/Opportunity/'+component.get("v.recordId")+'/view','_self');
    }
})