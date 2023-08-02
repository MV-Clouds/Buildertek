({
	doInit: function(component, event, helper) {
        //fire event to notify the Announcement component to handle JS load
        var appEvent = $A.get("e.c:SlickJSLoaded"); 
        appEvent.fire(); 
        
    	var numOfCards= component.get("v.numOfCards");
    	var autoPlay = Boolean(component.get("v.autoplay"));
    	var autoPlaySpeed = component.get("v.autoplaySpeed");

		var action = component.get("c.retrieveContent");
        action.setParams({type:"Sub_Announcements",
                          siteName:component.get("v.siteName"),
                              includePreview:component.get("v.includePreview")});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var subAnnouncements = JSON.parse(response.getReturnValue());
            console.log('subAnnouncements @@'+subAnnouncements);
		    component.set("v.subAnnouncements",subAnnouncements) ;
			// alert(subAnnouncements);
            component.set('v.setCallback', $A.getCallback(function(){
                $('#cardCarousel10').slick({dots:true,
					 infinite: true,
					 autoplay: autoPlay,
					 autoplaySpeed: autoPlaySpeed,
                                            prevArrow:'<button type="button"  class="slick-prev"></button>',
  					nextArrow:'<button type="button"   class="slick-next"></button>',
					slidesToShow: numOfCards,
                    pauseOnFocus: false,
                    pauseOnHover: false,
                    slidesToScroll: 3,
					responsive: [
                            {
                              breakpoint: 1200,
                              settings: {
                                slidesToShow: numOfCards,
                                slidesToScroll: 3
                              }
                            },
                            {
                              breakpoint: 992,
                              settings: {
                                slidesToShow: 2,
                                slidesToScroll: 2
                              }
                            },
                            {
                              breakpoint: 500,
                              settings: {
                                slidesToShow: 1,
                                slidesToScroll: 1
                              }
                            }

                          ]
					 });
            }));
            window.setTimeout(component.get('v.setCallback'));

                 
        });
        $A.enqueueAction(action);  
        
	},
    navigateToAllAnnouncements : function(component, event, helper) {		
		var navEvt = $A.get("e.force:navigateToURL");
		navEvt.setParams({
			"url": "/all-announcements"
		});
		navEvt.fire();
	}
})