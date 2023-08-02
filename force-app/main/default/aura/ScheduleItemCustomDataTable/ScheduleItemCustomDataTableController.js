({
    doInit : function(component, event, helper) {
        // component.set("v.Inputvalues", true);
        component.set("v.Show", false);
        component.set("v.isExpand",false);
        component.set("v.expandedList",[]);
        component.set("v.ShowTaskOrderSave",false)
        component.set("v.Spinner",true);
        component.set("v.isDuration",false)
        component.set("v.oninitExpandIcon",true)
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            component.set("v.currentTab",focusedTabId);
            
        })
        // helper.getDataTableRespone(component, helper);
        
        helper.getTableFieldSet(component, event, helper)
        if(component.find('expandCollapeseAllBtn')){
            if(component.find('expandCollapeseAllBtn').get('v.iconName')){
                var scheduleId =  component.get("v.recordId");
                var tabId = component.get("v.currentTab")
                if(tabId){
                    var spanEle = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                    if(spanEle[0]){
                        spanEle[0].style.display="inline-block";
                    }
                    if(document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0]){
                        document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0].style.display="none";
                    } 
                }
                component.find('expandCollapeseAllBtn').set("v.title", "Expand All");
                component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
            }
        }
        
    },
    
    inlineEditName : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.nameEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    closeNameBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'nameEditMode' att. as false   
        component.set("v.nameEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
        if(event.getSource().get("v.value").trim() == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    }, 
    onNameChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },
    calculateWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        console.log('final tag Name'+parObj.tagName);
        
        var mouseStart=event.clientX; 
        component.set("v.mouseStart",mouseStart);
        component.set("v.oldWidth",parObj.offsetWidth);
        event.stopPropagation()
    },
    
    setNewWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart = component.get("v.mouseStart");
        var oldWidth = component.get("v.oldWidth");
        //To calculate the new width of the column
        var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
        parObj.style.width = newWidth+'px';//assign new width to column
        event.stopPropagation();
    },
    
    resetColumn: function(component, event, helper) {
        // Get the component which was used for the mouse move
        if( component.get("v.currentEle") !== null ) {
            var newWidth = component.get("v.newWidth"); 
            var currentEle = component.get("v.currentEle").parentNode.parentNode; // Get the DIV
            var parObj = currentEle.parentNode; // Get the TH Element
            parObj.style.width = newWidth+'px';
            currentEle.style.width = newWidth+'px';
            console.log(newWidth);
            component.get("v.currentEle").style.right = 0; // Reset the column devided 
            component.set("v.currentEle", null); // Reset null so mouse move doesn't react again
        }
    },
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.setPageDataAsPerPagination(component, helper);
        component.set("v.isExpand",false);
        component.set("v.oninitExpandIcon",false)
        component.set("v.expandedList",[]);
        component.set("v.Show",false)
        component.set("v.ShowTaskOrderSave",false)
        if(component.find('expandCollapeseAllBtn')){
            if(component.find('expandCollapeseAllBtn').get('v.iconName')){
                var scheduleId =  component.get("v.recordId");
                var tabId = component.get("v.currentTab")
                if(tabId){
                    var spanEle = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                    if(spanEle[0]){
                        spanEle[0].style.display="inline-block";
                    }
                    if(document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0]){
                        document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0].style.display="none";
                    } 
                }
                component.find('expandCollapeseAllBtn').set("v.title", "Expand All");
                component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
            }
        }
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.setPageDataAsPerPagination(component, helper);
        component.set("v.isExpand",false);
        component.set("v.expandedList",[]);
        component.set("v.oninitExpandIcon",false)
        component.set("v.Show",false)
        component.set("v.ShowTaskOrderSave",false)
        if(component.find('expandCollapeseAllBtn')){
            if(component.find('expandCollapeseAllBtn').get('v.iconName')){
                var scheduleId =  component.get("v.recordId");
                var tabId = component.get("v.currentTab")
                if(tabId){
                    var spanEle = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                    if(spanEle[0]){
                        spanEle[0].style.display="inline-block";
                    }
                    if(document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0]){
                        document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0].style.display="none";
                    } 
                }
                component.find('expandCollapeseAllBtn').set("v.title", "Expand All");
                component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
            }
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
    handlelwcRefresh :  function(component, event, helper) {
        //component.set("v.Spinner",true);
        // $A.get('e.force:refreshView').fire();
        if(event.getParam('refreshmessageevent') == 'Refresh Component from gantt'){
            window.setTimeout(function(){ 
                component.set("v.Spinner",true);
                $A.get('e.force:refreshView').fire();
                //helper.getDataTableRespone(component, helper);
            }, 2000);
            
        }
        
    },
    
    reloadtable : function(component, event, helper) {
        /*debugger;
        component.set("v.Spinner",true);
        helper.getDataTableRespone(component, helper);*/
        
        component.set("v.Spinner",true);
        $A.get('e.force:refreshView').fire();
    },
    
    refreshComp : function(component, event, helper) {
        /*debugger;
        component.set("v.Spinner",true);
        helper.getDataTableRespone(component, helper);*/
        component.removeEventHandler('force:recordChange',component.getReference("c.refreshComp"))
        var appEvent = $A.get("e.c:refresh_componenent_event");
        appEvent.setParams({
            "refreshmessage" : "Refresh Component from table"
        });
        appEvent.fire();
        component.set("v.Spinner",true);
        // $A.get('e.force:refreshView').fire();
        var action = component.get("c.doInit")
        $A.enqueueAction(action)
        
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        component.set("v.deleteConfirmModal",false);
        component.set("v.deleteAction","");
        component.set("v.deleteRow","");
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
        component.set("v.Spinner",true);
        var deleObj = component.get("v.deleteRowClassData");
        var clsName = deleObj['delClassName'];
        var delIdx = deleObj['delerowIdx'];
        /*if(clsName && delIdx){
            if(document.getElementsByClassName(''+clsName)[0]){
                if(document.getElementsByClassName(''+clsName)[0].children.length){
                    if(document.getElementsByClassName(''+clsName)[0].children[0]){
                        if(document.getElementsByClassName(''+clsName)[0].children[0].rows.length){
                            document.getElementsByClassName(''+clsName)[0].children[0].rows[Number(delIdx)+1] ?  document.getElementsByClassName(''+clsName)[0].children[0].rows[Number(delIdx)+1].remove() : false;  
                        }
                    }
                }
            }
            
        }*/
        helper.deleteRecord(component, event,helper);
       /* window.setTimeout(function(){
            component.set("v.Spinner",false);
        },2000)*/
    },
    
    
    expandCollapseAll : function (component, event, helper) {
        var scheduleId =  component.get("v.recordId");
        var tabId = component.get("v.currentTab")
        var spanEle = event.currentTarget.dataset.iconname;
        console.log(spanEle)
        var expandallicon
        var collapeallIcon
        var scheduleItems = component.get("v.scheduleitemlst")
        
        if(tabId){
            expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
            collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
        }else{
            expandallicon = document.getElementsByClassName('expandAllBtn_'+scheduleId);
            collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_'+scheduleId);
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
        component.set("v.isExpand",false);
        component.set("v.expandedList",[]);
        var groups = component.get("v.scheduleitemlst");
        var budgetId = component.get("v.recordId")
        var expandList
        for(var j=0;j<groups.length;j++){
            
            
            var grpIndex = j;
            var expandicon
            var collapeIcon
            var className
            
            if(tabId){
                expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+grpIndex);
                collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+grpIndex);
                className = tabId+' '+scheduleId+" mapKey_"+grpIndex;
            }else{
                expandicon = document.getElementsByClassName(scheduleId+' expandGrpIcon_'+grpIndex);
                collapeIcon = document.getElementsByClassName(scheduleId+' collapseGrpIcon_'+grpIndex);
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
            
            /*if(labelName == 'Expand All') {   
                var expvalue = component.get("v.isExpand");
                //  alert('component.set("v.isExpandGrp",true);'+expvalue);
                scheduleItems[grpIndex].expanded = true;
                
                expandicon[0].style.display = 'none';
                // if(labelName == 'Expand All'){
                expandList =  component.get("v.expandedList")
                if(expandList){
                    if(expandList.indexOf(Number(j)) == -1){
                        expandList.push(Number(j))
                        component.set("v.expandedList",expandList)
                    }
                }else{
                    expandList = [];
                    expandList.push(Number(j))
                    component.set("v.expandedList",expandList)
                }
                // }
                //collapeIcon[0].style.display = 'inline-block';  
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
                if(expandList){
                    if(expandList.indexOf(Number(grpIndex)) > -1){
                        expandList.splice(expandList.indexOf(Number(grpIndex)),1)
                        component.set("v.expandedList",expandList)
                    }
                }
                var expvalue = component.get("v.isExpand");
                
                //collapeIcon[0].style.display = 'none';
                expandicon[0].style.display = 'inline-block';
                scheduleItems[grpIndex].expanded = false;
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
            }*/
        }
        component.set("v.scheduleitemlst",scheduleItems)
    },
    
    expandCollapseGroups : function (component, event, helper) { 
        var scheduleId = component.get("v.recordId")
        var tabId = component.get("v.currentTab")
        var grpIndex = event.currentTarget.dataset.grpindex;
        var expandicon
        var collapeIcon
        var className 
        var scheduleItems = component.get("v.scheduleitemlst")
        var expandedCount = component.get("v.expandedCount");
        var expandallicon;
        var collapeallIcon;
        
        if(tabId){
            var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+grpIndex);
            var collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+grpIndex);
            var className = tabId+' '+scheduleId+" mapKey_"+grpIndex;
        }else{
            expandicon = document.getElementsByClassName(scheduleId+' expandGrpIcon_'+grpIndex);
            collapeIcon = document.getElementsByClassName(scheduleId+' collapseGrpIcon_'+grpIndex);
            className = scheduleId+" mapKey_"+grpIndex;
        }
        
        var grpRows = document.getElementsByClassName(className) ;
        var allGroups = component.get("v.scheduleitemlst");
        
        var expandList = component.get("v.expandedList");
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
                expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
            }else{
                expandallicon = document.getElementsByClassName('expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_'+scheduleId);
            }
            
            collapeallIcon[0].style.display="inline-block";
            expandallicon[0].style.display="none";
            component.set("v.expandedCount",0)
            
        }else if(expandedCount == scheduleItems.length*(-1) || expandedCount == 0){
            if(tabId){
                expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
            }else{
                expandallicon = document.getElementsByClassName('expandAllBtn_'+scheduleId);
                collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_'+scheduleId);
            }
            
            expandallicon[0].style.display="inline-block";
            collapeallIcon[0].style.display="none";
            component.set("v.expandedCount",0)
        }
        /* if(expandicon[0]){
            if(expandicon[0].style.display=="inline-block")  {   
                expandicon[0].style.display = 'none';
                scheduleItems[grpIndex].expanded = true;
                
                if(collapeIcon.length){
                    collapeIcon[0].style.display = 'inline-block';  
                }
                
                if(expandList){
                    if(expandList.indexOf(Number(grpIndex)) == -1){
                        expandList.push(Number(grpIndex))
                        component.set("v.expandedList",expandList)
                    }
                }else{
                    expandList = [];
                    expandList.push(Number(grpIndex))
                    component.set("v.expandedList",expandList)
                }
                
                // component.set("v.isExpand",true);
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
                    component.set("v.isExpand",true);
                    //component.set("v.expandedList",[]);
                    
                    var expandallicon;
                    var collapeallIcon
                    
                    if(tabId){
                        expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                        collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
                    }else{
                        expandallicon = document.getElementsByClassName('expandAllBtn_'+scheduleId);
                        collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_'+scheduleId);
                    }
                    
                    collapeallIcon[0].style.display="inline-block";
                    expandallicon[0].style.display="none";
                }
                
                
            }
            else if(expandicon[0].style.display=="none"){
                scheduleItems[grpIndex].expanded = false;
                if(collapeIcon.length){
                    for(var i=0;i<collapeIcon.length;i++){
                        collapeIcon[i].style.display = 'none';
                    }
                    
                } 
                expandicon[0].style.display = 'inline-block';
                if(expandList){
                    if(expandList.indexOf(Number(grpIndex)) > -1){
                        expandList.splice(expandList.indexOf(Number(grpIndex)),1)
                        component.set("v.expandedList",expandList)
                    }
                }
                // component.set("v.isExpand",false);
                if(!expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                    expandicon[0].classList.add(tabId+'hideExpandIconhideCollapseIcon')
                }
                if(expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                    expandicon[0].classList.remove(tabId+'hideExpandIcon')
                }
                // component.set("v.isExpandGrp",false);
                for(var i=0;i<grpRows.length;i++){
                    var item = grpRows[i];
                    if(item.style.display=="block"){
                        item.style.display='none';
                        // $A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
                    }
                }
                var hideExpandIconEles =document.getElementsByClassName(scheduleId+' '+tabId+'hideExpandIconhideCollapseIcon')
                if(hideExpandIconEles.length == allGroups.length){
                    component.set("v.isExpand",false);
                    component.set("v.expandedList",[]);
                    
                    var expandallicon;
                    var collapeallIcon
                    
                    if(tabId){
                        expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                        collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
                    }else{
                        expandallicon = document.getElementsByClassName('expandAllBtn_'+scheduleId);
                        collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_'+scheduleId);
                    }
                    
                    expandallicon[0].style.display="inline-block";
                    collapeallIcon[0].style.display="none";
                }
            }
        }*/
        
        component.set("v.scheduleitemlst",scheduleItems)
    },  
    
    
    
    editRecord: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.rowid;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId,
        });
        
        editRecordEvent.fire();
        component.addEventHandler("force:recordChange", component.getReference("c.refreshComp"));
        
    },
    
    handleClick: function (component, event, helper) {
        helper.viewRecord(component, event);
    },
    deleteRecords: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.rowid;
        if(recordId != "" && recordId != undefined){
            //component.set("v.Show", false);
            var delObj = {}
            delObj['delClassName'] = event.currentTarget.dataset.classname;
            delObj['delerowIdx'] = event.currentTarget.dataset.itemindex;
            component.set("v.deleteRowClassData",delObj);
            component.set('v.isdeleteRow', recordId); 
            component.set("v.deleteConfirmModal", true);
            
            
        }else{
            var count = component.get("v.addRecordCount")-1;
            component.set("v.addRecordCount",count);
            if(count == 0){
                component.set("v.Show",false)
            }
            //component.set("v.Show", false);
            var list =  component.get("v.scheduleitemlst");
            var rowPhase = Number(event.currentTarget.dataset.phaseindex);
            var rowitem = Number(event.currentTarget.dataset.itemindex);
            list[rowPhase].value.splice(rowitem,1)
            component.set("v.scheduleitemlst",list);
            
        }
        
    },
    addRecords : function (component, event, helper) {
        // component.set("v.EditInputvalues", true
        
        // component.set("v.Inputvalues", false);
        component.set("v.Show", true);
        var rowId = event.currentTarget.dataset.rowid;
        var rowPhase = Number(event.currentTarget.dataset.phaseindex);
        var rowitem = Number(event.currentTarget.dataset.itemindex);
        var list =  component.get("v.scheduleitemlst")
        /* var obj = {
            "sobjectType" : "buildertek__Project_Task__c",
            "buildertek__Phase__c": list[rowPhase].key,
            "Name": "",
            "buildertek__Dependency__r.Name": "",
            "buildertek__Start__c": "",
            "buildertek__Finish__c": "",
            //"buildertek__Duration__c": 1,
            "buildertek__Resource__r.Name":"",
            "buildertek__Contractor__r.Name":"",
            "buildertek__Contractor_Resource__r.Name":"",
            "buildertek__Completion__c":0,
            
            "Id": "",
            
            "buildertek__Schedule__c": component.get("v.recordId")
        }
        */
        var obj = {
            'SObjs':{"sobjectType" : "buildertek__Project_Task__c",
                     "buildertek__Phase__c": list[rowPhase].key} ,
            'wbs':''
        }
        list[rowPhase].value.splice(rowitem+1,0,obj)
        var count = component.get("v.addRecordCount")
        component.set("v.addRecordCount",count+1)
        component.set("v.scheduleitemlst",list);
        
        /* var scheduleId = component.get("v.recordId")
        var tabId = component.get("v.currentTab")
        var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+rowPhase);
        
        var collapeIcon;
        if(tabId){
            collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+rowPhase);
        }else{
            collapeIcon = document.getElementsByClassName(scheduleId+' collapseGrpIcon_'+rowPhase);
        }
        var expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
        var collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
        
        if(collapeIcon.length){
            
            var expandList = component.get("v.expandedList");
            
            component.set("v.currentExpandIndex",rowPhase);
            component.set("v.expandedList",expandList)
            
            
        }*/
    },
    closeModel : function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
        
        component.set("v.oninitExpandIcon",false)
        component.set("v.dupScheduleItems",component.get("v.scheduleitemlst"))
        helper.getDataTableRespone(component, helper);
        component.set("v.Spinner",false);
        
        /* var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            
        }).catch(function(error) {
            console.log(error);
        });*/
    },
    
    
    onSave : function(component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.isTaskName",false)
        // var row = event.currentTarget.dataset.rowid;
        var updatedRecords = component.get("v.scheduleitemlst");
        
        //alert('scheduleitemlst'+updatedRecords.length);
        var insertUpdaterecords = [];
        for(var i=0;i<updatedRecords.length;i++){
            for(var j=0;j<updatedRecords[i].value.length;j++){
                // if(updatedRecords[i].value[j].Id == row){
                // for(var i=0;i < updatedRecords.length;i++){
                var rowItem = JSON.parse(JSON.stringify(updatedRecords[i].value[j]))
                if(!updatedRecords[i].value[j].SObjs.Name || (!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c) || (!updatedRecords[i].value[j].SObjs.buildertek__Finish__c && !rowItem.SObjs.buildertek__Dependency__c)){
                    // alert('scheduleitemlst'+updatedRecords[i].value[j].Name);
                    var message
                    if(!updatedRecords[i].value[j].SObjs.buildertek__Finish__c && !rowItem.SObjs.buildertek__Dependency__c){
                        message = 'Please fill in the End Date'
                    }
                    if(!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c){
                        message = 'Please fill in the Start Date'
                    }
                    if(!updatedRecords[i].value[j].SObjs.Name){
                        message = 'Please fill in the Name'
                    }
                    component.set("v.isTaskName", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.Spinner", false);
                    break;
                }else if( !component.get("v.isTaskName")){
                    component.set("v.isTaskName", false);
                    /* var obj ={
                        'Id' : updatedRecords[i].value[j].Id,
                        'Name': updatedRecords[i].value[j].Name,
                        "buildertek__Phase__c":  updatedRecords[i].value[j].buildertek__Phase__c,
                        "buildertek__Dependency__c": updatedRecords[i].value[j].buildertek__Dependency__c,
                        "buildertek__Start__c": updatedRecords[i].value[j].buildertek__Start__c,
                        "buildertek__Finish__c":  updatedRecords[i].value[j].buildertek__Finish__c,
                        "buildertek__Duration__c": updatedRecords[i].value[j].buildertek__Duration__c ?  updatedRecords[i].value[j].buildertek__Duration__c :updatedRecords[i].value[j].buildertek__Duration__c
                        "buildertek__Resource__c":updatedRecords[i].value[j].buildertek__Resource__c,
                        "buildertek__Contractor__c":updatedRecords[i].value[j].buildertek__Contractor__c,
                        "buildertek__Contractor_Resource__c": updatedRecords[i].value[j].buildertek__Contractor_Resource__c,
                        "buildertek__Completion__c": updatedRecords[i].value[j].buildertek__Completion__c,
                        "buildertek__Schedule__c": component.get("v.recordId")
                    }*/
                    
                    //insertUpdaterecords.push(updatedRecords[i].value[j]);
                    insertUpdaterecords.push(updatedRecords[i].value[j]);
                    
                }
            }
            
        }
        if(component.get("v.isTaskName") == false){
            var action = component.get("c.updateprojeccttasksDuplicate");
            action.setParams({
                'updatedprojecttaskListJSON' : JSON.stringify(insertUpdaterecords)  ,
                'scheduleId': component.get("v.recordId"),
                'currentPage': parseInt(component.get("v.currentPageNumber"))
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    
                    var result = response.getReturnValue();
                    // alert(response.getReturnValue());
                    if(result == 'true'){
                        //    alert('2');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Records Updated Successfully.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        //$A.get('e.force:refreshView').fire();
                        helper.getDataTableRespone(component, helper);
                        component.set("v.Spinner", false);
                    }
                    else{
                        // if(!result){
                        //   alert("1");
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: response.getReturnValue(),
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'Error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.Spinner", false);
                        
                    }
                } else{
                    // if(!result){
                    //   alert("1");
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: JSON.stringify(response.getError()[0]),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire();
                    component.set("v.Spinner", false);
                    
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
    handleChildBudgetLineEvent : function (component, event, helper) {
        var fieldName = event.getParam("message").fieldName;
        var selectedRecordId = event.getParam("message").selectedRecordId;
        var index = event.getParam("message").index;
        var phaseindex = event.getParam("message").phaseIndex;
        var list = component.get('v.scheduleitemlst');
        
        var record = list[phaseindex].value[index]['SObjs'];
        
        record[fieldName] = JSON.stringify(selectedRecordId) ? selectedRecordId.Id : null //? selectedRecordId[0].Id : null;
        
        list[phaseindex].value[index].SObjs = record;
        component.set('v.scheduleitemlst', list);
        
    },
    
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    drag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },
    
    drop: function (component, event, helper) {
        var data = event.dataTransfer.getData("text");
        // Find the record ID by crawling up the DOM hierarchy
        var tar = event.target.closest('[id]');
        var phaseindex = event.currentTarget.dataset.phaseindex
        
        var scheduleitemlst = component.get("v.scheduleitemlst");
        var index1, index2, temp;
        // Find the index of each item to move
        scheduleitemlst[phaseindex].value.forEach((v,i)=>{if(i===Number(data)) index1 = i; if(i===Number(tar.id)) index2 = i;});
        if(index1<index2) {
            // Lower index to higher index; we move the lower index first, then remove it.
            scheduleitemlst[phaseindex].value.splice(index2+1, 0,  scheduleitemlst[phaseindex].value[index1]);
            scheduleitemlst[phaseindex].value.splice(index1, 1);
        } else {
            // Higher index to lower index; we remove the higher index, then add it to the lower index.
            temp = scheduleitemlst[phaseindex].value.splice(index1, 1)[0];
            scheduleitemlst[phaseindex].value.splice(index2, 0, temp);
        }
        
        // Trigger aura:valueChange, component will rerender
        component.set("v.scheduleitemlst", scheduleitemlst);
        var rowPhase = event.currentTarget.dataset.phaseindex
        var scheduleId = component.get("v.recordId")
        var tabId = component.get("v.currentTab")
        var expandicon = document.getElementsByClassName(tabId+' '+scheduleId+' expandGrpIcon_'+rowPhase);
        var collapeIcon = document.getElementsByClassName(tabId+' '+scheduleId+' collapseGrpIcon_'+rowPhase);
        var expandallicon = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
        var collapeallIcon = document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId);
        
        if(collapeIcon.length){
            
            // collapeIcon[0].style.display = 'inline-block';  
            
            /* if(expandallicon[0].style.display == 'none'){
                component.set("v.isExpand",true)
            }else{
                var expandList = component.get("v.expandedList");
                
                component.set("v.currentExpandIndex",rowPhase);
                component.set("v.expandedList",expandList)
            }*/
            var expandList = component.get("v.expandedList");
            
            component.set("v.currentExpandIndex",rowPhase);
            component.set("v.expandedList",expandList)
            
            
        }
        component.set("v.ShowTaskOrderSave",true)
        event.preventDefault();
    },
    
    saveTaskOrder : function (component, event, helper) {
        var updatedRecords = component.get("v.scheduleitemlst");
        var insertUpdaterecords = [];
        
        for(var i=0;i<updatedRecords.length;i++){
            if(updatedRecords[i].value){
                for(var j=0;j<updatedRecords[i].value.length;j++){
                    insertUpdaterecords.push(updatedRecords[i].value[j].SObjs);
                }
            }
            
        }
        component.set("v.Spinner",true);
        var action = component.get("c.updateTaskOrder")
        action.setParams({
            scheduleItemListJSON : JSON.stringify(insertUpdaterecords),
            currentPage : parseInt(component.get("v.currentPageNumber"))
        })
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            if(response.getState() == "SUCCESS"){
                console.log(response.getState())
                console.log(response.getReturnValue());
                if(response.getReturnValue() == 'true'){
                    // $A.get('e.force:refreshView').fire() 
                    component.set("v.oninitExpandIcon",false)
                    component.set("v.dupScheduleItems",component.get("v.scheduleitemlst"))
                    helper.getDataTableRespone(component, helper);
                    var appEvent = $A.get("e.c:refresh_componenent_event");
                    appEvent.setParams({
                        "refreshmessage" : "Refresh Component from table"
                    });
                    appEvent.fire();
                    component.set("v.Spinner",false);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: response.getReturnValue(),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                    component.set("v.Spinner",false);
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: JSON.stringify(response.getError()),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner",false);
            }
        })
        $A.enqueueAction(action);
    },
    onSaveandupdate :  function (component, event, helper){
        var updatedRecords = component.get("v.scheduleitemlst");
        component.set("v.isTaskName",false)
        var insertUpdaterecords = [];
        for(var i=0;i<updatedRecords.length;i++){
            if(updatedRecords[i].value){
                for(var j=0;j<updatedRecords[i].value.length;j++){
                    var rowItem = JSON.parse(JSON.stringify(updatedRecords[i].value[j]))
                    var condition;
                    if(component.get("v.isFinish")){
                        condition = updatedRecords[i].value[j].SObjs.buildertek__Finish__c
                    }
                    if(component.get("v.isDuration")){
                        condition = updatedRecords[i].value[j].SObjs.buildertek__Duration__c
                    }
                    if(!updatedRecords[i].value[j].SObjs.Name || (!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c) || !String(condition) ){
                        // alert('scheduleitemlst'+updatedRecords[i].value[j].Name);
                        var message;
                        if(component.get("v.isFinish")){
                            if(!updatedRecords[i].value[j].SObjs.buildertek__Finish__c && !rowItem.SObjs.buildertek__Dependency__c){
                                message = 'Please fill in the End Date'
                            } 
                        }
                        if(component.get("v.isDuration")){
                            if(!updatedRecords[i].value[j].SObjs.buildertek__Duration__c){
                                message = 'Please fill in the Duration'
                            }
                        }
                        
                        if(!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c){
                            message = 'Please fill in the Start Date'
                        }
                        if(!updatedRecords[i].value[j].SObjs.Name){
                            message = 'Please fill in the Name'
                        }
                        component.set("v.isTaskName", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: message,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        component.set("v.Spinner", false);
                        toastEvent.fire();
                        break;
                    }else if( !component.get("v.isTaskName")){
                        component.set("v.isTaskName", false);
                        insertUpdaterecords.push(updatedRecords[i].value[j].SObjs);
                    }
                }
            }
        }
        
        var action = component.get("c.UPandINTaskOrder");
        action.setParams({
            scheduleItemsListJSON : JSON.stringify(insertUpdaterecords),
            scheduleId : component.get("v.recordId"),
            currentPage : parseInt(component.get("v.currentPageNumber"))
        })
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            component.set("v.Spinner",false);
            if(response.getState() == "SUCCESS"){
                console.log(response.getState())
                console.log(response.getReturnValue());
                if(response.getReturnValue() == 'true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Records Updated Successfully.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire() 
                    component.set("v.oninitExpandIcon",false)
                    component.set("v.dupScheduleItems",component.get("v.scheduleitemlst"))
                    helper.getDataTableRespone(component, helper);
                    //component.set("v.Spinner",false);
                    var appEvent = $A.get("e.c:refresh_componenent_event");
                    appEvent.setParams({
                        "refreshmessage" : "Refresh Component from table"
                    });
                    appEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: response.getReturnValue(),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.Spinner",false);
                }
            }else{
                var message;
                var error = response.getError()[0];
                if(Object.keys(error.fieldErrors).length){
                    if( Object.values(response.getError()[0].fieldErrors).length){
                        if( Object.values(response.getError()[0].fieldErrors)[0].length){
                            message = Object.values(response.getError()[0].fieldErrors)[0][0].message;
                        }
                    }
                }else if(Object.keys(error.pageErrors).length){
                    if( Object.values(response.getError()[0].pageErrors).length){
                        message = Object.values(response.getError()[0].pageErrors)[0].message;
                        
                    }
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message ? message : JSON.stringify(response.getError()[0]),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner",false);
            }
        })
        if( !component.get("v.isTaskName")){
            component.set("v.Spinner",true);
            $A.enqueueAction(action);
        }
        
    },
    
    openTabWithSubtab : function (component, event, helper) {  
        var recid = event.currentTarget.dataset.recid
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
            
            var parentTabId = tabResponse.tabId;
            var isSubtab = tabResponse.isSubtab;
            
            workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                recordId:recid,
                focus: true
            });
        });
    },
    openTabWithSubtabs : function (component, event, helper) {  
        event.preventDefault();
        event.stopPropagation()
        var recid = event.currentTarget.dataset.recids
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
            
            var parentTabId = tabResponse.tabId;
            var isSubtab = tabResponse.isSubtab;
            
            workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                recordId:recid,
                focus: true
            });
        });
    },
    
    saveSingleRecord :  function (component, event, helper){
        /*var recordId = event.currentTarget.dataset.rowid;
        var list =  component.get("v.scheduleitemlst");
        var rowPhase = Number(event.currentTarget.dataset.phaseindex);
        var rowitem = Number(event.currentTarget.dataset.itemindex);
        list[rowPhase].value.splice(rowitem,1)
        component.set("v.scheduleitemlst",list);*/
        
        var updatedRecords = component.get("v.scheduleitemlst");
        component.set("v.isTaskName",false)
        var insertUpdaterecords = [];
        for(var i=0;i<updatedRecords.length;i++){
            if(updatedRecords[i].value){
                for(var j=0;j<updatedRecords[i].value.length;j++){
                    var rowItem = JSON.parse(JSON.stringify(updatedRecords[i].value[j]))
                    var condition;
                    if(component.get("v.isFinish")){
                        condition = updatedRecords[i].value[j].SObjs.buildertek__Finish__c
                    }
                    if(component.get("v.isDuration")){
                        condition = updatedRecords[i].value[j].SObjs.buildertek__Duration__c
                    }
                    if(!updatedRecords[i].value[j].SObjs.Name || (!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c) || !String(condition) ){
                        // alert('scheduleitemlst'+updatedRecords[i].value[j].Name);
                        var message;
                        if(component.get("v.isFinish")){
                            if(!updatedRecords[i].value[j].SObjs.buildertek__Finish__c && !rowItem.SObjs.buildertek__Dependency__c){
                                message = 'Please fill in the End Date'
                            } 
                        }
                        if(component.get("v.isDuration")){
                            if(!updatedRecords[i].value[j].SObjs.buildertek__Duration__c){
                                message = 'Please fill in the Duration'
                            }
                        }
                        
                        if(!updatedRecords[i].value[j].SObjs.buildertek__Start__c && !rowItem.SObjs.buildertek__Dependency__c){
                            message = 'Please fill in the Start Date'
                        }
                        if(!updatedRecords[i].value[j].SObjs.Name){
                            message = 'Please fill in the Name'
                        }
                        component.set("v.isTaskName", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: message,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        component.set("v.Spinner", false);
                        toastEvent.fire();
                        break;
                    }else if( !component.get("v.isTaskName")){
                        component.set("v.isTaskName", false);
                        insertUpdaterecords.push(updatedRecords[i].value[j].SObjs);
                    }
                }
            }
        }
        
        var action = component.get("c.UPandINTaskOrder");
        action.setParams({
            scheduleItemsListJSON : JSON.stringify(insertUpdaterecords),
            scheduleId : component.get("v.recordId"),
            currentPage : parseInt(component.get("v.currentPageNumber"))
        })
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            component.set("v.Spinner",false);
            if(response.getState() == "SUCCESS"){
                console.log(response.getState())
                console.log(response.getReturnValue());
                if(response.getReturnValue() == 'true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Records Updated Successfully.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire() 
                    component.set("v.oninitExpandIcon",false)
                    component.set("v.dupScheduleItems",component.get("v.scheduleitemlst"))
                    helper.getDataTableRespone(component, helper);
                    //component.set("v.Spinner",false);
                    var appEvent = $A.get("e.c:refresh_componenent_event");
                    appEvent.setParams({
                        "refreshmessage" : "Refresh Component from table"
                    });
                    appEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: response.getReturnValue(),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.Spinner",false);
                }
            }else{
                var message;
                var error = response.getError()[0];
                if(Object.keys(error.fieldErrors).length){
                    if( Object.values(response.getError()[0].fieldErrors).length){
                        if( Object.values(response.getError()[0].fieldErrors)[0].length){
                            message = Object.values(response.getError()[0].fieldErrors)[0][0].message;
                        }
                    }
                }else if(Object.keys(error.pageErrors).length){
                    if( Object.values(response.getError()[0].pageErrors).length){
                        message = Object.values(response.getError()[0].pageErrors)[0].message;
                    }
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message ? message : JSON.stringify(response.getError()[0]),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner",false);
            }
        })
        if(!component.get("v.isTaskName")){
            component.set("v.Spinner",true);
            $A.enqueueAction(action);
        }
        
    },
    
    
    
})