({
    doInit : function(component, event, helper) {
       //Site Url Get 
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
        
        
      	var action =component.get("c.getAttachmentData");
             action.setParams({
                 "recordId" : component.get("v.recordId")
            });
             action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     component.set("v.imgUrl","/servlet/servlet.FileDownload?file="+result);
                  }
            });
            $A.enqueueAction(action); 
         var action1 =component.get("c.getCheckListfooter");
         action1.setParams({
                
            });
           action1.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                   
                     component.set("v.Text",result);
                  }
            });
            $A.enqueueAction(action1);
    },  
        
	doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files") != undefined) {
            if(component.find("fileId").get("v.files").length > 0){
                helper.uploadHelper(component, event);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Select a Valid File.",
                    "type":"error"
                });
                toastEvent.fire();
            }
            
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please Select a Valid File.",
                "type":"error"
            });
            toastEvent.fire();
        }
        var action =component.get("c.getAttachmentData");
             action.setParams({
                 "recordId" : component.get("v.recordId")
            });
             action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     component.set("v.imgUrl",component.get("v.siteUrl")+"servlet/servlet.FileDownload?file="+result);
                     //$A.get('e.force:refreshView').fire();
                  }
            });
            $A.enqueueAction(action); 
               
    },
 
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        
    },
    updateCheckList :  function(component, event, helper) {
        var action =component.get("c.updateCheckListData");
         action.setParams({
             "siteURL" : component.get("v.Url"),
               "Text" : component.get("v.Text")
            });
           action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Success!",
                    "message": "Checklist setting updated successfully",
                    "type":"Success"
            });
            toastEvent.fire();
                    
                  }
            });
            $A.enqueueAction(action);
        /* var action1 =component.get("c.updateCheckListDataText");
         action.setParams({
             "Text" : component.get("v.Text")
         
            });
           action1.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Success!",
                    "message": "Checklist setting updated successfully",
                    "type":"Success"
            });
            toastEvent.fire();
                    
                  }
            });
            $A.enqueueAction(action1);*/
    }
})