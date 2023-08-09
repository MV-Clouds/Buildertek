({    
     doInit : function(component, event, helper) {
         debugger;
         console.log('reached');
         component.set("v.Spinner",true);
         var workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTabId = response.tabId;
             component.set("v.currentTab",focusedTabId);
             //workspaceAPI.closeTab({tabId: focusedTabId});
         })
         helper.getDataTableRespone(component, helper);
    }, 
     
    update : function (component, event, helper) {
        // Get the new hash from the event
        var loc = event.getParam("token");
        console.log(loc)
       // window.clearInterval(component.get("v.setIntervalId"));
        // Do something else
    },
    
    reloadtable : function(component, event, helper) {
        /*debugger;
        component.set("v.Spinner",true);
        helper.getDataTableRespone(component, helper);*/
        $A.get('e.force:refreshView').fire();
    },

    handleApplicationEvent :function(component, event, helper) {
        var message = event.getParam("message");
 		console.log(message);
        // set the handler attributes based on event data
        if(message){
            component.set("v.recordId",message)
        }
        component.set("v.messageFromEvent", message);
        $A.get('e.force:refreshView').fire();
        
    },
    
    onTabFocused : function(component, event, helper) {
        console.log("Tab Focused");
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");        
        workspaceAPI.getTabInfo({
            tabId : focusedTabId
        }).then(function(response) {
            console.log(response);
        });
    },
    
    onSave : function( component, event, helper ) {   
          var updatedRecords
          if(JSON.parse(JSON.stringify(component.find( "tasksTable" )))[0]){
              if(Object.keys(JSON.parse(JSON.stringify(component.find( "tasksTable" )))[0]).length){
                  updatedRecords = component.find( "tasksTable" ).get( "v.draftValues" );  
              }else{
                  updatedRecords = JSON.parse(JSON.stringify(event.getParams())).draftValues;
              }
              
          }else{
              updatedRecords = JSON.parse(JSON.stringify(event.getParams())).draftValues;
          }
        //alert(updatedRecords);
        for(var i=0;i < updatedRecords.length;i++){
            if(updatedRecords[i].Name == undefined){
               // alert(updatedRecords[i].Name == undefined);
                component.set("v.isTaskName", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please fill in the Task Name.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }else{
                component.set("v.isTaskName", false);
            }
        }
        
       // var action = component.get( "c.updateprojeccttasks" );
       /*  action.setParams({  
              
            'updatedprojecttaskList' : updatedRecords 
              
        }); */
        if(component.get("v.isTaskName") == false){
         var action = component.get( "c.updateprojeccttasksDuplicate" ); 
        action.setParams({  
              
            'updatedprojecttaskList' : updatedRecords ,
            'scheduleId': component.get("v.recordId")
              
        });  
        action.setCallback( this, function( response ) {  
              
            var state = response.getState();   
            if ( state === "SUCCESS" ) {  
  
                if ( response.getReturnValue() === true ) {  
                       var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Records Updated Successfully.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                     $A.get('e.force:refreshView').fire();
                   helper.getDataTableRespone(component, helper);
                    component.find( "tasksTable" ).set( "v.draftValues", null );  
                      
                } else { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Something went wrong. Contact your system administrator.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                     
                }  
                  
            } else {  
                  
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Something went wrong. Contact your system administrator.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
            }  
              
        });  
        $A.enqueueAction( action );  
        }
          
    }  ,
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
       // alert('hi'+component.get("v.currentPageNumber"));
        helper.setPageDataAsPerPagination(component, helper); 
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.setPageDataAsPerPagination(component, helper);
    },
    
    selectedPagination : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.getSource().get('v.name'))); //event.target.name
        helper.setPageDataAsPerPagination(component, helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.setPageDataAsPerPagination(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPageDataAsPerPagination(component, helper);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var actionName = event.getParam('action').name;
        switch (action.name) {
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'add':
                console.log(JSON.parse(JSON.stringify(event.getParam('row'))))
                var row = JSON.parse(JSON.stringify(event.getParam('row')))
                var list =  component.get("v.dataByGroup");
                for(var i=0;i<list.length;i++){
                    if(list[i].groupName == 'No Phase'){
                        for(var j=0;j<list[i].groupData.length;j++){
                            if(list[i].groupData[j].Id == row.Id){
                                var obj = {
                                    "buildertek__Phase__c": "",
                                    "Name": "",
                                    "buildertek__Start__c": "",
                                    "buildertek__Finish__c": "",
                                    "buildertek__Duration__c": 0,
                                    "Id": "",
                                    "buildertek__Milestone__c": false,
                                    "CreatedDate": "",
                                    "buildertek__Schedule__c": component.get("v.recordId")
                                }
                                list[i].groupData.splice(j+1, 0, obj);
                                break;
                            }
                        }
                    }else if(list[i].groupName == row.buildertek__Phase__c){
                        for(var j=0;j<list[i].groupData.length;j++){
                            if(list[i].groupData[j].Id == row.Id){
                                var obj = {
                                    "buildertek__Phase__c": row.buildertek__Phase__c,
                                    "Name": "",
                                    "buildertek__Start__c": "",
                                    "buildertek__Finish__c": "",
                                    "buildertek__Duration__c": 0,
                                    "Id": "",
                                    "buildertek__Milestone__c": false,
                                    "CreatedDate": "",
                                    "buildertek__Schedule__c": component.get("v.recordId")
                                }
                                list[i].groupData.splice(j+1, 0, obj);
                                break;
                            }
                        }
                    }
                }
               component.set("v.dataByGroup",list);
                break;
            case 'delete':
                component.set("v.deleteConfirmModal",true);
                component.set("v.deleteAction",event.getParam('action'));
                component.set("v.deleteRow",event.getParam('row'));
                //helper.deleteRecord(component, event);
                break;
            case 'view':
                helper.viewRecord(component, event);
                break;
        }
    },
    
    CreateNewScheduleitemrec : function (component, event, helper) {
            var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "buildertek__Project_Task__c",
                              'defaultFieldValues': {
                                        'buildertek__Schedule__c' : component.get("v.recordId")
                                    }
                        });
        createRecordEvent.fire();
    },
    MassUpdateScheduleItem : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BT_ScheduleItemMassUpdate",
            componentAttributes: {
                recordId:component.get('v.recordId')
            }
        });
        evt.fire();
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        component.set("v.deleteConfirmModal",false);
        component.set("v.deleteAction","");
        component.set("v.deleteRow","");
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
        component.set("v.Spinner",true);
        helper.deleteRecord(component, event);
    },
    
    
    
    expandCollapseAll : function (component, event, helper) {
        
        var scheduleId =  component.get("v.recordId");
        var tabId = component.get("v.currentTab")
        var spanEle = event.currentTarget.dataset.iconname;
        console.log(spanEle)
        var expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
        var collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
        var labelName =spanEle
        if(labelName == 'Expand All'){
            expandallicon[0].style.display = 'none';
            collapeallIcon[0].style.display = 'inline-block';  
        }else if(labelName == 'Collapse All'){
            expandallicon[0].style.display = 'inline-block';
            collapeallIcon[0].style.display = 'none';  
        }
        
        var groups = component.get("v.dataByGroup");
        var budgetId = component.get("v.recordId")
        for(var j=0;j<groups.length;j++){
            var grpIndex = j;
            var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+grpIndex);
            var collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+grpIndex);
            var className = tabId+' '+scheduleId+" groupRows_"+grpIndex;
            var grpRows = document.getElementsByClassName(className) ;
            if(labelName == 'Expand All') {   
                component.set("v.isExpandGrp",true);
                
                expandicon[0].style.display = 'none';
                collapeIcon[0].style.display = 'inline-block';  
                for(var i=0;i<grpRows.length;i++){
                    var item = grpRows[i];
                    if(!expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                        expandicon[0].classList.add(tabId+'hideExpandIcon')
                    }
                    if(expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                        expandicon[0].classList.remove(tabId+'hideExpandIconhideCollapseIcon')
                    }
                    if(item.style.display=="none"){
                        item.style.display='block';
                    }
                }
                
            }else if( labelName == 'Collapse All')  {
                collapeIcon[0].style.display = 'none';
                expandicon[0].style.display = 'inline-block';
                component.set("v.isExpandGrp",false);
                for(var i=0;i<grpRows.length;i++){
                    var item = grpRows[i];
                    if(!expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                        expandicon[0].classList.add(tabId+'hideExpandIconhideCollapseIcon')
                    }
                    if(expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                        expandicon[0].classList.remove(tabId+'hideExpandIcon')
                    }
                    if(item.style.display=="block"){
                        item.style.display='none';
                    }
                }
                console.log(document.getElementsByClassName(className)[0]);
            }
        }
        
    },
    
    
    
    expandCollapseGroups : function (component, event, helper) { 
        var scheduleId = component.get("v.recordId")
        var tabId = component.get("v.currentTab")
        var grpIndex = event.currentTarget.dataset.grpindex;
        var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+grpIndex);
        var collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+grpIndex);
        var className = tabId+' '+scheduleId+" groupRows_"+grpIndex;
        var grpRows = document.getElementsByClassName(className) ;
        var allGroups = component.get("v.dataByGroup");
        //console.log(expandicon[0].style.display)
        //console.log(collapeIcon[0].style.display)
        // if(!expandicon[0].classList.contains('hideExpandIcon') && collapeIcon[0].classList.contains('hideCollapseIcon') )  {   
        if(expandicon[0].style.display=="inline-block" && collapeIcon[0].style.display=="none")  {     
            component.set("v.isExpandGrp",true);
            expandicon[0].style.display = 'none';
            collapeIcon[0].style.display = 'inline-block';  
            
            if(!expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                expandicon[0].classList.add(tabId+'hideExpandIcon')
            }
            if(expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                expandicon[0].classList.remove(tabId+'hideExpandIconhideCollapseIcon')
            }
            //$A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
            for(var i=0;i<grpRows.length;i++){
                var item = grpRows[i];
                if(item.style.display=="none"){
                    item.style.display='block';
                    // $A.util.toggleClass(expandicon[0], 'hideExpandIcon');
                }
            }
            var hideCollapseIconEles =document.getElementsByClassName(scheduleId+' '+tabId+'hideExpandIcon')//document.getElementsByClassName('hideCollapseIcon');
            if(hideCollapseIconEles.length == allGroups.length){
                var expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                var collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
                collapeallIcon[0].style.display="inline-block";
                expandallicon[0].style.display="none";
           }
            
            
        }//else if(expandicon[0].classList.contains('hideExpandIcon') && !collapeIcon[0].classList.contains('hideCollapseIcon')){
        else if(expandicon[0].style.display=="none" && collapeIcon[0].style.display=="inline-block"){
            collapeIcon[0].style.display = 'none';
            expandicon[0].style.display = 'inline-block';
            
            if(!expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                expandicon[0].classList.add(tabId+'hideExpandIconhideCollapseIcon')
            }
            if(expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                expandicon[0].classList.remove(tabId+'hideExpandIcon')
            }
            component.set("v.isExpandGrp",false);
            for(var i=0;i<grpRows.length;i++){
                var item = grpRows[i];
                if(item.style.display=="block"){
                    item.style.display='none';
                    // $A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
                }
            }
            var hideExpandIconEles =document.getElementsByClassName(scheduleId+' '+tabId+'hideExpandIconhideCollapseIcon')
            if(hideExpandIconEles.length == allGroups.length){
                var expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                var collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
                expandallicon[0].style.display="inline-block";
                collapeallIcon[0].style.display="none";
            }
        }
        
    },  
                
})