({
    // showToast: function(component, event, helper) {

    //     var params = event.getParam('arguments');
    //     try {
    //         component.set("v.message", params.message);
    //         component.set("v.messageType", params.messageType);

    //         component.set("v.status", params.messageType);

    //         $A.util.removeClass(component.find('toastModel'), 'slds-hide');
    //         $A.util.addClass(component.find('toastModel'), 'slds-show');

    //         var closeTime = component.get("v.autoCloseTime");
    //         var autoClose = component.get("v.autoClose");
    //         var autoCloseErrorWarning = component.get("v.autoCloseErrorWarning");

    //         if (params.messageType == 'success') {
    //             $A.util.addClass(component.find('line_status'), 'status_success');
    //             $A.util.addClass(component.find('border_line'), 'border_line_css');
    //             $A.util.addClass(component.find('toast_bg'), 'success_bg');
    //             $A.util.removeClass(component.find('line_status'), 'status_error');
    //             $A.util.removeClass(component.find('border_line'), 'border_line_e_css');
    //             $A.util.removeClass(component.find('toast_bg'), 'error_bg');
    //         } else {
    //             $A.util.addClass(component.find('line_status'), 'status_error');
    //             $A.util.addClass(component.find('border_line'), 'border_line_e_css');
    //             $A.util.addClass(component.find('toast_bg'), 'error_bg');
    //             $A.util.removeClass(component.find('line_status'), 'status_success');
    //             $A.util.removeClass(component.find('border_line'), 'border_line_css');
    //             $A.util.removeClass(component.find('toast_bg'), 'success_bg');
    //         }

    //         if (autoClose)
    //             if ((autoCloseErrorWarning && params.messageType != 'success') || params.messageType == 'success') {
    //                 setTimeout(function() {
    //                     $A.util.addClass(component.find('toastModel'), 'slds-hide');
    //                     if (params.messageType == 'success') {
    //                         $A.util.removeClass(component.find('line_status'), 'status_success');
    //                         $A.util.removeClass(component.find('border_line'), 'border_line_css');
    //                         $A.util.removeClass(component.find('toast_bg'), 'success_bg');
    //                     } else {
    //                         $A.util.removeClass(component.find('line_status'), 'status_error');
    //                         $A.util.removeClass(component.find('border_line'), 'border_line_e_css');
    //                         $A.util.removeClass(component.find('toast_bg'), 'error_bg');
    //                     }
    //                     component.set("v.message", "");
    //                     component.set("v.messageType", "");
    //                 }, closeTime);
    //             }
    //     } catch (err) {
    //         console.log('OUTPUT err : ', err.message);
    //     }
    // },

    // closeModel: function(component, event, helper) {
    //     $A.util.addClass(component.find('toastModel'), 'slds-hide');
    //     var status = component.get("v.status");
    //     console.log(status);
    //     if (status == 'success') {
    //         $A.util.removeClass(component.find('line_status'), 'status_success');
    //         $A.util.removeClass(component.find('border_line'), 'border_line_css');
    //         $A.util.removeClass(component.find('toast_bg'), 'success_bg');
    //     } else {
    //         $A.util.removeClass(component.find('line_status'), 'status_error');
    //         $A.util.removeClass(component.find('border_line'), 'border_line_e_css');
    //         $A.util.removeClass(component.find('toast_bg'), 'error_bg');
    //     }
    //     component.set("v.messageType", "");
    //     component.set("v.messageType", "");
    // }

    doInit : function(component,event,helper) {
        console.log('in doinit');
        helper.showToastMessage(component);
    }  
})