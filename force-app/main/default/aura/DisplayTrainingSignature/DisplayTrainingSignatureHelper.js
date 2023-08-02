({
	 doChecklistHelper: function(component, event, helper) {
        //Site Url Get 
         function getCookie(cname) {
             var name = cname + "=";
             var ca = document.cookie.split(';');
             
             for(var i=0; i<ca.length; i++) {
                 var c = ca[i];
                 while (c.charAt(0)==' ') c = c.substring(1);
                 if (c.indexOf(name) == 0) {
                     return c.substring(name.length, c.length);
                 }
             }
             return "";
         }
         //clear Cookies function
         function unsetCookie(cname) {
             document.cookie = cname+ '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
         }
         
         var siteUrl=getCookie('siteUrl');  
         //alert(siteUrl);
         if(siteUrl !='' && siteUrl != undefined){
             component.set("v.siteUrl",siteUrl);
         }
         else{
             // alert(siteUrl);
             component.set("v.siteUrl",'/');
         }
         //clear cookie
         unsetCookie('siteUrl');
 		//alert(component.get("v.siteUrl"));
      	var action =component.get("c.getAttachmentData");
             action.setParams({
                 "recordId" : component.get("v.recordId")
            });
             action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     
                     component.set("v.imgUrl",component.get("v.siteUrl")+"servlet/servlet.FileDownload?file="+result);
                  }
            });
            $A.enqueueAction(action); 
    },
})