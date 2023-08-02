({
    doInit : function(component, event, helper) {
        //helper.getServiceAppointmentDetail(component, event, helper);
    },
    navigateToDetailPage : function(component, event, helper) {
        parent.postMessage('closeLightbox','*');    
    },
    handleSuccess: function(component, event, helper) {
        helper.showError(component,'Success','confirm',"Date is updated successfully");
        var delayInMilliseconds = 2000; //1 second
        
        setTimeout(function() {
            parent.postMessage('closeLightbox','*'); 
        }, delayInMilliseconds);
    }
})