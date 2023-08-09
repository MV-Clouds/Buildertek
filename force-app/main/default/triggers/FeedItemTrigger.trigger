trigger FeedItemTrigger on FeedItem (before insert, after insert) {
   
    if(Trigger.isInsert && Trigger.isAfter){
         		system.debug('entered Trigger');
                FeedItemTriggerHandler.updateFeedItems(trigger.new);
            
    }

}