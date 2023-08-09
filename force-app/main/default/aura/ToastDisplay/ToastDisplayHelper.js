({
    showToastMessage : function(component) {
        var vfpath = "https://" + component.get("v.vfPath");
        console.log({vfpath});
        window.addEventListener("message", function(event) {
            console.log('event in toast helper');
            console.log({event});
            if ( (event.data.type) && (event.data.type=='EventFromVF') )
                debugger;
                if (event.origin !== vfpath) {
                    return;
                }
            var toastEvent = $A.get('e.force:showToast');
            console.log('toastEvent in new');
            console.log({toastEvent});
            toastEvent.setParams({
                type: 'success',
                message: 'test message',
                mode: 'sticky'
            });
            toastEvent.fire();
            console.log(event.data);
        }, false);
    }
})