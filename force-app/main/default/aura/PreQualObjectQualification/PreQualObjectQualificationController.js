({      
      
    doInit : function(component, event, helper) {  
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPreQualStage");
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            
            if(response.getState() === 'SUCCESS'){
                component.set("v.PreviousStage",response.getReturnValue());
                if(response.getReturnValue() == "Email Received" || response.getReturnValue() == "Not Qualified" || response.getReturnValue() == null){
                    component.set("v.isStageValid",true);
                    component.set("v.message","Do you want to change the Qualification Stage to Qualified?");
                }else if(response.getReturnValue() == "Not Qualified" || response.getReturnValue() == "Email Sent"){
                    component.set("v.isStageValid",false);
                    component.set("v.message","This Pre Qual has not been Qualified.  Please set the Qualification Stage to Qualified.");
                }
                else{
                    component.set("v.isStageValid",false);
                    component.set("v.message","This Vendor has already been Qualified.");
                }
            }
         });
         $A.enqueueAction(action);
    },
        
        
        
   handleSubmit : function(component, event, helper) { 
       component.set("v.Spinner",true);
       console.log('Length : ',component.get("v.uploadFileList"));
       if(component.get("v.uploadFileList").length > 0){
           var fileUploadAction = component.get("c.uploadFiles");
           $A.enqueueAction(fileUploadAction);
       }else{
           var action = component.get("c.ChangeAccountStatus");
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
           
         action.setCallback(this, function(response){
             console.log(response.getState());

             console.log(response.getReturnValue());
              debugger;
            if(response.getState() === 'SUCCESS'){
                var action = component.get("c.sendEmail");
                action.setParams({
                    recordId : component.get("v.recordId"),
                    filedata: JSON.stringify(component.get("v.fileData2"))
                });
                action.setCallback(this, function(response){
                    
                    if(response.getState() === 'SUCCESS'){
                        $A.get("e.force:closeQuickAction").fire() 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Qualification Stage has been changed to Qualified."  
                        });
                        toastEvent.fire();
                        window.location.reload()
                    } else{
                        debugger;
                        var action = component.get("c.ChangeAccountStatustoOld");
                        action.setParams({
                            "recordId" : component.get("v.recordId"),
                            "oldstatus": component.get("v.PreviousStage")
                        });
                        action.setCallback(this, function(response){
                            
                        });
                        $A.enqueueAction(action);
                        
                        
                        component.set("v.Spinner",false);
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
                         $A.get("e.force:closeQuickAction").fire() 

                    } 
                });
              $A.enqueueAction(action);
                
                 
               /*$A.get("e.force:closeQuickAction").fire() 
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Qualification Stage has been changed to Qualified."  
                });
                toastEvent.fire();
                window.location.reload()*/

            } else{
                debugger;
                  $A.get("e.force:closeQuickAction").fire() 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "message": "Please send MSA Email."  
                });
                toastEvent.fire();
            } 
        });
        $A.enqueueAction(action);
       }
       
       
       
        
    }  ,
    
    handleCancel : function(component, event, helper){
        component.set("v.showConfirmDialog",false);
         $A.get("e.force:closeQuickAction").fire()
    } ,
            
    /* File upload code start */
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
        var index = event.target.title;
  
        var namelist = component.get("v.FileNameList");
        namelist.splice(index,1);
        component.set("v.FileNameList",namelist);
     
        var oldFilelist = component.get("v.fileData2");
        oldFilelist.splice(index,1);
        component.set("v.fileData2",oldFilelist);
        console.log(JSON.stringify(component.get("v.fileData2")));
        
    },
   /* File upload Code end */
      
})