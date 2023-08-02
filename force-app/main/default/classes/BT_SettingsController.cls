public with sharing class BT_SettingsController {
    @AuraEnabled
    public static List<MenuClass> getMenuLists(){
        List<buildertek__Menu__c> menuList = [SELECT Id, Name, (SELECT Id, buildertek__Heading__c, buildertek__Description__c from buildertek__Menu_Contents__r) 
                                                        from buildertek__Menu__c where buildertek__Active__c = true];  
        system.debug('menuList ---------> '+menuList);
        
        List<MenuClass> menuToDisplay = new List<MenuClass>();
        for(buildertek__Menu__c menu : menuList){
            menuToDisplay.add(new MenuClass(menu));        
        }
        system.debug('menuToDisplay ------------> '+menuToDisplay);
        return menuToDisplay;
    }
    
   @AuraEnabled
   public static List<MenuContentClass> getAllMenuContents(String recordId){
        List< buildertek__Menu_Content__c> menuContentList;
        if(Schema.sObjectType.buildertek__Menu_Content__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Menu_Content__c.fields.buildertek__URL__c.isAccessible()
            && Schema.sObjectType.buildertek__Menu_Content__c.fields.buildertek__Heading__c.isAccessible()
            && Schema.sObjectType.buildertek__Menu_Content__c.fields.buildertek__Description__c.isAccessible()){
            
            menuContentList = [SELECT Id, buildertek__URL__c, buildertek__Heading__c, buildertek__Description__c from buildertek__Menu_Content__c where Id =: recordId];    
        }
        system.debug('menuContent -----------> '+menuContentList);
        List<MenuContentClass> contentClass = new List<MenuContentClass>(); 
        for(buildertek__Menu_Content__c content : menuContentList){
            contentClass.add(new MenuContentClass(content));        
        }
        return contentClass;
   }
    
    public class MenuClass{
        @AuraEnabled public buildertek__Menu__c menu { get; set; }
        public MenuClass( buildertek__Menu__c menu){
            this.menu = menu; 
        }
    }
    
    public class MenuContentClass{
        @AuraEnabled public buildertek__Menu_Content__c menuContent { get; set; }
        
        public MenuContentClass(buildertek__Menu_Content__c menuContent){
            this.menuContent = menuContent;    
        }
    }
}