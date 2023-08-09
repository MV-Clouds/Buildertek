({
     
    toastMsg : function( strType, strMessage ) {  
        var showToast = $A.get( "e.force:showToast" );   
        showToast.setParams({   
            //message : strMessage,  
            //type : strType,  
            //mode : 'sticky'  

            title : "Success!",
            message : strMessage,
            type: 'success',
            duration: '1000',
            key: 'info_alt',
            mode: 'pester'
        });   
        showToast.fire();
    },
    getfiles : function( component, event, helper) {  
        var fileslist = component.get("v.rfqstandardfiles");
        var btfileslist = component.get("v.rfqfiles");
        if(fileslist.length > 0){
            component.set("v.Isrfqfiles",true);
        }
        else if(btfileslist.length > 0){
            component.set("v.Isrfqfiles",true);
        }else{
            component.set("v.Isnorfqfiles",true);
        }
    },
    getvendorfiles : function( component, event, helper) {  
        var vendorfileslist = component.get("v.vendorstandardfiles");
        var files = component.get("v.files");
        if(vendorfileslist.length > 0){
            component.set("v.Isfiles",true);
        }
        else if(files.length > 0){
             component.set("v.Isfiles",true);
        }else{
            component.set("v.Isnofiles",true);
        }
    },
})