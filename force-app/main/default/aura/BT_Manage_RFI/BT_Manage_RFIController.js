({
    doInit: function (component, event, helper) {  
        
        var rfiaction = component.get("c.getRFISettings");
        rfiaction.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.rfisettings", fieldSetObj);
           /* var rfisett=component.get("v.rfisettings");
            alert('rfisett      '+rfisett);*/
        })
        $A.enqueueAction(rfiaction);
        
        
        
        var getRFQstatus = component.get("c.getRFQRecDetails");
        getRFQstatus.setParams({
            rfqId : component.get("v.recordId")
        })
        getRFQstatus.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.RFQstatus",response.getReturnValue().buildertek__Status__c);
            }
            
            
        })
        $A.enqueueAction(getRFQstatus);
        
        
        
        
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName : "buildertek__RFI__c",
            fieldSetName  : "buildertek__New_RFI_Community_Field_Set",
            parentRecordId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj); 
            var listofchange = component.get("v.fieldSetValues");
            var collist = [];
            //alert(component.get("v.rfisettings"));
            for (var i = 0; i < listofchange.length; i++) {
				                
                if(component.get("v.rfisettings") == true || component.get("v.rfisettings") == 'true'){
                    /*if(listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    }*/
                    if(listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Submitted_By__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    } 
                }else{
                    //if(listofchange[i].name != 'buildertek__Submitted_By__c' && listofchange[i].name != 'buildertek__Submitted_By2__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
                    if(listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Submitted_By2__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    } 
                }
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
        var action = component.get("c.getrfirecords");
        action.setParams({
            parentRecordId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            for(var i=0;i<fieldSetObj.length;i++){
                fieldSetObj[i]['rfqRowExpanded'] = false;
            }
            component.set("v.accountList", fieldSetObj);
            var rfilist = component.get("v.accountList");
            if(rfilist.length > 0){
                component.set("v.isrfi", true);
            }else{
                component.set("v.isrfinolist", true);
                component.set("v.isrfi", false);
            }
        })
        $A.enqueueAction(action);
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        var useraction = component.get("c.getUser");
        useraction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('getuser'+storeResponse);
                if(storeResponse == 'true'){
                    component.set("v.Isnewrfiresponse", true); 
                }else{
                    component.set("v.Isnewrfiresponse", false);
                }
            }
        });
        $A.enqueueAction(useraction); 
        var action2 = component.get("c.getrfiresponeserecords");
        action2.setParams({
            parentRecordId : component.get("v.recordId")
        })
        action2.setCallback(this, function(response) {
            var fieldSetObj = response.getReturnValue();
            var rfitotallist = component.get("v.accountList");
            //fieldSetObj.push({})
            var mapData = []
            var rfisWithNoRFIresponses = [];
            for(var i=0;i<Object.keys(fieldSetObj).length;i++){
                var obj = {};
                obj['rfi'] = Object.keys(fieldSetObj)[i]
                if(fieldSetObj[Object.keys(fieldSetObj)[i]].length){
                    obj['rfires'] = fieldSetObj[Object.keys(fieldSetObj)[i]]
                    rfisWithNoRFIresponses.push( Object.keys(fieldSetObj)[i])
                }else{
                    obj['rfires'] = undefined
                }
                mapData.push(obj);
            }
            for(var i=0;i<rfitotallist.length;i++){
                if(rfisWithNoRFIresponses){
                    if(rfisWithNoRFIresponses.indexOf(rfitotallist[i].Id) > -1){
                        rfitotallist[i]['isrefiRes'] = true;
                    }else {
                        var isnew = component.get("v.Isnewrfiresponse");
                        if(isnew){
                            rfitotallist[i]['isrefiRes'] = false;
                        }else{
                            rfitotallist[i]['isrefiRes'] = true;
                        }
                    }
                }
            }
            component.set("v.accountList",rfitotallist);
        })
        $A.enqueueAction(action2);
       
        var action = component.get("c.getrfirelatedfilesrecords");
        action.setParams({
            parentRecordId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
           // component.set("v.rfifilesList", fieldSetObj);
            var rfirecs  = component.get("v.accountList")
            if(rfirecs){
                for(var i=0;i<rfirecs.length;i++){
                    if(Object.keys(fieldSetObj).indexOf(rfirecs[i].Id) > -1){
                        var idx = Object.keys(fieldSetObj).indexOf(rfirecs[i].Id);
                        rfirecs[i].rfifileList = Object.values(fieldSetObj)[idx]
                    }
                }
            }
            
            component.set("v.accountList",rfirecs);
           // component.set("v.rfifilesRec", fieldSetObj.LinkedEntityId);
        })
        $A.enqueueAction(action);
        
        
    },
    expandCollapseGroups : function (component, event, helper) {
        // var recordId = event.currentTarget.dataset.rowid;
        // var rowId = event.currentTarget.dataset.grpindex;
        // var scheduleId = component.get("v.recordId")
        var rfirecordid = event.currentTarget.dataset.rowid;
        component.set("v.rfiId", rfirecordid);
        var recId = component.get("v.recordId");
        var tabId = component.get("v.currentTab")
        var grpIndex = event.currentTarget.dataset.grpindex;
        var expandicon
        var collapeIcon
        var className 
        var scheduleItems = component.get("v.accountList")
        var expandedCount = component.get("v.expandedCount");
        var expandallicon;
        var collapeallIcon;
        var expandedList = component.get("v.expandList")
        if(tabId){
            var expandicon = document.getElementsByClassName(tabId+' '+recId+' expandGrpIcon_'+grpIndex);
            var collapeIcon = document.getElementsByClassName(tabId+' '+recId+' collapseGrpIcon_'+grpIndex);
            var className = tabId+' '+scheduleId+" mapKey_"+grpIndex;
        }else{
            expandicon = document.getElementsByClassName(recId+' expandGrpIcon_'+grpIndex);
            collapeIcon = document.getElementsByClassName(recId+' collapseGrpIcon_'+grpIndex);
            className = recId+" mapKey_"+grpIndex;
        }
        
        var grpRows = document.getElementsByClassName(className) ;
        var allGroups = component.get("v.accountList");
        if(expandicon[0]){
            if(expandicon[0].style.display=="inline-block")  {   
                expandicon[0].style.display = 'none';
                scheduleItems[grpIndex].rfqRowExpanded = true;
                if(collapeIcon.length){
                    collapeIcon[0].style.display = 'inline-block';  
                }
                if(!expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                    expandicon[0].classList.add(tabId+'hideExpandIcon')
                }
                if(expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                    expandicon[0].classList.remove(tabId+'hideExpandIconhideCollapseIcon')
                }
                for(var i=0;i<grpRows.length;i++){
                    var item = grpRows[i];
                    if(item.style.display=="none"){
                        item.style.display='block';
                    }
                }
                //component.set("v.isrfiresponserow", true);
                helper.getrfirecords(component, event, helper);
                if(expandedList){
                    if(expandedList.indexOf(rfirecordid) < 0){
                        expandedList.push(rfirecordid);
                    }
                }else{
                    expandedList.push(rfirecordid);
                }
                component.set("v.expandList",expandedList)
                component.set("v.expandCount",expandedList.length)
                component.set("v.accountList",scheduleItems)
            }
            else if(expandicon[0].style.display=="none"){
                //component.set("v.isrfiresponserow", false);
                scheduleItems[grpIndex].rfqRowExpanded = false;
                if(collapeIcon.length){
                    for(var i=0;i<collapeIcon.length;i++){
                        collapeIcon[i].style.display = 'none';
                    }
                } 
                expandicon[0].style.display = 'inline-block';
                if(!expandicon[0].classList.contains(tabId+'hideExpandIconhideCollapseIcon')){
                    expandicon[0].classList.add(tabId+'hideExpandIconhideCollapseIcon')
                }
                if(expandicon[0].classList.contains(tabId+'hideExpandIcon')){
                    expandicon[0].classList.remove(tabId+'hideExpandIcon')
                }
                for(var i=0;i<grpRows.length;i++){
                    var item = grpRows[i];
                    if(item.style.display=="block"){
                        item.style.display='none';
                    }
                }
                if(expandedList){
                    if(expandedList.indexOf(rfirecordid) >= 0){
                        expandedList.splice(expandedList.indexOf(rfirecordid),1);
                        component.set("v.expandList",expandedList)
                        component.set("v.expandCount",expandedList.length)
                    }
                }
                component.set("v.accountList",scheduleItems)
            }
        }
    },
    addRFIResponseRec : function (component, event, helper) {
        //alert('res');
        component.set("v.newRFI",true);
        component.set("v.newResponse",false);
        component.set("v.isrfi",false);
        component.set("v.fileName", '');
        component.set("v.templateBody",'');
        component.set("v.responseval",'');

        var rfiresponserecordid = event.currentTarget.dataset.rowid;
        component.set("v.parentrfiresponseId",rfiresponserecordid);
    },
    addRFI : function (component, event, helper) {
        //alert('res');
        component.set("v.selectedUsers",[]);
        component.set("v.selectedContacts",[]); 
        component.set("v.fileName", '');
        component.set("v.templateBody",'');
        component.set("v.responseval",'');

        //component.set("v.newRFI",true);
        //component.set("v.newResponse",false);
        //component.set("v.isrfi",false);
        var rfiresponserecordid = event.currentTarget.dataset.rowid;
        component.set("v.rfiId",rfiresponserecordid);   
        //component.set("v.selectedUsers",'');
        //component.set("v.selectedContacts",'');
        var rfirecId =  rfiresponserecordid;         
        //alert('rfirecId--->'+rfirecId);       
          var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : rfirecId
        })
        action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
           component.set("v.selectedUsers",usernames);
           //alert(usernames);
            //component.set("v.newRFI",true);
            //component.set("v.newResponse",false);
            //component.set("v.isrfi",false);

        });
        $A.enqueueAction(action);
          var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : rfirecId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            component.set("v.selectedContacts",connames);
            var con=component.get("v.selectedContacts");             
            //component.set("v.newRFI",true);
            //component.set("v.newResponse",false);
            //component.set("v.isrfi",false);
            //alert(connames);
        });
        $A.enqueueAction(action);
      
        var action = component.get("c.getrfiRecord"); 
        action.setParams({
            parentRecordId : rfirecId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(fieldSetObj);
            component.set("v.newRFI",true);
            component.set("v.newResponse",false);
            component.set("v.isrfi",false);
            
            //alert(component.get("v.Isnewrfiresponse")); 
            
             if(component.get("v.rfisettings")==false){
                 if(component.get("v.Isnewrfiresponse")==true){
                     if(fieldSetObj.buildertek__RFI_Assigned_To__c!=null){
                         component.set("v.ReplyTo",fieldSetObj.buildertek__RFI_Assigned_To__r.Name);
                     } 
                     
                 }else{
                     if(fieldSetObj.buildertek__Submitted_By__c!=null){
                         component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By__r.Name);
                     }                      
                 }
             }else if(component.get("v.rfisettings")==true){
                 if(fieldSetObj.buildertek__Submitted_By2__c!=null){
                     component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By2__r.Name);
                 }   
             }
            
           
            
        })
        $A.enqueueAction(action);
        var relatedid = rfirecId;
        //helper.getFiles(component, event, helper,relatedid);
    },
    
    
    addRFIForward : function (component, event, helper) {
        //alert('res');
        component.set("v.selectedUsers",[]);
        component.set("v.selectedContacts",[]);        
        component.set("v.selectedContacts",[]);  
        component.set("v.fileName", '');
        component.set("v.templateBody",'');
        component.set("v.responseval",'');
        
  
        var rfiresponserecordid = event.currentTarget.dataset.rowid;
        component.set("v.rfiId",rfiresponserecordid); 
        
        
        //component.set("v.selectedUsers",'');
        //component.set("v.selectedContacts",'');
        var rfirecId =  rfiresponserecordid;         
        //alert('rfirecId--->'+rfirecId);       
        
        var relatedid = rfirecId;
        //helper.getFiles(component, event, helper,relatedid);
        
        var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : rfirecId
        })
        action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
            component.set("v.selectedUsers",usernames);
            //alert(usernames);            
            //component.set("v.newRFIForward",true);
            //component.set("v.newRFIResponseForward",false);            
            //component.set("v.newRFI",false);
            //component.set("v.newResponse",false);
            //component.set("v.isrfi",false);
            
        });
        $A.enqueueAction(action);
        

        
        var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : rfirecId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            component.set("v.selectedContacts",connames);
            var con=component.get("v.selectedContacts");             
            //component.set("v.newRFIForward",true);
            //component.set("v.newRFIResponseForward",false);  
            //component.set("v.newRFI",false);
            //component.set("v.newResponse",false);
            //component.set("v.isrfi",false);
            //alert(connames);
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getrfiquestion"); 
        action.setParams({
            parentRecordId : rfirecId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            
            component.set("v.newRFIForward",true);
            component.set("v.newRFIResponseForward",false);            
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",false);
            //alert(component.get("v.Isnewrfiresponse"));

            component.set("v.responseval",fieldSetObj);                
            
            
        })
        $A.enqueueAction(action);
       
 
    },
    
    
    doCancel : function (component, event, helper) {
        component.set("v.newRFIForward",false);
        component.set("v.newRFIResponseForward",false);  
        component.set("v.newRFI",false);
        component.set("v.newResponse",false);
        component.set("v.isrfi",true);
        component.set("v.fileName",'No File Selected..');
         component.set("v.errorMSG1", false);
                component.set("v.errorMSG2", false);
                component.set("v.errorMSG3", false);
                component.set("v.errorMSG4", false);
          var action = component.get("c.deleteFile");
        //alert(component.get("v.recordId"));
        action.setParams( { 
            RecordId : component.get("v.recordId"),
            fileIds: component.get('v.uploadedFileIds')
        }); 
        action.setCallback(this, function(actionResult) {
            
            var state = actionResult.getState();
            if(state == 'SUCCESS'){
               var fieldSetObj = actionResult.getReturnValue(); 
                component.set("v.Isfileuploaded",false);
            }
            
        });
        if(component.get("v.Isfileuploaded") == true){
            $A.enqueueAction(action);
        }
        
        
        
        
        
        component.set("v.fileName", '');
        component.set("v.templateBody",'');
        component.set("v.responseval",'');
		component.set("v.selectedfilesFill",[]); 
        
    },
    handleSubmit: function (component, event, helper) {
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        //alert("Users Ids-------------"+JSON.stringify(users));
        //alert("Contact Ids-----------"+JSON.stringify(cons));
        //alert(users.length);
        //alert(cons.length);
        var username = component.get("v.userInfo");
        component.set("v.IsSpinner",true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        //alert('today'+today);
        //component.set('v.today', today);
        var parentid = component.get("v.parentrfiresponseId");
        var parentresponseId = component.get("v.parentresponseId");
        var fields = event.getParam("fields");
        var rfiid = component.get("v.rfiId"); 
        var privatevalue= component.get("v.rfiId"); 
        parentid = rfiid;
        //alert('parentid-->'+parentid);
        fields.buildertek__RFI__c = parentid;
        fields.buildertek__Response_Date__c = today;
        fields.buildertek__Responder__c = username;
        fields.buildertek__Parent__c = parentresponseId;
        /*if(users.length>0 || cons.length>0 ){
        	fields.buildertek__Show_In_Community__c = false;     
        } */       
        event.preventDefault(); // Prevent default submit
       component.find('recordViewForm').submit(fields); // Submit form
    },
    onRecordSuccess: function (component, event, helper) {
        /*var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.rfiresponseId',eventId);

        if(component.get("v.rfisettings")==false){
            if(component.get("v.Isnewrfiresponse")==false){
                console.log('updateRFQ');
                var action = component.get("c.updateRFQ");
                //  var recordid=component.get("v.projRecordId");
                action.setParams({
                    RecordId : component.get("v.rfiresponseId"),
                    selectedUsers:component.get("v.selectedUsers"),
                    selectedContacts:component.get("v.selectedContacts")
                })
                action.setCallback(this, function (response) {
                    var fieldSetObj = response.getReturnValue();
                    console.log('updateRFQ'+fieldSetObj);
                })
                $A.enqueueAction(action);            
            }else{
                console.log('updateRFQ1');
                var action = component.get("c.updateRFQ1");
                //  var recordid=component.get("v.projRecordId");
                action.setParams({
                    RecordId : component.get("v.rfiresponseId")                
                })
                action.setCallback(this, function (response) {
                    var fieldSetObj = response.getReturnValue();
                    console.log('updateRFQ1'+fieldSetObj);
                })
                $A.enqueueAction(action);  
            }            
        }else  if(component.get("v.rfisettings")==true){
            var action = component.get("c.updateRFQ2");
            //  var recordid=component.get("v.projRecordId");
            action.setParams({
                RecordId : component.get("v.rfiresponseId")                
            })
            action.setCallback(this, function (response) {
                var fieldSetObj = response.getReturnValue();
                console.log('updateRFQ2'+fieldSetObj);
            })
            $A.enqueueAction(action);  
            
        }
        
      
    
        
        
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            helper.uploadHelper(component, event, helper);
            helper.getrfirecords(component, event, helper);
        } else{
            component.set("v.IsSpinner",false);
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                title : "Success!",
                message : 'RFI Response created successfully',
                type: 'success',
                duration: '10000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",true);
            helper.getrfirecords(component, event, helper);
            //$A.enqueueAction(component.get("c.expandCollapseGroups"));
            /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();*/
        }
        
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';                    
        component.set("v.selectedfileslist",event.getSource().get("v.files"));   
        var fileCount=event.getSource().get("v.files").length;
        var files='';
        var mapData = [];
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                fileName = event.getSource().get("v.files")[i]["name"];
                var obj = {};
                obj['Name'] = fileName;                
                if(i == 0){
                    files=fileName;    
                }else{
                    files=files+','+fileName;
                }
                mapData.push(obj);                
            }
        }
        else
        {
            files=fileName;
        }
        component.set("v.selectedfilesFill",mapData);
        
    }, 
    close :function(component, event, helper){
        component.set("v.newRFI",false);
        component.set("v.isrfi",false);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    filelist : function(component, event, helper) {
        var rfirecordid = event.currentTarget.dataset.rowid;
        var action = component.get("c.getContentDocs"); 
        action.setParams( { 
            arecordId : rfirecordid
        }); 
        action.setCallback(this, function(actionResult) {
            //alert(actionResult);
            var result = actionResult.getReturnValue();
            var btfileslist = result.btfileslist;
            var standardfiles = result.standardfiles;
            //alert(JSON.stringify(btfileslist));
            //alert(JSON.stringify(standardfiles));
            //component.set('v.files',actionResult.getReturnValue()); 
            //var fileslist = component.get('v.files');
            //alert('fileslist'+ fileslist.length);
            if(btfileslist.length > 0 || standardfiles.length > 0 ){
                if(btfileslist.length > 0){
                  component.set('v.files',btfileslist);   
                }
                if(standardfiles.length > 0){
                  component.set('v.rfqstandardfiles',standardfiles); 
                }
            
                component.set("v.Isfiles",true);
                component.set("v.isrfi",false);
            }else{
               // component.set("v.Isnofiles",true);
                component.set("v.isrfi",false);
            }
        }); 
        $A.enqueueAction(action); 
    },
    
    filelist1 : function(component, event, helper) {
        var rfirecordid = event.currentTarget.dataset.rowid;
        var action = component.get("c.getContentDocs1"); 
        action.setParams( { 
            arecordId : rfirecordid
        }); 
        action.setCallback(this, function(actionResult) {
            /*component.set('v.files',actionResult.getReturnValue()); 
            var fileslist = component.get('v.files');
            //alert('fileslist'+ fileslist.length);
            if(fileslist.length > 0){
                component.set("v.Isfiles",true);
                component.set("v.isrfi",false);
            }else{
               // component.set("v.Isnofiles",true);
                component.set("v.isrfi",false);
            }*/
                                    
            var result = actionResult.getReturnValue();
            var btfileslist = result.btfileslist;
            var standardfiles = result.standardfiles;
            //alert(JSON.stringify(btfileslist));
            //alert(JSON.stringify(standardfiles));
            if(btfileslist.length > 0 || standardfiles.length > 0 ){
                if(btfileslist.length > 0){
                  component.set('v.files',btfileslist);   
                }
                if(standardfiles.length > 0){
                  component.set('v.rfqstandardfiles',standardfiles); 
                }
            
                component.set("v.Isfiles",true);
                component.set("v.isrfi",false);
            }else{
               // component.set("v.Isnofiles",true);
                component.set("v.isrfi",false);
            }
            
            
        }); 
        $A.enqueueAction(action);  
        
    },
    
    getSelectedpreviewFile : function(component, event, helper) {
        var rec_id = event.currentTarget.getAttribute("data-Id");  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });
    },
    closeRFIModel: function (component, event, helper) {
        component.set("v.isrfi",false);
        component.set("v.isrfinolist",false);
        $A.get("e.force:closeQuickAction").fire(); 
      /*  var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();*/
    },
    closeModel: function (component, event, helper) {
        component.set("v.Isfiles",false);
      //  component.set("v.Isnofiles",false);
        component.set("v.isrfi",true);
        component.set("v.Isclosed",false);
        component.set("v.IsRFIclosed",false);
        component.set("v.selectedfilesFill",[]);
        /*  var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();*/
    },
    cancelRFQ : function (component, event, helper) {
        component.set("v.isrfi",false);
        var rfirecordid = event.currentTarget.dataset.rowid;
        component.set("v.closedrfi",rfirecordid);
        var action = component.get("c.getrfiRecord");
        action.setParams({
            parentRecordId : rfirecordid
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            // component.set("v.rfiRec", fieldSetObj);
            if(fieldSetObj.buildertek__Status__c == 'Closed'){
                component.set("v.Isclosed",true);
                component.set("v.IsRFIclosed",false);
            }else{
                component.set("v.Isclosed",false);
                component.set("v.IsRFIclosed",true);
            }
        })
        $A.enqueueAction(action);
    },
    updateRFI : function (component, event, helper) {
        component.set("v.IsSpinner",true);
        var action = component.get("c.updaterfirec");
        action.setParams({
            projectId : component.get("v.closedrfi")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Success!",
                message : 'RFI updated successfully',
                type: 'success',
                duration: '10000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set("v.IsSpinner",false);
            component.set("v.isrfi",true);
            component.set("v.IsRFIclosed",false);
            $A.get('e.force:refreshView').fire();
            /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();
            $A.get('e.force:refreshView').fire();*/
        })
        $A.enqueueAction(action);
    },
    redirectRecord : function(cmp, event, helper) {
        var rfirecordid = event.currentTarget.dataset.rowid;
        var navService = cmp.find("navService");
        var pageReference = {    
            "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
            "attributes": {
                "recordId": rfirecordid, //place your record id here that you wish to open
                "actionName": "view"
            }
        }
        
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
            window.open(url,'_blank'); //this opens your page in a seperate tab here
        }), 
              $A.getCallback(function(error) {
                  console.log('error: ' + error);
              }));

       /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": rfirecordid,
                "slideDevName": "related"
            });
            navEvt.fire();*/
      //  window.open('/lightning/r/buildertek__RFI__c/'+rfirecordid+'/view','_blank');
    },
    
    
     addResponseRec : function (component, event, helper) {
        
         var rfirecordid = event.currentTarget.dataset.rowid;
          component.set("v.rfi_response_Id",rfirecordid);
         component.set("v.selectedUsers",[]);
        component.set("v.selectedContacts",[]);
         
         var rfirecId = component.get("v.rfiId"); 
         
        //alert('rfirecId--->'+rfirecId);        
          var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : rfirecId
        })
        action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
            //alert(JSON.stringify(response));
           // alert(usernames.buildertek__User__c);
           //alert(usernames);
           component.set("v.selectedUsers",usernames);
            //component.set("v.selectedContacts",usernames.buildertek__Contact__c);
            //alert('get'+component.get("v.selectedUsers"));            
             //var parentresponseId = event.currentTarget.dataset.rowid;
             // alert('parentresponseId--->'+parentresponseId);
             //component.set("v.parentresponseId",parentresponseId); 
        });
        $A.enqueueAction(action);
          var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : rfirecId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            //alert(JSON.stringify(response));
           // alert(usernames.buildertek__User__c);
           //alert(connames);
           // component.set("v.selectedUsers",usernames.buildertek__User__c);
            component.set("v.selectedContacts",connames);
            var con=component.get("v.selectedContacts");
             
            //component.set("v.newRFI",false);
            // component.set("v.newResponse",true);
            // component.set("v.isrfi",false);
            //alert(con);
        });
        $A.enqueueAction(action);
        
         var action = component.get("c.getrfiRecord");
         action.setParams({
             parentRecordId : rfirecId
         })
         action.setCallback(this, function (response) {
             var fieldSetObj = response.getReturnValue();
             // component.set("v.rfiRec", fieldSetObj);
             
			
             component.set("v.newRFI",false);
             component.set("v.newResponse",true);
             component.set("v.isrfi",false);    
             console.log(component.get("v.Isnewrfiresponse"));
             
             if(component.get("v.rfisettings")==false){
                 if(component.get("v.Isnewrfiresponse")==true){
                     console.log('true');
                    if(fieldSetObj.buildertek__RFI_Assigned_To__c!=null){
                        component.set("v.ReplyTo",fieldSetObj.buildertek__RFI_Assigned_To__r.Name);
                    } 
    
                }else{
                    console.log('false');
                    if(fieldSetObj.buildertek__Submitted_By__c!=null){
                        component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By__r.Name);
                    } 
    
                }                          
             }else if(component.get("v.rfisettings")==true){
                 if(fieldSetObj.buildertek__Submitted_By2__c!=null){
                     component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By2__r.Name);
                 }   
             }
            
             
            
         })
         $A.enqueueAction(action);   
         
         var relatedid = rfirecordid;
         //helper.getFiles(component, event, helper,relatedid);

         /*var count=0;
         for(var k=1;k<1000;k++){
             count++;
         }*/
         //if(count>=1000){
            // component.set("v.newRFI",false);
            // component.set("v.newResponse",true);
            // component.set("v.isrfi",false);
             //var parentresponseId = event.currentTarget.dataset.rowid;
             // alert('parentresponseId--->'+parentresponseId);
             //component.set("v.parentresponseId",parentresponseId);  */ 
        // }
         
       
    },
    
    sendEmail : function (component, event, helper) {
        component.set("v.sendEmail",true);
        component.set("v.isrfi",false);
        var parentresponseId = event.currentTarget.dataset.rowid;
        //alert('parentresponseId--->'+parentresponseId);
        component.set("v.parentresponseId",parentresponseId);
    },
    
    
    handleRFIForwardSubmit: function (component, event, helper) {
        var privatevalue=component.get("v.private"); 
       // alert('privatevalue    '+privatevalue);
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        //alert("Users Ids-------------"+JSON.stringify(users));
        //alert("Contact Ids-----------"+JSON.stringify(cons));
        //alert(users.length);
        //alert(cons.length);
        var username = component.get("v.userInfo");
        component.set("v.IsSpinner",true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        //alert('today'+today);
        //component.set('v.today', today);
        var parentid = component.get("v.parentrfiresponseId");
        var parentresponseId = component.get("v.parentresponseId");
        var fields = event.getParam("fields");
        var rfiid = component.get("v.rfiId"); 
        
        parentid = rfiid;
        //alert('parentid-->'+parentid);
        fields.buildertek__RFI__c = parentid;
        fields.buildertek__Response_Date__c = today;
        fields.buildertek__Responder__c = username;
        fields.buildertek__Parent__c = parentresponseId;
        fields.buildertek__private__c  =privatevalue;
        /*if(users.length>0 || cons.length>0 ){
        	fields.buildertek__Show_In_Community__c = false;     
        } */    
        event.preventDefault(); // Prevent default submit
       component.find('recordViewForm').submit(fields); // Submit form
         //component.set("v.newRFIResponseForward",false); 
    },
    onRFIForwardRecordSuccess: function (component, event, helper) {
        
        /*var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.rfiresponseId',eventId);
        //alert(eventId);
        
        var action = component.get("c.updateRFIForward");
        //  var recordid=component.get("v.projRecordId");
        action.setParams({
            RecordId : component.get("v.rfiresponseId"),
            selectedUsers:component.get("v.selectedUsers"),
            selectedContacts:component.get("v.selectedContacts")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
        })
        $A.enqueueAction(action);
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            helper.uploadHelper(component, event, helper);
            helper.getrfirecords(component, event, helper);
        } else{
            component.set("v.IsSpinner",false);
            var toastEvent1 = $A.get("e.force:showToast");
            
            toastEvent1.setParams({
                title : "Success!",
                message : 'RFI forwarded successfully',
                type: 'success',
                duration: '10000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent1.fire();
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",true);
            component.set("v.newRFIForward",false);
            component.set("v.newRFIResponseForward",false);  
            helper.getrfirecords(component, event, helper);
            //$A.enqueueAction(component.get("c.expandCollapseGroups"));
            /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();*/
        } 
        
         
        
    },
    
    
      addResponseForward : function (component, event, helper) {
        //alert('res');
        component.set("v.selectedUsers",[]);
        component.set("v.selectedContacts",[]);        
        var parentresponseId = event.currentTarget.dataset.rowid;
        component.set("v.parentresponseId",parentresponseId); 
        var rfirecId = component.get("v.rfiId"); 		
          //alert(parentresponseId);
        //component.set("v.selectedUsers",'');
        //component.set("v.selectedContacts",'');
        //alert('rfirecId--->'+rfirecId);       
        var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : rfirecId
        })
        action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
            component.set("v.selectedUsers",usernames);
            //alert(usernames);            
            /*component.set("v.newRFIForward",false);
            component.set("v.newRFIResponseForward",true);            
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",false);*/
            
        });
        $A.enqueueAction(action);
        var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : rfirecId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            component.set("v.selectedContacts",connames);
            var con=component.get("v.selectedContacts");             
            /*component.set("v.newRFIForward",false);
            component.set("v.newRFIResponseForward",true);  
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",false);*/
            //alert(connames);
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getrfiresponse"); 
        action.setParams({
            parentRecordId : parentresponseId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(fieldSetObj); 
            //alert(component.get("v.Isnewrfiresponse"));

            component.set("v.newRFIForward",false);
            component.set("v.newRFIResponseForward",true);            
            component.set("v.newRFI",false);
            component.set("v.newResponse",false);
            component.set("v.isrfi",false);
            component.set("v.selectedfilesFill",[]); 
            
            component.set("v.responseval",fieldSetObj);                
            
            
        })
        $A.enqueueAction(action);
          var relatedid = parentresponseId;
          //helper.getFiles(component, event, helper,relatedid);

 
    },
    
    getPrivateValue:function (component, event, helper) {
        var privateval=event.getSource().get('v.checked');
        //alert('privateval'+privateval);
         component.set("v.private",privateval);  
    },
    
    sendResponse:function(component, event, helper) {             
       
        var rfirecId=component.get("v.rfiId"); 
       // var parentresponseId = event.currentTarget.dataset.rowid;
       // alert(rfirecId);
        var parentid = component.get("v.rfi_response_Id");
        //alert(parentid);
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.rfiId");
        var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.templateBody");
         
       
        
        if(component.get("v.Isnewrfiresponse")==true){
            users=[];
            cons=[];
        }
        if(varresponse !=''){ 
             component.set("v.IsSpinner",true);
        var action = component.get("c.createRFIResponse");
        action.setParams({
            rfiRecId:rfirecId,
            userId:username,
            response:varresponse,
            parentId:parentid,
            selectedUsers:users,
            selectedContacts:cons,
            selectedFiles: component.get("v.selectedFiles")           
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            var newRec=response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",false);
           
                //alert('newRec.Id--->'+newRec.Id);
                var newresponserecid = newRec.Id;
                component.set("v.newRFIResponse", newRec.Id);
                component.set("v.newResponse",false);
                component.set("v.isrfi",true);
                component.set("v.templateBody",'');
                component.set("v.newRFI",false);
                
                
                //alert(component.find("fuploader").get("v.files").length);   
                /*if (component.find("fuploader").get("v.files") != undefined) {
                    if(component.find("fuploader").get("v.files").length > 0){
                        //alert(newresponserecid);
                        helper.uploadHelper(component, event, newresponserecid,helper);
                        
                    }
                }else{
                    helper.getrfirecords(component, event, helper);
                }*/
                
                
                
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'RFI Response created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                
                
                if(component.get('v.uploadedFileIds').length > 0){
                    helper.copyfilesHelper(component,newresponserecid);
                }else{
                    helper.showMessage('RFI Response created successfully',true);
                    helper.getrfirecords(component, event, helper);
                    
                    component.set("v.IsSpinner",false);
                    
                    //location.reload();
                }
                component.set("v.selectedUsers",[])
               component.set("v.newRFIResponse", newRec.Id); 
            }
        })
        
       $A.enqueueAction(action);
             }else{
            component.set("v.errorMSG1", true);
                  component.set("v.errorMSG2", true);
        }
        //location.reload();
        
        
        
    },
    sendForward:function(component, event, helper) {
         
        var rfirecId=component.get("v.rfiId"); 
       // var parentresponseId = event.currentTarget.dataset.rowid;
       // alert(rfirecId);
        var parentid = component.get("v.rfi_response_Id");
        //alert(parentid);
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.rfiId");
        var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.responseval");
        if(varresponse !=''){
            component.set("v.IsSpinner",true);
        var privatevalue=component.get("v.private"); 
        var action = component.get("c.createRFIResponseForward");
        action.setParams({
            rfiRecId:rfirecId,
            userId:username,
            response:varresponse,
            parentId:parentid,
            selectedUsers:users,
            selectedContacts:cons,
            privatevalue:privatevalue,
            selectedFiles: component.get("v.selectedFiles") 
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            var newRec=response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",false);
                
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'RFI forwarded successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                var newresponserecid = newRec.Id;

                component.set("v.newRFIResponse", newRec.Id);
                component.set("v.newResponse",false);
                component.set("v.isrfi",true);
                component.set("v.newRFI",false);
                component.set("v.newRFIForward",false);
                component.set("v.newRFIResponseForward",false);
                //helper.getrfirecords(component, event, helper);
                
                  //alert(component.find("fuploader").get("v.files").length);   
                /*if (component.find("fuploader").get("v.files") != undefined) {
                    if(component.find("fuploader").get("v.files").length > 0){
                        //alert(newresponserecid);
                        helper.uploadHelper(component, event, newresponserecid,helper);
                        
                    }
                }else{
                    helper.getrfirecords(component, event, helper);
                }*/
                if(component.get('v.uploadedFileIds').length > 0){
                    helper.copyfilesHelper(component,newresponserecid);
                }else{
                    helper.showMessage('RFI Response created successfully',true);
                     helper.getrfirecords(component, event, helper);
                    
                    component.set("v.IsSpinner",false);
                    
                    //location.reload();
                }
                component.set("v.selectedUsers",[])
                component.set("v.newRFIResponse", newRec.Id);
                
                
                
            }
        })
        
       $A.enqueueAction(action);
            
            }else{
            component.set("v.errorMSG3", true);
                  component.set("v.errorMSG4", true);
        }
        //location.reload();
    },
    uploadFilepromise : function(component, event, helper) {
        
        var recid= component.get("v.rfiId");
          
        
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Upload File",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_AddFiles", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId":recid,
                    "selectedFiles": component.get("v.selectedFiles"),
                    "onCancel":function(){
                        component.get('v.modalPromise').then(function (modal) {
                            modal.close();
                            //$A.enqueueAction(component.get("c.doInit"));
                        });
                    },
                    "onSuccess":function(file){
                        component.get('v.modalPromise').then(function (modal) {
                            modal.close();
                            //$A.enqueueAction(component.get("c.doInit"));
                        });
                        
                        //alert('file --------> '+file);
                        var selectedFiles = [];
                        for(var i=0; i<file.length; i++){
                            selectedFiles.push({
                                "Id" : file[i].Id,
                                "Name" : file[i].Name
                            });    
                        }
                        //alert('selectedFiles ---------> '+selectedFiles.length);
                        component.set("v.selectedFiles", selectedFiles);
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    var modalPromise = component.find('overlay').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer") ,
                        showCloseButton: true,
                        cssClass: '',
                        closeCallback: function() {
                            
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
                },
                 closeErrorMSG1 : function(component, event, helper) {
                 component.set("v.errorMSG1", false);
                component.set("v.errorMSG2", false);
                component.set("v.errorMSG3", false);
                component.set("v.errorMSG4", false);
                },
                 closeErrorMSG2 : function(component, event, helper) {
                 component.set("v.errorMSG1", false);
                component.set("v.errorMSG2", false);
                component.set("v.errorMSG3", false);
                component.set("v.errorMSG4", false);
                },
                 closeErrorMSG3 : function(component, event, helper) {
                 component.set("v.errorMSG1", false);
                component.set("v.errorMSG2", false);
                component.set("v.errorMSG3", false);
                component.set("v.errorMSG4", false);
                },
                 closeErrorMSG4 : function(component, event, helper) {
                 component.set("v.errorMSG1", false);
                component.set("v.errorMSG2", false);
                component.set("v.errorMSG3", false);
                component.set("v.errorMSG4", false);
                },
                               // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.selectedfilesFill"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Name == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.selectedfilesFill", AllPillsList);
            }  
        }
    },
 
 
     handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
    	var fileIds = [];
        var mapData = [];
        var files='';
    	for (var i = 0; i < uploadedFiles.length; i++) { 
            //alert(JSON.stringify(uploadedFiles[i]));
            console.log(JSON.stringify(uploadedFiles[i]));
            fileIds.push(uploadedFiles[i]["contentVersionId"]);
            var fileName  =  uploadedFiles[i]["name"]; 
            //alert(fileName); 
            var obj = {};
            obj['Name'] = fileName;                
            if(i == 0){
                files=fileName;    
            }else{
                files=files+','+fileName;
            }
            mapData.push(obj); 
            //alert(uploadedFiles[i]["name"]);
            //alert(uploadedFiles[i]["documentId"]);
            //alert(uploadedFiles[i]["contentVersionId"]);
        }
    	component.set('v.uploadedFileIds',fileIds);
    	component.set("v.selectedfilesFill",mapData);                 

    	//alert(JSON.stringify(component.get('v.uploadedFileIds')));
        
            		
    
    
        // show success message – with no of files uploaded
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": uploadedFiles.length+" files has been uploaded successfully!"
        });
        toastEvent.fire();
        component.set("v.Isfileuploaded",true);
        //$A.get('e.force:refreshView').fire();
        
        // Close the action panel
        //var dismissActionPanel = $A.get('e.force:closeQuickAction');
        //dismissActionPanel.fire();
    },


    
})