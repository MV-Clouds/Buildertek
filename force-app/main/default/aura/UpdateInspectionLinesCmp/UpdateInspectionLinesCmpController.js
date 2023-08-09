({
    fetchInsp : function(component, event, helper) {
        helper.getPicklist(component,event,helper);
        
    },
    onSelectChange : function(component, event, helper) {
        
        console.log({event});
        var pickVal = event.getSource().get("v.value");
        console.log({pickVal});

        var my_ids = component.get("v.ids");
        var my_vals = component.get("v.vals");

        var picknames = [];

        var pickId = event.getSource().get("v.name");
        var my_map = component.get("v.inspMap");

        var map1 = new Map();
        var mylst = component.get("v.mylist");
        var custs = [];
        
        if(my_ids.includes(pickId) == false){
            
            my_ids.push(pickId);
            my_vals.push(pickVal);
            map1.set(pickId,pickVal);
            // for(var i=0;i<my_ids.length;i++){                
            //     my
            // }
            // for(var key in conts){
            //     custs.push({value:conts[key], key:key});
            // }
        }
        console.log({map1});
        console.log({my_ids});
        console.log({my_vals});
        console.log({pickId});
        console.log({mylst});
        console.log({my_map});

        var newMap= new Map();
        newMap.set(pickId,pickVal);

        console.log({newMap});

        component.set("v.inspMap",newMap);
        // var pickVal1 = event.getSource();
        // console.log({pickVal1});
    },
    saveEditModal : function(component, event, helper) {
        
    }
})