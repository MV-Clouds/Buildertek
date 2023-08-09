({
    doInit: function(component, event, helper) {
        var numOfCards= component.get("v.numOfCards");
        var autoPlay = Boolean(component.get("v.autoplay"));
        var autoPlaySpeed = component.get("v.autoplaySpeed");
        
        var action = component.get("c.retrieveContent");
        action.setParams({type:"Announcement",
                          siteName:component.get("v.siteName"),
                          includePreview:component.get("v.includePreview")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var cardContent = JSON.parse(response.getReturnValue());
            component.set("v.cardContent",cardContent) ;
            component.set('v.setCallback', $A.getCallback(function(){
                
                $('#cardCarouselDepartment1').slick({dots:false,
                                           infinite: true,
                                           autoplay: autoPlay,
                                           autoplaySpeed: autoPlaySpeed,
                                           arrows: true,
                                           pauseOnFocus: false,
                                           pauseOnHover: false,
                                           prevArrow:'<button type="button"  class="slick-prev"></button>',
                                           nextArrow:'<button type="button"   class="slick-next"></button>',
                                           //prevArrow: '<div class="prevBtn"><svg class="slds-button__icon slds-button__icon--large" focusable="false" data-key="chevronleft" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/' + baseUrlResponse +'/_slds/icons/v7.18.0/utility-sprite/svg/symbols.svg#chevronleft"></use></svg></div>',
                                           //nextArrow: '<div class="nextBtn"><svg class="slds-button__icon slds-button__icon--large" focusable="false" data-key="chevronright" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/' + baseUrlResponse +'/_slds/icons/v7.18.0/utility-sprite/svg/symbols.svg#chevronright"></use></svg></div>',
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