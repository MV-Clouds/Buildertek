trigger ContentDocumentLink on ContentDocumentLink(after insert, after update, before delete, before insert, before update ){
if (!BT_Utils.isTriggerDeactivate('ContentDocumentLink') && !ContentDocumentLinkHandler.skiptrigger){
		ContentDocumentLinkHandler handler = new ContentDocumentLinkHandler(Trigger.isExecuting, Trigger.size);
		if (Trigger.isInsert){
			if (ContentDocumentLinkHandler.skiptrigger){
				return;
			}
			if (Trigger.isBefore){
				handler.OnBeforeInsert(Trigger.new);
			} else if (Trigger.isAfter){
				handler.OnAfterInsert(Trigger.new, Trigger.newMap);
			}
		} else if (Trigger.isUpdate){
			if (ContentDocumentLinkHandler.skiptrigger){
				return;
			}
			if (Trigger.isBefore){
				handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
			} else if (Trigger.isAfter){
				handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
			}
		}
    	if (Trigger.isDelete && Trigger.isAfter){
			handler.OnAfterDelete(Trigger.old);
		}
	}
}