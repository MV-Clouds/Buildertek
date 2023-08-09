trigger PickListDestValueMapping on PicklistValueMapping__c (before Update) {
 	Set<Id> pickListMappingRecIds = new Set<Id>();
    Set<Id> fieldDefIds = new Set<Id>();
    Set<Id> destFieldDefIds = new Set<Id>();
    
    for(PicklistValueMapping__c pickListMappingRec : Trigger.New){
        pickListMappingRecIds.add(pickListMappingRec.Id);
    }
    
	Map<Id, PicklistValueMapping__c> pickListMappingRecList = new Map<Id, PicklistValueMapping__c>([SELECT Id, DestinationPicklistValue__c, SourcePicklistValue__r.FieldDef__c, DestinationPickListName__c from PicklistValueMapping__c WHERE ID =: pickListMappingRecIds]);
    
    for(PicklistValueMapping__c pickListMapRec :pickListMappingRecList.values()){
        fieldDefIds.add(pickListMapRec.SourcePicklistValue__r.FieldDef__c);
    }
    
    Map<Id, Id> destFieldIdsToSrcFieldIds = new Map<Id, Id>();
    List<FieldMapping__c> fieldMappingRecList = [SELECT ObjectMapping__c, SourceField__c, DestinationField__c from FieldMapping__c WHERE SourceField__c IN: fieldDefIds];
    for(FieldMapping__c filedMapRec : fieldMappingRecList){
        destFieldDefIds.add(filedMapRec.DestinationField__c);
        destFieldIdsToSrcFieldIds.put(filedMapRec.DestinationField__c, filedMapRec.SourceField__c);
    }
    
    List<FieldDef__c> fieldDefList = new List<FieldDef__c>([SELECT ID, Name, APIName__c, Object__c, SFFieldTypeID__c,(Select Id, FieldDef__c, PicklistValue__c from PicklistValueDefs__r) from FieldDef__c  where Id IN: destFieldDefIds]);
    Map<String, Id> pickListNameToIdMap = new Map<String, Id>();
    for(FieldDef__c fieldRec : fieldDefList ){
        for(PicklistValueDef__c eachPickListDef : fieldRec.PicklistValueDefs__r)
          pickListNameToIdMap.put( destFieldIdsToSrcFieldIds.get(fieldRec.Id)+'-'+eachPickListDef.PicklistValue__c, eachPickListDef.Id);
    }
    
    for(PicklistValueMapping__c pickListMappingRec : Trigger.new){
        if(pickListNameToIdMap.containsKey(pickListMappingRecList.get(pickListMappingRec.Id).SourcePicklistValue__r.FieldDef__c +'-'+pickListMappingRec.DestinationPickListName__c)){
            System.debug('Destination pick list Field :'+pickListNameToIdMap.get(pickListMappingRecList.get(pickListMappingRec.Id).SourcePicklistValue__r.FieldDef__c +'-'+pickListMappingRec.DestinationPickListName__c));
                pickListMappingRec.DestinationPicklistValue__c = pickListNameToIdMap.get(pickListMappingRecList.get(pickListMappingRec.Id).SourcePicklistValue__r.FieldDef__c +'-'+pickListMappingRec.DestinationPickListName__c);
            system.debug('Picklist value:  '+pickListMappingRec.DestinationPicklistValue__c);
        }
    }
  
}