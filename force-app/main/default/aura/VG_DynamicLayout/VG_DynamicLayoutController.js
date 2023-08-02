({
	doInit : function(component, event, helper) {
		// the function that reads the url parameters for preview mode only
        if (component.get('v.PreviewMode')) {
            
            var getUrlParameter = function getUrlParameter(sParam) {
                var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('?'),
                    sParameterName,
                    i;

                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('=');

                    if (sParameterName[0] === sParam) {
                        return sParameterName[1] === undefined ? true : sParameterName[1];
                    }
                }
            };
            component.set('v.SiteId', getUrlParameter('Id'));
        	component.set('v.siteTypeLoaded', true);
        }
    }
})