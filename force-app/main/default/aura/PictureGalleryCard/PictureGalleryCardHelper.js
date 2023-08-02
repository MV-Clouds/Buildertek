({
	getImages : function(component) {
		var action = component.get('c.getImages');
        action.setParams({ listingId: component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var slides = response.getReturnValue();
                slides = slides.map(function(url) {
                    return url.replace('(', '%28').replace(')', '%29');
                });
                console.log(slides);
                component.set("v.slides", slides);
            } else if (state === 'ERROR') {
                var errors = response.getErrors();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
	}
})