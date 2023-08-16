({
		// >>>>>>>>>>>>>> CHB - 78, 80 <<<<<<<<<<<<<<<<<<<
		Check_Create_User_Access: function(component, event, helper){
			var action1 = component.get("c.CheckUserAccess");
			action1.setParams({
				AccessType: 'Create'
			});
			action1.setCallback(this, function(response) {
				console.log('CheckUserHaveAcces >> ',response.getReturnValue());
				if(response.getReturnValue() == 'True'){
				   component.set("v.HaveCreateAccess", true);
				}
				else if(response.getReturnValue() == 'False'){
					component.set("v.HaveCreateAccess", false);
				}
			});
			$A.enqueueAction(action1);
		},

})