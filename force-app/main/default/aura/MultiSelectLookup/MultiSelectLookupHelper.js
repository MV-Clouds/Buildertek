
({
	searchRecordsHelper : function(component, event, helper, selectedRecords) {       
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.message', '');
        component.set('v.recordsList', []);
        var searchString = component.get('v.searchString');
    	var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : searchString,
            'values' : JSON.stringify(selectedRecords),
            'containerForExtraId1' : component.get('v.containerForExtraId1'),
            'containerForExtraId2' : component.get('v.containerForExtraId2')
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(selectedRecords) ) {
                        var selectedRcrds = component.get('v.selectedRecords') || [];
                        for(var i = 0; i < result.length; i++) {
                            if(selectedRcrds.includes(result[i].value))
                                result[i].isSelected = true;
                        }
                        component.set('v.recordsList', result);        
					} else {
                        component.set('v.selectedDataObj', result);
					}
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(selectedRecords) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	}
})
/*
 Code by CafeForce
 Website: http://www.cafeforce.com
 DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE
*/
