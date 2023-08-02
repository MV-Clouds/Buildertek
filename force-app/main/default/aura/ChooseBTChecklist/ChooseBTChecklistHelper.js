({
	helperMethod : function() {
		
	},
    
     refreshList : function(component, event) {
		
        var availableMenus=document.getElementById('available').childNodes; 
        var available=[];
        for(var i=0;i<availableMenus.length;i++){
            //available[i]=availableMenus[i].getAttribute('id');
        }
		
        var selectedIdsMenus=document.getElementById('Selected').childNodes; 
      
        var selectedIds=[];
        for(var i=0;i<selectedIdsMenus.length;i++){
            selectedIds[i]=selectedIdsMenus[i].getAttribute('id');
        }
		
        component.set("v.selectedIds",selectedIds);
	
	},
    showToast : function(component, event, helper) {
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'The record has been updated successfully',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
   /* console.log('Inside Show Toast');
        
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success",
        "message": "The record has been updated successfully."
    });
    toastEvent.fire();*/
    }
    
})