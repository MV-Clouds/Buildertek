/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
    	String startUrl = System.currentPageReference().getParameters().get('startURL').escapeHtml4();
    	String displayType = System.currentPageReference().getParameters().get('display').escapeHtml4();
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}