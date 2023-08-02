({
	 doInit : function(component, event, helper) {
         var action1 = component.get("c.getRQToAccount");
        action1.setParams({
            recordId: component.get("v.recordId"),
        });
        action1.setCallback(this, function (response) {
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result == 'Awarded' || result == 'Accepted' || result == 'Quote Submitted' || result == 'Rejected'){
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can't upload files, this RFQ is already "+result+".",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire();
                    component.set("v.isAttachDocClick",false);
                    
                }else{
                    component.set("v.isAttachDocClick",true);   
                   // 
                }
            }
        });
        $A.enqueueAction(action1);
         
         
         

       /*$A.get("e.force:closeQuickAction").fire();
        // helper.uploadfileforrfq(component, event, helper);
        var action1 = component.get("c.getRQToAccount");
        action1.setParams({
            recordId: component.get("v.recordId"),
        });
        action1.setCallback(this, function (response) {
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result == "Quote Submitted"){
                   // $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can't upload files, this RFQ is already Submitted.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire();
                }else if(result == "Email Sent"){
                    helper.uploadfileforrfq(component, event, helper);
                }else{
                     $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can't upload files, this RFQ is already Submitted.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire();
                }
            }
        });
        $A.enqueueAction(action1);*/
    },

    
    doCancel : function (component, event, helper) {
        component.set("v.selectedfilesFill",[]);
        component.set("v.isAttachDocClick",false);  
        $A.get("e.force:closeQuickAction").fire();
    },  
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';                
        //alert(event.getSource().get("v.files").length);
        if (event.getSource().get("v.files").length > 0) {
            // fileName = event.getSource().get("v.files")[0]['name'];
        }
        
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
        //alert(typeof event.getSource().get("v.files"));        
        //component.set("v.fileName", fileName);
      }, 
    
    addFiles : function (component, event, helper) {
        var fills = component.get("v.selectedfilesFill");                    
        if(fills.length>0) {
            
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            component.set("v.isAttachDocClick",false); 
            var recid = component.get("v.recordId");
            //alert(recid);
            helper.uploadHelper(component, event, recid,helper);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please Select files to add',
                type : 'error',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();  
        }
    },    
                    
    
    
    
    
    
    
    
    
})