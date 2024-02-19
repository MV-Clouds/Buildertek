({
    doInit : function(component, event, helper) {
        try {

            helper.ErrorModalChange_Helper(component, event, helper, !component.get("v.isErrorModal"));
            
        } catch (error) {
            console.log('error in doInit : ', error.stack);
            
        }
    },

    isErrorModalChange: function(component, event, helper){
        try {
            console.log('inside isErrorModalChange : ', component.get("v.isErrorModal"));
            var isErrorModal = component.get("v.isErrorModal"); 
            helper.ErrorModalChange_Helper(component, event, helper, isErrorModal);
        } catch (error) {
            console.log('error in isErrorModalChange : ', error.stack);
            
        }
    }
})
