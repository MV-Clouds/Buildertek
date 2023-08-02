({
    handleChange : function(component, event, helper) {
        var radioGrpValue = component.get("v.value");
        alert(radioGrpValue);
        $A.get("e.force:closeQuickAction").fire();
       // component.set("v.SendMailBox",true);
//component.set("v.radiobuttons",false);
         
        
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Send payment validation!",
            "message": "Are you sure you want to resend Registration Email?",
            closeCallback: function() {
               component.set("v.radiobuttons",true);
            }
        });   
    },
    
    Cancel:function(component, event, helper) {
     component.set("v.SendMailBox",false);
       component.set("v.radiobuttons",true);
}
})