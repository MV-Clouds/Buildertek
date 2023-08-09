({
    
    doInit: function(component, event, helper) {
        var lookupDivElem1 =component.find("lookupDiv");
        //alert(lookupDivElem1);
        $A.util.addClass(lookupDivElem1,"slds-hide");
        $A.util.removeClass(lookupDivElem1,"slds-show");		
        document.onclick = function(e){            
            var selectedItem = event.currentTarget;
            var elem, evt = e ? e:event;
            if (evt.srcElement)  elem = evt.srcElement;
            else if (evt.target) elem = evt.target;            
            var lookupDivElem1 =document.getElementById("a_lookupDiv");
            //alert('in init'+lookupDivElem1);
            if(lookupDivElem1 && elem){
                if(!lookupDivElem1.contains(elem)){
                    $A.util.addClass(lookupDivElem1,"slds-hide");
                    $A.util.removeClass(lookupDivElem1,"slds-show");
                } 
            }
        }
    },
    
    searchKeyChange: function(component, event, helper) {    
        var searchStr = event.target.value;             
        if(searchStr.length > 2){
            helper.searchPeople(component,searchStr);
            helper.searchArticles(component,searchStr);           
            helper.searchAnnouncements(component,searchStr);
            helper.searchEvents(component,searchStr);
            var contentDiv = component.find("lookupDiv").getElement();           
            $A.util.addClass(contentDiv,"slds-show");
            $A.util.removeClass(contentDiv,"slds-hide");			
        }
    },
    
    showResults : function(component,event,helper){        
        var contentDiv = component.find("lookupDiv").getElement();		
        $A.util.toggleClass(contentDiv, "toggle");	   
    },
    
    navigate : function(component,event,helper){
        var idx = event.currentTarget.id;
        console.log(idx);        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx
        });
        navEvt.fire();
        
    },
    /* commented as it is not required after changing the code to work for right-click 
    ,

	
    navigateToAnnouncement : function(component,event,helper){
        var idx = event.currentTarget.id;
        console.log(idx);                
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
           "url": "/announcementsdetail?id="+idx
         });
		navEvt.fire();
        navEvt.setParams({
          "recordId": idx
        });
        navEvt.fire();
	}   	    
   */
})