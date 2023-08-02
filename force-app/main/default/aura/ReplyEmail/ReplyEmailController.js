({
   doInit : function(component, event, helper) {
        var objectName = component.get("v.objectAPI");
        helper.getFiles(component, event, helper);
            
       
       
	},
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 
        component.set("v.Spinner", true);
        var getEmail = component.get("v.email");
        var getCcEmail = component.get("v.ccEmail");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.bodytext");
        var emailMessageId = component.get("v.emailMessageId");
        var getrecid = component.get("v.recordId");
        console.log('Id>>>>>'+ getrecid);
        
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
           // alert('Please Enter valid Email Address');
            component.set("v.Spinner", false);
        } else {
            helper.sendHelper(component, event, helper,getEmail, getCcEmail, getSubject, getbody,getrecid,emailMessageId);
        }
    },
 
    // when user click on the close buttton on message popup ,
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.bodytext", null);
    },
    
    doCancel : function(component, event, helper) {
        component.get("v.cancelCallback")();
    }
})