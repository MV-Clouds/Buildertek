({    
    handleAllChange: function (component, event) {
        var currentTarget =event.getSource();
        var isEditInfo = currentTarget.get("v.value");
        console.log(isEditInfo);
        var lstRecords = component.get("v.listWrapper");
        
        for(var i=0; i< lstRecords.length>0; i++){
            if(isEditInfo){
                lstRecords[i].checked = true;
                component.set("v.selectedCount", lstRecords.length);
            }
            else{
                lstRecords[i].checked = false; 
                component.set("v.selectedCount",0);
            }            
        }
        component.set("v.listWrapper",lstRecords)
        
        
    }    ,
    handleChange: function (component, event) {
        
        var currentTarget =event.getSource();        
        var isEditInfo = currentTarget.get("v.value");        
        var lstRecords = component.get("v.listWrapper");
        var selectedCountInfo = component.get("v.selectedCount");
        for(var i=0; i< lstRecords.length>0; i++){            
            var indexInfo = currentTarget.get("v.text");
            if(indexInfo == i){
                if(isEditInfo){
                    selectedCountInfo += 1;
                    lstRecords[i].checked = true;
                }
                else{
                    selectedCountInfo -= 1;
                    lstRecords[i].checked = false;
                }
            }
        }
        
        if(selectedCountInfo>=0)
            component.set("v.selectedCount",selectedCountInfo);
        component.set("v.listWrapper",lstRecords)
        if(lstRecords.length != selectedCountInfo){
            component.set("v.isAll",false);
        }else{
            component.set("v.isAll",true);
        }
    }
})