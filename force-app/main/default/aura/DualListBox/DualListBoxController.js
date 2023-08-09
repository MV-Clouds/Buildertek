({
	doInit : function(component, event, helper) {
      //Site Url Get 
     // component.set("v.isSuccess", false);
         function getCookie(cname) {
             var name = cname + "=";
             var ca = document.cookie.split(';');
             
             for(var i=0; i<ca.length; i++) {
                 var c = ca[i];
                 while (c.charAt(0)==' ') c = c.substring(1);
                 if (c.indexOf(name) == 0) {
                     return c.substring(name.length, c.length);
                 }
             }
             return "";
         }
         //clear Cookies function
         function unsetCookie(cname) {
             document.cookie = cname+ '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
         }
         
         var siteUrl=getCookie('siteUrl');  
         //alert(siteUrl);
         if(siteUrl !='' && siteUrl != undefined){
             component.set("v.siteUrl",siteUrl);
         }
         else{
             //alert("else");
             // alert(siteUrl);
             component.set("v.siteUrl",'/');
         }
         //clear cookie
         unsetCookie('siteUrl');
 		//alert(component.get("v.siteUrl"));
 		
        
        var action8 =component.get("c.getPreQualSettings");
         action8.setParams({
                
            });
           action8.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     component.set("v.isMultiPrequal",result.isMultiPreQual);
                      component.set("v.isEnableBox",result.isEnableBox);
                  }
            });
            $A.enqueueAction(action8);
        
         var action =component.get("c.getCheckListData");
         action.setParams({
                
            });
           action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     component.set("v.Url",result);
                  }
            });
            $A.enqueueAction(action);
        
        
        
        
        
        
      	var action1 =component.get("c.getAttachmentData");
             action1.setParams({
                 
            });
             action1.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                   
                     component.set("v.imgUrl","/servlet/servlet.FileDownload?file="+result);
                  }
            });
            $A.enqueueAction(action1);
        
         var action2 =component.get("c.getCheckListfooter");
         action2.setParams({
                
            });
           action2.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                    
                     component.set("v.Text",result);
                  }
            });
            $A.enqueueAction(action2);
        
		var action = component.get("c.getSelectedTemplates");	
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	var result = response.getReturnValue();
                if(result != null){
                    if(result.includes(',')){
                    	var options = result.split(',');    
                        if(options){
                            debugger;
                            for(let i in options){
                                  if(options[i] == 'buildertek__Pre_QualProcess_VF'){
                                    options[i] = 'Pre_QualProcess_VF';
                                }
                                else if(options[i] == 'buildertek__Standard_PreQual_VF'){
                                     options[i] = 'Standard_PreQual_VF';
                                }
                            }
                        }
                        component.set("v.selectedTemplatesList", options);
                    }else{
                        var options = [];
                        options.push(result);
                        debugger;
                         for(let i in options){
                                 if(options[i] == 'buildertek__Pre_QualProcess_VF'){
                                    options[i] = 'Pre_QualProcess_VF';
                                }
                              else if(options[i] == 'buildertek__Standard_PreQual_VF'){
                                     options[i] = 'Standard_PreQual_VF';
                                }
                            }
                        component.set("v.selectedTemplatesList", options);
                    }
                	
                }
            }    
        });
        $A.enqueueAction(action);
	},
    
    editList : function(component, event, helper) {
        var action = component.get("c.getTemplates");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	var result = response.getReturnValue();
                var opts = [];
                for(var i=0;i<result.length;i++){
                	opts.push(
                        { label: result[i].Name, value: result[i].Name }
                    );	    
                }
                component.set("v.options", opts);
                component.set("v.isEdit", true);
            }    
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
    	component.set("v.isEdit", false);    
    },
    
    handleChange : function(component, event, helper) {
    	var selectedOptionValue = event.getParam("value");
        component.set("v.selectedValue", selectedOptionValue);
    },
    
    save : function(component, event, helper) {
        var selectedTemplates = component.get("v.selectedValue");
        console.log('@@@@@@@@2'+component.get("v.selectedValue"));
        var selTemplate = '';
        if(selectedTemplates != undefined){
        for(var i=0;i<selectedTemplates.length;i++){
        	selTemplate += selectedTemplates[i]+',';	    
        }
        }
        selTemplate = selTemplate.substring(0, selTemplate.length - 1);
    	var action = component.get("c.saveNode");   
        action.setParams({
            selectedTemplate : selTemplate
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	component.set("v.isEdit", false);
                $A.enqueueAction(component.get("c.doInit"));
            }    
        });
        $A.enqueueAction(action);
    },
    
	doSave: function(component, event, helper) {
        //component.set("v.isText",true);
        if (component.find("fileId").get("v.files") != undefined) {
            if(component.find("fileId").get("v.files").length > 0){
                helper.uploadHelper(component, event);
            }
            else{
                
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    component.set("v.message", 'Please Select a Valid File.');
                    component.set("v.isError", true);
                    component.set("v.isSuccess", false);
                    //component.set("v.Spinner", false);
                    window.setTimeout(
                        $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 3000
            );
                
                
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Select a Valid File.",
                    "type":"error"
                });
                toastEvent.fire();*/
            }
            
        } else {
            
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    component.set("v.message", 'Please Select a Valid File.');
                    component.set("v.isError", true);
                    component.set("v.isSuccess", false);
                    //component.set("v.Spinner", false);
                    window.setTimeout(
                        $A.getCallback(function() {
                    component.set("v.isError", false);
                }), 3000
            );
                
            
           /* var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please Select a Valid File.",
                "type":"error"
            });
            toastEvent.fire();*/
        }
        var action =component.get("c.getAttachmentData");
            
             action.setCallback(this,function(a){
                 //alert(a.getState());
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     //alert('@@@@@@@@@@@@@'+result);
                     component.set("v.imgUrl",component.get("v.siteUrl")+"servlet/servlet.FileDownload?file="+result);
                    component.sampleMethod();
                  }
            });
            $A.enqueueAction(action); 
               
    },
     handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.isText",true);
        }
        component.set("v.fileName", fileName);
        
    },
    selectChange : function(component, event, helper) {
       var checkCmp = component.find("chkbox");
        //alert(checkCmp.get("v.value"));
        component.set("v.isMultiPrequal" , checkCmp.get("v.value"));
           var action8 =component.get("c.handlePreQualSettings");
         action8.setParams({
             isMulti : checkCmp.get("v.value")
            });
           action8.setCallback(this,function(a){
               //alert(a.getState());
                if(a.getState()==='SUCCESS'){
                    //var result = a.getReturnValue();
                     //component.set("v.isMultiPrequal",result);
                  }
            });
            $A.enqueueAction(action8);
        //alert('llukyjth'+component.get("v.isMultiPrequal"));
    },
    
    checkBoxChange : function(component, event, helper) {
        
        var check = event.getSource().get("v.checked")
      /*  if(check){
            event.getSource().set("v.label","Save in Box Files")
        }
        else{
            event.getSource().set("v.label","Save in Files")
        } */
        
        var action = component.get("c.updateEnableBox");
        action.setParams({ enableBox : check });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            component.set("v.isEnableBox",response.getReturnValue())
                
                
            }
            else if (state === "INCOMPLETE") {
                console.log("State is Incomplete");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    }
   
})