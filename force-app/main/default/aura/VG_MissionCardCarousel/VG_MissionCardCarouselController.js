({
    doInit: function(component, event, helper) {
			var numOfCards= component.get("v.numOfCards");
            var autoPlay = Boolean(component.get("v.autoplay"));
            var autoPlaySpeed = component.get("v.autoplaySpeed");
            
            var action = component.get("c.retrieveContent");
            action.setParams({"type":"Mission_Statement"});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var cardContent = JSON.parse(response.getReturnValue());
                component.set("v.cardContent",cardContent) ;
                component.set('v.setCallback', $A.getCallback(function(){
                    $('#cardCarousel').slick({dots:true,
                                              infinite: true,
                                              autoplay: true,
                                              autoplaySpeed: 3000,
                                              prevArrow: '',
                                              nextArrow: '',
                                              slidesToShow: 1,
                                              slidesToScroll: 1,
                                              responsive: [
                                                  {
                                                      breakpoint: 1200,
                                                      settings: {
                                                          slidesToShow: 1,
                                                          slidesToScroll: 1
                                                      }
                                                  },
                                                  {
                                                      breakpoint: 992,
                                                      settings: {
                                                          slidesToShow: 1,
                                                          slidesToScroll: 1
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
        
    }
})