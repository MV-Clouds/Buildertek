({
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
    
 
	
    sendHelper: function(component,event,helper, getEmail, getCcEmail, getSubject, getbody,getrecid,emailMessageId) {
        
        var  cc,  ccIds = [], files, fileIds = [] ;
        cc = component.get("v.selectedCcContact");
		files = component.get("v.selectedFiles");
		cc.forEach(function(v){ ccIds.push(v.Id) });
		files.forEach(function(v){ fileIds.push(v.Id) });
        console.log('helperrecid'+getrecid);
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method 
        action.setParams({
            'mMail': getEmail,
            'ccEmail': ccIds,
            'mSubject': getSubject,
            'mbody': getbody,
            'recid':getrecid,
            'msgId':emailMessageId,
            'files': fileIds
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.enqueueAction(component.get("v.saveCallback"));
                var result = response.getReturnValue();
                if(result.isSuccess === true){
                    component.set("v.Spinner", false);
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": 'Email sent successfully',
                        closeCallback: function() {
                            component.get("v.cancelCallback")();
                        }
                    });     
                }else{
            	    component.set("v.Spinner", false);
            	    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.strMessage,
                        closeCallback: function() {
                        }
                    });   
            	} 
                  
            }
            
        });
        $A.enqueueAction(action);
    }
})