({
    doInit: function(component, event, helper) {
        var action1 = component.get("c.getrfqfiles");
            action1.setParams({
                recordId: component.get("v.recordId"),
            });
            action1.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.rfqfiles",result);
                    var fileslist = component.get("v.rfqfiles");
                   /* if(fileslist.length > 0){
                        component.set("v.Isrfqfiles",true);
                    }else{
                        component.set("v.Isnorfqfiles",true);
                    }*/
                    //helper.getfiles(component, event, helper);
                } 
            });
        $A.enqueueAction(action1);
        var action3 = component.get("c.getContentfiles");
            action3.setParams({
                arecordId: component.get("v.recordId"),
            });
            action3.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.rfqstandardfiles",result);
                    var fileslist = component.get("v.rfqstandardfiles");
                   /* if(fileslist.length > 0){
                        component.set("v.Isrfqfiles",true);
                    }*/
                } 
                 helper.getfiles(component, event, helper);
            });
        $A.enqueueAction(action3);
         
        var action2 = component.get("c.getContentDocs");
            action2.setParams({
                arecordId: component.get("v.recordId"),
            });
            action2.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.files",result);
                } 
            });
        $A.enqueueAction(action2);
        var action4 = component.get("c.getvendorContentfiles");
            action4.setParams({
                arecordId: component.get("v.recordId"),
            });
            action4.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.vendorstandardfiles",result);
                }
                helper.getvendorfiles(component, event, helper);
            });
        $A.enqueueAction(action4);
    },
    getSelectedpreviewFile : function(component, event, helper) {
        var rec_id = event.currentTarget.getAttribute("data-Id");  
      //  alert('rec_id'+rec_id);
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });
    },
    
})