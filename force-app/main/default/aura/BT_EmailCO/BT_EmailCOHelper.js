({
	getTemplate : function(component, event, helper) {
		var dbAction = component.get("c.getTemplates");
        console.log("Folder Name : ",component.get("v.templatefolderName"));
        var folname;
        if (component.get("v.sObjectName") == 'buildertek__Change_Order__c') {
            folname = 'BT CO';
        }
        else if(component.get("v.sObjectName") == 'buildertek__Project__c'){
            folname = 'My Personal Email Templates';
        }
        else if(component.get("v.sObjectName") == 'buildertek__Permit__c'){
            folname = 'BT Permit Email';
        }
        else if(component.get("v.sObjectName") == 'buildertek__RFI__c'){
            folname = 'BT RFI';
        }
        else if(component.get("v.sObjectName") == 'buildertek__Submittal__c'){
            folname = 'BT Submittal';
        }
        else if(component.get("v.sObjectName") == 'buildertek__Quote__c'){
            folname = 'BT Quote';
        }
        else{
            folname = component.get("v.templatefolderName");
        }
        console.log('folname',folname);
        dbAction.setParams({
            folderName: folname,
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue().length > 0) {
                 console.log("Templates : ", response.getReturnValue())
                 var y = response.getReturnValue();
                if(y != undefined){
                    for(var i = 0;i<y.length;i++){
                        if(y[i].Name == 'Invoice3'){
                             console.log("for Check")
                           y.shift();
                        }
                    }
                    } 
                console.log("Modified : ",y); 
                component.set("v.templates",response.getReturnValue());
                var objectAPI = component.get("v.sObjectName");
                if (objectAPI != 'buildertek__Permit__c') {
                    component.set("v.selectedTemplate", response.getReturnValue()[0].Id);
                }
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
                console.log('1stt');
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
            "objectAPIName" : component.get("v.sObjectName")
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
        // debugger;
		var to, cc, toIds = [], ccIds = [], files, fileIds = [], subject, body, recordId, templateId, pdfFileName;
		
        body = '';
        var fileInput = '';
        var contentDocumentIds = [];
        if(component.get("v.selectedfilesFill").length>0) {
            fileInput = component.get("v.selectedfilesFill");
            console.log('fileInput selected;-->' , component.get("v.selectedfilesFill"));
            for (var i = 0; i < fileInput.length; i++) {
                var contentDocumentId = fileInput[i].Id;
                contentDocumentIds.push(contentDocumentId);
            }
        }
        console.log('contentDocumentIds :--->' , contentDocumentIds);

		to = component.get("v.selectedToContact");
		cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");
		files = contentDocumentIds; //selectedFillIds  //selectedFiles
		to.forEach(function(v){ toIds.push(v.Id) });
		cc.forEach(function(v){ ccIds.push(v.Id) }); 
        files.forEach(function(v){ fileIds.push(v) });
		body += component.get("v.templateBody");

        // helper.getProjectName(component, event, helper);


        console.log('fileIds ==>',{fileIds});

		subject = component.get("v.subject"); 
		templateId = component.get("v.selectedTemplate");
        console.log("Selected template id : ",templateId)
		recordId = component.get("v.recordId");
		pdfFileName = component.get("v.pdfFileName");
		var dbAction = component.get("c.SendEmail");
        console.log('pdfFileName' + component.get("v.pdfFileName"));
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
        });
        dbAction.setCallback(this, function (response) {
        //    debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success'){
                    console.log('1stt');
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    if (component.get("v.sObjectName") == 'buildertek__Change_Order__c' || component.get("v.sObjectName") == 'buildertek__Project__c' || component.get("v.sObjectName") == 'buildertek__Permit__c' || component.get("v.sObjectName") == 'buildertek__RFI__c' || component.get("v.sObjectName") == 'buildertek__Submittal__c' || component.get("v.sObjectName") == 'buildertek__Quote__c') {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Email Sent',
                            type : 'success',
                            duration: '5000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                    }
                    // component.get("v.onSuccess")(); // Getting Error popup in Team-k sandbox (Open Issue on 19th Sep 2023 By Brian)
                    $A.get('e.force:refreshView').fire();
                    
                    
                }else{
                    console.log('2stt');
                    console.log(response.getReturnValue());
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    // debugger;
                    // component.get("v.onCancel")();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                      //  message: response.getReturnValue(),
                        message:'Please Add Email in To Address.',
                        type : 'error',
                        duration: '5000',
						mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('3stt');
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                component.get("v.onCancel")();
            }
        });
        $A.enqueueAction(dbAction);
	
	},
    
    
        
	/*MAX_FILE_SIZE: 4500000,
    save : function(component, helper, file) {
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
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
    }*/
    
    
    
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb      
    filesCount : 0,
    fileInputLenght: 0,
    fileIds:[],
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadHelper: function(component, event, recid,helper) {
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fuploader").get("v.files");
        var fileInput = component.get("v.selectedfileslist");
        console.log('fileInput ==> ',fileInput);
        //alert('fileInput--->'+fileInput);
        this.fileInputLenght = fileInput.length; 
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

                console.log(file.size , '=======file.size=========');
                //alert(file);
                // check the selected file size, if select file size greter then MAX_FILE_SIZE,
                // then show a alert msg to user,hide the loading spinner and return from function 
                if (file.size > self.MAX_FILE_SIZE) {
                    component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    this.showMessages('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size,false);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    console.log('4stt');
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
        //alert('uploadFile--->'+recid);
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
            console.log('fileContents',fileContents);
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
        //alert('uploadProcess--->'+recid);
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
        console.log('== uploadInChunk ==');
        //component.set("v.IsSpinner",true); 
       // component.set("v.isSubmit",true);
        // call the apex method 'SaveFile'
        //alert('uploadInChunk--->'+recid);       
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert('getchunk--->'+getchunk);

        console.log('recid ==> '+recid);
        console.log('file.name ==> '+file.name);
        console.log('getchunk ==> '+getchunk);
        console.log('file.type ==> '+file.type);
        console.log('attachId ==> '+attachId);

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
            console.log(' -- setCallback --');
            //component.set("v.IsSpinner",true);
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            console.log('attachId ==> '+attachId);
            //alert('attachId--->'+attachId);
            this.fileIds.push(attachId);
            var state = response.getState();
            console.log('state ==> '+state);
            var responce = response.getReturnValue();
            console.log('Responce -> ',{responce});
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
                console.log(startPosition < endPosition);
                console.log({startPosition});
                console.log({endPosition});

                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,recid,helper);
                    // debugger;
                } else {
                    // if(this.filesCount == this.fileInputLenght){ 
                        //alert(this.fileIds.length);
                        // console.log('this.fileIds ==> '+this.fileIds);
                        // component.set("v.selectedFillIds",this.fileIds);
                        // $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                        // this.send(component, event, helper);
                        // this.filesCount = 0;
                        // this.fileInputLenght = 0;
                        // this.fileIds = [];
                       
                    // }
                }
                if(this.filesCount == this.fileInputLenght){ 
                    //alert(this.fileIds.length);
                    console.log('this.fileIds ==> '+this.fileIds);
                    component.set("v.selectedFillIds",this.fileIds);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                	this.send(component, event, helper);
                    this.filesCount = 0;
                    this.fileInputLenght = 0;
                    this.fileIds = [];
                   
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
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message,
            'duration': '10000',
            'mode': 'dismissible'
        });
        toastEvent.fire();
    },
    showMessages : function(message,isSuccess) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message,
            'duration': '3000',
            'mode': 'dismissible'
        });
        toastEvent.fire();
    },
    getProjectName:function(component, event, helper) {
        var action = component.get('c.getProNameAndAutoNum');
        console.log('get  proj name heloper');
        var objectName = component.get("v.objectAPI");
        var objApiName ;
        if (objectName) {
            objApiName = component.get("v.objectAPI");
        }
        else{
            objApiName = component.get("v.sObjectName");
        }
        action.setParams({
            recordId : component.get("v.recordId"),
            objectAPIName: objApiName,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result= response.getReturnValue();
            console.log({result});
            if (state === "SUCCESS") {
				component.set("v.pdfFileName", result);

            }
        });
        $A.enqueueAction(action);
    },
    getBody:function(component, event, helper) {
        var action = component.get('c.getBodyFromQuote');
        var objectName = component.get("v.sObjectName");
        action.setParams({
            recordId : component.get("v.recordId"),
            objectAPIName: objectName,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state---->',state);
            var result= response.getReturnValue();
            console.log({result});
            if (state === "SUCCESS") {
                if (result != null) {
                    component.set("v.templateBody", result);
                }
				else {
                    component.set("v.templateBody", '');
                }

            }
        });
        $A.enqueueAction(action);
    },

    getFileList: function(component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRelatedFiles");

        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var files = response.getReturnValue();
                console.log('FILES :->', files);

                if (files && files.length > 0) {
                    component.set("v.showModel",true);
                    files = this.convertFileSizes(files);
                    var selectedFillIds = component.get("v.selectedFillIds");
                    
                    files.forEach(function(file) {
                        file.isChecked = selectedFillIds.includes(file.ContentDocumentId);
                    });
                    
                    component.set("v.relatedFiles", files);
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                } else {
                    component.set("v.showModel",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'There are no files related to the record.',
                        type : 'error',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'something went wrong.',
                        type : 'error',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }
        });

        $A.enqueueAction(action);
    },

    convertFileSizes: function(files) {
        for (var i = 0; i < files.length; i++) {
            var fileSize = files[i].ContentSize;
            files[i].FormattedSize = this.formatFileSize(fileSize);
        }
        return files;
    },

    formatFileSize: function(sizeInBytes) {
        if (isNaN(sizeInBytes) || sizeInBytes <= 0) {
            return 'N/A';
        }

        var units = ['B', 'KB', 'MB', 'GB', 'TB'];
        var i = parseInt(Math.floor(Math.log(sizeInBytes) / Math.log(1024)));
        return Math.round((sizeInBytes / Math.pow(1024, i)) * 100) / 100 + ' ' + units[i];
    },
    saveButton: function(component, event, helper) {
        // Get the selected files and map data
        var selectedFiles = component.get("v.selectedFile") || [];
        var mapData = component.get("v.selectedfilesFill") || [];

        // Process the selected files and update mapData
        var files = '';
        selectedFiles.forEach(function(selectedFile) {
            var fileName = selectedFile.Title;
            var fileId = selectedFile.ContentDocumentId;

            // Check if the fileId is already in the mapData
            var fileInMap = mapData.some(function(mapFile) {
                return mapFile.Id === fileId;
            });

            // If the fileId is not in the mapData, add it
            if (!fileInMap) {
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
                mapData.push(obj);

                if (files === '') {
                    files = fileName;
                } else {
                    files += ',' + fileName;
                }
            }
        });

        component.set("v.fileName", files);
        component.set("v.selectedfilesFill", mapData);

        var fileIds = selectedFiles.map(function(v) {
            return v.ContentDocumentId;
        });

        component.set("v.selectedFillIds", fileIds);

        console.log(component.get("v.fileName"));
        console.log('fileIds :->', fileIds);
        console.log('updated mapdata :-->', component.get("v.selectedfilesFill"));
        component.set("v.showModel",false);
    },
    onChecboxChanges: function(component, event, helper) {
        var file = event.getSource().get("v.name");
        var selectedFiles2 = component.get("v.selectedFiles2") || [];

        selectedFiles2.push(file);
        component.set("v.selectedFiles2", selectedFiles2);
        console.log('selectedFiles2:', selectedFiles2);
        var selectedFiles = component.get("v.selectedFile") || [];

        // Check if the file is already in the selectedFiles array
        var fileIndex = selectedFiles.findIndex(function(selectedFile) {
            return selectedFile.Id === file.Id;
        });

        if (event.getSource().get("v.checked")) {
            // If the file is not already in the array, add it
            if (fileIndex === -1 && !component.get("v.selectedFillIds").includes(file.ContentDocumentId)) {
                selectedFiles.push(file);
            }
        } else {
            // If the file is in the array, remove it
            if (fileIndex !== -1) {
                selectedFiles.splice(fileIndex, 1);
            }
        }

        component.set("v.selectedFile", selectedFiles);
        console.log('selectedFiles :->', selectedFiles);
    },
    standardFileUploderFileChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var fileId = '';
    
        var existingMapData = component.get('v.selectedfilesFill');
        var newFilesList = event.getParam('files');
        console.log('newFilesList', newFilesList);

        var resultMapArray = [];

        newFilesList.forEach(function(newMap) {
            var resultMap = {
                "Id": newMap.contentVersionId,
                "ContentDocumentId": newMap.documentId,
                "Title": newMap.name.substring(0, newMap.name.lastIndexOf(".")), 
                "ContentSize":  0, 
                "ContentBodyId": newMap.contentBodyId,
                "FileType": newMap.mimeType.split("/")[1],
                "VersionData": '0',
                "FormattedSize": '0KB',
                "isChecked": true 
            };

            resultMapArray.push(resultMap);
        });
        var selected = component.get("v.selectedFile") || [];
        selected.push(...resultMapArray);
        component.set("v.selectedFile", selected);
        console.log('resultMapArray', selected);

        var fileCount = newFilesList.length;
        var files = '';
        var mapData = existingMapData || [];
    
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = newFilesList[i]['name'].substring(0, newFilesList[i]['name'].lastIndexOf("."));
                fileId = newFilesList[i].documentId;
    
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
    
                mapData.push(obj);
            }
            files = mapData.map(function(file) {
                return file.Name;
            }).join(', ');
        } else {
            files = fileName;
        }
    
        component.set('v.selectedfilesFill', mapData);
        var fileIds = component.get("v.selectedFillIds") || [];
        mapData.forEach(function(data) {
            // Check if data.Id is not in fileIds before pushing
            if (!fileIds.includes(data.Id)) {
                fileIds.push(data.Id);
            }
        });
        component.set("v.selectedFillIds", fileIds);
        console.log('fileIds 2:->', fileIds);
        console.log('mapData 2 :-->',component.get('v.selectedfilesFill'));
    },
    clearPillValues :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");    
        var AllPillsList = component.get("v.selectedfilesFill") || [];    
        var selectedFillIds = component.get("v.selectedFillIds") || [];
    
        // Use Array.findIndex to find the index of the selected pill in the list
        var pillIndex = AllPillsList.findIndex(function(pill) {
            return pill.Id === selectedPillId;
        });
    
        if (pillIndex !== -1) {
            // Add the Id to selectedFillIds if not already present
            if (!selectedFillIds.includes(selectedPillId)) {
                selectedFillIds.push(selectedPillId);
            }
    
            // Remove the pill from selected files
            AllPillsList.splice(pillIndex, 1);
    
            // Remove the Id from selectedFillIds
            var fillIdIndex = selectedFillIds.indexOf(selectedPillId);
            if (fillIdIndex !== -1) {
                selectedFillIds.splice(fillIdIndex, 1);
            }
    
            // Update the selected files and selectedFillIds attributes
            component.set("v.selectedfilesFill", AllPillsList);
            component.set("v.selectedFillIds", selectedFillIds);
    
            console.log('Pill removed. Updated selected files:', AllPillsList);
            console.log('Updated selectedFillIds:', selectedFillIds);
            var selectedFiles = component.get("v.selectedFile") || [];
            var selectedFillIdsSet = new Set(selectedFillIds);

            // Filter selectedFiles based on matching selectedFillIds
            var filteredSelectedFiles = selectedFiles.filter(function(file) {
                return selectedFillIdsSet.has(file.ContentDocumentId);
                });

            // Update the attribute with the filtered list
            component.set("v.selectedFile", filteredSelectedFiles);
        } else {
            console.log('Pill not found in the list.');
        }
        
    },

    
        
    
})