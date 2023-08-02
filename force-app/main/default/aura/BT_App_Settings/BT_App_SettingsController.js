({
	doInit : function(component, event, helper) {
		component.set("v.isHomePage", true);
	    var cmpTargetHomePage = component.find('homeId');
	    //var cmpTargetHome = component.find('homePageId');
	    $A.util.addClass(cmpTargetHomePage, 'selected');
	   // $A.util.addClass(cmpTargetHome, 'selected');
	    helper.showMenuList(component, event, helper);
	    helper.highlightSelectedRow(component, event, helper);
	    
	},
	
	showHomePage : function(component, event, helper) { 
	    component.set("v.isHomePage", true);
	    component.set("v.isUsers", false);
	    component.set("v.isAccounts", false);
	    component.set("v.isProducts", false);
	    component.set("v.isPageLayouts", false);
	    helper.highlightSelectedRow(component, event, helper);
	},
	
	showUsers : function(component, event, helper) {
	    component.set("v.isHomePage", false);
	    component.set("v.isUsers", true);
	    component.set("v.isAccounts", false);
	    component.set("v.isProducts", false);
	    component.set("v.isPageLayouts", false);
	    component.set("v.isAccountsEnabled", true);
	    var menuId = event.target.id;
	    helper.getMenuContents(component, event, menuId);
	    helper.highlightSelectedRow(component, event, helper);
	},
	
	showContents : function(component, event, helper) {
	    
	},
	
	showAccounts : function(component, event, helper) { 
	    component.set("v.isHomePage", false);
	    component.set("v.isUsers", false);
	    component.set("v.isAccounts", true);
	    component.set("v.isProducts", false);
	    component.set("v.isPageLayouts", false);
	    component.set("v.isProductsEnabled", true);
	    helper.highlightSelectedRow(component, event, helper);
	},
	
	showProducts : function(component, event, helper) {
	    component.set("v.isHomePage", false);
	    component.set("v.isUsers", false);
	    component.set("v.isAccounts", false);
	    component.set("v.isProducts", true);
	    component.set("v.isPageLayouts", false);
	    component.set("v.isPageLayoutsEnabled", true);
	    helper.highlightSelectedRow(component, event, helper);
	},
	
	showPageLayouts : function(component, event, helper) {
	    component.set("v.isHomePage", false);
	    component.set("v.isUsers", false);
	    component.set("v.isAccounts", false);
	    component.set("v.isProducts", false);
	    component.set("v.isPageLayouts", true);
	    helper.highlightSelectedRow(component, event, helper);
	},

})