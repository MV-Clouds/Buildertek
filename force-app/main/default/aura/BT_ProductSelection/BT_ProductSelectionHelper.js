({
	checkIfPriceBookExists : function(component) {
		var opp = component.get("v._opportunity");
        var pricebook2Id = component.get("v._pricebook2Id");
        if(pricebook2Id){
            $A.util.removeClass(component.find("productSelection"),"slds-hide");
            $A.util.addClass(component.find("pricebookSelection"),"slds-hide");
            $A.util.addClass(component.find("backbutton"),"slds-hide");
            showPriceBookSelection = false;
            return showPriceBookSelection;
        } else {
        	$A.util.removeClass(component.find("backbutton"),"slds-hide");
        }
        
        if(opp){
        	pricebook2Id = opp.Pricebook2Id;
        } else {
        	component.set("v._opportunity", new Object());
        }
        
        var showPriceBookSelection = true;
        $A.util.addClass(component.find("pricebookSelection"),"slds-hide");
        $A.util.addClass(component.find("productSelection"),"slds-hide");
        
        if(!pricebook2Id){
            $A.util.removeClass(component.find("pricebookSelection"),"slds-hide")
            showPriceBookSelection = true;
        } else {
        	$A.util.removeClass(component.find("productSelection"),"slds-hide");
            $A.util.addClass(component.find("pricebookSelection"),"slds-hide");
            $A.util.removeClass(component.find("backbutton"),"slds-hide");
            showPriceBookSelection = false;
        }
        return showPriceBookSelection;
	},
    retrieveProductCandidates: function(component){
        var orderBy = component.get("v.orderString");
        //alert('orderString --------> '+orderBy);
    	var pricebook2Id = component.get("v._pricebook2Id");
    	if(!pricebook2Id) {
    		pricebook2Id = component.get("v._opportunity").Pricebook2Id;
        }
        var getProductCandidate = component.get("c.getProductCandidate");
        getProductCandidate.setParams({
            "pricebook2Id":pricebook2Id,
            "orderedBy":orderBy
        });
        
        getProductCandidate.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.productCandidates", response.getReturnValue());   
            }else{
                console.log("Failed with state: "+ state);
            }
        });
        
        $A.enqueueAction(getProductCandidate);
	},
    
    retrieveProductCandidatesByPFamily: function(component){
        component.set("v.isSpinner",true);
        var orderBy = component.get("v.orderString");
        var selectedProductFamily = component.get("v.selectedProductFamily");
        //alert('orderString --------> '+orderBy);
    	var pricebook2Id = component.get("v._pricebook2Id");
    	if(!pricebook2Id) {
    		pricebook2Id = component.get("v._opportunity").Pricebook2Id;
        }
        var getProductCandidate = component.get("c.getProductCandidateByPBFamily");
        getProductCandidate.setParams({
            "pricebook2Id":pricebook2Id,
            "orderedBy":orderBy,
            "PFamily" : selectedProductFamily
        });
        
        getProductCandidate.setCallback(this, function(response){
            component.set("v.isSpinner",false);
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.productCandidates", response.getReturnValue());   
            }else{
                console.log("Failed with state: "+ state);
            }
        });
        
        $A.enqueueAction(getProductCandidate);
	},
    search: function(component){
        var pricebook2Id = component.get("v._opportunity").Pricebook2Id;
		var filterInfo = component.get("v._filter");
        var orderBy = component.get("v.orderBy");
        filterInfo = filterInfo ? filterInfo : {};
        filterInfo.orderBy = orderBy;
        var applyFilter = component.get("c.applyFilterSearch");
        applyFilter.setParams({
            "pricebook2Id": pricebook2Id,
            "filterInfoStr": JSON.stringify (filterInfo)
        });
        
        applyFilter.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.productCandidates",response.getReturnValue());
                console.log(response.getReturnValue());   
            }else{
                console.log("Failed with state: "+ state);
            }
        });
        
        $A.enqueueAction(applyFilter);
	},
})