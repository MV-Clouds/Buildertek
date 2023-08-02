({
    doInit : function(component, event, helper) {
        console.log("Hello")
        console.log(component.get("v.toEmail"));
        var action = component.get("c.getPreQualStage");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result){
                    debugger;
                    if(!result.ismultiPreQual){
                        console.log('$$$$$$$$$$$$$$$$$$$$$'+result);
                        if(result.QualificationStage == "Not Qualified" || result.QualificationStage == null || result.QualificationStage == "Email Sent"){
                            component.set("v.isStageValid",true);
                        }  
                        else if(result.QualificationStage == "Fully Executed"){
                            component.set("v.isStageValid",false);
                            component.set("v.message",'This Vendor has already been Pre Qualified. Contact your system administrator to assist.');
                            
                        }
                        else{
                            component.set("v.isStageValid",false);
                            component.set("v.message",'This Vendor has already '+result.QualificationStage+'. Contact your system administrator to assist.');
                        }
                    }else{
                        component.set("v.isStageValid",true);
                        /*console.log('$$$$$$$$$$$$$$$$$$$$$'+result);
                        if(result.QualificationStage == "Not Qualified" || result.QualificationStage == null || result.QualificationStage == "Email Sent"){
                            component.set("v.isStageValid",true);
                        }  
                        else if(result.QualificationStage == "Fully Executed"){
                            component.set("v.isStageValid",false);
                            component.set("v.message",'This Vendor has already been Pre Qualified. Contact your system administrator to assist.');
                            
                        }
                        else{
                           component.set("v.isStageValid",false);
                           component.set("v.message",'This Vendor has already '+result.QualificationStage+'. Contact your system administrator to assist.');
                       }*/
                    }
                }
                
                
            }
             console.log("Hello1")
        console.log(component.get("v.toEmail"));
        });
        $A.enqueueAction(action);
        
        helper.getAllTemplates(component, event, helper);
        helper.getContacts(component, event, helper);
        
    },
    
    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    sendEmail : function(component, event, helper) {
        var elmnt = document.getElementById("pageTop");
        elmnt.scrollIntoView();
        var emailForm = component.find("emailForm");
        var addemailval = emailForm.get("v.validity").valid;
        
        component.set("v.Spinner",true);
        var filedata = component.get("v.fileData2");
        
        var toIds = [];
        var ccIds = [];
        var emailIds = [];
        var EmailValue='';
        debugger;
        var to = component.get("v.selectedToContact");
        if(to != undefined){
            to.forEach(function (v) {
                toIds.push(v.Id)
            });
        }
        
        
        /* if(addemailval.valid == false){
            component.set("v.isNotValid",true);
        }*/
        //alert(toIds[0]);
        
        
        // var cc = component.get("v.selectedCcContact");
        // 
        
        var emailId = component.get("v.toEmail");
        var selectedTemplate = component.get("v.selectedTemplate");
        var EmailValue = '';
        if(emailId != undefined && emailId != ''){
            emailIds.push(emailId);  
        }
        if(toIds.length > 1 || (toIds.length == 1 && emailId != undefined && emailId != null && emailId != '')){
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "warning!",
                "type": "warning",
                "message": "Please select either Primary Contact or Additional Email not both."
            });
            toastEvent.fire();
            
        }
        else if(addemailval == false){
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Invalid additional email."
            });
            toastEvent.fire();
        }
        
            else if(toIds.length != 0 || emailIds.length != 0){
                var action = component.get("c.getContact");
                action.setParams({
                    "conId" : toIds[0],
                });
                action.setCallback(this, function(a){
                    if (a.getState() === "SUCCESS") {
                        if( (a.getReturnValue().Email != null &&  a.getReturnValue().Email != undefined &&  a.getReturnValue().Email !='') || (emailIds.length != 0)){
                            //if(selectedTemplate != null && selectedTemplate != ''){
                            var action = component.get("c.sendEmailToVendor");
                            
                            action.setParams({
                                recordId : component.get("v.recordId"),
                                emailTemplateId : component.get("v.selectedTemplate"),
                                to : toIds,
                                cc : ccIds,
                                emailIds: emailIds,
                                filedata: JSON.stringify(component.get("v.fileData2"))
                            });
                            action.setCallback(this, function(response){
                                debugger;
                                if(response.getState() === 'SUCCESS'){
                                    component.set("v.Spinner",false);
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Success!",
                                        "type": "success",
                                        "message": "Email sent successfully."
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                    $A.get('e.force:refreshView').fire();
                                }else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : '',
                                        message:'File size limit exceeded',
                                        duration:' 2000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    component.set("v.Spinner",false);
                                    
                                }  
                            });
                            $A.enqueueAction(action);
                            /*}
                        else{
                            component.set("v.Spinner", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": 'error',
                                "message": "Please select an Email Template."
                            });
                            toastEvent.fire();    
                        }*/
                        }else{
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "",
                                "type": 'error',
                                "message": "The Primary Contact Email cannot be null."
                            });
                            toastEvent.fire();
                            component.set("v.Spinner",false);
                        }
                        
                    }
                });
            $A.enqueueAction(action);             
        }
        
            else {
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "type": 'error',
                    "message": "Please populate the To Address: field in order to send an Email."
                });
                toastEvent.fire();
            }
        
    },
    
    onEmailChange: function (component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (emailId.charAt(emailId.length - 1) == ';') {
            emailId = emailId.replace(';', '');
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId)) {
                    emailIds.push(emailId);
                }
            }
        }
        if(emailIds.length > 0){
            component.set('v.emailIds', emailIds);  
        }
        
    },
    handleEmailRemove: function (component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },
    
    
    preview : function (component, event, helper) {
        component.set("v.showPreview", true);
        sessionStorage.setItem('Preview', 'Yes');
        /*jQuery("document").ready(function(){
            var element = $("#html-content-holder");
		
			// Global variable
			var getCanvas;
            
            html2canvas(element, {
                onrendered: function(canvas) {
                    $("#previewImage").append(canvas);
                    getCanvas = canvas;
                }
            });
        }); */
    },
    handleFilesChange2 : function(component, event, helper) {
        var fileName = "No File Selected..";  
        var fileCount = event.target.files;
        var files='';
        var names =[];
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            names.push(component.get("v.fileData2")[i]["fileName"])
        }
        for (var i = 0; i < fileCount.length; i++) 
        {
            names.push(fileCount[i]["name"])
        }
        
        component.get("v.fileData2")
        component.set("v.FileNameList",names);
        var filedata = component.get("v.FileLabelList");
        
        
        
        if (fileCount.length > 0) {
            component.set("v.uploadFile", true);
            for (var i = 0; i < fileCount.length; i++) 
            {
                fileName = fileCount[i]["name"];
                if(files == ''){
                    files = fileName;
                }else{
                    files = files+','+fileName;
                }
                helper.readFiles2(component, event, helper, fileCount[i]);
                
            }
        }
        component.set("v.fileName2", files);	
        
    },
    removeRow : function(component, event, helper) {
        var index = Number(event.target.title);
        debugger;
        var namelist = component.get("v.FileNameList");
        var deletingFile = namelist[index];
        namelist.splice(index,1);
        component.set("v.FileNameList",namelist);
        
        
        
        
        var oldFilelist = component.get("v.fileData2");
        var deleteIndex;
        for(var i=0;i<oldFilelist.length;i++){
            if(oldFilelist[i]){
                var f = JSON.parse(JSON.stringify(oldFilelist[i]));
                if(f['fileName'] == deletingFile){
                    deleteIndex = i;
                    break;
                }
            }
        }
        if(deleteIndex > -1){
            oldFilelist.splice(deleteIndex,1);
        }
        
        component.set("v.fileData2",oldFilelist);
        console.log(JSON.stringify(component.get("v.fileData2")));
        
    },
    handleCancel : function(component, event, helper){
        component.set("v.showConfirmDialog",false);
        $A.get("e.force:closeQuickAction").fire()
    }
    
})