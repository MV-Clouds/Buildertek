({
    getTemplate : function(component, event, helper) {
        var dbAction = component.get("c.getTemplates");
        var abc = component.get("v.templatefolderName");
        // alert('abc........'+abc);
        dbAction.setParams({
            folderName: component.get("v.templatefolderName"),
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            var y = response.getReturnValue();
           if(y != undefined){
               var x;
                    for(var i = 0;i<y.length;i++){
                        if(y[i].Name != 'Change Order1' && y[i].Name != 'EmailChangeOrders'){
                             console.log("for Check")
                           x = y[i].Id;
                            console.log("Temp id : ",x);
                        }
                    }
                    } 
            console.log('jjjjjj',response.getReturnValue());
            if (state === "SUCCESS" && response.getReturnValue().length > 0) {
                component.set("v.templates", response.getReturnValue());
                component.set("v.selectedTemplate", x);
              //  alert('hai,,,,,,'+component.get("v.selectedTemplate"));
            }
        });
        $A.enqueueAction(dbAction);
    },
    getbodyTemplate : function(component, event, helper) {
        var dbAction = component.get("c.getbodyTemplates");
        var objectName = component.get("v.objectAPI");
        var foldername = '';
        if(objectName == 'buildertek__Account_Payable__c'){
            foldername =  'Invoice body template folder';
        }else if(objectName == 'buildertek__Billings__c'){
            foldername =  'Invoice(AR) body template folder'; 
        }
        dbAction.setParams({
            folderName: foldername
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            //  alert('selectedbodyTemplateItem'+component.get("v.selectedbodyTemplateItem"));
            if (state === "SUCCESS" && response.getReturnValue().length > 0) {
                component.set("v.bodytemplatesList", response.getReturnValue());
                component.set("v.selectedbodyTemplateItem", response.getReturnValue()[0].Id);
                this.getBodyContent(component,response.getReturnValue()[0].Id);
                console.log(response.getReturnValue()[0].Body);
            }
        });
        $A.enqueueAction(dbAction);
    },
    getBodyContent : function(component,invoiceBodyTemplateId){
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var action = component.get("c.gettemplatebodyContent");
        action.setParams({
            recordId: component.get("v.recordId"),
            templateId: component.get("v.selectedbodyTemplateItem")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // alert('response.getReturnValue()'+response.getReturnValue());
            if (state === "SUCCESS" && response.getReturnValue()) {
                component.set("v.selectedInvoiceBodyContent",response.getReturnValue());
                component.set("v.templateBody",response.getReturnValue());
                console.log(response.getReturnValue());
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getFiles : function(component, event, helper) {
        ////alert('selectedFiles length  ------>    '+component.get("v.selectedFiles").length);
        //alert('selectedFiles   ------>    '+JSON.stringify(component.get("v.selectedFiles")));
        var action = component.get("c.getFileAttachments");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result =  response.getReturnValue();
                if(result != undefined){
                    result = JSON.parse(result);     
                }
                var selectedFiles = [];
                var customFiles;
                var standardFiles;
                var attachments;
                if(result != undefined){
                    for(var i=0;i<result.length;i++){
                        customFiles = result[i].customFilesList;
                        standardFiles = result[i].ContentVersionList;
                        attachments = result[i].attachmentList;
                        if(customFiles != undefined){
                            for(var j=0;j<customFiles.length;j++ ){
                                selectedFiles.push({
                                    'Id' : customFiles[j].Id,
                                    'Name' : customFiles[j].Name
                                });
                            }
                        }
                        if(standardFiles != undefined){
                            for(var k=0;k<standardFiles.length;k++ ){
                                selectedFiles.push({
                                    'Id' : standardFiles[k].ContentDocumentId,
                                    'Name' : standardFiles[k].Title
                                });
                            }
                        }
                        
                        if(attachments != undefined){ 
                            for(var l=0;l<attachments.length;l++ ){
                                selectedFiles.push({
                                    'Id' : attachments[l].Id,
                                    'Name' : attachments[l].Name
                                });
                            }
                        } 
                        
                    }
                    component.set("v.selectedFiles", selectedFiles);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getContact : function(component, event, helper) {
        var action = component.get("c.getObjectContact");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "objectAPIName" : component.get("v.objectAPI")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                //alert('result ---------> '+result);
                var selectedContact = component.get("v.selectedToContact");
                if(selectedContact.length == 0){
                    selectedContact.push(result);   
                }
                component.set("v.selectedToContact", selectedContact);
            }
        });
        $A.enqueueAction(action);
    },
    
    send:function(component, event, helper) {
        var m = component.get("v.records")
        debugger;
        var to, cc, toIds = [], ccIds = [], files, fileIds = [], subject, body, recordId, templateId, pdfFileName;
        body = '';
        to = component.get("v.selectedToContact");
        cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");
        files = component.get("v.selectedFillIds"); //selectedFillIds  //selectedFiles
        to.forEach(function(v){ toIds.push(v.Id) });
        cc.forEach(function(v){ ccIds.push(v.Id) }); 
        files.forEach(function(v){ fileIds.push(v) });
        body += component.get("v.templateBody");
        subject = component.get("v.subject"); 
        templateId = component.get("v.selectedTemplate");
        recordId = component.get("v.records");
        pdfFileName = component.get("v.pdfFileName");
        var dbAction = component.get("c.SendEmail");
        console.log("To : ",toIds," ,cc : ",ccIds," ,files : ",fileIds," ,subject : ",subject," ,body : ",body," ,recordId : ",recordId," ,templateId : ",templateId," ,pdfFileName : ",pdfFileName," ,emailIds : ",emailIds);
        dbAction.setParams({
            to:toIds,
            cc: ccIds,
            files: fileIds,
            subject: subject,
            body: body,
            recordId: recordId,
            templateId: templateId,
            pdfFileName: pdfFileName,
            emailIds: emailIds,
            Ids : recordId
        });
    
        dbAction.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success'){
                   // alert("ok")
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                   // component.get("v.onSuccess")(); 
                 //   $A.get('e.force:refreshView').fire(); 
                    sforce.one.showToast({
                        
                        "title": "",
                        
                        "message": "Email Sent Successfully",
                        
                        "type": "success" //supported types are error, success, info, warning
                        
                    });
                   
                window.open("/lightning/r/buildertek__Project__c/"+component.get("v.parentRecordId")+"/related/buildertek__Change_Orders__r/view","_self");
                }else{
                    console.log(response.getReturnValue());
                    debugger;
                    component.get("v.onCancel")();
                      sforce.one.showToast({
                        
                        "title": "",
                        
                        "message": response.getReturnValue(),
                        
                        "type": "error" //supported types are error, success, info, warning
                        
                    });
                  /*  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: response.getReturnValue(),
                        type : 'error',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); */
                } 
            }else{
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                component.get("v.onCancel")();
            }
        });
        $A.enqueueAction(dbAction);
        
    },
    
    
    
    //MAX_FILE_SIZE: 4500000,
    save : function(component, helper, file) {
        if (file.size > this.MAX_FILE_SIZE) {
            /*  alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size); */
            return;
        }
        
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            
            self.upload(component, file, fileContents);
        };
        
        fr.readAsDataURL(file);
    },
    
    upload: function(component, file, fileContents) {
        
        var action = component.get("c.saveTheFile"); 
        
        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === "SUCCESS"){
                var attachId = a.getReturnValue();
                console.log(attachId);  
                var action = component.get("c.getDocuments");
                action.setParams({
                    recordId : attachId
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var result = response.getReturnValue();
                        var templateBody = component.get("v.templateBody");
                        var url = '<p><img src="'+result+'"/></p>';
                        templateBody += url;
                        component.set("v.templateBody", templateBody);
                        //alert('body-------->' +component.get("v.templateBody"));
                        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    }
                });
                $A.enqueueAction(action);
            }
            
        });
        
        $A.enqueueAction(action); 
    },
    
    
    
    
    //   MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    // CHUNK_SIZE: 750000,      //Chunk Max size 750Kb      
    // filesCount : 0,
    // fileInputLenght: 0,
    // fileIds:[],
    /**
     * This method to upload files
     * @param: File Data
     */
    uploadHelper: function(component, event, recid,helper) {
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fuploader").get("v.files");
        var fileInput = component.get("v.selectedfileslist");
     
        //alert('fileInput--->'+fileInput);
        this.fileInputLenght = fileInput.length; 
      //  alert("upload complte")
        //alert('uploadHelper--->'+recid);
        var fills = component.get("v.selectedfilesFill");
        //alert('fill--->'+fills);
        for (var i = 0; i < fileInput.length; i++) { 
            var filenameexists = false;
            for (var j = 0; j < fills.length; j++) {
                if(fileInput[i]["name"] == fills[j].Name){
                    //alert('name i'+fileInput[i]["name"]);
                    //alert('name j'+fills[j].Name); 
                    filenameexists = true; 
                    break;
                }
            }
            
            if(filenameexists){
              
                var file = fileInput[i];
                var self = this;
                //alert(file);
                // check the selected file size, if select file size greter then MAX_FILE_SIZE,
                // then show a alert msg to user,hide the loading spinner and return from function 
                if (file.size > self.MAX_FILE_SIZE) {
                   
                    component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    this.showMessage('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size,false);
                    return;
                }
            
                self.uploadFile(component, file,recid,helper); 
              
            }
            
            
        }
    }, 
    /**
     * This method to upload files
     * @param: File Data
     */
    uploadFile:function(component, file,recid,helper) {
       // alert('uploadFile--->'+recid);
        var self = this;
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {              
            //component.set("v.IsSpinner",true);
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
          
            self.uploadProcess(component, file, fileContents,recid,helper);
        });
        objFileReader.readAsDataURL(file);
    }, 
    /**
     * This method to upload files
     * @param: File Data
     */
    uploadProcess: function(component, file, fileContents,recid,helper) {
       
        console.log("Uploading files"); 
        var self = this;
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
       
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',recid,helper); 
        
    },
    /**
     * This method to upload files
     * @param: File Data,Safety Event Id
     */
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,recid,helper) {
        //component.set("v.IsSpinner",true); 
        // component.set("v.isSubmit",true);
        // call the apex method 'SaveFile'
        //alert('uploadInChunk--->'+recid);       
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert('getchunk--->'+getchunk);
        var action = component.get("c.uploadFile");
        action.setParams({ 
            parentId: recid,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type, 
            fileId: attachId
        });
        // set call back 
        action.setCallback(this, function(response) { 
            //component.set("v.IsSpinner",true);
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            //alert('attachId--->'+attachId);
            this.fileIds.push(attachId);
            var state = response.getState();
            //alert('state--->'+state);
            if (state === "SUCCESS") {
                //component.set("v.IsSpinner",true);
                this.filesCount++; 
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,recid,helper);
                } else {
                    //this.showMessage('File(s) uploaded successfully',true);
                    /* var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "related"
                    });
                    navEvt.fire();*/               
                    //component.set("v.isAttachDocClick",false);  
                    //helper.getrfirecords(component, event, helper);
                    //component.set("v.isSubmit",true);
                }
                if(this.filesCount == this.fileInputLenght){ 
                    //alert(this.fileIds.length);
                    component.set("v.selectedFillIds",this.fileIds);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                    this.send(component, event, helper);
                    
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") { 
                //component.set("v.Spinner", false); 
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.showMessage("Error message: " + response.getReturnValue(),false);
                    }
                } else {
                    console.log("Unknown error");
                    this.showMessage("Unknown error",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    showMessage : function(message,isSuccess) {
      /*  var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message,
            'duration': '10000',
            'mode': 'dismissible'
        });
        toastEvent.fire(); */
        
         sforce.one.showToast({
                        
                        "title": isSuccess?"Success!":"Error!",
                        
                        "message": message,
                        
                        "type":isSuccess?"success":"error" //supported types are error, success, info, warning
                        
                    });
    },
    
})