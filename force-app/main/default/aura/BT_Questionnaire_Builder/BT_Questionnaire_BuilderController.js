/* Lightning Component Controller.
 * Copyright 2018-2019, @ thoriyas.
 * All rights reserved
 *
 * Created by - Sagar Thoriya
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert */

({
	init : function(component, event, helper){
      
    },
	
	/*This function is used to navigate to back*/
	goback: function(component, event, helper){
		component.destroy();
      	window.history.back(); 
    },
    
    /* after script load handler */
    loadSections: function(component, event, helper){
        var adid = component.get("v.recordId");
	    $('#'+adid+'sections').nestable({ maxDepth:1,
    									  handleClass:'av-section-handle', 
    									  listClass:'av-list', 
    									  threshold:15}).on('change', function(e) {
             var list   = e.length ? e : $(e.target);
            helper.setSortIds(component, event, helper, list.nestable('serialize'));
           
        });
	   helper.defaultTreeFilterCondition(component);
    },
    
    save: function(component, event, helper){
    	
    }
    
})