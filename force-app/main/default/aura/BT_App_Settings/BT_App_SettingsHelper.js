({
	showMenuList : function(component, event, helper) {
		//component.set("v.Spinner",true);
		var options = [];
        var action = component.get("c.getMenuLists");
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            options.push(result);
	            component.set("v.displayMenuList",result);
	            component.set("v.Spinner",false);
	        }
	    });
	    $A.enqueueAction(action);    
	},
	
	getMenuContents : function(component, event, menuId) {
	    var action = component.get("c.getAllMenuContents");
	    action.setParams({
	        "recordId" : menuId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set('v.displayMenuContentList', result);
	        }
	    });
	    $A.enqueueAction(action);
	}, 
	

	highlightSelectedRow : function(component, event, helper) {
	    var selectedHomePage = component.get("v.isHomePage");
	    var selectedUsers = component.get("v.isUsers");
	    var selectedAccounts = component.get("v.isAccounts");
	    var selectedProducts = component.get("v.isProducts");
	    var selectedPageLayouts = component.get("v.isPageLayouts");
	    
	    var cmpTargetHomePage = component.find('homeId');
	    var cmpTargetUsers = component.find('usersId');
	    var cmpTargetAccounts = component.find('accountsId');
	    var cmpTargetProducts = component.find('productsId');
	    var cmpTargetPageLayouts = component.find('pageLayoutsId');
	    
	    var cmpTargetHome = component.find('homePageId');
	    var cmpTargetUser = component.find('userId');
	    var cmpTargetAccount = component.find('accountId');
	    var cmpTargetProduct = component.find('productId');
	    var cmpTargetPageLayout = component.find('pageLayoutId');
	    
	    if(selectedHomePage == true){
	        $A.util.addClass(cmpTargetHomePage, 'selected'); 
	        $A.util.addClass(cmpTargetHome, 'selected'); 
	    }else{
	        $A.util.removeClass(cmpTargetHomePage, 'selected');
	        $A.util.removeClass(cmpTargetHome, 'selected');
	    } 
	    if(selectedUsers == true){
	        $A.util.addClass(cmpTargetUsers, 'selected'); 
	        $A.util.addClass(cmpTargetUser, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetUsers, 'selected');
	        $A.util.removeClass(cmpTargetUser, 'selected');
	    }
	    if(selectedAccounts == true){
	        $A.util.addClass(cmpTargetAccounts, 'selected'); 
	        $A.util.addClass(cmpTargetAccount, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetAccounts, 'selected');
	        $A.util.removeClass(cmpTargetAccount, 'selected');
	    }
	    if(selectedProducts == true){
	        $A.util.addClass(cmpTargetProducts, 'selected'); 
	        $A.util.addClass(cmpTargetProduct, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetProducts, 'selected');
	        $A.util.removeClass(cmpTargetProduct, 'selected');
	    }
	    if(selectedPageLayouts == true){
	        $A.util.addClass(cmpTargetPageLayouts, 'selected'); 
	        $A.util.addClass(cmpTargetPageLayout, 'selected');
	    }else{
	        $A.util.removeClass(cmpTargetPageLayouts, 'selected');
	        $A.util.removeClass(cmpTargetPageLayout, 'selected');
	    }
	}
})