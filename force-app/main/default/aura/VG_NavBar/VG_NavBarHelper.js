({
    
    getPrefix : function(component){
        var action1 = component.get("c.getPrefix");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var a = response.getReturnValue();
                console.log('a'+a);   
                if(a!=null){
                    component.set("v.communityPrefix",'/'+a+'/s');
                }
                else{
                    component.set("v.communityPrefix",'/');
                }
            }
        });
        $A.enqueueAction(action1); 
    },
    
    getDepartmentNavigations: function(component) {
        var action1 = component.get("c.getDepartmentNavigations");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var nav = response.getReturnValue();
                if (nav) {
                    var allDepartments = [];
                    for(var k in nav) {
                        console.log('key'+k);
                        allDepartments.push(k);
                    }
                    component.set('v.AllDepartments',allDepartments);
                    console.log('all departments'+allDepartments);
                    component.set('v.AllDepartmentWithNav', nav);
                }
            }
        });
        $A.enqueueAction(action1);
    }
})